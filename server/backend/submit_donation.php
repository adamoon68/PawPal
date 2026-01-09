<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'config.php';

// Check if data is present
if (!isset($_POST['user_id']) || !isset($_POST['pet_id'])) {
    echo json_encode(['status' => 'failed', 'message' => 'Missing data']);
    exit();
}

$user_id = $_POST['user_id'];
$pet_id = $_POST['pet_id'];
$type = $_POST['type'] ?? 'Money'; // Default to Money if not set
$amount = $_POST['amount'] ?? '0';
$description = $_POST['description'] ?? '';

// Insert into Database
$stmt = $conn->prepare("INSERT INTO tbl_donations (user_id, pet_id, donation_type, amount, description, date_created) VALUES (?, ?, ?, ?, ?, NOW())");
$stmt->bind_param("sssss", $user_id, $pet_id, $type, $amount, $description);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Donation recorded']);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'Database error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>