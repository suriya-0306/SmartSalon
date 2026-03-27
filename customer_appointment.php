customer_appointment.php → backend/customer_appointment.php
<?php
header("Content-Type: application/json");
require_once "config.php";

$email = $_GET['email'] ?? '';

if (empty($email)) {
    echo json_encode([
        "status" => false,
        "message" => "Email is required"
    ]);
    exit;
}

$stmt = $conn->prepare(
    "SELECT service, appointment_date, appointment_time, status
     FROM appointments
     WHERE user_email = ?
     ORDER BY appointment_date DESC, appointment_time DESC"
);

$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

$appointments = [];

while ($row = $result->fetch_assoc()) {
    $appointments[] = $row;
}

echo json_encode([
    "status" => true,
    "appointments" => $appointments
]);
