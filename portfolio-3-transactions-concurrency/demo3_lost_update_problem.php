<?php
// ============================================================
// DEMO 3: Concurrency ISSUE -- the lost update problem
//
// HOW TO RUN THIS DEMO:
//   1. Open TWO browser tabs (or two different browsers, e.g. Chrome
//      + Firefox, to guarantee two separate MySQL connections).
//   2. Load this script in BOTH tabs within a couple of seconds of
//      each other (start tab 1, then quickly start tab 2 before
//      tab 1's 8-second sleep finishes).
//   3. Watch the timestamps each tab prints.
//
// WHAT HAPPENS:
// Both requests read the SAME starting grade_id before either has
// written anything back. Both then independently add 1 and write
// it back. The SECOND write silently overwrites the first -- one
// promotion is completely lost, with no error and no warning.
// This is the classic "lost update" anomaly.
// ============================================================
require 'config.php';

$employee_id = 2;

echo "<pre>";

$res = $mysqli->query("SELECT grade_id FROM employee WHERE employee_id = $employee_id");
$row = $res->fetch_assoc();
$current_grade = (int) $row['grade_id'];
echo "[" . date('H:i:s') . "] Read grade_id = $current_grade (no lock held)\n";

// Simulate a realistic delay -- an HR officer reviewing the promotion
// on screen before clicking "Save", or slow application logic.
sleep(8);

$new_grade = $current_grade + 1;
$mysqli->query("UPDATE employee SET grade_id = $new_grade WHERE employee_id = $employee_id");
echo "[" . date('H:i:s') . "] Wrote grade_id = $new_grade (blind write, based on stale read)\n";

echo "\nIf both tabs printed the SAME 'Read grade_id' value, and the SAME\n";
echo "'Wrote grade_id' value, one promotion has been silently lost --\n";
echo "the grade only went up by 1 instead of 2, even though two separate\n";
echo "promotions were processed.\n";
echo "</pre>";

$mysqli->close();
