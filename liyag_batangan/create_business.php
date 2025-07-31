<?php
// Enable error reporting (for debugging)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Log PHP errors to a separate file
ini_set("log_errors", 1);
ini_set("error_log", __DIR__ . "/php-error.log");

// Set headers for CORS and JSON
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Define a log file for general operations
$logFile = __DIR__ . "/logs.txt";
function writeLog($message) {
    global $logFile;
    $timestamp = date("Y-m-d H:i:s");
    file_put_contents($logFile, "[$timestamp] $message\n", FILE_APPEND);
}

// Database config
$host = "localhost";
$user = "root";
$password = "";
$database = "liyag_batangan";

// Connect to database
$conn = new mysqli($host, $user, $password, $database);
if ($conn->connect_error) {
    $errMsg = "Database connection failed: " . $conn->connect_error;
    writeLog($errMsg);
    echo json_encode(["status" => "error", "message" => $errMsg]);
    exit;
}
writeLog("Connected to database successfully.");

// Create directories if not exist
$uploadDirLogo = "uploads/business_logos/";
$uploadDirDocs = "uploads/business_documents/";

if (!is_dir($uploadDirLogo)) {
    mkdir($uploadDirLogo, 0777, true);
    writeLog("Created directory: $uploadDirLogo");
}
if (!is_dir($uploadDirDocs)) {
    mkdir($uploadDirDocs, 0777, true);
    writeLog("Created directory: $uploadDirDocs");
}

// Log incoming data
writeLog("POST data: " . print_r($_POST, true));
writeLog("FILES data: " . print_r($_FILES, true));

// Validate required POST fields
$requiredFields = ['user_id', 'business_name', 'business_description', 'business_address', 'status'];
foreach ($requiredFields as $field) {
    if (!isset($_POST[$field])) {
        $errMsg = "Missing required field: $field";
        writeLog($errMsg);
        echo json_encode(["status" => "error", "message" => $errMsg]);
        exit;
    }
}
if (!isset($_FILES['business_logo']) || !isset($_FILES['document'])) {
    $errMsg = "Missing file(s): logo or document";
    writeLog($errMsg);
    echo json_encode(["status" => "error", "message" => $errMsg]);
    exit;
}

// Sanitize inputs
$user_id = intval($_POST['user_id']);
$business_name = $conn->real_escape_string($_POST['business_name']);
$business_description = $conn->real_escape_string($_POST['business_description']);
$business_address = $conn->real_escape_string($_POST['business_address']);
$status = $conn->real_escape_string($_POST['status']);

// Prepare file names and move
$logoName = uniqid() . "_" . basename($_FILES["business_logo"]["name"]);
$docName = uniqid() . "_" . basename($_FILES["document"]["name"]);
$logoPath = $uploadDirLogo . $logoName;
$docPath = $uploadDirDocs . $docName;

writeLog("Uploading files...");
$logoUploaded = move_uploaded_file($_FILES["business_logo"]["tmp_name"], $logoPath);
$docUploaded = move_uploaded_file($_FILES["document"]["tmp_name"], $docPath);
writeLog("Logo upload: " . ($logoUploaded ? "Success" : "Failed"));
writeLog("Document upload: " . ($docUploaded ? "Success" : "Failed"));

if ($logoUploaded && $docUploaded) {
    // Insert into vendor_account
    $stmt = $conn->prepare("INSERT INTO vendor_account (
        user_id, business_name, business_description, business_address, logo_url, verification_document, status
    ) VALUES (?, ?, ?, ?, ?, ?, ?)");

    if (!$stmt) {
        $errMsg = "Prepare failed: " . $conn->error;
        writeLog($errMsg);
        echo json_encode(["status" => "error", "message" => $errMsg]);
        exit;
    }

    $stmt->bind_param("issssss", 
        $user_id, $business_name, $business_description, $business_address, 
        $logoPath, $docPath, $status
    );

    if ($stmt->execute()) {
        writeLog("Inserted vendor_account for user_id: $user_id");

        // Add notification
        $title = "🛍️ Business Submission Received";
        $message = "Thank you for submitting \"$business_name\". Your business is under review.";

        $notif = $conn->prepare("INSERT INTO notifications (user_id, title, message) VALUES (?, ?, ?)");
        if ($notif) {
            $notif->bind_param("iss", $user_id, $title, $message);
            $notif->execute();
            $notif->close();
            writeLog("Notification sent to user_id: $user_id");
        } else {
            writeLog("Failed to prepare notification insert: " . $conn->error);
        }

        echo json_encode([
            "status" => "success",
            "message" => "Business submitted successfully and notification sent"
        ]);
    } else {
        $errMsg = "Database insert failed: " . $stmt->error;
        writeLog($errMsg);
        echo json_encode([
            "status" => "error",
            "message" => $errMsg
        ]);
    }

    $stmt->close();
} else {
    $errMsg = "File upload failed";
    writeLog($errMsg);
    echo json_encode([
        "status" => "error",
        "message" => $errMsg
    ]);
}

$conn->close();
writeLog("Connection closed.");
?>
