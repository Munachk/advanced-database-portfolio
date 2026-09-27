-- ============================================================
-- PrimeTrust Bank HR Management System
-- Portfolio 2: Query Processing and Optimisation
-- Target engine: MySQL 8.0+
-- ============================================================

-- Q1. Simple SELECT with filter
-- All active employees, most recently hired first
SELECT employee_id, first_name, last_name, hire_date, status
FROM employee
WHERE status = 'active'
ORDER BY hire_date DESC;

-- Q2. Multi-table JOIN
-- Full employee roster with department, branch and grade names
SELECT e.employee_id,
       CONCAT(e.first_name, ' ', e.last_name) AS full_name,
       d.department_name,
       b.branch_name,
       g.grade_title
FROM employee e
JOIN department d ON e.department_id = d.department_id
JOIN branch b      ON e.branch_id     = b.branch_id
JOIN grade g       ON e.grade_id      = g.grade_id;

-- Q3. Aggregate: headcount per department
SELECT d.department_name, COUNT(*) AS headcount
FROM employee e
JOIN department d ON e.department_id = d.department_id
WHERE e.status = 'active'
GROUP BY d.department_name
ORDER BY headcount DESC;

-- Q4. Aggregate: headcount per branch per region
SELECT b.region, b.branch_name, COUNT(*) AS headcount
FROM employee e
JOIN branch b ON e.branch_id = b.branch_id
WHERE e.status = 'active'
GROUP BY b.region, b.branch_name
ORDER BY b.region, headcount DESC;

-- Q5. Average tenure (in years) per grade
-- MySQL note: EXTRACT(YEAR FROM AGE(...)) does not exist in MySQL.
-- TIMESTAMPDIFF is the direct equivalent.
SELECT g.grade_title,
       ROUND(AVG(TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE())), 1) AS avg_tenure_years
FROM employee e
JOIN grade g ON e.grade_id = g.grade_id
WHERE e.status = 'active'
GROUP BY g.grade_title
ORDER BY avg_tenure_years DESC;

-- Q6. Correlated subquery
-- Employees who have been promoted more than once
SELECT e.employee_id, e.first_name, e.last_name
FROM employee e
WHERE (
    SELECT COUNT(*)
    FROM employment_history h
    WHERE h.employee_id = e.employee_id
      AND h.event_type = 'promotion'
) > 1;

-- Q6b. Same result, rewritten without a correlated subquery
-- (cheaper at scale -- see performance-analysis.md)
SELECT e.employee_id, e.first_name, e.last_name
FROM employee e
JOIN (
    SELECT employee_id
    FROM employment_history
    WHERE event_type = 'promotion'
    GROUP BY employee_id
    HAVING COUNT(*) > 1
) promoted ON e.employee_id = promoted.employee_id;

-- Q7. Non-correlated subquery
-- Departments with more staff than the bank-wide average department size
SELECT department_name, headcount FROM (
    SELECT d.department_name, COUNT(*) AS headcount
    FROM employee e
    JOIN department d ON e.department_id = d.department_id
    WHERE e.status = 'active'
    GROUP BY d.department_name
) AS dept_counts
WHERE headcount > (
    SELECT AVG(cnt) FROM (
        SELECT COUNT(*) AS cnt
        FROM employee e
        WHERE e.status = 'active'
        GROUP BY e.department_id
    ) AS avg_calc
);

-- Q8. Window function: rank employees by tenure within their own department
-- (MySQL 8.0+ only -- window functions did not exist before 8.0)
SELECT e.first_name, e.last_name, d.department_name, e.hire_date,
       RANK() OVER (
           PARTITION BY e.department_id
           ORDER BY e.hire_date ASC
       ) AS seniority_rank_in_dept
FROM employee e
JOIN department d ON e.department_id = d.department_id
WHERE e.status = 'active';

-- Q9. Window function: running headcount growth by hire year
SELECT hire_year,
       new_hires,
       SUM(new_hires) OVER (ORDER BY hire_year) AS running_total_headcount
FROM (
    SELECT YEAR(hire_date) AS hire_year, COUNT(*) AS new_hires
    FROM employee
    GROUP BY YEAR(hire_date)
) AS yearly
ORDER BY hire_year;

-- Q10. Full audit trail for one employee (event sourcing style read)
SELECT h.event_date, h.event_type, h.old_value, h.new_value, h.processed_by
FROM employment_history h
WHERE h.employee_id = 1
ORDER BY h.event_date;
