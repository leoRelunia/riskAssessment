<?php
include 'db_connect.php';


$sql = "SELECT id, calamity, situation_overview, response_actions, immediate_needs, recommendations, created_at FROM situational_reports ORDER BY id DESC";


$result = $conn->query($sql);

$reports = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
}

echo json_encode($reports);

$conn->close();
