<?php

error_reporting(0); 

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

include 'config.php';


if (!isset($_POST['user_id']) || !isset($_POST['pet_name'])) {
    $response = array('status' => 'failed', 'message' => 'No data received');
    sendJsonResponse($response);
    die();
}


$user_id = $_POST['user_id'];
$pet_name = $_POST['pet_name'];
$pet_type = $_POST['pet_type'];
$category = $_POST['category'];
$description = $_POST['description'];
$lat = $_POST['lat'];
$lng = $_POST['lng'];


$imagesJSON = $_POST['images']; 
$imageArray = json_decode($imagesJSON, true);

$uploadedPaths = [];


$uploadDir = __DIR__ . '/uploads/pets/'; 
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

if (is_array($imageArray)) {
    foreach ($imageArray as $base64String) {
       
        $filename = "pet_" . uniqid() . ".jpg";
        $filepath = $uploadDir . $filename;

        
        $decodedImage = base64_decode($base64String);

       
        if ($decodedImage !== false) {
            if (file_put_contents($filepath, $decodedImage)) {
                $uploadedPaths[] = $filename;
            }
        }
    }
} else {
    $response = array('status' => 'failed', 'message' => 'Invalid image format');
    sendJsonResponse($response);
    die();
}


if (count($uploadedPaths) == 0) {
    $response = array('status' => 'failed', 'message' => 'Failed to upload images');
    sendJsonResponse($response);
    die();
}


$finalImagePaths = json_encode($uploadedPaths);


$sql = "INSERT INTO tbl_pets (user_id, pet_name, pet_type, category, description, image_paths, lat, lng, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";
$stmt = $conn->prepare($sql);

if ($stmt) {

    $stmt->bind_param("isssssss", $user_id, $pet_name, $pet_type, $category, $description, $finalImagePaths, $lat, $lng);
    
    if ($stmt->execute()) {
        $response = array('status' => 'success', 'data' => null);
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'message' => 'Database Insertion Failed: ' . $stmt->error);
        sendJsonResponse($response);
    }
    $stmt->close();
} else {
    $response = array('status' => 'failed', 'message' => 'Statement Preparation Failed: ' . $conn->error);
    sendJsonResponse($response);
}

$conn->close();

// Helper function to send JSON
function sendJsonResponse($sentArray)
{
    echo json_encode($sentArray);
}
?>