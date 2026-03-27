<?php

$host = "sqlXXX.infinityfree.com";   // 👉 change this
$user = "if0_41491821";              // your username
$pass = "YOUR_PASSWORD";             // your DB password
$db   = "if0_41491821_smart_salon";  // your DB name

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode([
        "status" => false,
        "message" => "Database connection failed"
    ]));
}

?>