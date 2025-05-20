<?php
include 'db_connect.php';


$sql = "SELECT id, zone_num, flood_level, flood_depth, notes, image_cover, created_at FROM flood_updates ORDER BY created_at DESC";


$result = $conn->query($sql);

$reports = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
}

echo json_encode($reports);

$conn->close();
