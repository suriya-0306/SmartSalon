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

// ONLY POST REQUEST
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    echo json_encode([
        "status" => false,
        "message" => "Invalid request method"
    ]);
    exit;
}

// READ FORM DATA
$email    = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';
$role     = $_POST['role'] ?? '';

// VALIDATION
if (empty($email) || empty($password) || empty($role)) {
    echo json_encode([
        "status" => false,
        "message" => "All fields are required"
    ]);
    exit;
}

// ✅ FETCH USER INCLUDING USERNAME
$stmt = $conn->prepare(
    "SELECT id, username, password, role 
     FROM users 
     WHERE email = ? AND role = ?"
);
$stmt->bind_param("ss", $email, $role);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        "status" => false,
        "message" => "Invalid email or role"
    ]);
    exit;
}

$user = $result->fetch_assoc();

// ✅ PASSWORD CHECK (PLAIN TEXT – AS PER YOUR DB)
if ($password === $user['password']) {

    // ✅ RETURN USERNAME
    echo json_encode([
        "status"   => true,
        "message"  => "Login successful",
        "user_id"  => $user['id'],
        "username" => $user['username'],   // 🔥 IMPORTANT
        "role"     => $user['role']
    ]);

} else {
    echo json_encode([
        "status" => false,
        "message" => "Incorrect password"
    ]);
}

$stmt->close();
$conn->close();
?>
