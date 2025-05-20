<?php

include 'db_connect.php';
// Get the POST data
$data = json_decode(file_get_contents("php://input"), true);

// Define required fields (optional fields removed)
$required_fields = ['calamity', 
                    'situation_overview', 
                    'response_actions', 
                    'immediate_needs', 
                    'recommendations'];

// Check for missing fields
$missing_fields = [];
foreach ($required_fields as $field) {
    if (!isset($data[$field]) || (is_string($data[$field]) && trim($data[$field]) === '')) {
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
$stmt = $conn->prepare("INSERT INTO situational_reports (calamity, situation_overview, response_actions, immediate_needs, recommendations)
                       VALUES (?, ?, ?, ?, ?)");

// Check if the statement was prepared successfully
if ($stmt === false) {
    echo json_encode(["success" => false, "message" => "Error preparing the statement: " . $conn->error]);
    exit;
}

// Bind the parameters to the placeholders
$stmt->bind_param("sssss", 
    $data['calamity'], 
    $data['situation_overview'], 
    $data['response_actions'], 
    $data['immediate_needs'], 
    $data['recommendations']
);

// Execute the statement
if ($stmt->execute()) {
    // If the insert is successful
    echo json_encode(["success" => true, "message" => "Data saved successfully"]);
} else {
    // If there's an error in the insert
    echo json_encode(["success" => false, "message" => "Failed to save data: " . $stmt->error]);
}
?>
