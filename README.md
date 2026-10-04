# Advanced Database Systems Portfolio — MIT 8103

**Module:** MIT 8103 Advanced Database Systems
**Assessment:** Individual Practical Database Portfolio
**Academic Session:** 2026/2027 — First Semester Continuous Assessment

---

## Case Study

**PrimeTrust Bank HR Management System** — a database supporting the Human
Resources department in managing staff records across branches, tracking
promotions, transfers, and resignations, and supporting reporting-line/
organisational hierarchy queries.

- **Users:** HR officers, branch managers, department heads, auditors
- **Key data:** employees, departments, branches, grades, employment
  history, leave records
- **Key operations:** onboard employee, promote/transfer employee, process
  resignation, generate headcount/payroll reports, audit staff changes

This case study is used consistently across all five portfolio activities,
as required by the assessment brief.

---

## Tech Stack

- **Database engine:** MySQL 10.4.32-MariaDB
 (tested locally via XAMPP / phpMyAdmin)
- **Scripting:** PHP (`mysqli`/PDO) for Portfolio 3 transaction demos,
  Python for seed data generation
- **NoSQL (Portfolio 4):** MongoDB and MongoDB compass
- **Diagrams:** Mermaid (renders natively in GitHub Markdown)

---

## How to Run This Locally

1. Install [XAMPP](https://www.apachefriends.org/) and start **Apache** + **MySQL**.
2. Open `http://localhost/phpmyadmin`.
3. Create a database named `primetrust_hr`.
4. Import `portfolio-1-database-design/schema_mysql.sql` (Import tab → choose file → Go).
5. Import `portfolio-2-query-optimisation/seed_mysql_large.sql` for a realistic dataset.
6. Run queries from `portfolio-2-query-optimisation/queries_mysql.sql` one at a time
   in the SQL tab to reproduce the results documented in `performance-analysis.md`.

---

## Progress

| Portfolio | Status | Marks |
|---|---|---|
| Portfolio 1: Database Design and Modelling | ✅ Complete | 7 |
| Portfolio 2: Query Processing and Optimisation | ✅ Complete | 7 |
| Portfolio 3: Transactions and Concurrency | ✅ Complete | 7 |
| Portfolio 4: NoSQL and Advanced Data Models | ✅ Complete | 7 |
| Portfolio 5: Distributed and Cloud Database Exercise | ✅ Complete | 6 |
| Final Documentation | ✅ Complete | 6 |

---

## Individual Reflection

Working through this portfolio, I chose the PrimeTrust Bank HR
Management System as my case study because it gave me enough structure
to meaningfully apply every topic the module covered, while staying
close to a domain I could reason about concretely, noting that staff records,
promotions, and organisational hierarchy map fairly naturally onto
database concepts.

**Database design (Portfolio 1):** the most instructive part of the
design wasn't the straightforward entities ; it was the circular
relationship between `department` and `employee` (a department is headed
by an employee, but an employee belongs to a department). Resolving this
meant creating one table without its foreign key and adding the
constraint afterward with `ALTER TABLE`, which taught me more about how
referential integrity is actually enforced than a textbook example would
have. I also made a deliberate choice not to hard-delete employees on
resignation. a `status` column with a soft delete preserves the audit
trail, which felt like the right call for a system handling payroll-
adjacent data, even though it meant every query had to remember to filter
by `status = 'active'`.

**Query optimisation (Portfolio 2):** writing the `EXPLAIN` comparisons
before and after adding indexes was the clearest demonstration in the
whole portfolio of *why* indexing matters, rather than just being told
that it does. 

**Transactions and concurrency (Portfolio 3):** the lost-update
demonstration was the single most useful exercise in the whole
assessment. Seeing two browser tabs silently overwrite each other's
promotion, with no error raised by MySQL at all, made the abstract idea
of a "concurrency issue" concrete in a way no amount of reading about
isolation levels had. Fixing it with `SELECT ... FOR UPDATE` and watching
the second tab visibly pause until the first committed was the moment the
whole transactions module clicked for me.

**NoSQL (Portfolio 4):** modelling the same employee data as MongoDB
documents instead of relational rows made the trade-offs between the two
paradigms tangible rather than theoretical. The relational schema is
better at enforcing that data is always consistent and correctly typed;
the document model is better at representing employees who each have a
genuinely different set of optional fields (certifications, leave
records, a resignation record) without needing nullable columns or
near-empty join tables for each.

**Distributed and cloud (Portfolio 5):** thinking through CAP theorem
trade-offs for this specific case study rather than in the abstract 
clarified for me why "it depends" is usually the honest answer in
database design. Payroll-affecting writes need strong consistency even
at the cost of some availability during a partition; a read-only
headcount dashboard can tolerate staleness that a grade change cannot.

**Overall challenges:** the biggest recurring challenge was keeping every
portfolio activity consistent with the same case study and the same
underlying data, rather than treating each portfolio as an isolated
exercise, I think deciding early on the six core tables in Portfolio 1 paid off
by Portfolio 5, since every later activity could build on the same
schema rather than inventing new structure each time.

**Lessons learned:** the most transferable lesson from this portfolio
wasn't any single SQL technique, but the habit of generating real
evidence rather than assuming correctness; running `EXPLAIN`, actually
triggering a rollback, actually racing two concurrent requests against
each other, rather than just writing code that looks correct on paper.

---

## AI Use Declaration

- **AI tool used:** Claude (Anthropic)
  
- **What it was used for:** drafting initial
  schema and query structure, generating seed/test data and explaining
  normalization steps. Also for the MongoDB explanations and developing the json employee file. Also, explained
  some core concepts for me in portfolio 5.
  
- **How the output was reviewed/verified:** all
  SQL was executed against a live MySQL instance via XAMPP/phpMyAdmin to
  confirm it runs correctly; schema and query logic were reviewed and
  understood, not copied blindly; execution plan evidence was independently captured from my own database, not assumed.
  Same was tested on my MongoDB and the cloud database using aiven.


