<?php
include 'db_connect.php';


$sql = "SELECT id, zone_num, risk_type, household_name, risk_description, num_of_pwd, num_of_senior, num_of_infant_toddler, num_of_flood_fatality, num_of_property_damage, damage_description, impacted_remarks, risk_impact_level, risk_probability_level, risk_severity_level, current_control_measures, option_action, action_remarks FROM risk_assessment_report ORDER BY id DESC";


$result = $conn->query($sql);

$reports = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
}

echo json_encode($reports);

$conn->close();
