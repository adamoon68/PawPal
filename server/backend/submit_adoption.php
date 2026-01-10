<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'config.php';

// 1. Check if data is missing
if (!isset($_POST['user_id']) || !isset($_POST['pet_id']) || !isset($_POST['motivation'])) {
    echo json_encode(['status' => 'failed', 'message' => 'Missing required fields']);
    exit();
}

$user_id = $_POST['user_id'];
$pet_id = $_POST['pet_id'];
$motivation = trim($_POST['motivation']); // Remove extra spaces

// 2. Check if motivation is empty
if (empty($motivation)) {
    echo json_encode(['status' => 'failed', 'message' => 'Please enter your reason for adoption']);
    exit();
}

// 3. Insert into Database safely
$stmt = $conn->prepare("INSERT INTO tbl_adoptions (user_id, pet_id, motivation) VALUES (?, ?, ?)");
$stmt->bind_param("sss", $user_id, $pet_id, $motivation);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Adoption request submitted successfully']);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'Database error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>