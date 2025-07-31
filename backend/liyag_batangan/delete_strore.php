<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$conn = new mysqli("localhost", "root", "", "liyag_batangan");

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed."]));
}

$user_id = $_POST['user_id'];

// Delete from vendor_account table
$conn->query("DELETE FROM vendor_account WHERE user_id = '$user_id'");

// Change user_type to 'user'
$conn->query("UPDATE users SET user_type = 'user' WHERE user_id = '$user_id'");

echo json_encode(["status" => "success"]);
$conn->close();
?>
