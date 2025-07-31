<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$conn = new mysqli("localhost", "root", "", "liyag_batangan");

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed."]));
}

$product_id = $_POST['product_id'] ?? null;

if (!$product_id) {
    echo json_encode(["status" => "error", "message" => "Product ID is required."]);
    exit;
}

$stmt = $conn->prepare("DELETE FROM products WHERE product_id = ?");
$stmt->bind_param("i", $product_id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Product deleted successfully."]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to delete product."]);
}

$stmt->close();
$conn->close();
?>
