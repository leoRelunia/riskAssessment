<?php

include 'db_connect.php';
// Get the POST data
$data = json_decode(file_get_contents("php://input"), true);


// Define required fields
$required_fields = ['date', 'calamity_name', 'calamity_type', 'severity_level', 'flood_cause', 'alert_level', 'current_status'];

// Check for missing fields
$missing_fields = [];
foreach ($required_fields as $field) {
    if (empty($data[$field])) {
        $missing_fields[] = $field;
    }
}

// If there are missing fields, return a detailed error message
if (!empty($missing_fields)) {
    echo json_encode([
        "success" => false,
        "message" => "Missing required fields: " . implode(", ", $missing_fields)
    ]);
    exit;
}


// Prepare the SQL statement with placeholders
$stmt = $conn->prepare("INSERT INTO calamity (date, calamity_name, calamity_type, severity_level, flood_cause, alert_level, current_status)
                       VALUES (?, ?, ?, ?, ?, ?, ?)");

// Check if the statement was prepared successfully
if ($stmt === false) {
    echo json_encode(["success" => false, "message" => "Error preparing the statement: " . $conn->error]);
    exit;
}

// Bind the parameters to the placeholders
$stmt->bind_param("sssssss",
    $data['date'], 
    $data['calamity_name'],
    $data['calamity_type'], 
    $data['severity_level'], 
    $data['flood_cause'], 
    $data['alert_level'], 
    $data['current_status'], 
);

// Execute the statement
if ($stmt->execute()) {
    // If the insert is successful
    echo json_encode(["success" => true, "message" => "Data saved successfully"]);
} else {
    // If there's an error in the insert
    echo json_encode(["success" => false, "message" => "Failed to save data: " . $stmt->error]);
}
