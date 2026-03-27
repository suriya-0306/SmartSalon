post_appointments.php → backend/post_appointments.php
<?php
// SHOW ERRORS (TURN OFF IN PRODUCTION)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// HEADERS
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// DB CONNECTION
require_once __DIR__ . "/config.php";

// ONLY POST
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    echo json_encode([
        "status" => false,
        "message" => "Only POST method allowed"
    ]);
    exit;
}

// READ JSON / FORM DATA
$input = json_decode(file_get_contents("php://input"), true);

$user_email        = $input['user_email']        ?? $_POST['user_email']        ?? '';
$service           = $input['service']           ?? $_POST['service']           ?? '';
$appointment_date  = $input['appointment_date']  ?? $_POST['appointment_date']  ?? '';
$appointment_time  = $input['appointment_time']  ?? $_POST['appointment_time']  ?? '';
$hairstyle_image   = $input['hairstyle_image']   ?? $_POST['hairstyle_image']   ?? null;
$address           = $input['address']           ?? $_POST['address']           ?? '';
$payment_option    = $input['payment_option']    ?? $_POST['payment_option']    ?? null;

// VALIDATION
if (
    empty($user_email) ||
    empty($service) ||
    empty($appointment_date) ||
    empty($appointment_time) ||
    empty($address)
) {
    echo json_encode([
        "status" => false,
        "message" => "Required fields are missing"
    ]);
    exit;
}

if (!filter_var($user_email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        "status" => false,
        "message" => "Invalid email format"
    ]);
    exit;
}

// SQL INSERT
$sql = "
    INSERT INTO appointments (
        user_email,
        service,
        appointment_date,
        appointment_time,
        hairstyle_image,
        address,
        payment_option,
        status
    ) VALUES (?, ?, ?, ?, ?, ?, ?, 'Upcoming')
";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode([
        "status" => false,
        "message" => "SQL prepare failed",
        "error" => $conn->error
    ]);
    exit;
}

// BIND PARAMS
$stmt->bind_param(
    "sssssss",
    $user_email,
    $service,
    $appointment_date,
    $appointment_time,
    $hairstyle_image,
    $address,
    $payment_option
);

// EXECUTE
if ($stmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Appointment booked successfully",
        "appointment_id" => $stmt->insert_id
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Failed to book appointment",
        "error" => $stmt->error
    ]);
}

// CLOSE
$stmt->close();
$conn->close();
?>