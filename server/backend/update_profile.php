<?php
header("Access-Control-Allow-Origin: *");
include 'config.php';

$user_id = $_POST['user_id'];
$name = $_POST['name'];
$phone = $_POST['phone'];
$image = $_POST['image'] ?? '';

$sql = "UPDATE tbl_users SET name='$name', phone='$phone' WHERE user_id='$user_id'";
if ($conn->query($sql) === TRUE) {
    if (!empty($image)) {
        // Ensure upload directory exists
        $uploadDir = __DIR__ . '/uploads/profile/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }
        
        $decodedImage = base64_decode($image);
        $filename = "profile_" . $user_id . "_" . time() . ".jpg";
        file_put_contents($uploadDir . $filename, $decodedImage);
        
        $conn->query("UPDATE tbl_users SET profile_image='$filename' WHERE user_id='$user_id'");
    }
    echo json_encode(['status' => 'success', 'message' => 'Profile updated']);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'Update failed']);
}
?>