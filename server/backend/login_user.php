<?php
header("Access-Control-Allow-Origin: *");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {

    if (!isset($_POST['email']) || !isset($_POST['password'])) {
        $response = array('status' => 'failed', 'message' => 'Bad Request');
        sendJsonResponse($response);
        exit();
    }

    $email = $_POST['email'];
    $password = $_POST['password'];
    $hashedpassword = sha1($password);

    include 'config.php';

    // Check credentials
    $sql = "SELECT * 
            FROM tbl_users 
            WHERE email = '$email' AND password = '$hashedpassword'";

    $result = $conn->query($sql);

    if ($result->num_rows > 0) {

        $userdata = array();
        while ($row = $result->fetch_assoc()) {
            unset($row['password']); // dont return password hash
            $userdata[] = $row;
        }

        $response = array(
            'status' => 'success',
            'message' => 'Login successful',
            'data' => $userdata
        );
        sendJsonResponse($response);

    } else {

        $response = array(
            'status' => 'failed',
            'message' => 'Invalid email or password',
            'data' => null
        );
        sendJsonResponse($response);
    }

} else {

    $response = array('status' => 'failed', 'message' => 'Method Not Allowed');
    sendJsonResponse($response);
    exit();
}


function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
