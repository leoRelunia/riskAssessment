<?php

include 'db_connect.php';
// Get the POST data
$data = json_decode(file_get_contents("php://input"), true);

// Define required fields (optional fields removed)
$required_fields = ['zone_num', 'flood_depth', 'flood_level', 'notes'];

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

// Validate that quantity, cost, and beneficiaries are numeric
if (!is_numeric($data['flood_depth'])) {
    echo json_encode([
        "success" => false,
        "message" => "Fields 'flood_depth' must be numeric."
    ]);
    exit;
}

// Prepare the SQL statement with placeholders
$stmt = $conn->prepare("INSERT INTO flood_updates (zone_num, flood_level, flood_depth, notes, image_cover)
                       VALUES (?, ?, ?, ?, ?)");

// Check if the statement was prepared successfully
if ($stmt === false) {
    echo json_encode(["success" => false, "message" => "Error preparing the statement: " . $conn->error]);
    exit;
}

// Bind the parameters to the placeholders
$stmt->bind_param("sssds", 
    
    $data['image_cover'], 
    $data['zone_num'], 
    $data['flood_level'], 
    $data['flood_depth'], 
    $data['notes']
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
