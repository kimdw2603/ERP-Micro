-- Test TransferEmployee procedure
CALL TransferEmployee('EM00052', 'DE00702', '팀원', '2025-01-01');

SELECT * FROM employee WHERE employee_ID = 'EM00052';
SELECT * FROM position_history WHERE employee_ID = 'EM00052' ORDER BY start_date DESC;


-- Test CreateProject procedure
CALL CreateProject('Test Project', '2024-01-01', '2024-12-31', 'DE00001,DE00002,DE00003');

SELECT p.project_name, GROUP_CONCAT(d.dept_name) as departments
FROM project p
JOIN participation pt ON p.project_ID = pt.project_ID
JOIN departments d ON pt.dept_ID = d.dept_ID
WHERE p.project_name = 'Test Project'
GROUP BY p.project_name;


-- Test ApproveJournal procedure
CALL ApproveJournal('J10291', 'EM00010');

SELECT * FROM journal WHERE journal_ID = 'J10291';
SELECT * FROM approval WHERE journal_ID = 'J10291';