# Graph Model for Organisational Hierarchy

This is a supplementary discussion, not a required second implementation as the document-model MongoDB work is the primary,
fully-implemented deliverable for Portfolio 4.

## Why a graph fits this part of the problem

The relational schema handles "who reports to whom" through
`department.department_head_id` and `employee.department_id` — this works
for one level, but a query like *"show me everyone in Ibrahim Musa's
reporting chain, three levels down"* requires a recursive query
(`WITH RECURSIVE` in MySQL 8+), which is awkward to write and can be slow.
A graph database treats reporting lines as first-class relationships,
making these traversals natural and fast regardless of depth.

## Model (Neo4j / Cypher syntax)

```cypher
CREATE (chidi:Employee {id: 'EMP-001', name: 'Chidi Okafor', grade: 'Manager'})
CREATE (ibrahim:Employee {id: 'EMP-003', name: 'Ibrahim Musa', grade: 'Department Head'})
CREATE (ngozi:Employee {id: 'EMP-002', name: 'Ngozi Bello', grade: 'Senior Officer'})
CREATE (compliance:Department {name: 'Compliance'})

CREATE (chidi)-[:REPORTS_TO]->(ibrahim)
CREATE (ngozi)-[:REPORTS_TO]->(ibrahim)
CREATE (ibrahim)-[:HEADS]->(compliance)
```

## Example queries this makes easy

**Everyone in a manager's reporting chain, any depth:**
```cypher
MATCH (e:Employee)-[:REPORTS_TO*1..5]->(head:Employee {name: 'Ibrahim Musa'})
RETURN e.name
```

**Shortest path between two employees in the org chart:**
```cypher
MATCH path = shortestPath(
    (a:Employee {name: 'Chidi Okafor'})-[:REPORTS_TO*]-(b:Employee {name: 'Ngozi Bello'})
)
RETURN path
```

Both of these would require either multiple self-joins with a fixed depth
limit, or a recursive CTE, in the relational schema; the graph model
expresses them as a single pattern match instead.

## If you want to actually deploy this

- **Neo4j AuraDB Free** (cloud, no install) — sign up, get a connection
  URI, and run the Cypher above in the built-in browser query console.
- **Neo4j Desktop** (local) — similar to installing XAMPP, gives you a
  local instance plus the Neo4j Browser UI.

