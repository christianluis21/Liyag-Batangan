<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

$host = 'localhost';
$user = 'root';
$password = '';
$database = 'liyag_batangan';

$conn = new mysqli($host, $user, $password, $database);

// Handle DB connection error
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

$user_id = $_POST['user_id'] ?? '';
$name = $_POST['name'] ?? '';
$email = $_POST['email'] ?? '';
$phone = $_POST['phone_number'] ?? '';
$address = $_POST['address'] ?? '';

if (!$user_id || !$name || !$email) {
    echo json_encode(["status" => "error", "message" => "Missing required fields"]);
    exit;
}

$profilePicPath = null;

// Handle file upload
if (isset($_FILES['profile_pic']) && $_FILES['profile_pic']['error'] === UPLOAD_ERR_OK) {
    $uploadDir = 'uploads/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $ext = pathinfo($_FILES['profile_pic']['name'], PATHINFO_EXTENSION);
    $filename = 'profile_' . time() . '_' . rand(1000, 9999) . '.' . $ext;
    $filePath = $uploadDir . $filename;

    if (move_uploaded_file($_FILES['profile_pic']['tmp_name'], $filePath)) {
        $profilePicPath = $conn->real_escape_string($filename); // ✅ Only save filename
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to upload image"]);
        exit;
    }
}

// Build SQL query
$sql = "UPDATE users SET 
        name = ?, 
        email = ?, 
        phone_number = ?, 
        address = ?";

if ($profilePicPath) {
    $sql .= ", profile_picture = ?";
}

$sql .= " WHERE user_id = ?";

$stmt = $conn->prepare($sql);
if ($profilePicPath) {
    $stmt->bind_param("sssssi", $name, $email, $phone, $address, $profilePicPath, $user_id);
} else {
    $stmt->bind_param("ssssi", $name, $email, $phone, $address, $user_id);
}

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Profile updated",
        "profile_picture" => $profilePicPath // ✅ Send filename to Flutter
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Update failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
