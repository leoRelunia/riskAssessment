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
    $ddate = $data['ddate'];
    $dname = $data['dname'];
    $iname = $data['iname'];
    $dtype = $data['dtype'];
    $measure = $data['measure'];
    $quantity = $data['quantity'];
    $cost = $data['cost'];
    $beneficiaries = $data['beneficiaries'];
    $process = $data['process'];
    $venue = $data['venue'];
    $remarks = $data['remarks'];

    // Validate input
    if (empty($id) || empty($ddate) || empty($dname) || empty($iname) || empty($dtype) || empty($measure) || empty($quantity) || empty($cost) || empty($beneficiaries) || empty($process) || empty($venue) || empty($remarks)) {
        echo json_encode(['success' => false, 'message' => 'All fields are required.']);
        exit;
    }

    // Prepare the SQL statement
    $sql = "UPDATE relief_reports SET ddate=?, dname=?, iname=?, dtype=?, measure=?, quantity=?, cost=?, beneficiaries=?, process=?, venue=?, remarks=? WHERE id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssssssssssi", $ddate, $dname, $iname, $dtype, $measure, $quantity, $cost, $beneficiaries, $process, $venue, $remarks, $id);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Report updated successfully.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update report.']);
    }

    $stmt->close();
}

$conn->close();
