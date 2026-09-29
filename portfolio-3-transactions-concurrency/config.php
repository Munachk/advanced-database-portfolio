<?php
// ============================================================
// Portfolio 3: shared database connection
// Place this whole folder inside your XAMPP htdocs directory, e.g.
//   C:\xampp\htdocs\portfolio3\   (Windows)
//   /Applications/XAMPP/htdocs/portfolio3/   (Mac)
// Then access scripts at http://localhost/portfolio3/<script>.php
// ============================================================

// Make mysqli throw exceptions on error instead of silently failing --
// this is what lets our try/catch blocks actually catch problems
// (e.g. a foreign key violation) and trigger a rollback.
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$host = '127.0.0.1';
$user = 'root';
$pass = '';          // default XAMPP MySQL root password is blank
$db   = 'primetrust_hr';

$mysqli = new mysqli($host, $user, $pass, $db);
$mysqli->set_charset('utf8mb4');
