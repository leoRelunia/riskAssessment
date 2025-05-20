<?php
include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    // Validate Household Data
    $requiredFields = ['household_id', 'hhstreet', 'hhzone', 'lot', 'materialused', 'toiletfacility', 'meansofcommunication', 'sourceofwater', 'electricity', 'hhwith', 'familyincome', 'residents'];
    foreach ($requiredFields as $field) {
        if (!isset($data[$field])) {
            echo json_encode(["success" => false, "message" => "Missing required field: $field"]);
            exit();
        }
    }

    $household_id = $data['household_id'];
    $residents = $data['residents'];
    // tighali ko si id
    // Validate Residents Data BEFORE updating household
    foreach ($residents as $resident) {
        $residentRequiredFields = ['fname', 'lname', 'cstatus', 'religion', 'dbirth', 'age', 'gender', 'education', 'occupation', 'beneficiary', 'pregnant', 'disability', 'hhtype'];
        foreach ($residentRequiredFields as $rField) {
            if (!isset($resident[$rField])) {
                echo json_encode(["success" => false, "message" => "Missing resident field: $rField"]);
                exit();
            }
        }
    }

    // Now that validation is complete, begin transaction
    $conn->begin_transaction();
    try {
        // Update household
        $stmt = $conn->prepare("UPDATE households SET hhstreet = ?, hhzone = ?, lot = ?, materialused = ?, toiletfacility = ?, meansofcommunication = ?, sourceofwater = ?, electricity = ?, hhwith = ?, familyincome = ? WHERE id = ?");
        
        $stmt->bind_param("ssssssssssi", $data['hhstreet'], $data['hhzone'], $data['lot'], $data['materialused'], 
            $data['toiletfacility'], $data['meansofcommunication'], $data['sourceofwater'], $data['electricity'], 
            $data['hhwith'], $data['familyincome'], $household_id);
        $stmt->execute();

        // Update residents
        $stmt = $conn->prepare("UPDATE residents SET 
            profilepicture = ?, 
            fname = ?, 
            mname = ?, 
            lname = ?, 
            suffix = ?, 
            alias = ?, 
            cnumber = ?, 
            cstatus = ?, 
            religion = ?, 
            dbirth = ?, 
            age = ?, 
            gender = ?, 
            education = ?, 
            occupation = ?, 
            beneficiary = ?, 
            pregnant = ?, 
            disability = ?, 
            hhtype = ? 
        WHERE id = ?"); 

        foreach ($residents as $resident) {
            $stmt->bind_param("ssssssssssisssssssi", 
                $resident['profilepicture'], 
                $resident['fname'],
                $resident['mname'], 
                $resident['lname'], 
                $resident['suffix'], 
                $resident['alias'], 
                $resident['cnumber'], 
                $resident['cstatus'], 
                $resident['religion'], 
                $resident['dbirth'],
                $resident['age'], 
                $resident['gender'], 
                $resident['education'], 
                $resident['occupation'], 
                $resident['beneficiary'], 
                $resident['pregnant'], 
                $resident['disability'], 
                $resident['hhtype'], 
                $resident['id']); 
            
            if (!$stmt->execute()) {
                echo json_encode(["success" => false, "message" => "Error updating resident: " . $stmt->error]);
                exit();
            }
        }

        $conn->commit();
        echo json_encode(["success" => true, "message" => "Data updated successfully"]);
    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}
