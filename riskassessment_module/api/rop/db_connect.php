<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
header("Access-Control-Allow-Methods: POST, GET, DELETE, PUT, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");


error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database connection
$servername = "localhost";  
$username = "root";        
$password = "";          
$dbname = "reliefoperation";     

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Database connection failed: {$conn->connect_error}"]);
    exit;
}

