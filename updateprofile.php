<?php
// SHOW ERRORS (dev only)
ini_set('display_errors', 1);
error_reporting(E_ALL);

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// INCLUDE DB CONFIG
include("config.php");

// READ email
$email = $_POST['email'] ?? '';

if (empty($email)) {
    echo json_encode([
        "status" => false,
        "message" => "Email required"
    ]);
    exit;
}

// VALIDATE EMAIL
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        "status" => false,
        "message" => "Invalid email"
    ]);
    exit;
}

// CHECK IMAGE
if (!isset($_FILES['profile_image']) || $_FILES['profile_image']['error'] !== 0) {
    echo json_encode([
        "status" => false,
        "message" => "Image required",
        "debug" => $_FILES
    ]);
    exit;
}

// UPLOAD PATH
$targetDir = "uploads/profile_images/";
if (!is_dir($targetDir)) {
    mkdir($targetDir, 0777, true);
}

$fileName = time() . "_" . basename($_FILES["profile_image"]["name"]);
$targetFile = $targetDir . $fileName;

// MOVE
if (!move_uploaded_file($_FILES["profile_image"]["tmp_name"], $targetFile)) {
    echo json_encode([
        "status" => false,
        "message" => "Upload failed"
    ]);
    exit;
}

// UPDATE DB
$stmt = $conn->prepare(
    "UPDATE users SET profile_image = ? WHERE email = ?"
);
$stmt->bind_param("ss", $targetFile, $email);
$stmt->execute();

echo json_encode([
    "status" => true,
    "image_url" => $targetFile
]);

$stmt->close();
$conn->close();
?>
