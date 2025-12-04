<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

include 'config.php';

$user_id = $_POST['user_id'] ?? '';
if ($user_id == '') {
    echo json_encode(['success' => false, 'message' => 'Missing user_id']);
    exit();
}

$stmt = $conn->prepare("SELECT pet_id, user_id, pet_name, pet_type, category, description, image_paths, lat, lng, created_at FROM tbl_pets WHERE user_id = ? ORDER BY created_at DESC");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$res = $stmt->get_result();

$data = [];
while ($row = $res->fetch_assoc()) {
    // image_paths stored as JSON string; decode to array
    $ips = [];
    if (!empty($row['image_paths'])) {
        $tmp = json_decode($row['image_paths'], true);
        if (is_array($tmp)) $ips = $tmp;
    }
    $row['image_paths'] = $ips;
    $data[] = $row;
}

echo json_encode(['success' => true, 'data' => $data]);

$stmt->close();
$conn->close();
?>
