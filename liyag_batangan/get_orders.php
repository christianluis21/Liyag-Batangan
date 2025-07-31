<?php
header("Content-Type: application/json");

$conn = new mysqli("localhost", "root", "", "liyag_batangan");
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]);
    exit;
}

$user_id = $_POST['user_id'] ?? null;

if (!$user_id) {
    echo json_encode(["error" => "Missing user_id"]);
    exit;
}

// Fetch order items joined with products for orders made by the user
$query = "
    SELECT 
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        oi.quantity,
        oi.price,
        (oi.quantity * oi.price) AS total_price,
        p.name AS name,
        p.image_url
    FROM order_item oi
    JOIN order_app o ON oi.order_id = o.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.user_id = ?
    ORDER BY oi.order_item_id DESC
";

$stmt = $conn->prepare($query);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$order_items = [];

while ($row = $result->fetch_assoc()) {
    $order_items[] = $row;
}

echo json_encode($order_items);
?>
