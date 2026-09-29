-- ============================================================
-- Run this in phpMyAdmin's SQL tab between concurrency demo runs
-- to reset employee_id=2 back to a known grade_id before testing
-- demo3 or demo4 again.
-- ============================================================
UPDATE employee SET grade_id = 2 WHERE employee_id = 2;  -- back to 'Senior Officer'

-- Optional: also clear out any history rows the demos added, if you
-- want a totally clean slate for your screenshots
-- DELETE FROM employment_history WHERE employee_id = 2 AND processed_by LIKE 'HR-Admin (PHP demo)%';
