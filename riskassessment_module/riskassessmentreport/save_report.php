<?php

include 'db_connect.php';
// Get the POST data
$data = json_decode(file_get_contents("php://input"), true);

// Define required fields (optional fields removed)
$required_fields = ['zone_num', 
                    'risk_type', 
                    'household_name', 
                    'risk_description', 
                    'risk_impact_level', 
                    'risk_probability_level',
                    'risk_severity_level', 
                    'current_control_measures',
                    'option_action'];

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

// Optional numeric fields with default value of 0
$data['num_of_pwd'] = isset($data['num_of_pwd']) && is_numeric($data['num_of_pwd']) ? (int)$data['num_of_pwd'] : 0;
$data['num_of_senior'] = isset($data['num_of_senior']) && is_numeric($data['num_of_senior']) ? (int)$data['num_of_senior'] : 0;
$data['num_of_infant_toddler'] = isset($data['num_of_infant_toddler']) && is_numeric($data['num_of_infant_toddler']) ? (int)$data['num_of_infant_toddler'] : 0;
$data['num_of_flood_fatality'] = isset($data['num_of_flood_fatality']) && is_numeric($data['num_of_flood_fatality']) ? (int)$data['num_of_flood_fatality'] : 0;
$data['num_of_property_damage'] = isset($data['num_of_property_damage']) && is_numeric($data['num_of_property_damage']) ? (int)$data['num_of_property_damage'] : 0;

// Optional text fields with default value of empty string
$data['damage_description'] = isset($data['damage_description']) ? $data['damage_description'] : '';
$data['impacted_remarks'] = isset($data['impacted_remarks']) ? $data['impacted_remarks'] : '';
$data['action_remarks'] = isset($data['action_remarks']) ? $data['action_remarks'] : '';

// Prepare the SQL statement with placeholders
$stmt = $conn->prepare("INSERT INTO risk_assessment_report (
    zone_num, risk_type, household_name, risk_description, 
    num_of_pwd, num_of_senior, num_of_infant_toddler, num_of_flood_fatality, num_of_property_damage, 
    damage_description, impacted_remarks, 
    risk_impact_level, risk_probability_level, risk_severity_level, 
    current_control_measures, option_action, action_remarks
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

// Check if the statement was prepared successfully
if ($stmt === false) {
    echo json_encode(["success" => false, "message" => "Error preparing the statement: " . $conn->error]);
    exit;
}

// Bind the parameters to the placeholders
$stmt->bind_param("ssssiiiiissssssss", 
    $data['zone_num'], 
    $data['risk_type'], 
    $data['household_name'], 
    $data['risk_description'], 
    $data['num_of_pwd'], 
    $data['num_of_senior'], 
    $data['num_of_infant_toddler'], 
    $data['num_of_flood_fatality'], 
    $data['num_of_property_damage'], 
    $data['damage_description'], 
    $data['impacted_remarks'], 
    $data['risk_impact_level'], 
    $data['risk_probability_level'], 
    $data['risk_severity_level'], 
    $data['current_control_measures'], 
    $data['option_action'], 
    $data['action_remarks']
);

// Execute the statement
if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Data saved successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to save data: " . $stmt->error]);
}
?>
