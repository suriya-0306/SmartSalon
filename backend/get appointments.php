<?php
// SHOW ERRORS (DEV ONLY)
ini_set('display_errors', 1);
error_reporting(E_ALL);

// HEADERS
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

// DB CONNECTION
require_once __DIR__ . "/config.php";

// ONLY GET
if ($_SERVER["REQUEST_METHOD"] !== "GET") {
    echo json_encode([
        "status" => false,
        "message" => "Only GET method allowed"
    ]);
    exit;
}

// ✅ FETCH ALL APPOINTMENTS (ADMIN DASHBOARD)
$sql = "
SELECT 
    a.id,
    a.user_email,
    u.username AS customer_name,
    a.service,
    a.appointment_date,
    a.appointment_time,
    a.hairstyle_image,
    a.address,
    a.status,
    a.payment_option,
    a.created_at
FROM appointments a
JOIN users u ON u.email = a.user_email
ORDER BY a.created_at DESC
";

$result = $conn->query($sql);

if (!$result) {
    echo json_encode([
        "status" => false,
        "message" => "Query failed",
        "error" => $conn->error
    ]);
    exit;
}

$appointments = [];

while ($row = $result->fetch_assoc()) {
    $appointments[] = $row;
}

echo json_encode([
    "status" => true,
    "appointments" => $appointments
]);

$conn->close();
?>