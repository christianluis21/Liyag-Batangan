<?php
// filepath: update_cart_quantity.php
header('Content-Type: application/json');


$conn = new mysqli("localhost", "root", "", "liyag_batangan");
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]);
    exit;
}

$cart_item_id = $_POST['cart_item_id'] ?? '';
$quantity = $_POST['quantity'] ?? '';

if (!$cart_item_id || !$quantity) {
    echo json_encode(['error' => 'Missing cart_item_id or quantity']);
    exit;
}

$stmt = $conn->prepare("UPDATE cart_item SET quantity = ? WHERE cart_item_id = ?");
$stmt->bind_param("ii", $quantity, $cart_item_id);
if ($stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['error' => 'Failed to update quantity']);
}
$stmt->close();
$conn->close();
?>