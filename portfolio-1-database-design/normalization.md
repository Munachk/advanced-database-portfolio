# Normalization Walkthrough — PrimeTrust Bank HR

## Starting point: a single flat "employee master" spreadsheet

This is the kind of table many teams start with (and the one I originally
considered before expanding the design):

| emp_id | emp_name | dob | department | dept_head | branch | branch_region | grade | salary_band |
|--------|----------|-----|------------|-----------|--------|----------------|-------|-------------|

Problems with this as a single table:

- **Insertion anomaly**: you can't record a new department until it has at
  least one employee, since department info only exists as columns on the
  employee row.
- **Update anomaly**: if a department head changes, you must update it on
  *every row* of every employee in that department — miss one and the data
  is inconsistent.
- **Deletion anomaly**: if the last employee in a branch resigns and is
  removed, the branch's region information disappears with them.

## Step 1 — First Normal Form (1NF)

Requirement: atomic columns, no repeating groups.

The flat table above is already atomic (no comma-separated lists in a
cell), so it passes 1NF as long as we don't store, say, a list of past
grades in one `grade_history` text field. That temptation is exactly why
`employment_history` exists as its own table rather than a text column.

## Step 2 — Second Normal Form (2NF)

Requirement: every non-key attribute must depend on the *whole* primary key
(only relevant where the key is composite — but it's the right point to
notice partial dependencies hiding in the flat design).

In the flat table, `branch_region` depends only on `branch`, not on
`emp_id` directly — it's a **partial/transitive** dependency riding along
on the employee row. Same for `salary_band`, which depends on `grade`, not
on the employee.

**Fix:** extract `branch` and `grade` into their own tables:

```
branch(branch_id PK, branch_name, region)
grade(grade_id PK, grade_title, salary_band)
```

## Step 3 — Third Normal Form (3NF)

Requirement: no transitive dependencies — non-key attributes must depend
on the key, the whole key, and nothing but the key.

`department_head` in the flat table is transitively dependent:
`emp_id → department → department_head`. The head's name isn't a fact about
the employee row it sits on — it's a fact about the *department*. Storing it
per-employee-row means every employee in the department repeats the same
head, and there is no single place to make it a real foreign key.

**Fix:** extract `department` into its own table, with `department_head_id`
as a foreign key pointing at `employee`:

```
department(department_id PK, department_name, department_head_id FK -> employee)
```

## Result: final 3NF schema

```
branch(branch_id PK, branch_name, region)
grade(grade_id PK, grade_title, salary_band)
department(department_id PK, department_name, department_head_id FK)
employee(employee_id PK, first_name, last_name, date_of_birth, hire_date,
         grade_id FK, department_id FK, branch_id FK, status)
employment_history(history_id PK, employee_id FK, event_type, old_value,
                    new_value, event_date, processed_by)
audit_log(log_id PK, table_affected, record_id, action, performed_by, performed_at)
```

Every non-key column in every table now depends only on that table's own
primary key. Updating a department head is a single `UPDATE` on one row in
`department`, not a mass update across every employee row — the update
anomaly from the flat design is gone.

## A deliberate denormalization decision

`employment_history.old_value` / `new_value` are stored as plain text
(e.g. `'Officer'` → `'Senior Officer'`) rather than as foreign keys to
`grade_id`. This is intentional: a grade can be renamed or retired later,
and the history table needs to preserve *what the value was at the time of
the event*, not what it currently resolves to. This is a standard
audit-log trade-off.
