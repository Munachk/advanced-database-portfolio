# Query Performance Analysis — Portfolio 2

## Evidence source

`seed_and_demo.py` seeds a 120-employee working database (5 departments, 4
branches, 5 grades, with realistic promotion history) and runs the queries
from `queries.sql` against it. Full console output is captured in
`demo_output.txt`. SQLite was used here to get fast, reproducible evidence
without needing a server — the query logic is standard SQL and maps
directly onto the PostgreSQL `schema.sql`/`queries.sql` in this repo. See
the "Adapting to PostgreSQL" section below for the two syntax differences
that matter.

## Finding 1: filtering by a foreign key without an index causes a full scan

Before adding an index on `employee.department_id`, filtering the 120-row
employee table by department produced:

```
SCAN employee
```

This means the engine reads every row in the table to find matches — fine
at 120 rows, but this scales linearly and becomes a real cost once the
table holds tens of thousands of employees across a full bank.

After running:

```sql
CREATE INDEX idx_employee_department ON employee(department_id);
```

the same query's plan became:

```
SEARCH employee USING INDEX idx_employee_department (department_id=?)
```

The engine now uses the index to jump directly to matching rows instead of
scanning the whole table. This is the concrete justification for the three
indexes already declared at the bottom of `schema.sql`
(`idx_employee_department`, `idx_employee_branch`, `idx_employee_status`) —
all three columns are used in `WHERE` and `JOIN` clauses across
`queries.sql` (Q1, Q3, Q4, Q8).

## Finding 2: the correlated subquery (Q6) is the most expensive query in the set

Q6 re-runs a `COUNT(*)` against `employment_history` once *per employee row*
in the outer query — an O(n×m) pattern. On 120 employees it's instant; at
bank scale, this is the first query I'd rewrite. An equivalent, cheaper
form uses a single `GROUP BY ... HAVING` instead of a correlated subquery:

```sql
SELECT e.employee_id, e.first_name, e.last_name
FROM employee e
JOIN (
    SELECT employee_id
    FROM employment_history
    WHERE event_type = 'promotion'
    GROUP BY employee_id
    HAVING COUNT(*) > 1
) promoted ON e.employee_id = promoted.employee_id;
```

This runs the aggregation once over `employment_history` rather than once
per employee, and (with `idx_history_employee` from `schema.sql`) lets the
join use an index instead of a per-row correlated lookup.

## Finding 3: window functions (Q8, Q9) don't need extra indexes to be efficient

`RANK() OVER (PARTITION BY department_id ORDER BY hire_date)` benefits from
having `department_id` and `hire_date` available cheaply, which the
existing `idx_employee_department` index already helps with — no separate
composite index was needed at this data volume. At much larger scale, a
composite index on `(department_id, hire_date)` would let the partition
sort itself use the index rather than sorting in memory — worth testing
with `EXPLAIN ANALYZE` once real data volume is available.

## Adapting this evidence to PostgreSQL for submission

Two things change when you run this for real against `schema.sql`:

1. Use `EXPLAIN ANALYZE <query>;` instead of SQLite's
   `EXPLAIN QUERY PLAN`. PostgreSQL's output additionally reports actual
   execution time and row counts (`actual time=... rows=... loops=...`),
   which is stronger evidence than the plan-only output shown here — screenshot
   that output for your submission.
2. Look for `Seq Scan` (before index) turning into `Index Scan` or
   `Bitmap Heap Scan` (after index) in the PostgreSQL plan — this is the
   PostgreSQL equivalent of the `SCAN` → `SEARCH` change demonstrated above.

## Suggested indexing evidence to also capture in Postgres

```sql
EXPLAIN ANALYZE SELECT * FROM employee WHERE department_id = 3;
-- run once before CREATE INDEX, once after; screenshot both
```
