<?php
// filepath: get_businesses.php

header('Content-Type: application/json');

$conn = new mysqli("localhost", "root", "", "liyag_batangan");
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed."]));
}

$sql = "SELECT vendor_id, user_id, business_name, business_address, business_description, logo_url, registration_date, verification_document, status FROM vendor_account";
$result = $conn->query($sql);

$businesses = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $businesses[] = [
            'vendor_id' => $row['vendor_id'],
            'user_id' => $row['user_id'],
            'business_name' => $row['business_name'],
            'business_address' => $row['business_address'],
            'business_description' => $row['business_description'],
            'logo_url' => $row['logo_url'],
            'registration_date' => $row['registration_date'],
            'verification_document' => $row['verification_document'],
            'status' => $row['status']
        ];
    }
}

echo json_encode($businesses);
$conn->close();
?>