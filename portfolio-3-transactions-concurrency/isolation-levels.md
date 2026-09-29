# Transaction Isolation Levels — PrimeTrust Bank HR

MySQL's InnoDB engine (the default engine used throughout this portfolio)
supports four standard SQL isolation levels. This document explains each
in terms of the HR case study, and gives a short SQL-only demo you can run
in two separate phpMyAdmin browser sessions to see the difference yourself.

## The four levels, in HR terms

| Level | What it prevents | HR example |
|---|---|---|
| **READ UNCOMMITTED** | Nothing — allows dirty reads | An HR report could show a promotion that later gets rolled back, as if it had actually happened |
| **READ COMMITTED** | Dirty reads | A report only ever sees committed data, but re-reading the same employee twice in one report could show different grades if someone else committed a change in between |
| **REPEATABLE READ** (MySQL's default) | Dirty reads + non-repeatable reads | Once a transaction reads an employee's grade, it will see the SAME value for that employee for the rest of the transaction, even if another transaction commits a change in the meantime |
| **SERIALIZABLE** | All of the above + phantom reads | The strictest level — transactions are effectively queued one after another for any rows they touch |

**MySQL/InnoDB's default is REPEATABLE READ** 

## Why this matters for the case study

The concurrency control demo (`demo4_lost_update_fixed.php`) uses
`SELECT ... FOR UPDATE`, which works *regardless* of the session's
isolation level — it takes an explicit row lock rather than relying on
the isolation level's default read behaviour. This is intentional: for a
financial/HR system where a lost promotion or an incorrect payroll
grade has real consequences, explicit locking is more predictable than
relying solely on isolation-level defaults.

## Demo: seeing REPEATABLE READ in action (optional, SQL-only)

This demo needs two genuinely separate MySQL sessions. phpMyAdmin's SQL
tab can share a connection across browser tabs in the same browser, so
for a reliable demo, open phpMyAdmin in **two different browsers**
(e.g. Chrome and Firefox), or use the MySQL command-line client twice.

**Session A:**
```sql
START TRANSACTION;
SELECT grade_id FROM employee WHERE employee_id = 2;
-- note the value returned, e.g. grade_id = 2
-- do NOT commit yet -- leave this transaction open
```

**Session B (in the other browser):**
```sql
START TRANSACTION;
UPDATE employee SET grade_id = 5 WHERE employee_id = 2;
COMMIT;
```

**Back in Session A (still the same open transaction):**
```sql
SELECT grade_id FROM employee WHERE employee_id = 2;
-- under REPEATABLE READ (MySQL's default): still shows the OLD value (2)
-- even though Session B already committed a change to 5
COMMIT;
SELECT grade_id FROM employee WHERE employee_id = 2;
-- NOW shows 5 -- the new transaction (after COMMIT) sees the committed change
```

The value staying frozen at `2` until Session A's own transaction ends is REPEATABLE READ working
as designed.

To compare against READ COMMITTED, run this at the start of Session A
instead:
```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT grade_id FROM employee WHERE employee_id = 2;
-- repeat the same steps as above; this time the second SELECT inside
-- Session A's transaction WILL show Session B's committed change (5)
-- immediately, without needing to COMMIT first
```
