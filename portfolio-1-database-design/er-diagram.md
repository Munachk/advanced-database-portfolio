# ER Diagram — PrimeTrust Bank HR Management System

This renders automatically when viewed on GitHub (Mermaid support is native
in GitHub's Markdown renderer — no extra tool needed). If your lecturer wants
an image file too, paste this block into the Mermaid Live Editor
(https://mermaid.live) and export as PNG/SVG into this folder as `er-diagram.png`.

```mermaid
erDiagram
    BRANCH ||--o{ EMPLOYEE : "employs"
    GRADE  ||--o{ EMPLOYEE : "assigned to"
    DEPARTMENT ||--o{ EMPLOYEE : "belongs to"
    EMPLOYEE ||--o{ EMPLOYMENT_HISTORY : "has"
    EMPLOYEE ||--o| DEPARTMENT : "heads (optional)"

    BRANCH {
        int branch_id PK
        string branch_name
        string region
    }

    GRADE {
        int grade_id PK
        string grade_title
        string salary_band
    }

    DEPARTMENT {
        int department_id PK
        string department_name
        int department_head_id FK
    }

    EMPLOYEE {
        int employee_id PK
        string first_name
        string last_name
        date date_of_birth
        date hire_date
        int grade_id FK
        int department_id FK
        int branch_id FK
        string status
    }

    EMPLOYMENT_HISTORY {
        int history_id PK
        int employee_id FK
        string event_type
        string old_value
        string new_value
        date event_date
        string processed_by
    }

    AUDIT_LOG {
        int log_id PK
        string table_affected
        int record_id
        string action
        string performed_by
        timestamp performed_at
    }
```

## Notes on relationships

- **Branch → Employee** (1:M): each branch employs many staff; each employee
  belongs to exactly one branch.
- **Grade → Employee** (1:M): each grade is held by many employees.
- **Department → Employee** (1:M): standard reporting-line membership.
- **Employee → Department** (1:1, optional, circular reference): a department
  is *headed by* one employee. This is the one deliberately circular FK in the
  schema — `department.department_head_id` points to `employee`, while
  `employee.department_id` points back to `department`. Handled in
  `schema.sql` by creating `department` first without the FK, then adding it
  with `ALTER TABLE` once `employee` exists. `audit_log` is intentionally
  **not** linked by a formal FK to every table (it stores `table_affected` +
  `record_id` instead) — this is a common trade-off for a generic, reusable
  audit trail, and worth a sentence in your reflection.
