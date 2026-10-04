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

*To be completed once all portfolios are finished — design choices made,
challenges faced (e.g. the circular foreign key between `department` and
`employee`, MySQL version constraints on CHECK enforcement), and lessons
learned.*

---

## AI Use Declaration

- **AI tool used:** Claude (Anthropic)
- **What it was used for:** drafting initial
  schema and query structure, generating seed/test data and explaining
  normalization steps. Also for the MongoDB explanations and developing the json employee file
- **How the output was reviewed/verified:** all
  SQL was executed against a live MySQL instance via XAMPP/phpMyAdmin to
  confirm it runs correctly; schema and query logic were reviewed and
  understood, not copied blindly; execution plan evidence was independently captured from my own database, not assumed.
  Same was tested on my MongoDB too.


