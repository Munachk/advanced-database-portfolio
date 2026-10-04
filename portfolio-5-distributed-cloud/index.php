
<?php
// Define credentials cleanly without using the mysql:// URI string
$host = 'mysql-2f908d72-munadavid-d5f9.a.aivencloud.com';
$port = '16585';
$user = 'avnadmin';
$pass = 'AVNS_g6lbFjmYJDapg8ZoC1P'; // Keep it inside single quotes ''

$dsn = "mysql:host=$host;port=$port;dbname=defaultdb";

$options = [
    PDO::MYSQL_ATTR_SSL_CA => 'C:\Users\Munachi Nwolisa\Documents\p5\ca.pem',
    PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false
];

try {
  $db = new PDO($dsn, $user, $pass, $options);
  $stmt = $db->query("SELECT VERSION()");
  print("Connected successfully! Version: " . $stmt->fetch()[0]);
} catch (Exception $e) {
  echo "Error: " . $e->getMessage();
}

