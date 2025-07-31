<?php
header('Content-Type: application/json');
$conn = new mysqli("localhost", "root", "", "liyag_batangan");

if (!$conn) {
    echo json_encode(["status" => "error", "message" => "Database connection failed."]);
    exit;
}

$phone = $_POST['phone'] ?? '';
$newPassword = $_POST['new_password'] ?? '';

if (empty($phone) || empty($newPassword)) {
    echo json_encode(["status" => "error", "message" => "Phone and new password are required."]);
    exit;
}

// Hash the new password (highly recommended)
$hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);

$stmt = $conn->prepare("UPDATE users SET password = ? WHERE phone_number = ?");
$stmt->bind_param("ss", $hashedPassword, $phone);
$stmt->execute();

if ($stmt->affected_rows > 0) {
    echo json_encode(["status" => "success", "message" => "Password updated successfully."]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to update password."]);
}

$stmt->close();
$conn->close();
?>
