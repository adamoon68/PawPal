<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'config.php';

// 1. Check for basic required fields
if (!isset($_POST['user_id']) || !isset($_POST['pet_id'])) {
    echo json_encode(['status' => 'failed', 'message' => 'Missing user or pet data']);
    exit();
}

$user_id = $_POST['user_id'];
$pet_id = $_POST['pet_id'];
$type = $_POST['type'] ?? 'Money';
$amount = trim($_POST['amount'] ?? '0');
$description = trim($_POST['description'] ?? '');

// 2. VALIDATION LOGIC
if ($type === 'Money') {
   
    if (empty($amount) || !is_numeric($amount) || floatval($amount) <= 0) {
        echo json_encode(['status' => 'failed', 'message' => 'Please enter a valid amount']);
        exit();
    }
  
    if (empty($description)) {
        $description = "Monetary Donation";
    }
} else {
    
    if (empty($description)) {
        echo json_encode(['status' => 'failed', 'message' => 'Please enter a description of the items']);
        exit();
    }
}

// 3. Insert into Database safely
$stmt = $conn->prepare("INSERT INTO tbl_donations (user_id, pet_id, donation_type, amount, description, date_created) VALUES (?, ?, ?, ?, ?, NOW())");
$stmt->bind_param("sssss", $user_id, $pet_id, $type, $amount, $description);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Donation submitted successfully']);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'Database error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>