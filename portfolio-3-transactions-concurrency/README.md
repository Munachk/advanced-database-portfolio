# Portfolio 3: Transactions and Concurrency

Covers all four required elements: **commit**, **rollback**, **isolation**,
and a **concurrency issue with its control mechanism**, using PHP
(`mysqli`) against the same `primetrust_hr` MySQL database from
Portfolios 1–2.

## Setup

1. Copy this whole folder into your XAMPP `htdocs` directory, e.g.:
   - Windows: `C:\xampp\htdocs\portfolio3\`
   - Mac: `/Applications/XAMPP/htdocs/portfolio3/`
2. Confirm Apache **and** MySQL are both running in the XAMPP Control Panel. Screenshot in `apache_mysql_running.png`
3. Confirm `config.php`'s credentials match your setup (default XAMPP
   root password is blank — only change this if you set a password).
4. You should already have `primetrust_hr` populated from Portfolios 1–2.
   If not, import `schema_mysql.sql` then `seed_mysql_large.sql` first.

## Files

| File | Demonstrates |
|---|---|
| `config.php` | Shared DB connection (not a demo itself) |
| `demo1_commit.php` | Successful transaction — COMMIT |
| `demo2_rollback.php` | Deliberately failing transaction — ROLLBACK |
| `demo3_lost_update_problem.php` | Concurrency **issue**: lost update, no locking |
| `demo4_lost_update_fixed.php` | Concurrency **control mechanism**: `SELECT ... FOR UPDATE` |
| `reset_demo_data.sql` | Resets test data between demo runs |
| `isolation-levels.md` | Isolation level explanation + SQL-only demo |

## How to run each demo

### 1. Commit demo
Visit `http://localhost/portfolio3/demo1_commit.php`. Screenshot the
"Before" and "After" output — grade_id should change, and a new
`employment_history` row should appear.

### 2. Rollback demo
Visit `http://localhost/portfolio3/demo2_rollback.php`. Screenshot the
output — it should show the ROLLBACK message, and the "After" grade_id
should be **unchanged** from "Before" (the invalid grade was rejected).

### 3. Concurrency issue (lost update)
1. Run `reset_demo_data.sql` in phpMyAdmin first.
2. Open two browser tabs (or two different browsers).
3. Load `demo3_lost_update_problem.php` in tab 1.
4. Within ~2 seconds, load the same URL in tab 2.
5. Wait ~8 seconds for both to finish. Screenshot both tabs side by side —
   both should show the *same* "Read grade_id" value, proving neither saw
   the other's change before writing.
6. Check the actual database value afterwards:
   ```sql
   SELECT grade_id FROM employee WHERE employee_id = 2;
   ```
   It will have only gone up by **1**, even though two updates ran — one
   promotion was silently lost. Screenshot this too.

### 4. Concurrency control mechanism (the fix)
1. Run `reset_demo_data.sql` again to reset.
2. Repeat the same two-tab process, but with
   `demo4_lost_update_fixed.php` this time.
3. Screenshot both tabs — tab 2 should visibly **pause** ("Requesting
   lock...") until tab 1 finishes and commits, then proceed.
4. Check the database value:
   ```sql
   SELECT grade_id FROM employee WHERE employee_id = 2;
   ```
   This time it will have gone up by **2** — both promotions applied
   correctly, because the lock serialized them.

### 5. Isolation levels
Follow the SQL-only walkthrough in `isolation-levels.md` using two
separate browser phpMyAdmin sessions (or the MySQL CLI). Screenshot the
before/after `SELECT` results inside the open transaction.

## Screenshots checklist

- [ ] `demo1-commit-output.png`
- [ ] `demo2-rollback-output.png`
- [ ] `demo3-tab1.png` and `demo3-tab2.png`
- [ ] `demo3-db-value-after.png` (the lost-update proof)
- [ ] `demo4-tab1.png` and `demo4-tab2.png`
- [ ] `demo4-db-value-after.png` (the fix proof)
- [ ] `isolation-repeatable-read.png`

## Note on the `reset_demo_data.sql` step

Because demo3 and demo4 both modify the *same* row, you must reset
`employee_id = 2`'s grade between test runs, or your "before" state won't
match what the write-up describes.

