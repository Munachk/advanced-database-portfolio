# Portfolio 4: NoSQL and Advanced Data Models

**Model chosen:** Document store (MongoDB)
**Case study element modelled:** Employee 360 profile — the same
`employee` + `employment_history` data from Portfolios 1–3, remodelled as
self-contained documents instead of normalized relational tables.

## Setup (no local install needed — easiest path)

1. Create a free account at [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas).
2. Create a free-tier (M0) cluster — takes a few minutes to provision.
3. Under "Database Access," create a database user with a password.
4. Under "Network Access," allow your current IP (or `0.0.0.0/0` for
   simplicity while testing — tighten this if you keep the cluster around).
5. Click "Connect" → "Compass" or "Shell" to get your connection string.

### MongoDB Compass (GUI — easiest for screenshots)
1. Download [MongoDB Compass](https://www.mongodb.com/products/compass).
2. Paste your connection string to connect.
3. Create database `primetrust_hr_nosql`, collection `employee_profiles`.
4. Use the "Import Data" button to import `employee_profiles.json` directly.
5. Use the "Aggregations" tab to build and run the pipelines from
   `mongo_commands.js` visually — Compass shows you the result live.


## Why a document model suits this part of the case study

The relational schema (Portfolio 1) is the right choice for data with a
fixed, consistent shape across every row — every employee has exactly one
`grade_id`, one `department_id`, one `branch_id`. But an **HR profile
view** — the kind of screen an HR officer opens to see "everything about
this one employee" — has a different shape problem:

- Not every employee has certifications, leave records, or a resignation
  record. In the relational model, this means either nullable columns
  (wasted space, awkward `NULL` checks) or extra join tables (more
  complexity for what's fundamentally optional, sparse data).
- Building that one profile screen from the relational schema means
  joining `employee` + `employment_history` + possibly a future
  `certifications` table + a future `leave` table — four or five joins
  for one read.
- In the document model, one `employee_profiles` document *is* the whole
  profile — `promotion_history`, `certifications`, `leave_records` are
  embedded arrays inside it. Reading one employee's full profile is a
  single document fetch, no joins at all.

This is a genuine trade-off, not a strict improvement — see below.

## Trade-offs

**What's better in the document model:**
- Single-read profile lookups (no joins)
- Naturally handles employees with different optional fields
- Schema changes (e.g. adding a new optional field to some employees)
  need no migration — just start writing documents with the new field

**What's worse / harder than the relational model:**
- Enforcing that every `department` value matches a real department is
  no longer a database-level guarantee (no foreign keys) — this becomes
  an application-level responsibility
- Cross-employee aggregate reporting (e.g. "average tenure per grade,"
  Portfolio 2's Q5) is more awkward — the aggregation pipeline syntax is
  less familiar than SQL's `GROUP BY`, though it's just as capable
- Updating a value that's duplicated across many documents (e.g. if a
  department gets renamed) means updating every document that embeds it,
  since there's no single source-of-truth row like the relational
  `department` table provides

**Conclusion:** the relational schema remains the
system of record for transactional integrity (Portfolios 1–3); the
document model is well suited as a **read-optimized view** layer for the
HR profile screen specifically — a common real-world pattern (keep your
source of truth relational, denormalize into a document store for a
specific fast-read use case), not a wholesale replacement.

## Files

| File | Purpose |
|---|---|
| `employee_profiles.json` | 5 sample documents, deliberately with varying optional fields |
| `mongo_commands.js` | Collection creation, queries, aggregation pipelines, update demo |
| `graph-model-bonus.md` | Supplementary graph-model discussion for org hierarchy |

## Screenshots checklist

- [ ] Compass `compass.png`
- [ ] MongoDB `mongoDB.png` 
- [ ] Create Compass DB  `compass_db.png`
- [ ] Imported collection (5 documents, count = 5)  `imported.png`
- [ ] The current department   `department-count.png`
- [ ] The department-headcount aggregation result   `department-headcount`
- [ ] The `$unwind` promotion-events query result   `unwind.png`
- [ ] Before/after of the `updateOne` promotion push (EMP-002's document) `promotion-query.png`  `after-query.png`
- [ ] The two schema-flexibility queries (with/without `certifications` field) `true.png`  `false.png`

