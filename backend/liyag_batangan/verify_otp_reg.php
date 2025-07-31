<?php
header('Content-Type: application/json');

$conn = new mysqli("localhost", "root", "", "liyag_batangan");
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed."]);
    exit;
}

$email = $_POST['email'] ?? '';
$otp = $_POST['otp'] ?? '';

if (empty($email) || empty($otp)) {
    echo json_encode(["status" => "error", "message" => "Email and OTP are required."]);
    exit;
}

// Check OTP from email_verification table
$stmt = $conn->prepare("SELECT otp_code, otp_expiry FROM email_verification WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "No OTP found. Please request again."]);
    exit;
}

$row = $result->fetch_assoc();

$currentTime = date('Y-m-d H:i:s');
if ($otp !== $row['otp_code']) {
    echo json_encode(["status" => "error", "message" => "Incorrect OTP."]);
} else if ($currentTime > $row['otp_expiry']) {
    echo json_encode(["status" => "error", "message" => "OTP has expired."]);
} else {
    echo json_encode(["status" => "success", "message" => "OTP verified."]);
}

$stmt->close();
$conn->close();
?>
