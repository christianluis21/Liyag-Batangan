<?php
header('Content-Type: application/json');
$conn = new mysqli("localhost", "root", "", "liyag_batangan");

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}

$email = $_POST['email'] ?? '';
$new_password = $_POST['new_password'] ?? '';

if (empty($email) || empty($new_password)) {
    echo json_encode(["status" => "error", "message" => "Missing parameters"]);
    exit;
}

// Changed to SHA256 hashing
$hashed_password = hash('sha256', $new_password);

$stmt = $conn->prepare("UPDATE users SET password = ? WHERE email = ?");
$stmt->bind_param("ss", $hashed_password, $email);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Password updated"]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to update password"]);
}

$stmt->close();
$conn->close();
?>