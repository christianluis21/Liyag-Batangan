<?php
header("Content-Type: application/json");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "liyag_batangan";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Get the user_id from the POST request
$user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;

if ($user_id === 0) {
    echo json_encode(["status" => "error", "message" => "Invalid user ID provided."]);
    $conn->close();
    exit();
}

// Start a transaction
$conn->begin_transaction();

try {
    // 1. Get vendor_id associated with the user_id
    $stmt = $conn->prepare("SELECT vendor_id FROM vendor_account WHERE user_id = ?");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $business = $result->fetch_assoc();
    $stmt->close();

    $vendor_id = null;
    if ($business) {
        $vendor_id = $business['vendor_id'];
    }

    if ($vendor_id) {
        // 2. Delete products associated with this vendor
        $stmt = $conn->prepare("DELETE FROM products WHERE vendor_id = ?");
        $stmt->bind_param("i", $vendor_id);
        $stmt->execute();
        $stmt->close();
    }

    // 3. Delete the business entry
    $stmt = $conn->prepare("DELETE FROM vendor_account WHERE user_id = ?");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $stmt->close();

    // 4. Update the user_type in the users table from 'vendor' to 'user'
    $stmt = $conn->prepare("UPDATE users SET user_type = 'user' WHERE user_id = ? AND user_type = 'vendor'");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $stmt->close();

    // If all operations successful, commit the transaction
    $conn->commit();
    echo json_encode(["status" => "success", "message" => "Store and associated data deleted, and user type updated to 'user'."]);

} catch (mysqli_sql_exception $exception) {
    // Rollback transaction on error
    $conn->rollback();
    echo json_encode(["status" => "error", "message" => "Database error: " . $exception->getMessage()]);
} catch (Exception $e) {
    // Catch any other exceptions
    $conn->rollback();
    echo json_encode(["status" => "error", "message" => "An unexpected error occurred: " . $e->getMessage()]);
}

$conn->close();
?>