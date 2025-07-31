<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$targetDir = "uploads/products/";

$conn = new mysqli("localhost", "root", "", "liyag_batangan");
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]);
    exit;
}

if (
    isset($_POST['vendor_id'], $_POST['name'], $_POST['description'], $_POST['price'],
          $_POST['stock_quantity'], $_POST['category_id']) &&
    isset($_FILES['product_image'])
) {
    $vendor_id = (int) $_POST['vendor_id'];
    $category_id = (int) $_POST['category_id'];
    $name = $conn->real_escape_string($_POST['name']);
    $description = $conn->real_escape_string($_POST['description']);
    $price = floatval($_POST['price']);
    $stock_quantity = (int) $_POST['stock_quantity'];

    $image = $_FILES['product_image'];
    $imageName = uniqid("prod_") . "_" . basename($image["name"]);
    $imagePath = $targetDir . $imageName;
    $fullImagePath = __DIR__ . "/" . $imagePath;

    if (!file_exists(__DIR__ . "/" . $targetDir)) {
        mkdir(__DIR__ . "/" . $targetDir, 0777, true);
    }

    if (move_uploaded_file($image["tmp_name"], $fullImagePath)) {
        $stmt = $conn->prepare("INSERT INTO products (vendor_id, category_id, name, description, price, stock_quantity, image_url) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("iissdis", $vendor_id, $category_id, $name, $description, $price, $stock_quantity, $imagePath);


        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Product added successfully."]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to insert product: " . $stmt->error]);
        }

        $stmt->close();
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to upload image."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Missing required fields."]);
}

$conn->close();
?>
