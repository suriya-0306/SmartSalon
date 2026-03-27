<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

include("config.php");

// DB CONNECT
$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    echo json_encode([
        "status" => false,
        "message" => "Database connection failed"
    ]);
    exit;
}

// ONLY POST
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    echo json_encode([
        "status" => false,
        "message" => "POST method required"
    ]);
    exit;
}

// READ INPUT
$email       = trim(strtolower($_POST['email'] ?? ''));
$newPassword = $_POST['new_password'] ?? '';

if (empty($email) || empty($newPassword)) {
    echo json_encode([
        "status" => false,
        "message" => "Email and password required"
    ]);
    exit;
}

// 🔎 CHECK USER EXISTS FIRST
$check = $conn->prepare(
    "SELECT id FROM users WHERE LOWER(email) = ?"
);
$check->bind_param("s", $email);
$check->execute();
$check->store_result();

if ($check->num_rows === 0) {
    echo json_encode([
        "status" => false,
        "message" => "User not found"
    ]);
    exit;
}
$check->close();

// 🔐 HASH PASSWORD
$hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);

// 🔄 UPDATE PASSWORD
$stmt = $conn->prepare(
    "UPDATE users SET password = ? WHERE LOWER(email) = ?"
);
$stmt->bind_param("ss", $hashedPassword, $email);

if ($stmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Password updated successfully"
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Password update failed"
    ]);
}

$stmt->close();
$conn->close();
?>