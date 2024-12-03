USE `ERP-Micro`;

DELIMITER //

DROP TRIGGER IF EXISTS before_account_delete//
CREATE TRIGGER before_account_delete
BEFORE DELETE ON account
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM transaction WHERE account_code = OLD.account_code) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete account with existing transactions';
    END IF;
    
    IF OLD.is_active = 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete active account';
    END IF;
END //

-- DROP TRIGGER IF EXISTS before_transaction_insert//
-- CREATE TRIGGER before_transaction_insert
-- BEFORE INSERT ON transaction
-- FOR EACH ROW
-- BEGIN
--     DECLARE balance_check DECIMAL(15,2);
--     SET balance_check = NEW.debit - NEW.credit;
--     
--     -- Update journal totals
--     UPDATE journal 
--     SET total_debit = total_debit + NEW.debit,
--         total_credit = total_credit + NEW.credit
--     WHERE journal_ID = NEW.journal_ID;
--     
--     -- Validate balance
--     IF balance_check != 0 THEN
--         SIGNAL SQLSTATE '45000'
--         SET MESSAGE_TEXT = 'Invalid transaction: Debit and Credit must be equal';
--     END IF;
-- END //

DROP TRIGGER IF EXISTS before_order_insert//
CREATE TRIGGER before_order_insert
BEFORE INSERT ON `order`
FOR EACH ROW
BEGIN
    DECLARE v_journal_id VARCHAR(7);
    
    SET v_journal_id = CONCAT('J', LPAD(FLOOR(RAND() * 100000), 5, '0'));
    
    -- Create journal entry
    INSERT INTO journal (
        journal_ID,
        total_debit,
        total_credit,
        dept_ID,
        is_approved
    ) VALUES (
        v_journal_id,
        NEW.order_price,
        NEW.order_price,
        'DE00004', -- 영업부
        0
    );

    -- -- Create debit transaction
    -- SET v_transaction_id = CONCAT('TR', LPAD(FLOOR(RAND() * 100000), 5, '0'));
    -- INSERT INTO transaction (
    --     trans_ID,
    --     journal_ID,
    --     account_code,
    --     trans_date,
    --     debit,
    --     credit
    -- ) VALUES (
    --     v_transaction_id,
    --     v_journal_id,
    --     'AC00001', -- 매출채권
    --     NEW.order_date,
    --     NEW.order_price,
    --     0
    -- );
    
    -- -- Create credit transaction
    -- SET v_transaction_id = CONCAT('TR', LPAD(FLOOR(RAND() * 100000), 5, '0'));
    -- INSERT INTO transaction (
    --     trans_ID,
    --     journal_ID,
    --     account_code,
    --     trans_date,
    --     debit,
    --     credit
    -- ) VALUES (
    --     v_transaction_id,
    --     v_journal_id,
    --     'AC00002', -- 매출
    --     NEW.order_date,
    --     0,
    --     NEW.order_price
    -- );
    
    -- Set journal_id in order
    SET NEW.journal_id = v_journal_id;
END //

DROP TRIGGER IF EXISTS before_supply_insert//
CREATE TRIGGER before_supply_insert
BEFORE INSERT ON supply
FOR EACH ROW
BEGIN
    DECLARE v_journal_id VARCHAR(7);
    DECLARE v_transaction_id VARCHAR(7);
    DECLARE v_cost DECIMAL(10,2);
    
    SET v_journal_id = CONCAT('J', LPAD(FLOOR(RAND() * 100000), 5, '0'));
    SET v_cost = NEW.cost;
    
    -- Create journal entry
    INSERT INTO journal (
        journal_ID,
        total_debit,
        total_credit,
        dept_ID,
        is_approved
    ) VALUES (
        v_journal_id,
        v_cost,
        v_cost,
        'DE00005', -- 구매부
        0
    );
    
    -- -- Create debit transaction
    -- SET v_transaction_id = CONCAT('TR', LPAD(FLOOR(RAND() * 100000), 5, '0'));
    -- INSERT INTO transaction (
    --     trans_ID,
    --     journal_ID,
    --     account_code,
    --     trans_date,
    --     debit,
    --     credit
    -- ) VALUES (
    --     v_transaction_id,
    --     v_journal_id,
    --     'AC00003', -- 재고자산
    --     CURRENT_DATE,
    --     v_cost,
    --     0
    -- );
    
    -- -- Create credit transaction
    -- SET v_transaction_id = CONCAT('TR', LPAD(FLOOR(RAND() * 100000), 5, '0'));
    -- INSERT INTO transaction (
    --     trans_ID,
    --     journal_ID,
    --     account_code,
    --     trans_date,
    --     debit,
    --     credit
    -- ) VALUES (
    --     v_transaction_id,
    --     v_journal_id,
    --     'AC00004', -- 매입채권
    --     CURRENT_DATE,
    --     0,
    --     v_cost
    -- );
    
    -- Set journal_id in supply
    SET NEW.journal_id = v_journal_id;
END//

DROP TRIGGER IF EXISTS before_production_insert//
CREATE TRIGGER before_production_insert
BEFORE INSERT ON production
FOR EACH ROW
BEGIN
    DECLARE v_journal_id VARCHAR(7);
    DECLARE v_transaction_id VARCHAR(7);
    -- DECLARE v_material_cost DECIMAL(10,2);
    DECLARE v_cost DECIMAL(10,2);
    
    SET v_journal_id = CONCAT('J', LPAD(FLOOR(RAND() * 100000), 5, '0'));
    SET v_cost = NEW.cost;
    
    -- Create journal entry
    INSERT INTO journal (
        journal_ID,
        total_debit,
        total_credit,
        dept_ID,
        is_approved
    ) VALUES (
        v_journal_id,
        v_cost,
        v_cost,
        'DE00006', -- 생산부
        0
    );
    
    -- -- Create debit transaction
    -- SET v_transaction_id = CONCAT('TR', LPAD(FLOOR(RAND() * 100000), 5, '0'));
    -- INSERT INTO transaction (
    --     trans_ID,
    --     journal_ID,
    --     account_code,
    --     trans_date,
    --     debit,
    --     credit
    -- ) VALUES (
    --     v_transaction_id,
    --     v_journal_id,
    --     'AC00005', -- 재고자산
    --     NEW.production_date,
    --     v_cost,
    --     0
    -- );
    
    -- -- Create credit transaction
    -- SET v_transaction_id = CONCAT('TR', LPAD(FLOOR(RAND() * 100000), 5, '0'));
    -- INSERT INTO transaction (
    --     trans_ID,
    --     journal_ID,
    --     account_code,
    --     trans_date,
    --     debit,
    --     credit
    -- ) VALUES (
    --     v_transaction_id,
    --     v_journal_id,
    --     'AC00006', -- 생산 비용
    --     NEW.production_date,
    --     0,
    --     v_cost
    -- );
    
    -- Set journal_id in production
    SET NEW.journal_id = v_journal_id;
END//

DELIMITER ;