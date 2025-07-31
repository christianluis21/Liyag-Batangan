<?php
header('Content-Type: application/json');
require 'vendor/autoload.php'; // Composer autoload

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// DB connection
$conn = new mysqli("localhost", "root", "", "liyag_batangan");
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed."]);
    exit;
}

// Get email from POST-
$email = $_POST['email'] ?? '';
if (empty($email)) {
    echo json_encode(["status" => "error", "message" => "Email is required."]);
    exit;
}

// Check if user exists
$stmt = $conn->prepare("SELECT * FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "Email not found."]);
    exit;
}

// Generate OTP and expiry
$otp = rand(100000, 999999);
$otp_expiry = date('Y-m-d H:i:s', strtotime('+5 minutes'));

// Save OTP and expiry to DB
$update = $conn->prepare("UPDATE users SET otp_code = ?, otp_expiry = ? WHERE email = ?");
$update->bind_param("sss", $otp, $otp_expiry, $email);
if (!$update->execute()) {
    echo json_encode(["status" => "error", "message" => "Failed to store OTP."]);
    exit;
}

// Send email using PHPMailer
$mail = new PHPMailer(true);
try {
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;
    $mail->Username = 'liyagbatangan@gmail.com'; // Your Gmail
    $mail->Password = 'vznb rthw hyex owwt';     // App password
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = 587;

    // SSL options (if needed to avoid cert error)
    $mail->SMTPOptions = [
        'ssl' => [
            'verify_peer' => false,
            'verify_peer_name' => false,
            'allow_self_signed' => true,
        ]
    ];

    $mail->setFrom('liyagbatangan@gmail.com', 'Liyag Batangan');
    $mail->addAddress($email);
    $mail->isHTML(true); // <-- Important to enable HTML content
    $mail->Subject = 'Your LIYAG BATANGAN OTP Code';
    $mail->Body = "Your OTP code is: <strong>$otp</strong><br>This code will expire in 5 minutes.";

    $mail->send();

    echo json_encode([
        "status" => "success",
        "message" => "OTP sent to your email.",
    ]);
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => "Mail Error: {$mail->ErrorInfo}"]);
}

$stmt->close();
$update->close();
$conn->close();
?>
