<?php
header("Access-Control-Allow-Origin: *");
$mysqli = new mysqli("localhost", "root", "", "liyag_batangan");

$result = $mysqli->query("SELECT category_id, name FROM product_categories");
$categories = [];

while ($row = $result->fetch_assoc()) {
    $categories[] = $row;
}

echo json_encode($categories);
?>
