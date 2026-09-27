# Advanced Database Systems Portfolio — MIT 8103

**Module:** MIT 8103 Advanced Database Systems
**Assessment:** Individual Practical Database Portfolio (40 marks)
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
- **NoSQL (Portfolio 4):** *TBD — MongoDB / Neo4j*
- **Diagrams:** Mermaid (renders natively in GitHub Markdown)

---

## Repository Structure

```
advanced-database-portfolio/
├── portfolio-1-database-design/
│   ├── schema_mysql.sql          -- MySQL 10.4.32 schema (6 tables, keys, constraints)
│   ├── er-diagram.md             -- Mermaid ER diagram + relationship notes
│   └── normalization.md          -- 1NF → 2NF → 3NF walkthrough
├── portfolio-2-query-optimisation/
│   ├── queries_mysql.sql         -- 10+ queries: joins, aggregates, subqueries, window functions
│   ├── seed_mysql.sql            -- small seed set (10 employees)
│   ├── seed_mysql_large.sql      -- larger seed set (120 employees) for index evidence
│   └── performance-analysis.md   -- EXPLAIN findings, before/after indexing
├── portfolio-3-transactions-concurrency/   (in progress)
├── portfolio-4-nosql/                      (in progress)
├── portfolio-5-distributed-cloud/          (in progress)
└── README.md
```

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
| Portfolio 3: Transactions and Concurrency | 🔄 In progress | 7 |
| Portfolio 4: NoSQL and Advanced Data Models | ⬜ Not started | 7 |
| Portfolio 5: Distributed and Cloud Database Exercise | ⬜ Not started | 6 |
| Final Documentation | ⬜ Not started | 6 |

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
  normalization steps.
- **How the output was reviewed/verified:** all
  SQL was executed against a live MySQL instance via XAMPP/phpMyAdmin to
  confirm it runs correctly; schema and query logic were reviewed and
  understood, not copied blindly; execution plan evidence (EXPLAIN output)
  was independently captured from my own database, not assumed.


