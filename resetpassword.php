<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

include("config.php");

// DB CONNECTION
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
        "message" => "Invalid request method"
    ]);
    exit;
}

// READ FORM DATA
$username = $_POST['username'] ?? '';
$phone    = $_POST['phone'] ?? '';

// VALIDATION
if (empty($username) || empty($phone)) {
    echo json_encode([
        "status" => false,
        "message" => "All fields are required"
    ]);
    exit;
}

// CHECK USER
$stmt = $conn->prepare(
    "SELECT id FROM users WHERE username = ? AND phone = ?"
);
$stmt->bind_param("ss", $username, $phone);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    echo json_encode([
        "status" => true,
        "message" => "User verified"
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Invalid username or phone"
    ]);
}

$stmt->close();
$conn->close();
?>
