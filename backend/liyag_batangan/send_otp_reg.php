<?php
header('Content-Type: application/json');
require 'vendor/autoload.php'; // Composer autoload

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

$conn = new mysqli("localhost", "root", "", "liyag_batangan");
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed."]);
    exit;
}

$email = $_POST['email'] ?? '';
$otp = $_POST['otp'] ?? '';

if (empty($email) || empty($otp)) {
    echo json_encode(["status" => "error", "message" => "Email and OTP are required."]);
    exit;
}

// Store OTP and expiry in a separate table
$expiry = date('Y-m-d H:i:s', strtotime('+5 minutes'));
$conn->query("CREATE TABLE IF NOT EXISTS email_verification (
    email VARCHAR(255) PRIMARY KEY,
    otp_code VARCHAR(6),
    otp_expiry DATETIME
)");

$saveOtp = $conn->prepare("REPLACE INTO email_verification (email, otp_code, otp_expiry) VALUES (?, ?, ?)");
$saveOtp->bind_param("sss", $email, $otp, $expiry);
$saveOtp->execute();

// Send OTP
$mail = new PHPMailer(true);
try {
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;
    $mail->Username = 'liyagbatangan@gmail.com';
    $mail->Password = 'vznb rthw hyex owwt';
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = 587;

    $mail->SMTPOptions = [
        'ssl' => [
            'verify_peer' => false,
            'verify_peer_name' => false,
            'allow_self_signed' => true,
        ]
    ];

    $mail->setFrom('liyagbatangan@gmail.com', 'Liyag Batangan');
    $mail->addAddress($email);
    $mail->isHTML(true);
    $mail->Subject = 'Your LIYAG BATANGAN REGISTRATION OTP Code';
    $mail->Body = "Your OTP code is: <strong>$otp</strong><br>This code will expire in 5 minutes.";

    $mail->send();

    echo json_encode(["status" => "success", "message" => "OTP sent to your email."]);
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => "Mail Error: {$mail->ErrorInfo}"]);
}

$saveOtp->close();
$conn->close();
?>
