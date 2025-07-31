<?php
header('Content-Type: application/json');

// Database connection
$conn = new mysqli("localhost", "root", "", "liyag_batangan");
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed."]);
    exit;
}

// Get phone from POST
$phone = $_POST['phone'] ?? '';
if (empty($phone)) {
    echo json_encode(["status" => "error", "message" => "Phone number is required."]);
    exit;
}

// Validate PH number format
if (!preg_match('/^09\d{9}$/', $phone)) {
    echo json_encode(["status" => "error", "message" => "Invalid Philippine phone number format."]);
    exit;
}

// Check if phone exists
$stmt = $conn->prepare("SELECT * FROM users WHERE phone_number = ?");
$stmt->bind_param("s", $phone);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "Phone number not found."]);
} else {
    // Generate OTP
    $otp = rand(100000, 999999);

    // iTexMo API v2 config
    $url = "https://api.itexmo.com/api/v2/SMS";
    $data = [
        "ApiCode"    => "PR-SAMPL123456_ABCDE",      // 🔁 Your real API code
        "ClientId"   => "QWE456",                    // 🔁 Your Client ID
        "Email"      => "test@email.com",            // 🔁 Your email
        "Password"   => "password",                  // 🔁 Your password
        "SenderId"   => "IMT.TEXT3",                 // Optional (will use ITEXMO SMS by default)
        "Recipients" => [$phone],
        "Message"    => "Your LIYAG BATANGAN OTP code is $otp. It will expire in 5 minutes."
    ];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    $response = curl_exec($ch);
    curl_close($ch);

    $decoded = json_decode($response, true);

    if (isset($decoded['Status']) && $decoded['Status'] === 'Success') {
        echo json_encode([
            "status" => "success",
            "message" => "OTP sent successfully.",
            "otp" => $otp // ⚠️ FOR DEVELOPMENT ONLY — REMOVE IN PRODUCTION
        ]);
    } else {
        $error = $decoded['ErrorMessage'] ?? 'Unknown error.';
        echo json_encode([
            "status" => "error",
            "message" => "Failed to send OTP. iTexMo: $error"
        ]);
    }
}

$stmt->close();
$conn->close();
?>
