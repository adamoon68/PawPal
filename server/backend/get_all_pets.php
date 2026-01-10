<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'config.php';

$search = $_GET['search'] ?? '';
$type = $_GET['type'] ?? 'All';

// SQL Query: JOIN tbl_users to get the owner's name
$sql = "SELECT p.*, u.name as owner_name 
        FROM tbl_pets p 
        LEFT JOIN tbl_users u ON p.user_id = u.user_id 
        WHERE 1=1";

if (!empty($search)) {
    $search = $conn->real_escape_string($search);
    $sql .= " AND p.pet_name LIKE '%$search%'";
}

if ($type != 'All') {
    $type = $conn->real_escape_string($type);
    $sql .= " AND p.pet_type = '$type'";
}

$sql .= " ORDER BY p.created_at DESC";

$result = $conn->query($sql);

if ($result) {
    $data = [];
    while ($row = $result->fetch_assoc()) {

        $ips = [];
        if (!empty($row['image_paths'])) {
            $tmp = json_decode($row['image_paths'], true);
            if (is_array($tmp))
                $ips = $tmp;
        }
        $row['image_paths'] = $ips;

        $data[] = $row;
    }
    echo json_encode(['status' => 'success', 'data' => $data]);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'Database error']);
}
?>