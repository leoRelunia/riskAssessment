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
    $calamity = $data['calamity'];
    $situation_overview = $data['situation_overview'];
    $response_actions = $data['response_actions'];
    $immediate_needs = $data['immediate_needs'];
    $recommendations = $data['recommendations'];

    // Validate input
    if (empty($id) || empty($calamity) || empty($situation_overview) || empty($response_actions) || empty($immediate_needs) || empty($recommendations)) {
        echo json_encode(['success' => false, 'message' => 'All fields are required.']);
        exit;
    }

    // Prepare the SQL statement
    $sql = "UPDATE situational_reports SET calamity=?, situation_overview=?, response_actions=?, immediate_needs=?, recommendations=? WHERE id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssss", 
        $calamity, 
        $situation_overview, 
        $response_actions, 
        $immediate_needs, 
        $recommendations, 
);
    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Report updated successfully.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update report.']);
    }

    $stmt->close();
}

$conn->close();
