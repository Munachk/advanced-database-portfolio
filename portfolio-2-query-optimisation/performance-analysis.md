# Query Performance Analysis — Portfolio 2 (MySQL)

## Setup

Database: `primetrust_hr`, MySQL 10.4.32 (via XAMPP / phpMyAdmin).
Schema: `schema_mysql.sql`. Seed data: `seed_mysql_large.sql` (120 employees,
4 branches, 5 departments, 66 promotion/resignation history rows).

Run `SELECT VERSION();` in the SQL tab and the output recorded, screenshot too attached `show_version.png`.

> **MySQL version used:** `______10.4.32-MariaDB________`
> (This matters: `EXPLAIN ANALYZE` needs 8.0.18 +, and `CHECK` constraints
> are only actually enforced from 8.0.16 +)

---

## Finding 1: filtering by a foreign key without an index

**Before adding the index**, run query:

```sql
EXPLAIN SELECT * FROM employee WHERE department_id = 3;
```


**What to look for:** `type: ALL` means MySQL is scanning every row in the
table to find matches — the `key` column will show `NULL` (no index used).

Confirm the index exists (it's already declared in `schema_mysql.sql`):

```sql
SHOW INDEX FROM employee;
```

**After confirming the index**, re-run the same `EXPLAIN` and record the
result:


**What to look for:** `type: ref` (or `range`) with
`key: idx_employee_department` means MySQL is now using the index to jump
directly to matching rows instead of scanning the table.



If your MySQL version supports it (8.0.18+), also run:

```sql
EXPLAIN ANALYZE SELECT * FROM employee WHERE department_id = 3;
```

This reports **actual** execution time and row counts (not just the
planned estimate), which is stronger evidence — screenshot that output too
if available.

---

## Finding 2: the correlated subquery (Q6) vs. the rewritten join (Q6b)

`queries_mysql.sql` contains two versions of "employees promoted more than
once":

- **Q6** — a correlated subquery that re-runs a `COUNT(*)` against
  `employment_history` once *per employee row* in the outer query.
- **Q6b** — a single `GROUP BY ... HAVING` aggregation joined back to
  `employee` once.

Run both and compare their plans:

```sql
EXPLAIN SELECT e.employee_id, e.first_name, e.last_name
FROM employee e
WHERE (SELECT COUNT(*) FROM employment_history h
       WHERE h.employee_id = e.employee_id AND h.event_type = 'promotion') > 1;

EXPLAIN SELECT e.employee_id, e.first_name, e.last_name
FROM employee e
JOIN (
    SELECT employee_id FROM employment_history
    WHERE event_type = 'promotion'
    GROUP BY employee_id HAVING COUNT(*) > 1
) promoted ON e.employee_id = promoted.employee_id;
```

Record both plans here and note which shows a `DEPENDENT SUBQUERY` in
`select_type` (Q6 — the more expensive pattern, since it's evaluated once
per outer row) versus a plain `DERIVED` table (Q6b — evaluated once,
overall).


---

## Finding 3: window functions (Q8, Q9)

`RANK() OVER (PARTITION BY department_id ORDER BY hire_date)` requires
MySQL 8.0+ (window functions did not exist in 5.7 and earlier — confirm
your version supports this before relying on Q8/Q9).

```sql
EXPLAIN SELECT e.first_name, e.last_name, d.department_name, e.hire_date,
       RANK() OVER (PARTITION BY e.department_id ORDER BY e.hire_date ASC) AS seniority_rank
FROM employee e JOIN department d ON e.department_id = d.department_id
WHERE e.status = 'active';
```

Record whether the plan shows a `Using filesort` step in `Extra` — this
indicates MySQL had to sort in memory/disk to compute the window ranking.
A composite index on `(department_id, hire_date)` (not currently in
`schema_mysql.sql`) could let the sort use the index instead — worth
testing as a stretch goal:

```sql
CREATE INDEX idx_employee_dept_hiredate ON employee(department_id, hire_date);
-- re-run the EXPLAIN above and compare the Extra column
```

---

## Summary table (fill in once you've run everything above)

| Query | Technique demonstrated | Index used? | Notable finding |
|-------|------------------------|--------------|------------------|
| Q1 | Simple filter | | |
| Q2 | Multi-table JOIN | | |
| Q3 | Aggregate (GROUP BY) | | |
| Q6 vs Q6b | Correlated subquery vs join rewrite | | |
| Q7 | Nested subquery | | |
| Q8 | Window function (RANK) | | |
| Q9 | Window function (running total) | | |

---

## Screenshots checklist for this folder

- [ ] `mysql-version.png` — output of `SELECT VERSION();`
- [ ] `explain-before-index.png`
- [ ] `explain-after-index.png` (or `explain-analyze-*.png` if 8.0.18+)
- [ ] `explain-q6-vs-q6b.png`
- [ ] `show-index-employee.png` — output of `SHOW INDEX FROM employee;`
