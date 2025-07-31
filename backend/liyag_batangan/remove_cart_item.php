<?php
header("Content-Type: application/json");

$response = array();

// Database connection details
$dbhost = "localhost";
$dbuser = "root";
$dbpass = "";
$dbname = "liyag_batangan";

// Create database connection
$conn = new mysqli($dbhost, $dbuser, $dbpass, $dbname);

// Check connection
if ($conn->connect_error) {
    $response['status'] = 'error';
    $response['message'] = 'Database connection failed: ' . $conn->connect_error;
    echo json_encode($response);
    exit(); // Terminate script execution if connection fails
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Sanitize input: Ensure cart_item_id is an integer
    // FILTER_SANITIZE_NUMBER_INT removes all characters except digits, plus and minus sign.
    $cart_item_id = filter_input(INPUT_POST, 'cart_item_id', FILTER_SANITIZE_NUMBER_INT);

    // Validate the sanitized input
    // Check for empty string (if no digits were present) or if it's not a valid integer representation
    if ($cart_item_id === false || $cart_item_id === null || $cart_item_id === '') {
        $response['status'] = 'error';
        $response['message'] = 'Cart item ID is required and must be a valid number.';
        echo json_encode($response);
        $conn->close(); // Close the connection before exiting
        exit();
    }

    // Convert to integer (filter_input returns string/null/false)
    $cart_item_id = (int)$cart_item_id;

    // Prepare statement to prevent SQL injection
    $stmt = $conn->prepare("DELETE FROM cart_item WHERE cart_item_id = ?");

    // Check if prepare was successful
    if ($stmt === false) {
        $response['status'] = 'error';
        $response['message'] = 'Prepare failed: ' . $conn->error;
        echo json_encode($response);
        $conn->close(); // Close the connection before exiting
        exit();
    }

    $stmt->bind_param("i", $cart_item_id); // 'i' for integer

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            $response['status'] = 'success';
            $response['message'] = 'Cart item removed successfully.';
        } else {
            $response['status'] = 'error';
            $response['message'] = 'Cart item not found or already removed.';
        }
    } else {
        $response['status'] = 'error';
        $response['message'] = 'Database error during execution: ' . $stmt->error;
    }

    $stmt->close(); // Close the statement
} else {
    $response['status'] = 'error';
    $response['message'] = 'Invalid request method.';
}

$conn->close(); // Close the database connection at the end of the script
echo json_encode($response);
?>