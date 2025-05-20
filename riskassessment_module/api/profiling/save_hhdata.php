<?php
include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    // Validate Household Data and log incoming data
    error_log(print_r($data, true)); // Log incoming data for debugging

    $requiredFields = ['hhstreet', 'hhzone', 'lot', 'materialused', 'toiletfacility', 'meansofcommunication', 'sourceofwater', 'electricity', 'hhwith', 'familyincome', 'residents'];
    foreach ($requiredFields as $field) {
        if (empty($data[$field])) { // Check if the field is empty
            echo json_encode(["success" => false, "message" => "Missing required field: $field"]);
            exit();
        }
    }

    $residents = $data['residents'];
    
    // Validate Residents Data BEFORE inserting household and log resident data
    error_log(print_r($residents, true)); // Log residents data for debugging

    foreach ($residents as $resident) {
        $residentRequiredFields = ['fname', 'lname', 'cstatus', 'religion', 'dbirth', 'age', 'gender', 'education', 'occupation', 'beneficiary', 'pregnant', 'disability', 'hhtype'];
        foreach ($residentRequiredFields as $rField) {
            if (empty($resident[$rField])) { // Check if the resident field is empty
                echo json_encode(["success" => false, "message" => "Missing resident field: $rField"]);
                exit();
            }
        }
    }

    // Now that validation is complete, begin transaction
    $conn->begin_transaction();
    try {
        // Insert household
        $stmt = $conn->prepare("INSERT INTO households (hhstreet, hhzone, lot, materialused, toiletfacility, meansofcommunication, sourceofwater, electricity, hhwith, familyincome) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        
        $stmt->bind_param("ssssssssss", 
            $data['hhstreet'], 
            $data['hhzone'], 
            $data['lot'], 
            $data['materialused'], 
            $data['toiletfacility'], 
            $data['meansofcommunication'], 
            $data['sourceofwater'], 
            $data['electricity'], 
            $data['hhwith'], 
            $data['familyincome']
        );
        
        if (!$stmt->execute()) {
            error_log("SQL Error on household insert: " . $stmt->error);
            throw new Exception("Database error: " . $stmt->error);
        }
        
        $household_id = $stmt->insert_id;

        // Insert residents
        $stmt = $conn->prepare("INSERT INTO residents (household_id, profilepicture, fname, mname, lname, suffix, alias, cnumber, cstatus, religion, dbirth, age, gender, education, occupation, beneficiary, pregnant, disability, hhtype) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        
        foreach ($residents as $resident) {
            // Prepare the values to bind
            $profilePicture = $resident['profilepicture'] ?? ''; 
            $fname = $resident['fname'];
            $mname = $resident['mname'] ?? ''; 
            $lname = $resident['lname'];
            $suffix = $resident['suffix'] ?? ''; 
            $alias = $resident['alias'] ?? ''; 
            $cnumber = $resident['cnumber'];
            $cstatus = $resident['cstatus'];
            $religion = $resident['religion'];
            $dbirth = $resident['dbirth'];
            $age = (int)$resident['age']; 
            $gender = $resident['gender'];
            $education = $resident['education'];
            $occupation = $resident['occupation'];
            $beneficiary = $resident['beneficiary'];
            $pregnant = $resident['pregnant'];
            $disability = $resident['disability'];
            $hhtype = $resident['hhtype'];
            
            // Bind parameters and execute
            $stmt->bind_param("issssssssssisssssss", 
                $household_id, 
                $profilePicture, 
                $fname,
                $mname, 
                $lname, 
                $suffix, 
                $alias, 
                $cnumber, 
                $cstatus, 
                $religion, 
                $dbirth,
                $age, 
                $gender, 
                $education, 
                $occupation, 
                $beneficiary, 
                $pregnant, 
                $disability, 
                $hhtype
            );        
            if (!$stmt->execute()) {
                error_log("SQL Error on resident insert: " . $stmt->error);
                throw new Exception("Database error: " . $stmt->error);
            }
        }

        $conn->commit();
        echo json_encode(["success" => true, "message" => "Data saved successfully"]);
    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}
