<?php
// filepath: get_cart_items.php
header('Content-Type: application/json');

$mysqli = new mysqli("localhost", "root", "", "liyag_batangan");

$user_id = $_POST['user_id'] ?? '';

if (!$user_id) {
    echo json_encode([]);
    exit;
}

// Fix table name: should be cart_items not cart_item
$sql = "SELECT ci.cart_item_id, ci.product_id, ci.quantity, ci.price, p.name, p.image_url
        FROM cart_item ci
        JOIN products p ON ci.product_id = p.product_id
        WHERE ci.user_id = ?";
$stmt = $mysqli->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$items = [];
while ($row = $result->fetch_assoc()) {
    $items[] = $row;
}
echo json_encode($items);

$stmt->close();
$mysqli->close();
?>