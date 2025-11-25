<?php
header("Access-Control-Allow-Origin: *");
include 'config.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    sendJsonResponse([
        'status' => 'failed',
        'message' => 'Method Not Allowed'
    ]);
    exit();
}

if (
    !isset($_POST['email']) || 
    !isset($_POST['password']) || 
    !isset($_POST['name']) || 
    !isset($_POST['phone'])
) {
    http_response_code(400);
    sendJsonResponse([
        'status' => 'failed',
        'message' => 'Bad Request'
    ]);
    exit();
}

// Retrieve form data
$email = $_POST['email'];
$name = $_POST['name'];
$phone = $_POST['phone'];
$password = $_POST['password'];
$hashedPassword = sha1($password);

// Check if email exists
$sqlCheck = "SELECT email FROM tbl_users WHERE email = '$email'";
$result = $conn->query($sqlCheck);

if ($result->num_rows > 0) {
    sendJsonResponse([
        'status' => 'failed',
        'message' => 'Email already registered'
    ]);
    exit();
}

// Insert new user
$sqlInsert = "INSERT INTO tbl_users (name, email, password, phone)
              VALUES ('$name', '$email', '$hashedPassword', '$phone')";

try {
    if ($conn->query($sqlInsert) === TRUE) {
        sendJsonResponse([
            'status' => 'success',
            'message' => 'User registered successfully'
        ]);
    } else {
        sendJsonResponse([
            'status' => 'failed',
            'message' => 'User registration failed'
        ]);
    }
} catch (Exception $e) {
    sendJsonResponse([
        'status' => 'failed',
        'message' => $e->getMessage()
    ]);
}

// JSON response function
function sendJsonResponse($array)
{
    header('Content-Type: application/json');
    echo json_encode($array);
}
?>
