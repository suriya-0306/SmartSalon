<?php
$host = "localhost";
$user = "root";          // default XAMPP user
$pass = "";              // default XAMPP password
$db   = "smartsalon_db";    // 👈 YOUR DATABASE NAME

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode([
        "status" => false,
        "message" => "Database connection failed"
    ]));
}
?>