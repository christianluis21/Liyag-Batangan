<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// Connect to MySQL
$conn = new mysqli("localhost", "root", "", "liyag_batangan");

// Check connection
if ($conn->connect_error) {
    die(json_encode([
        "status" => "error",
        "message" => "Database connection failed."
    ]));
}

// Fetch products where stock > 0 and status is Active
$sql = "SELECT product_id, vendor_id, category_id, name, description, price, stock_quantity, image_url, status 
        FROM products 
        WHERE stock_quantity > 0 AND status = 'Active' 
        ORDER BY created_at DESC";

$result = $conn->query($sql);

$products = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $products[] = $row;
    }
}

echo json_encode($products);
$conn->close();
?>
