<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

include 'config.php';

$operation = $_POST['operation'] ?? '';

if ($operation == 'delete') {

    // DELETE LOGIC

    $pet_id = $_POST['pet_id'] ?? '';

    if ($pet_id == '') {
        echo json_encode(['success' => false, 'message' => 'Missing pet_id']);
        exit();
    }

    $stmt = $conn->prepare("DELETE FROM tbl_pets WHERE pet_id = ?");
    $stmt->bind_param("s", $pet_id);
    
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['success' => true, 'message' => 'Pet deleted successfully']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Pet not found or already deleted']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Database error']);
    }
    $stmt->close();

} else {

    // FETCH LOGIC (Default)

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
}

$conn->close();
?>