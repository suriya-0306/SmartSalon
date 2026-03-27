<?php

ini_set('display_errors', 1);
error_reporting(E_ALL);


header("Content-Type: application/json");

// DATABASE CONNECTION
include("config.php");

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    echo json_encode([
        "status" => false,
        "message" => "Database connection failed"
    ]);
    exit;
}

// ALLOW ONLY POST
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    echo json_encode([
        "status" => false,
        "message" => "Invalid request method"
    ]);
    exit;
}

// READ FORM DATA
$role     = $_POST['role']     ?? '';
$username = $_POST['username'] ?? '';
$email    = $_POST['email']    ?? '';
$phone    = $_POST['phone']    ?? '';
$password = $_POST['password'] ?? '';

// VALIDATION
if (
    empty($role) ||
    empty($username) ||
    empty($email) ||
    empty($phone) ||
    empty($password)
) {
    echo json_encode([
        "status" => false,
        "message" => "All fields are required"
    ]);
    exit;
}

// CHECK EMAIL EXISTS
$check = $conn->prepare("SELECT id FROM users WHERE email = ?");
$check->bind_param("s", $email);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    echo json_encode([
        "status" => false,
        "message" => "Email already registered"
    ]);
    exit;
}

// ❌ NO PASSWORD HASHING (as requested)
$plainPassword = $password;

// INSERT USER
$stmt = $conn->prepare(
    "INSERT INTO users (role, username, email, phone, password)
     VALUES (?, ?, ?, ?, ?)"
);

$stmt->bind_param(
    "sssss",
    $role,
    $username,
    $email,
    $phone,
    $plainPassword
);

if ($stmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Signup successful"
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Signup failed"
    ]);
}

$stmt->close();
$conn->close();
?>