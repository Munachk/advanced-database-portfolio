-- ============================================================
-- PrimeTrust Bank HR Management System
-- Portfolio 1: Database Design and Modelling
-- Target engine: MySQL 8.0+
-- ============================================================
-- Run: SELECT VERSION();  first, to confirm you're on 8.0.16+
-- (needed for CHECK constraints to actually be enforced, not
-- just silently parsed and ignored).
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS employment_history;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS branch;
DROP TABLE IF EXISTS grade;
SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------
-- BRANCH
-- ------------------------------------------------------------
CREATE TABLE branch (
    branch_id      INT AUTO_INCREMENT PRIMARY KEY,
    branch_name    VARCHAR(100) NOT NULL UNIQUE,
    region         VARCHAR(50)  NOT NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- GRADE  (job grade / salary band lookup)
-- ------------------------------------------------------------
CREATE TABLE grade (
    grade_id       INT AUTO_INCREMENT PRIMARY KEY,
    grade_title    VARCHAR(50) NOT NULL UNIQUE,   -- e.g. 'Officer', 'Senior Manager'
    salary_band    VARCHAR(20) NOT NULL           -- e.g. 'B1', 'B2'
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- DEPARTMENT
-- department_head_id references employee, and employee references
-- department -> a genuine circular FK. We create department first
-- WITHOUT the FK, create employee, then ALTER TABLE to add it.
-- InnoDB is required (not MyISAM) because MyISAM does not support
-- foreign keys at all.
-- ------------------------------------------------------------
CREATE TABLE department (
    department_id      INT AUTO_INCREMENT PRIMARY KEY,
    department_name    VARCHAR(100) NOT NULL UNIQUE,
    department_head_id INT NULL   -- FK added later via ALTER TABLE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- EMPLOYEE
-- ------------------------------------------------------------
CREATE TABLE employee (
    employee_id     INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(60) NOT NULL,
    last_name       VARCHAR(60) NOT NULL,
    date_of_birth   DATE NOT NULL,
    hire_date       DATE NOT NULL,
    grade_id        INT NOT NULL,
    department_id   INT NOT NULL,
    branch_id       INT NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT chk_status CHECK (status IN ('active', 'resigned', 'suspended', 'retired')),
    CONSTRAINT chk_dob_plausible CHECK (date_of_birth < hire_date),
    CONSTRAINT fk_employee_grade      FOREIGN KEY (grade_id)      REFERENCES grade(grade_id),
    CONSTRAINT fk_employee_department FOREIGN KEY (department_id) REFERENCES department(department_id),
    CONSTRAINT fk_employee_branch     FOREIGN KEY (branch_id)     REFERENCES branch(branch_id)
) ENGINE=InnoDB;

-- Now that employee exists, wire up the circular FK on department
ALTER TABLE department
    ADD CONSTRAINT fk_department_head
    FOREIGN KEY (department_head_id) REFERENCES employee(employee_id);

-- ------------------------------------------------------------
-- EMPLOYMENT_HISTORY
-- One row per HR event: onboarding, promotion, transfer, resignation
-- ------------------------------------------------------------
CREATE TABLE employment_history (
    history_id      INT AUTO_INCREMENT PRIMARY KEY,
    employee_id     INT NOT NULL,
    event_type      VARCHAR(20) NOT NULL,
    old_value       VARCHAR(100),      -- e.g. previous grade_title or department_name
    new_value       VARCHAR(100),
    event_date      DATE NOT NULL DEFAULT (CURRENT_DATE),
    processed_by    VARCHAR(60) NOT NULL,   -- HR officer name/id
    CONSTRAINT chk_event_type CHECK (event_type IN ('onboarding', 'promotion', 'transfer', 'resignation', 'suspension')),
    CONSTRAINT fk_history_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- AUDIT_LOG
-- System-level trail, independent of the business event log above
-- ------------------------------------------------------------
CREATE TABLE audit_log (
    log_id          INT AUTO_INCREMENT PRIMARY KEY,
    table_affected  VARCHAR(50) NOT NULL,
    record_id       INT NOT NULL,
    action          VARCHAR(20) NOT NULL,
    performed_by    VARCHAR(60) NOT NULL,
    performed_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_action CHECK (action IN ('INSERT', 'UPDATE', 'DELETE'))
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Helpful indexes (justified further in Portfolio 2)
-- ------------------------------------------------------------
CREATE INDEX idx_employee_department ON employee(department_id);
CREATE INDEX idx_employee_branch     ON employee(branch_id);
CREATE INDEX idx_employee_status     ON employee(status);
CREATE INDEX idx_history_employee    ON employment_history(employee_id);

-- ------------------------------------------------------------
-- MySQL-specific notes for your documentation:
-- 1. `DEFAULT (CURRENT_DATE)` requires MySQL 8.0.13+ for non-TIMESTAMP
--    columns. If your version is older, drop the DEFAULT and set
--    event_date explicitly in every INSERT instead.
-- 2. CHECK constraints are parsed (no error) but silently NOT enforced
--    on MySQL versions before 8.0.16. Run `SELECT VERSION();` and note
--    the result.
--    
-- 3. ENGINE=InnoDB is required for foreign keys and for the row-level
--    locking you'll rely on in Portfolio 3 (transactions/concurrency).
--    The default engine in modern MySQL is already InnoDB.
--  
-- ------------------------------------------------------------
