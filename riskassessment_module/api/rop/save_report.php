<?php

include 'db_connect.php';
// Get the POST data
$data = json_decode(file_get_contents("php://input"), true);


// Define required fields
$required_fields = ['ddate', 'dname', 'iname', 'dtype', 'measure', 'quantity', 'cost', 'beneficiaries', 'process', 'venue', 'remarks'];

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
if (!is_numeric($data['quantity']) || !is_numeric($data['cost'])) {
    echo json_encode([
        "success" => false,
        "message" => "Fields 'quantity', 'cost', and 'beneficiaries' must be numeric."
    ]);
    exit;
}

// Prepare the SQL statement with placeholders
$stmt = $conn->prepare("INSERT INTO relief_reports (ddate, dname, iname, dtype, measure, quantity, cost, beneficiaries, process, venue, remarks)
                       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

// Check if the statement was prepared successfully
if ($stmt === false) {
    echo json_encode(["success" => false, "message" => "Error preparing the statement: " . $conn->error]);
    exit;
}

// Bind the parameters to the placeholders
$stmt->bind_param("sssssidssss", 
    $data['ddate'], 
    $data['dname'],
    $data['iname'], 
    $data['dtype'], 
    $data['measure'], 
    $data['quantity'], 
    $data['cost'], 
    $data['beneficiaries'], 
    $data['process'], 
    $data['venue'], 
    $data['remarks']
);

// Execute the statement
if ($stmt->execute()) {
    // If the insert is successful
    echo json_encode(["success" => true, "message" => "Data saved successfully"]);
} else {
    // If there's an error in the insert
    echo json_encode(["success" => false, "message" => "Failed to save data: " . $stmt->error]);
}
