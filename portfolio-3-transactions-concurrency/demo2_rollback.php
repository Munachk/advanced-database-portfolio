<?php
// ============================================================
// DEMO 2: Failing transaction -- ROLLBACK
//
// Same promotion logic as demo1, but this time we deliberately use
// a grade_id that does not exist (99999). The foreign key constraint
// on employee.grade_id -> grade.grade_id rejects the UPDATE, our
// catch block fires, and we roll back -- proving the employee's
// real grade is untouched even though the transaction "tried" to
// change it.
// ============================================================
require 'config.php';

$employee_id      = 2;
$invalid_grade_id = 99999;   // does not exist in the grade table
$old_grade_title   = 'Manager';
$new_grade_title    = 'Nonexistent Grade';
$processed_by       = 'HR-Admin (PHP demo)';

echo "<pre>";
echo "Before:\n";
$before = $mysqli->query("SELECT employee_id, first_name, last_name, grade_id FROM employee WHERE employee_id = $employee_id");
print_r($before->fetch_assoc());

$mysqli->begin_transaction();

try {
    $stmt1 = $mysqli->prepare("UPDATE employee SET grade_id = ? WHERE employee_id = ?");
    $stmt1->bind_param('ii', $invalid_grade_id, $employee_id);
    $stmt1->execute();   // <-- this line should throw: FK constraint violation

    // This second statement never runs because the exception above
    // jumps straight to the catch block -- proving the transaction
    // is genuinely atomic, not just "best effort."
    $stmt2 = $mysqli->prepare("INSERT INTO employment_history
        (employee_id, event_type, old_value, new_value, event_date, processed_by)
        VALUES (?, 'promotion', ?, ?, CURDATE(), ?)");
    $stmt2->bind_param('isss', $employee_id, $old_grade_title, $new_grade_title, $processed_by);
    $stmt2->execute();

    $mysqli->commit();
    echo "\nThis line should NOT print -- if it does, something is wrong.\n";

} catch (mysqli_sql_exception $e) {
    $mysqli->rollback();
    echo "\nROLLBACK triggered as expected.\n";
    echo "Error was: " . $e->getMessage() . "\n";
}

echo "\nAfter (grade_id must be unchanged from 'Before'):\n";
$after = $mysqli->query("SELECT employee_id, first_name, last_name, grade_id FROM employee WHERE employee_id = $employee_id");
print_r($after->fetch_assoc());

$history_count = $mysqli->query("SELECT COUNT(*) AS cnt FROM employment_history WHERE employee_id = $employee_id AND new_value = '$new_grade_title'");
echo "\nHistory rows referencing the failed promotion (should be 0):\n";
print_r($history_count->fetch_assoc());
echo "</pre>";

$mysqli->close();
