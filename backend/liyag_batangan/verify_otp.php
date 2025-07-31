<?php
header('Content-Type: application/json');
$conn = new mysqli("localhost", "root", "", "liyag_batangan");

$email = $_POST['email'] ?? '';
$otp = $_POST['otp'] ?? '';

if (empty($email) || empty($otp)) {
    echo json_encode(["status" => "error", "message" => "Email and OTP required."]);
    exit;
}

$query = $conn->prepare("SELECT otp_code, otp_expiry FROM users WHERE email = ?");
$query->bind_param("s", $email);
$query->execute();
$result = $query->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "Invalid email."]);
    exit;
}

$row = $result->fetch_assoc();
$current_time = date('Y-m-d H:i:s');

if ($row['otp_code'] === $otp && $current_time < $row['otp_expiry']) {
    echo json_encode(["status" => "success", "message" => "OTP verified."]);
} else {
    echo json_encode(["status" => "error", "message" => "Invalid or expired OTP."]);
}

$conn->close();
?>
