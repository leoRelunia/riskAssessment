<?php
include 'db_connect.php';


$sql = "SELECT id, date, calamity_name, calamity_type, severity_level, flood_cause, alert_level, current_status FROM calamity";


$result = $conn->query($sql);

$reports = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
}

echo json_encode($reports);

$conn->close();
