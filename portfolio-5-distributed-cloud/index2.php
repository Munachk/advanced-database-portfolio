<?php
$host = 'mysql-2f908d72-munadavid-d5f9.a.aivencloud.com';
$port = '16585';
$user = 'avnadmin';
$pass = 'AVNS_g6lbFjmYJDapg8ZoC1P';

$dsn = "mysql:host=$host;port=$port;dbname=defaultdb";
$options = [
    PDO::MYSQL_ATTR_SSL_CA => 'C:\Users\Munachi Nwolisa\Documents\p5\ca.pem',
    PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false
];

try {
  $db = new PDO($dsn, $user, $pass, $options);
  echo "Connected successfully!\n";

  // 1. Import schema.sql
  if (file_exists('schema_mysql.sql')) {
      $schema = file_get_contents('schema_mysql.sql');
      $db->exec($schema);
      echo "✅ schema_mysql.sql imported successfully!\n";
  } else {
      echo "❌ schema_mysql.sql file not found.\n";
  }

  // 2. Import seed.sql
  if (file_exists('seed_mysql_large.sql')) {
      $seed = file_get_contents('seed_mysql_large.sql');
      $db->exec($seed);
      echo "✅ seed_mysql_large.sql imported successfully!\n";
  } else {
      echo "❌ seed_mysql_large.sql file not found.\n";
  }

} catch (Exception $e) {
  echo "Error: " . $e->getMessage();
}
