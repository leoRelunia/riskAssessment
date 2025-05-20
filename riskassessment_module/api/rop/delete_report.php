<?php
header('Content-Type: application/json');

// Include database connection
include_once 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get the report ID from the request
    $id = $_POST['id']; // Updated to use 'id'

    // Check if id is provided
    if (empty($id)) {
        echo json_encode(['success' => false, 'message' => 'ID is required.']);
        exit;
    }

    // Prepare the DELETE statement
    $stmt = $conn->prepare("DELETE FROM relief_reports WHERE id = ?"); 
    $stmt->bind_param("i", $id);

    // Execute the statement
    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Report deleted successfully.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to delete report.']);
    }

    // Close the statement
    $stmt->close();
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request method.']);
}

// Close the database connection
$conn->close();
?>
