<?php
include 'db_connect.php';


$sql = "SELECT id, ddate, dname, iname, dtype, measure, quantity, cost, beneficiaries, process, venue, remarks FROM relief_reports";


$result = $conn->query($sql);

$reports = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
}

echo json_encode($reports);

$conn->close();
