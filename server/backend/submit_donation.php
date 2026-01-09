<?php
error_reporting(0);
include 'config.php';

// 1. HANDLE RETURN FROM BILLPLZ (Payment Success/Fail)
if (isset($_GET['billplz']) && isset($_GET['billplz']['paid'])) {
    $paid = $_GET['billplz']['paid'];
    $bill_id = $_GET['billplz']['id'];
    $user_id = $_GET['user_id'];
    $pet_id = $_GET['pet_id'];
    $amount = $_GET['amount'];

    echo "<html><head><meta name='viewport' content='width=device-width, initial-scale=1'></head><body style='text-align:center;font-family:sans-serif;'>";
    
    if ($paid === 'true') {
        $desc = "Billplz ID: $bill_id";
        // Insert donation into database
        $sql = "INSERT INTO tbl_donations (user_id, pet_id, donation_type, amount, description, date_created) 
                VALUES ('$user_id', '$pet_id', 'Money', '$amount', '$desc', NOW())";
        
        if ($conn->query($sql) === TRUE) {
            echo "<h2 style='color:green'>Payment Successful</h2>";
            echo "<p>Thank you for donating RM $amount.</p>";
            echo "<br><p>Please close this window.</p>";
        } else {
            echo "<h2 style='color:orange'>Paid, but Database Error</h2>";
            echo "<p>" . $conn->error . "</p>";
        }
    } else {
        echo "<h2 style='color:red'>Payment Failed</h2>";
        echo "<p>Please try again.</p>";
    }
    echo "</body></html>";
    exit();
}

// 2. HANDLE REQUEST FROM APP (Create Bill)
// We check for 'amount' in GET (WebView load) or POST (Standard donation)
$amount = $_REQUEST['amount'] ?? 0;
$type = $_REQUEST['type'] ?? 'Money';

// If it's a Money donation loaded via GET (WebView), create the bill
if ($type == 'Money' && isset($_GET['amount'])) {
    
    $user_id = $_GET['user_id'];
    $pet_id = $_GET['pet_id'];
    $email = $_GET['email'];
    $phone = $_GET['phone'];
    $name = $_GET['name'];
    $amount_cents = floatval($amount) * 100;

    // API CONFIG
    $api_key = 'YOUR-API-KEY-HERE'; 
    $collection_id = 'YOUR-COLLECTION-ID-HERE';
    $host = 'https://www.billplz-sandbox.com/api/v3/bills';

    // RETURN URL (Points back to this file)
    // IMPORTANT: Use your machine's IP address here
    $callback_url = "http://172.20.10.2/pawpal/server/backend/submit_donation.php?user_id=$user_id&pet_id=$pet_id&amount=$amount";

    $data = array(
        'collection_id' => $collection_id,
        'email' => $email,
        'mobile' => $phone,
        'name' => $name,
        'amount' => $amount_cents,
        'description' => 'Donation for Pet ID: ' . $pet_id,
        'callback_url' => $callback_url,
        'redirect_url' => $callback_url
    );

    $process = curl_init($host);
    curl_setopt($process, CURLOPT_HEADER, 0);
    curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
    curl_setopt($process, CURLOPT_TIMEOUT, 30);
    curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
    curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
    curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data));

    $return = curl_exec($process);
    curl_close($process);

    $bill = json_decode($return, true);

    // REDIRECT THE WEBVIEW TO BILLPLZ
    header("Location: {$bill['url']}");
    exit();
} 

// 3. HANDLE STANDARD DONATIONS (POST - Food/Medical)
if ($_SERVER['REQUEST_METHOD'] == 'POST' && $type != 'Money') {
    header("Content-Type: application/json; charset=UTF-8");
    
    $user_id = $_POST['user_id'];
    $pet_id = $_POST['pet_id'];
    $description = $_POST['description'];

    $sql = "INSERT INTO tbl_donations (user_id, pet_id, donation_type, amount, description, date_created) 
            VALUES ('$user_id', '$pet_id', '$type', '$amount', '$description', NOW())";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(['status' => 'success', 'message' => 'Donation submitted']);
    } else {
        echo json_encode(['status' => 'failed', 'message' => 'Error: ' . $conn->error]);
    }
}
?>