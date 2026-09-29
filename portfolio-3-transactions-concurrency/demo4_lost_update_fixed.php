<?php
// ============================================================
// DEMO 4: Concurrency CONTROL MECHANISM -- fixing the lost update
//
// Same scenario as demo3, but the read now uses
//   SELECT ... FOR UPDATE
// inside an explicit transaction. This takes a row-level lock on
// the employee row for the duration of the transaction. Any other
// transaction that tries to SELECT ... FOR UPDATE the same row must
// WAIT until the first transaction commits or rolls back.
//
// HOW TO RUN THIS DEMO:
//   1. Reset the employee's grade_id first if you want a clean
//      before/after comparison (see reset_demo_data.sql).
//   2. Open TWO browser tabs, load this script in both, starting
//      tab 2 a couple of seconds after tab 1 (while tab 1 is still
//      inside its 8-second sleep).
//   3. Watch tab 2 -- it will visibly PAUSE at the "waiting for lock"
//      point until tab 1 finishes and commits. Screenshot the timing
//      difference between the two tabs' printed timestamps.
//
// RESULT: grade_id increases by 2 (both promotions are correctly
// applied, one after the other) instead of being silently lost.
// ============================================================
require 'config.php';

$employee_id = 2;

echo "<pre>";
echo "[" . date('H:i:s') . "] Requesting lock (SELECT ... FOR UPDATE)...\n";
flush();

$mysqli->begin_transaction();

$res = $mysqli->query("SELECT grade_id FROM employee WHERE employee_id = $employee_id FOR UPDATE");
$row = $res->fetch_assoc();
$current_grade = (int) $row['grade_id'];
echo "[" . date('H:i:s') . "] Lock acquired. Read grade_id = $current_grade\n";
flush();

// Same simulated delay as demo3 -- but this time the row is LOCKED,
// so a concurrent second request cannot read past its own
// SELECT ... FOR UPDATE line until this transaction commits.
sleep(8);

$new_grade = $current_grade + 1;
$mysqli->query("UPDATE employee SET grade_id = $new_grade WHERE employee_id = $employee_id");
$mysqli->commit();

echo "[" . date('H:i:s') . "] Committed grade_id = $new_grade. Lock released.\n";
echo "\nCompare the two tabs' timestamps: the second tab's 'Lock acquired'\n";
echo "line should appear only AFTER the first tab's 'Committed' line --\n";
echo "proving the lock genuinely serialized the two updates.\n";
echo "</pre>";

$mysqli->close();
