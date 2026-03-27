<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

include("config.php");

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

// READ email from GET
$email = $_GET['email'] ?? '';

if (empty($email)) {
    echo json_encode([
        "status" => false,
        "message" => "Email is required"
    ]);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        "status" => false,
        "message" => "Invalid email format"
    ]);
    exit;
}

// PREPARED STATEMENT
$stmt = $conn->prepare(
    "SELECT username, email, phone, profile_image 
     FROM users 
     WHERE email = ?"
);

$stmt->bind_param("s", $email);
$stmt->execute();

$result = $stmt->get_result();

if ($result && $result->num_rows === 1) {
    $user = $result->fetch_assoc();
    echo json_encode([
        "status" => true,
        "data" => $user
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "User not found"
    ]);
}

$stmt->close();
$conn->close();
?>