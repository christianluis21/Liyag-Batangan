<?php
// filepath: add_to_cart_simple.php

header('Content-Type: application/json');

$conn = new mysqli("localhost", "root", "", "liyag_batangan");
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]);
    exit;
}

$user_id = $_POST['user_id'] ?? '';
$product_id = $_POST['product_id'] ?? '';
$quantity = $_POST['quantity'] ?? '1';

if (!$user_id || !$product_id) {
    echo json_encode(['error' => 'Missing user_id or product_id']);
    exit;
}

// Get product price
$price = 0;
$price_stmt = $conn->prepare("SELECT price FROM products WHERE product_id = ?");
$price_stmt->bind_param("i", $product_id);
$price_stmt->execute();
$price_stmt->bind_result($product_price);
if ($price_stmt->fetch()) {
    $price = $product_price;
}
$price_stmt->close();

// Check if product already exists in cart for this user
$stmt = $conn->prepare("SELECT cart_item_id, quantity FROM cart_item WHERE user_id = ? AND product_id = ?");
$stmt->bind_param("ii", $user_id, $product_id);
$stmt->execute();
$stmt->bind_result($cart_item_id, $existing_qty);

if ($stmt->fetch()) {
    // Update quantity
    $stmt->close();
    $new_qty = $existing_qty + intval($quantity);
    $update = $conn->prepare("UPDATE cart_item SET quantity = ?, price = ? WHERE cart_item_id = ?");
    $update->bind_param("idi", $new_qty, $price, $cart_item_id);
    if ($update->execute()) {
        echo json_encode(['success' => true, 'message' => 'Quantity updated']);
    } else {
        echo json_encode(['error' => 'Failed to update quantity']);
    }
    $update->close();
} else {
    $stmt->close();
    // Insert new item
    $insert = $conn->prepare("INSERT INTO cart_item (user_id, product_id, quantity, price) VALUES (?, ?, ?, ?)");
    $insert->bind_param("iiid", $user_id, $product_id, $quantity, $price);
    if ($insert->execute()) {
        echo json_encode(['success' => true, 'message' => 'Item added']);
    } else {
        echo json_encode(['error' => 'Failed to add item']);
    }
    $insert->close();
}
$conn->close();
?>