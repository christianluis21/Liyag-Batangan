<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Database connection
$conn = new mysqli("localhost", "root", "", "liyag_batangan");
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed."]));
}

// Get and sanitize notification_id
$notification_id = intval($_POST['notification_id'] ?? 0);

if ($notification_id === 0) {
    echo json_encode(["status" => "error", "message" => "Missing or invalid notification_id."]);
    exit;
}

// Delete notification
$stmt = $conn->prepare("DELETE FROM notifications WHERE notification_id = ?");
$stmt->bind_param("i", $notification_id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Notification deleted."]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to delete notification."]);
}

$stmt->close();
$conn->close();
?>
