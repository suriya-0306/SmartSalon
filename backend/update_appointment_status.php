<?php
header("Content-Type: application/json");
require_once "config.php";

$id     = $_POST['id'] ?? '';
$status = $_POST['status'] ?? '';

if (empty($id) || empty($status)) {
    echo json_encode([
        "status" => false,
        "message" => "id and status are required"
    ]);
    exit;
}

// CHECK CURRENT STATUS
$stmt = $conn->prepare("SELECT status FROM appointments WHERE id = ?");
$stmt->bind_param("i", $id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        "status" => false,
        "message" => "Appointment not found"
    ]);
    exit;
}

$row = $result->fetch_assoc();

if ($row['status'] === "Completed") {
    echo json_encode([
        "status" => false,
        "message" => "Appointment already completed"
    ]);
    exit;
}

// UPDATE STATUS
$update = $conn->prepare(
    "UPDATE appointments SET status = ? WHERE id = ?"
);
$update->bind_param("si", $status, $id);

if ($update->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Status updated successfully"
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Failed to update status"
    ]);
}