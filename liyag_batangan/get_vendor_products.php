<?php
header("Content-Type: application/json");

// DB connection
$host = 'localhost';
$db = 'liyag_batangan'; // replace with your actual DB name
$user = 'root';
$pass = ''; // your DB password

$conn = new mysqli($host, $user, $pass, $db);

// Check connection
if ($conn->connect_error) {
    die(json_encode(['error' => 'Connection failed: ' . $conn->connect_error]));
}

// Get POST data
$vendor_id = isset($_POST['vendor_id']) ? intval($_POST['vendor_id']) : 0;

if ($vendor_id === 0) {
    echo json_encode([]);
    exit;
}

// Fetch products
$sql = "SELECT * FROM products WHERE vendor_id = ? ORDER BY created_at DESC";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $vendor_id);
$stmt->execute();
$result = $stmt->get_result();

$products = [];

while ($row = $result->fetch_assoc()) {
    $products[] = $row;
}

echo json_encode($products);

// Close connection
$stmt->close();
$conn->close();
?>
