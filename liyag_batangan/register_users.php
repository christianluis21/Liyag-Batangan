<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: text/plain"); // Ensure plain response for Flutter

$conn = new mysqli("localhost", "root", "", "liyag_batangan");

if ($conn->connect_error) {
    echo "error: Database connection failed.";
    exit;
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $phone = $_POST['phone'] ?? '';
    $address = $_POST['address'] ?? '';

    if (!$email || !$password || !$name) {
        echo "error: Missing required fields.";
        exit;
    }

    // ✅ Check if email already exists
    $check = $conn->prepare("SELECT user_id FROM users WHERE email = ?");
    $check->bind_param("s", $email);
    $check->execute();
    $check->store_result();

    if ($check->num_rows > 0) {
        echo "email_exists";
        $check->close();
        $conn->close();
        exit;
    }
    $check->close();

    // Changed to SHA256 hashing
    $hashedPassword = hash('sha256', $password);

    $stmt = $conn->prepare("INSERT INTO users (name, email, password, phone_number, address) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("sssss", $name, $email, $hashedPassword, $phone, $address);

    if ($stmt->execute()) {
        $user_id = $conn->insert_id;

        // Welcome notification
        $title = "Welcome to Liyag Batangan!";
        $message = "Thank you for registering! Start exploring local delicacies and offers today.";
        $notifStmt = $conn->prepare("INSERT INTO notifications (user_id, title, message) VALUES (?, ?, ?)");
        $notifStmt->bind_param("iss", $user_id, $title, $message);
        $notifStmt->execute();
        $notifStmt->close();

        echo "success";
    } else {
        echo "error: " . $stmt->error;
    }

    $stmt->close();
    $conn->close();
}
?>