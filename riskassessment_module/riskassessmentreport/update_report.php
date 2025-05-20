<?php
include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true); 

    // Check if data is received
    if (!$data) {
        echo json_encode(['success' => false, 'message' => 'No data received.']);
        exit;
    }

    $id = $data['id'];
    $zone_num = $data['zone_num'];
    $risk_type = $data['risk_type'];
    $household_name = $data['household_name'];
    $risk_description = $data['risk_description'];
    $num_of_pwd = $data['num_of_pwd'];
    $num_of_senior = $data['num_of_senior'];
    $num_of_infant_toddler = $data['num_of_infant_toddler'];
    $num_of_flood_fatality = $data['num_of_flood_fatality'];
    $num_of_property_damage = $data['num_of_property_damage'];
    $damage_description = $data['damage_description'];
    $impacted_remarks = $data['impacted_remarks'];
    $risk_impact_level = $data['risk_impact_level'];
    $risk_probability_level = $data['risk_probability_level'];
    $risk_severity_level = $data['risk_severity_level'];
    $current_control_measures = $data['current_control_measures'];
    $option_action = $data['option_action'];
    $action_remarks = $data['action_remarks'];

    // Validate input
    if (empty($id) || empty($zone_num) || empty($risk_type) || empty($household_name) || empty($risk_description) || empty($num_of_pwd) || empty($num_of_senior) || empty($num_of_infant_toddler) || empty($num_of_flood_fatality) || empty($num_of_property_damage) || empty($damage_description) || empty($impacted_remarks) || empty($risk_impact_level) || empty($risk_probability_level) || empty($risk_severity_level) || empty($current_control_measures) || empty($option_action) || empty($action_remarks)) {
        echo json_encode(['success' => false, 'message' => 'All fields are required.']);
        exit;
    }

    // Prepare the SQL statement
    $sql = "UPDATE risk_assessment_report SET zone_num=?, risk_type=?, household_name=?, risk_description=?, num_of_pwd=?, num_of_senior=?, num_of_infant_toddler=?, num_of_flood_fatality=?, num_of_property_damage=?, damage_description=?, impacted_remarks=?, risk_impact_level=?, risk_probability_level=?, risk_severity_level=?, current_control_measures=?, option_action=?, action_remarks=? WHERE id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssssiiiiissssssssi", 
        $zone_num, 
        $risk_type, 
        $household_name, 
        $risk_description, 
        $num_of_pwd, 
        $num_of_senior, 
        $num_of_infant_toddler, 
        $num_of_flood_fatality, 
        $num_of_property_damage, 
        $damage_description, 
        $impacted_remarks, 
        $risk_impact_level, 
        $risk_probability_level, 
        $risk_severity_level, 
        $current_control_measures, 
        $option_action, 
        $action_remarks,
        $id
);
    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Report updated successfully.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update report.']);
    }

    $stmt->close();
}

$conn->close();
