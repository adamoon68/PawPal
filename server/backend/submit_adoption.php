<?php
header("Access-Control-Allow-Origin: *");
include 'config.php';

$user_id = $_POST['user_id'];
$pet_id = $_POST['pet_id'];
$motivation = $_POST['motivation'];

$sql = "INSERT INTO tbl_adoptions (user_id, pet_id, motivation) VALUES ('$user_id', '$pet_id', '$motivation')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success', 'message' => 'Adoption request submitted']);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'Error: ' . $conn->error]);
}
?>