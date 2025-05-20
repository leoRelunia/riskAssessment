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
    $date = $data['date'];
    $calamity_name = $data['calamity_name'];
    $calamity_type = $data['calamity_type'];
    $severity_level = $data['severity_level'];
    $flood_cause = $data['flood_cause'];
    $alert_level = $data['alert_level'];
    $current_status = $data['current_status'];

    // Validate input
    if (empty($id) || empty($date) || empty($calamity_name) || empty($calamity_type) || empty($severity_level) || empty($flood_cause) || empty($alert_level) || empty($current_status)) {
        echo json_encode(['success' => false, 'message' => 'All fields are required.']);
        exit;
    }

    // Prepare the SQL statement
    $sql = "UPDATE calamity SET date=?, calamity_name=?, calamity_type=?, severity_level=?, flood_cause=?, alert_level=?, current_status=? WHERE id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssssssi", $date, $calamity_name, $calamity_type, $severity_level, $flood_cause, $alert_level, $current_status, $id);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Report updated successfully.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update report.']);
    }

    $stmt->close();
}

$conn->close();
