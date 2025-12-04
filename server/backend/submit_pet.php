<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

include 'config.php';

// read raw JSON body
$body = file_get_contents('php://input');
if (!$body) {
    echo json_encode(['success' => false, 'message' => 'No input received']);
    exit();
}

$data = json_decode($body, true);
if (!$data) {
    echo json_encode(['success' => false, 'message' => 'Invalid JSON']);
    exit();
}

// required fields
$user_id = $data['user_id'] ?? '';
$pet_name = $data['pet_name'] ?? '';
$pet_type = $data['pet_type'] ?? '';
$category = $data['category'] ?? '';
$description = $data['description'] ?? '';
$lat = $data['lat'] ?? '';
$lng = $data['lng'] ?? '';
$images = $data['images'] ?? [];

if ($user_id == '' || $pet_name == '' || $pet_type == '' || $category == '' || $description == '' || $lat == '' || $lng == '' || !is_array($images) || count($images) < 1) {
    echo json_encode(['success' => false, 'message' => 'Missing required fields or images']);
    exit();
}

$uploadedPaths = [];
$uploadDir = __DIR__ . '/uploads/pets/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

foreach ($images as $imgBase64) {
    // generate a filename
    $filename = uniqid('pet_') . '.png';
    $filepath = $uploadDir . $filename;

    // if image includes data URI header, remove it
    if (strpos($imgBase64, 'base64,') !== false) {
        $parts = explode('base64,', $imgBase64);
        $imgBase64 = $parts[1];
    }

    $decoded = base64_decode($imgBase64);
    if ($decoded === false) continue;

    // save using file_put_contents
    $saved = file_put_contents($filepath, $decoded);
    if ($saved !== false) {
        $uploadedPaths[] = $filename;
    }
}

// store in DB: image_paths as JSON string
$imagesJson = json_encode($uploadedPaths);

// prepare insert
$stmt = $conn->prepare("INSERT INTO tbl_pets (user_id, pet_name, pet_type, category, description, image_paths, lat, lng, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())");
$stmt->bind_param("isssssss", $user_id, $pet_name, $pet_type, $category, $description, $imagesJson, $lat, $lng);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Pet submitted successfully']);
} else {
    echo json_encode(['success' => false, 'message' => 'Failed to insert into DB']);
}

$stmt->close();
$conn->close();
?>
