<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$conn = new mysqli("localhost", "root", "", "liyag_batangan");

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed."]));
}

$product_id = $_POST['product_id'] ?? null;
$price = $_POST['price'] ?? null;
$stock_quantity = $_POST['stock_quantity'] ?? null;

if (!$product_id || $price === null || $stock_quantity === null) {
    echo json_encode(["status" => "error", "message" => "Missing required fields."]);
    exit;
}

$stmt = $conn->prepare("UPDATE products SET price = ?, stock_quantity = ? WHERE product_id = ?");
$stmt->bind_param("dii", $price, $stock_quantity, $product_id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Product updated successfully."]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to update product."]);
}

$stmt->close();
$conn->close();
?>
