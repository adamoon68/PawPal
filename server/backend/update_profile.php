<?php
error_reporting(0); 
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'config.php';

if (!isset($_POST['user_id']) || !isset($_POST['name']) || !isset($_POST['phone'])) {
    echo json_encode(['status' => 'failed', 'message' => 'Missing required fields']);
    exit();
}

$user_id = $_POST['user_id'];
$name = $_POST['name'];
$phone = $_POST['phone'];
$image = $_POST['image'] ?? '';

// 1. Update Name and Phone
$stmt = $conn->prepare("UPDATE tbl_users SET name=?, phone=? WHERE user_id=?");
$stmt->bind_param("sss", $name, $phone, $user_id);

if ($stmt->execute()) {
    $newFilename = null;

    // 2. Handle Image Upload (if provided)
    if (!empty($image)) {
        $uploadDir = __DIR__ . '/uploads/profile/';
        if (!is_dir($uploadDir)) mkdir($uploadDir, 0777, true);

        $decodedImage = base64_decode($image);
        if ($decodedImage !== false) {
            $newFilename = "profile_" . $user_id . "_" . time() . ".jpg";
            file_put_contents($uploadDir . $newFilename, $decodedImage);
            
            
            $imgStmt = $conn->prepare("UPDATE tbl_users SET profile_image=? WHERE user_id=?");
            $imgStmt->bind_param("ss", $newFilename, $user_id);
            $imgStmt->execute();
        }
    }
    
    
    echo json_encode([
        'status' => 'success', 
        'message' => 'Profile updated',
        'data' => ['filename' => $newFilename] 
    ]);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'Database update failed']);
}
?>