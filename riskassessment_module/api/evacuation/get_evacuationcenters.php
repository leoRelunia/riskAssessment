<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "evacuation";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Get calamity_name from query string
$calamity_name = isset($_GET['calamity_name']) ? $_GET['calamity_name'] : '';

$sql = "SELECT id, evacuation_centername, zone, evacuation_type, contact_person, contact_number 
        FROM evacuation_centers 
        WHERE calamity_name = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $calamity_name); // Use "s" for string
$stmt->execute();
$result = $stmt->get_result();

$centers = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $centers[] = $row;
    }
}

echo json_encode($centers);

$stmt->close();
$conn->close();
?>
