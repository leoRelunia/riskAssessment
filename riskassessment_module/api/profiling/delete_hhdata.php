<?php
include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $household_id = $_POST['household_id'];

    // Prepare and execute the delete statement
    $stmt = $conn->prepare("DELETE FROM households WHERE id = ?");
    $stmt->bind_param("i", $household_id);

    if ($stmt->execute()) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to delete record']);
    }

    $stmt->close();
}

$conn->close();
