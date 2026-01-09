<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'config.php';

$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode(['status' => 'failed', 'message' => 'Missing user_id']);
    exit();
}


$sql = "SELECT d.*, p.pet_name, p.image_paths 
        FROM tbl_donations d
        LEFT JOIN tbl_pets p ON d.pet_id = p.pet_id
        WHERE d.user_id = ? 
        ORDER BY d.date_created DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {

    $row['image_paths'] = json_decode($row['image_paths'] ?? '[]', true);
    $data[] = $row;
}

echo json_encode(['status' => 'success', 'data' => $data]);

$stmt->close();
$conn->close();
?>