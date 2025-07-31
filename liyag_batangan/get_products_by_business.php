<?php

header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

$conn = new mysqli("localhost", "root", "", "liyag_batangan");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Expect 'vendor_id' from Flutter
    $vendorId = isset($_POST['vendor_id']) ? intval($_POST['vendor_id']) : 0;

    if ($vendorId > 0) {
        $stmt = $conn->prepare("
            SELECT 
                product_id, vendor_id, category_id, name, description, 
                price, stock_quantity, image_url, status, created_at, updated_at
            FROM 
                products
            WHERE 
                vendor_id = ? AND status != 'Discontinued'
                AND stock_quantity > 0
        ");
        $stmt->bind_param('i', $vendorId);

        if ($stmt->execute()) {
            $result = $stmt->get_result();
            $products = [];

            while ($row = $result->fetch_assoc()) {
                $products[] = $row;
            }

            echo json_encode($products);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to execute query']);
        }

        $stmt->close();
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid vendor ID']);
    }
} else {
    http_response_code(405); // Method Not Allowed
    echo json_encode(['error' => 'Invalid request method']);
}

$conn->close();
?>
