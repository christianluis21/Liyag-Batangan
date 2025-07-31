<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conn = new mysqli("localhost", "root", "", "liyag_batangan");

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';

    if (!$email || !$password) {
        echo json_encode(["status" => "error", "message" => "Missing fields"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $res = $stmt->get_result();

    if ($res->num_rows > 0) {
        $user = $res->fetch_assoc();

        // ✅ Hash the provided password with SHA256 for comparison
        $hashedPasswordAttempt = hash('sha256', $password);

        // ✅ Compare the SHA256 hashed password with the one from the database
        if ($hashedPasswordAttempt === $user['password']) { // Note: $user['password'] would store the SHA256 hash
            echo json_encode([
                "status" => "success",
                "message" => "Login successful",
                "user" => [
                    "user_id" => $user['user_id'],
                    "name" => $user['name'],
                    "email" => $user['email'],
                    "phone_number" => $user['phone_number'],
                    "address" => $user['address'],
                    "profile_picture" => $user['profile_picture'],
                    "user_type" => $user['user_type']
                ]
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Incorrect password"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "User not found"]);
    }

    $stmt->close();
    $conn->close();
}
?>