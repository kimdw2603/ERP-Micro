USE `ERP-Micro`;

DELIMITER //

DROP PROCEDURE IF EXISTS TransferEmployee//
CREATE PROCEDURE TransferEmployee(
    IN p_employee_ID VARCHAR(7),
    IN p_new_dept_ID VARCHAR(7),
    IN p_new_position VARCHAR(20),
    IN p_start_date DATE
)
BEGIN
    DECLARE v_old_dept VARCHAR(7);
    
    IF NOT EXISTS (SELECT 1 FROM employee WHERE employee_ID = p_employee_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee not found';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM departments WHERE dept_ID = p_new_dept_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Department not found';
    END IF;


    SELECT current_dept INTO v_old_dept
        FROM employee
        WHERE employee_ID = p_employee_ID;

    START TRANSACTION;
        -- Update end_date of current position
        UPDATE position_history 
            SET end_date = DATE_SUB(p_start_date, INTERVAL 1 DAY)
            WHERE employee_ID = p_employee_ID AND dept_ID = v_old_dept AND end_date IS NULL;
        
        -- Update current department in employee
        UPDATE employee 
            SET current_dept = p_new_dept_ID,
                current_position = p_new_position
            WHERE employee_ID = p_employee_ID;
        
        -- Insert new position history
        INSERT INTO position_history (
            pos_history_ID,
            employee_ID,
            dept_ID,
            position,
            start_date
        ) VALUES (
            CONCAT('PO', LPAD(FLOOR(RAND() * 100000), 5, '0')),
            p_employee_ID,
            p_new_dept_ID,
            p_new_position,
            p_start_date
        );
    COMMIT;
END //


DROP PROCEDURE IF EXISTS CreateProject//
CREATE PROCEDURE CreateProject(
    IN p_project_name VARCHAR(20),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_dept_IDs TEXT -- comma-separated department IDs
)
BEGIN
    DECLARE v_project_ID VARCHAR(7);
    DECLARE v_dept_IDs VARCHAR(7);
    DECLARE v_pos INT DEFAULT 1;
    DECLARE v_length INT;
    
    SET v_project_ID = CONCAT('PRJ', LPAD(FLOOR(RAND() * 10000), 4, '0'));

    START TRANSACTION;
        -- Create project
        INSERT INTO project (
            project_ID,
            project_name,
            start_date,
            end_date
        ) VALUES (
            v_project_ID,
            p_project_name,
            p_start_date,
            p_end_date
        );

        -- Insert participation records
        INSERT INTO participation (dept_ID, project_ID)
        WITH RECURSIVE split_strings AS (
            SELECT 
                TRIM(SUBSTRING_INDEX(p_dept_IDs, ',', 1)) AS dept_ID,
                SUBSTRING(p_dept_IDs, LENGTH(SUBSTRING_INDEX(p_dept_IDs, ',', 1)) + 2) AS remainder
            UNION ALL
            SELECT 
                TRIM(SUBSTRING_INDEX(remainder, ',', 1)),
                SUBSTRING(remainder, LENGTH(SUBSTRING_INDEX(remainder, ',', 1)) + 2)
            FROM split_strings 
            WHERE remainder != ''
        )
        SELECT dept_ID, v_project_ID FROM split_strings AS s;
    COMMIT;
END //


DROP PROCEDURE IF EXISTS ApproveJournal//
CREATE PROCEDURE ApproveJournal(
    IN p_journal_ID VARCHAR(7),
    IN p_approver_ID VARCHAR(7)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM journal WHERE journal_ID = p_journal_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Journal not found';
    END IF;
    IF EXISTS (SELECT 1 FROM journal WHERE journal_ID = p_journal_ID AND total_debit != total_credit) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debit and credit must be equal';
    END IF;
    IF EXISTS (SELECT 1 FROM approval WHERE journal_ID = p_journal_ID AND approver_ID = p_approver_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Journal already approved by this approver';
    END IF;

    START TRANSACTION;
        -- Update journal status
        UPDATE journal
            SET is_approved = 1
            WHERE journal_ID = p_journal_ID;
        
        -- Create approval record
        INSERT INTO approval (
            approval_ID,
            journal_ID,
            status,
            approver_ID,
            approved_date
        ) VALUES (
            CONCAT('APR', LPAD(FLOOR(RAND() * 10000), 4, '0')),
            p_journal_ID,
            'Approved',
            p_approver_ID,
            CURRENT_DATE
        );
    COMMIT;
END //

DELIMITER ;