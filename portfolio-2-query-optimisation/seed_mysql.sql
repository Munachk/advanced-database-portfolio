-- ============================================================
-- Portfolio 2: MySQL seed data for generating real evidence
-- Run this AFTER schema_mysql.sql, using the MySQL CLI or phpMyAdmin.
--
--   mysql -u root -p primetrust_hr < schema_mysql.sql
--   mysql -u root -p primetrust_hr < seed_mysql.sql
--
-- Then capture your own EXPLAIN evidence (see commands at the bottom).
-- ============================================================

INSERT INTO branch (branch_name, region) VALUES
('Victoria Island', 'Lagos'),
('Ikeja', 'Lagos'),
('Wuse', 'Abuja'),
('GRA', 'Port Harcourt');

INSERT INTO grade (grade_title, salary_band) VALUES
('Officer', 'B1'),
('Senior Officer', 'B2'),
('Manager', 'B3'),
('Senior Manager', 'B4'),
('Department Head', 'B5');

INSERT INTO department (department_name) VALUES
('Retail Banking'), ('IT'), ('Compliance'), ('Treasury'), ('Customer Service');

-- A representative slice of employees (expand with a PHP/Python loop if you
-- want 100+ rows for a more convincing before/after index comparison)
INSERT INTO employee (first_name, last_name, date_of_birth, hire_date, grade_id, department_id, branch_id, status) VALUES
('Chidi', 'Okafor', '1988-03-14', '2016-02-01', 3, 1, 1, 'active'),
('Ngozi', 'Bello', '1990-07-22', '2017-05-10', 2, 2, 2, 'active'),
('Ibrahim', 'Musa', '1985-11-02', '2015-01-30', 4, 1, 1, 'active'),
('Amaka', 'Eze', '1992-01-19', '2019-09-15', 1, 5, 3, 'active'),
('Tunde', 'Adeyemi', '1983-06-30', '2014-03-01', 5, 1, 1, 'active'),
('Fatima', 'Yakubu', '1995-04-11', '2021-06-01', 1, 3, 4, 'active'),
('Kelechi', 'Nwosu', '1989-09-09', '2018-01-20', 2, 4, 2, 'resigned'),
('Bisi', 'Balogun', '1991-12-25', '2020-04-14', 2, 2, 3, 'active'),
('Emeka', 'Okon', '1987-02-17', '2016-11-11', 3, 3, 1, 'active'),
('Zainab', 'Abubakar', '1993-08-08', '2019-02-02', 1, 4, 4, 'active');

INSERT INTO employment_history (employee_id, event_type, old_value, new_value, event_date, processed_by) VALUES
(2, 'promotion', 'Officer', 'Senior Officer', '2019-06-01', 'HR-Admin1'),
(2, 'promotion', 'Senior Officer', 'Manager', '2022-06-01', 'HR-Admin1'),
(9, 'promotion', 'Officer', 'Senior Officer', '2018-06-01', 'HR-Admin2'),
(9, 'promotion', 'Senior Officer', 'Manager', '2021-01-15', 'HR-Admin2'),
(7, 'resignation', 'active', 'resigned', '2023-03-01', 'HR-Admin1');


