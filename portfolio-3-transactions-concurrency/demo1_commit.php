<?php
// ============================================================
// DEMO 1: Successful transaction -- COMMIT
//
// A promotion is really two writes that must happen together:
//   1. update the employee's grade
//   2. record the change in employment_history
// Wrapping both in one transaction means either BOTH happen, or
// NEITHER does -- the database is never left half-updated.
// ============================================================
require 'config.php';

$employee_id      = 2;                     // must exist in your seed data
$new_grade_id     = 3;                     // 3 = 'Manager' in the grade table
$old_grade_title  = 'Senior Officer';
$new_grade_title  = 'Manager';
$processed_by     = 'HR-Admin (PHP demo)';

echo "<pre>";
echo "Before:\n";
$before = $mysqli->query("SELECT employee_id, first_name, last_name, grade_id FROM employee WHERE employee_id = $employee_id");
print_r($before->fetch_assoc());

$mysqli->begin_transaction();

try {
    $stmt1 = $mysqli->prepare("UPDATE employee SET grade_id = ? WHERE employee_id = ?");
    $stmt1->bind_param('ii', $new_grade_id, $employee_id);
    $stmt1->execute();

    $stmt2 = $mysqli->prepare("INSERT INTO employment_history
        (employee_id, event_type, old_value, new_value, event_date, processed_by)
        VALUES (?, 'promotion', ?, ?, CURDATE(), ?)");
    $stmt2->bind_param('isss', $employee_id, $old_grade_title, $new_grade_title, $processed_by);
    $stmt2->execute();

    $mysqli->commit();
    echo "\nCOMMIT successful -- both the grade update and the history record were saved.\n";

} catch (mysqli_sql_exception $e) {
    $mysqli->rollback();
    echo "\nROLLBACK -- something failed, no partial change was saved: " . $e->getMessage() . "\n";
}

echo "\nAfter:\n";
$after = $mysqli->query("SELECT employee_id, first_name, last_name, grade_id FROM employee WHERE employee_id = $employee_id");
print_r($after->fetch_assoc());

$history = $mysqli->query("SELECT * FROM employment_history WHERE employee_id = $employee_id ORDER BY history_id DESC LIMIT 1");
echo "\nLatest history row:\n";
print_r($history->fetch_assoc());
echo "</pre>";

$mysqli->close();
