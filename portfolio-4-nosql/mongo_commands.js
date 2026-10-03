// ============================================================
// Portfolio 4: MongoDB document-model demo
// This can be run in the aggregations tab or the MongoDB shell
// Running mine in the aggregations tab, either connected to
// MongoDB Atlas (free tier, cloud) or a local MongoDB install.
//
// ============================================================

use primetrust_hr_nosql;

// ------------------------------------------------------------
// 1. Confirm the employee count of the collection
// ------------------------------------------------------------
print("--- After import, confirm the count: ---");
db.employee_profiles.countDocuments();

// ------------------------------------------------------------
// 2. Basic query: find all active employees in one department
// ------------------------------------------------------------

{status:'active','current_position.department':'IT'}

// ------------------------------------------------------------
// 3. Query into a nested/embedded array: employees with 2+ promotions
// ------------------------------------------------------------

[
  {
    "$match": {
    $expr: { $gte: [ { $size: "$promotion_history" }, 2 ] }
}
  }
]

// ------------------------------------------------------------
// 4. Aggregation pipeline: headcount per department (like Portfolio 2's Q3)
// ------------------------------------------------------------

[
  { "$match": { "status": "active" } },
  { "$group": { "_id": "$current_position.department", "headcount": { "$sum": 1 } } },
  { "$sort": { "headcount": -1 } }
]


// ------------------------------------------------------------
// 5. $unwind: flatten promotion_history to analyse individual promotion events
// ------------------------------------------------------------

[
  {
    "$unwind": "$promotion_history"
  },
  {
    "$project": {
      "_id": 0,
      "employee": { "$concat": ["$first_name", " ", "$last_name"] },
      "date": "$promotion_history.date",
      "from": "$promotion_history.from",
      "to": "$promotion_history.to"
    }
  }
]


// ------------------------------------------------------------
// 6. Update: push a new promotion onto an employee's embedded array
// (equivalent to the PHP demo1_commit.php transaction in Portfolio 3,
// but here it's a single atomic document update -- no JOIN needed
// because the history lives inside the employee document itself)
//
// Also note, This command is an update mutation (updateOne), which cannot be run in the Aggregations tab and must be executed in the embedded >_ MONGOSH terminal at the bottom of Compass.
// The Aggregations and Documents tabs are read-only query builders meant for reading/transforming data, not modifying documents.
// ------------------------------------------------------------
print("--- Promoting EMP-002 ---");
db.employee_profiles.updateOne(
    { _id: "EMP-002" },
    {
        $set: { "current_position.grade": "Manager" },
        $push: { "promotion_history": { date: "2026-09-29", from: "Senior Officer", to: "Manager" } }
    }
);
db.employee_profiles.findOne({ _id: "EMP-002" });

// ------------------------------------------------------------
// 7. Schema flexibility demo: only some documents have "skills",
// "certifications", "leave_records" or "resignation" fields at all --
// no ALTER TABLE, no NULL columns wasted on employees who don't use them
// ------------------------------------------------------------

[
  {
    "$match": {
      "certifications": { "$exists": true }
    }
  },
  {
    "$project": {
      "_id": 0,
      "first_name": 1,
      "last_name": 1,
      "certifications": 1
    }
  }
]


[
  {
    "$match": {
      "certifications": { "$exists": false }
    }
  },
  {
    "$project": {
      "_id": 0,
      "first_name": 1,
      "last_name": 1,
      "certifications": 1
    }
  }
]



