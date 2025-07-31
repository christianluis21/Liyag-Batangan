<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

error_reporting(E_ALL);
ini_set('display_errors', 1);

$targetDir = "uploads/products/";

$conn = new mysqli("localhost", "root", "", "liyag_batangan");
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]);
    exit;
}

$user_id = $_POST['user_id'] ?? '';
$order_items = json_decode($_POST['order_items'] ?? '[]', true);
$total_price = $_POST['total_price'] ?? '0';
$name = $_POST['name'] ?? '';
$address = $_POST['address'] ?? '';
$phone_number = $_POST['phone_number'] ?? '';

if (!$user_id || empty($order_items)) {
    echo json_encode(['error' => 'Missing user_id or order_items']);
    exit;
}

// Insert order
$stmt = $conn->prepare("INSERT INTO order_app (user_id, name, address, contact, total_price) VALUES (?, ?, ?, ?, ?)");
if (!$stmt) {
    echo json_encode(['error' => 'Order prepare failed: ' . $conn->error]);
    exit;
}
$stmt->bind_param("isssd", $user_id, $name, $address, $phone_number, $total_price);
if ($stmt->execute()) {
    $order_id = $stmt->insert_id;
    $stmt->close();

    // Insert order items and update product stock
    foreach ($order_items as $item) {
        $product_id = $item['product_id'];
        $quantity = $item['quantity'];
        $price = $item['price'];

        // Insert order item
        $oi_stmt = $conn->prepare("INSERT INTO order_item (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)");
        if (!$oi_stmt) {
            echo json_encode(['error' => 'Order items prepare failed: ' . $conn->error]);
            exit;
        }
        $oi_stmt->bind_param("iiid", $order_id, $product_id, $quantity, $price);
        if (!$oi_stmt->execute()) {
            echo json_encode(['error' => 'Order items execute failed: ' . $oi_stmt->error]);
            $oi_stmt->close();
            exit;
        }
        $oi_stmt->close();

        // Update product stock
        $update_stmt = $conn->prepare("UPDATE products SET stock_quantity = stock_quantity - ? WHERE product_id = ?");
        if (!$update_stmt) {
            echo json_encode(['error' => 'Stock update prepare failed: ' . $conn->error]);
            exit;
        }
        $update_stmt->bind_param("ii", $quantity, $product_id);
        if (!$update_stmt->execute()) {
            echo json_encode(['error' => 'Stock update execute failed: ' . $update_stmt->error]);
            $update_stmt->close();
            exit;
        }
        $update_stmt->close();
    }

    // Clear user's cart
    $del_stmt = $conn->prepare("DELETE FROM cart_item WHERE user_id = ?");
    if (!$del_stmt) {
        echo json_encode(['error' => 'Cart clear prepare failed: ' . $conn->error]);
        exit;
    }
    $del_stmt->bind_param("i", $user_id);
    if (!$del_stmt->execute()) {
        echo json_encode(['error' => 'Cart clear execute failed: ' . $del_stmt->error]);
        $del_stmt->close();
        exit;
    }
    $del_stmt->close();

    echo json_encode(['success' => true]);
} else {
    echo json_encode(['error' => 'Failed to place order: ' . $stmt->error]);
    $stmt->close();
}
$conn->close();
?>