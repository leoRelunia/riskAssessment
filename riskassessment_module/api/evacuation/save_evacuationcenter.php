<?php
include 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

// Add calamity_name to the list of required fields
$required_fields = ['evacuation_centername', 'zone', 'evacuation_type', 'contact_person', 'contact_number', 'calamity_name'];

$missing_fields = [];
foreach ($required_fields as $field) {
    if (!isset($data[$field]) || $data[$field] === "") {
        $missing_fields[] = $field;
    }
}

if (!empty($missing_fields)) {
    echo json_encode([
        "success" => false,
        "message" => "Missing required fields: " . implode(", ", $missing_fields)
    ]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO evacuation_centers (evacuation_centername, zone, evacuation_type, contact_person, contact_number, calamity_name) VALUES (?, ?, ?, ?, ?, ?)");

if ($stmt === false) {
    echo json_encode(["success" => false, "message" => "Error preparing the statement: " . $conn->error]);
    exit;
}

$stmt->bind_param("ssssss",
    $data['evacuation_centername'],
    $data['zone'],
    $data['evacuation_type'],
    $data['contact_person'],
    $data['contact_number'],
    $data['calamity_name']
);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Evacuation center added successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Error adding evacuation center: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
