<?php
header("Content-Type: application/json");
require_once "config.php";

$email = $_POST['email'] ?? '';
$service = $_POST['service'] ?? '';
$date = $_POST['appointment_date'] ?? '';
$time = $_POST['appointment_time'] ?? '';

if (empty($email) || empty($service) || empty($date) || empty($time)) {
    echo json_encode([
        "status" => false,
        "message" => "All fields are required"
    ]);
    exit;
}

$stmt = $conn->prepare(
    "UPDATE appointments
     SET status = 'Cancelled'
     WHERE user_email = ?
       AND service = ?
       AND appointment_date = ?
       AND appointment_time = ?"
);

$stmt->bind_param("ssss", $email, $service, $date, $time);

if ($stmt->execute() && $stmt->affected_rows > 0) {
    echo json_encode([
        "status" => true,
        "message" => "Appointment cancelled successfully"
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Appointment not found or already cancelled"
    ]);
}