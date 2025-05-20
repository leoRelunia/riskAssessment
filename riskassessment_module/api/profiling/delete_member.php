<?php
include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $resident_id = $_POST['resident_id'];

    // Validate resident_id
    if (empty($resident_id)) {
        echo json_encode(["success" => false, "message" => "Missing resident ID"]);
        exit();
    }

    // Prepare and execute the delete statement
    $stmt = $conn->prepare("DELETE FROM residents WHERE id = ?");
    $stmt->bind_param("i", $resident_id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Member deleted successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error deleting member: " . $stmt->error]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}
