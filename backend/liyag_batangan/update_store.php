<?php
// Set headers for CORS and JSON handling
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json"); // Ensure JSON response

// Database configuration
$host = "localhost";
$user = "root";
$password = "";
$database = "liyag_batangan";

// Create database connection
$conn = new mysqli($host, $user, $password, $database);
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed: " . $conn->connect_error]));
}

// Define upload directory for logos
$uploadDirLogo = "uploads/business_logos/";

// Ensure upload directory exists
if (!is_dir($uploadDirLogo)) {
    mkdir($uploadDirLogo, 0777, true);
}

// Check if it's a POST request
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Validate required POST fields for updating
    // We expect vendor_id, business_name, and business_address
    // logo_image is optional for update
    if (!isset($_POST['vendor_id']) || !isset($_POST['business_name']) || !isset($_POST['business_address'])) {
        echo json_encode(["status" => "error", "message" => "Missing required fields: vendor_id, business_name, or business_address"]);
        $conn->close();
        exit();
    }

    // Assign and sanitize input values
    $vendor_id = intval($_POST['vendor_id']);
    $business_name = $conn->real_escape_string($_POST['business_name']);
    $business_address = $conn->real_escape_string($_POST['business_address']);

    $logo_url = null;
    $update_logo_clause = '';
    $params = [];
    $types = '';

    // Handle image upload if a new logo_image is provided
    if (isset($_FILES['logo_image']) && $_FILES['logo_image']['error'] === UPLOAD_ERR_OK) {
        $file_tmp_path = $_FILES['logo_image']['tmp_name'];
        $file_name = $_FILES['logo_image']['name'];
        $file_ext = strtolower(pathinfo($file_name, PATHINFO_EXTENSION));

        $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif'];

        if (in_array($file_ext, $allowed_extensions)) {
            // Generate a unique file name
            $new_file_name = uniqid('logo_', true) . '.' . $file_ext;
            $upload_path = $uploadDirLogo . $new_file_name;

            if (move_uploaded_file($file_tmp_path, $upload_path)) {
                $logo_url = $upload_path;
                $update_logo_clause = ', logo_url = ?';
                // Add logo_url to parameters for prepared statement
                $params[] = $logo_url;
                $types .= 's';
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Failed to move uploaded file.']);
                $conn->close();
                exit();
            }
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Invalid file type for logo. Only JPG, JPEG, PNG, GIF are allowed.']);
            $conn->close();
            exit();
        }
    }

    // Prepare the update statement
    // We are only updating business_name, business_address, and potentially logo_url
    $sql = "UPDATE vendor_account SET business_name = ?, business_address = ?" . $update_logo_clause . " WHERE vendor_id = ?";

    $stmt = $conn->prepare($sql);

    if ($stmt === false) {
        echo json_encode(['status' => 'error', 'message' => 'Failed to prepare statement: ' . $conn->error]);
        $conn->close();
        exit();
    }

    // Bind parameters
    // The order of types and parameters must match the order in the SQL query
    $bound_params = [$business_name, $business_address];
    $bound_types = 'ss'; // 's' for string (business_name, business_address)

    if ($logo_url !== null) {
        $bound_params[] = $logo_url;
        $bound_types .= 's'; // Add 's' if logo_url is included
    }
    $bound_params[] = $vendor_id;
    $bound_types .= 'i'; // 'i' for integer (vendor_id)

    // Use call_user_func_array to bind parameters dynamically
    // The `&` before each parameter in the `call_user_func_array` is crucial for `bind_param`
    // to work correctly with references.
    $refs = [];
    foreach($bound_params as $key => $value) {
        $refs[$key] = &$bound_params[$key];
    }
    call_user_func_array([$stmt, 'bind_param'], array_merge([$bound_types], $refs));

    // Execute the statement
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['status' => 'success', 'message' => 'Store updated successfully.']);
        } else {
            // If no rows affected, it means the data was the same or vendor_id not found
            echo json_encode(['status' => 'success', 'message' => 'No changes made or vendor ID not found.']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to update store: ' . $stmt->error]);
    }

    $stmt->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method. Only POST allowed.']);
}

$conn->close();
?>