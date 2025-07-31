<?php
// Enable error reporting
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Error logging
ini_set("log_errors", 1);
ini_set("error_log", __DIR__ . "/php-error.log");

// CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Logging function
$logFile = __DIR__ . "/logs.txt";
function writeLog($message) {
    global $logFile;
    $timestamp = date("Y-m-d H:i:s");
    file_put_contents($logFile, "[$timestamp] $message\n", FILE_APPEND);
}

// Database connection
$host = "localhost";
$user = "root";
$password = "";
$database = "liyag_batangan";

$conn = new mysqli($host, $user, $password, $database);
if ($conn->connect_error) {
    writeLog("Database connection failed: " . $conn->connect_error);
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}
writeLog("Connected to database successfully.");

// Create directories
$uploadDirLogo = "uploads/business_logos/";
$uploadDirDocs = "uploads/business_documents/";

if (!is_dir($uploadDirLogo)) mkdir($uploadDirLogo, 0777, true);
if (!is_dir($uploadDirDocs)) mkdir($uploadDirDocs, 0777, true);

// Log POST/FILES
writeLog("POST data: " . print_r($_POST, true));
writeLog("FILES data: " . print_r($_FILES, true));

// Sanitize inputs with fallback defaults
$user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
$business_name = isset($_POST['business_name']) ? $conn->real_escape_string($_POST['business_name']) : "Untitled Business";
$business_description = isset($_POST['business_description']) ? $conn->real_escape_string($_POST['business_description']) : "";
$business_address = isset($_POST['business_address']) ? $conn->real_escape_string($_POST['business_address']) : "";


// File uploads
$logoPath = "";
$docPath = "";

if (isset($_FILES["business_logo"]) && $_FILES["business_logo"]["error"] == 0) {
    $logoName = uniqid() . "_" . basename($_FILES["business_logo"]["name"]);
    $logoPath = $uploadDirLogo . $logoName;
    if (move_uploaded_file($_FILES["business_logo"]["tmp_name"], $logoPath)) {
        writeLog("Logo upload: Success");
    } else {
        writeLog("Logo upload: Failed");
        $logoPath = "";
    }
} else {
    writeLog("Logo upload: Skipped");
}

if (isset($_FILES["document"]) && $_FILES["document"]["error"] == 0) {
    $docName = uniqid() . "_" . basename($_FILES["document"]["name"]);
    $docPath = $uploadDirDocs . $docName;
    if (move_uploaded_file($_FILES["document"]["tmp_name"], $docPath)) {
        writeLog("Document upload: Success");
    } else {
        writeLog("Document upload: Failed");
        $docPath = "";
    }
} else {
    writeLog("Document upload: Skipped");
}

// Insert into vendor_account
$stmt = $conn->prepare("INSERT INTO vendor_account (
    user_id, business_name, business_description, business_address, logo_url, verification_document
) VALUES (?, ?, ?, ?, ?, ?)");

if (!$stmt) {
    writeLog("Prepare failed: " . $conn->error);
    echo json_encode(["status" => "error", "message" => "Statement preparation failed"]);
    exit;

    
}

if (!$stmt->bind_param("isssss", 
    $user_id, $business_name, $business_description, $business_address, 
    $logoPath, $docPath
)) {
    writeLog("Bind param failed: " . $stmt->error);
    echo json_encode(["status" => "error", "message" => "Parameter binding failed"]);
    $stmt->close();
    $conn->close();
    exit;
}

if ($stmt->execute()) {
    writeLog("Inserted vendor_account for user_id: $user_id");

    // Send notification
    $title = "🛍️ Business Submission Received";
    $message = "Thank you for submitting \"$business_name\". Your business is under review.";

    $notif = $conn->prepare("INSERT INTO notifications (user_id, title, message) VALUES (?, ?, ?)");
    if ($notif) {
        $notif->bind_param("iss", $user_id, $title, $message);
        $notif->execute();
        $notif->close();
        writeLog("Notification sent to user_id: $user_id");
    } else {
        writeLog("Notification prepare failed: " . $conn->error);
    }

    echo json_encode([
        "status" => "success",
        "message" => "Business submitted successfully"
    ]);
} else {
    writeLog("Database insert failed: " . $stmt->error);
    echo json_encode(["status" => "error", "message" => "Database insert failed"]);
}

$stmt->close();
$conn->close();
writeLog("Connection closed.");
?>
