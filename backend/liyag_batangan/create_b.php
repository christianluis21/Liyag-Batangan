<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

// Database connection details
$servername = "localhost";
$username = "root"; // Replace with your database username
$password = "";     // Replace with your database password
$dbname = "liyag_batangan"; // Replace with your database name

// Create database connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Collect form data
    $user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
    $business_name = isset($_POST['business_name']) ? $conn->real_escape_string($_POST['business_name']) : '';
    $description = isset($_POST['description']) ? $conn->real_escape_string($_POST['description']) : '';
    $status = isset($_POST['status']) ? $conn->real_escape_string($_POST['status']) : 'Pending';
    $business_address = isset($_POST['business_address']) ? $conn->real_escape_string($_POST['business_address']) : '';

    // Validate essential fields (registration_date is now handled by DB, so remove from this check)
    if (empty($user_id) || empty($business_name) || empty($description) || empty($business_address)) {
        echo json_encode(["status" => "error", "message" => "Missing required fields."]);
        $conn->close();
        exit();
    }

    // Handle business logo upload
    $business_logo_path = null;
    if (isset($_FILES['business_logo']) && $_FILES['business_logo']['error'] == UPLOAD_ERR_OK) {
        $logo_tmp_name = $_FILES['business_logo']['tmp_name'];
        $logo_name = basename($_FILES['business_logo']['name']);
        $logo_upload_dir = 'uploads/business_logos/'; // Directory to save logos (create if not exists)
        
        // Ensure upload directory exists
        if (!is_dir($logo_upload_dir)) {
            mkdir($logo_upload_dir, 0777, true);
        }

        $logo_target_file = $logo_upload_dir . uniqid() . '_' . $logo_name; // Unique filename to prevent overwrites
        
        if (move_uploaded_file($logo_tmp_name, $logo_target_file)) {
            $business_logo_path = $conn->real_escape_string($logo_target_file);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to upload business logo."]);
            $conn->close();
            exit();
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Business logo not provided or upload error."]);
        $conn->close();
        exit();
    }

    // Handle document upload (PDF only)
    $document_path = null;
    if (isset($_FILES['document']) && $_FILES['document']['error'] == UPLOAD_ERR_OK) {
        $doc_tmp_name = $_FILES['document']['tmp_name'];
        $doc_name = basename($_FILES['document']['name']);
        $doc_file_type = strtolower(pathinfo($doc_name, PATHINFO_EXTENSION));

        // Check if the file is a PDF
        if ($doc_file_type != "pdf") {
            echo json_encode(["status" => "error", "message" => "Only PDF documents are allowed."]);
            $conn->close();
            exit();
        }
        
        $document_upload_dir = 'uploads/documents/'; // Directory to save documents (create if not exists)

        // Ensure upload directory exists
        if (!is_dir($document_upload_dir)) {
            mkdir($document_upload_dir, 0777, true);
        }

        $doc_target_file = $document_upload_dir . uniqid() . '_' . $doc_name; // Unique filename

        if (move_uploaded_file($doc_tmp_name, $doc_target_file)) {
            $document_path = $conn->real_escape_string($doc_target_file);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to upload document."]);
            $conn->close();
            exit();
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Business document not provided or upload error."]);
        $conn->close();
        exit();
    }

    // Prepare and execute the SQL statement to insert business data
    // Removed registration_date from the column list and the bind_param
    $stmt = $conn->prepare("INSERT INTO businesses (user_id, business_name, description, business_logo, document, status, business_address) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("issssss", $user_id, $business_name, $description, $business_logo_path, $document_path, $status, $business_address);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Business submitted successfully!"]);
    } else {
        // If there's a database error, clean up uploaded files
        if ($business_logo_path && file_exists($business_logo_path)) {
            unlink($business_logo_path);
        }
        if ($document_path && file_exists($document_path)) {
            unlink($document_path);
        }
        echo json_encode(["status" => "error", "message" => "Error: " . $stmt->error]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
?>