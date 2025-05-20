<?php
include 'db_connect.php';

$sql = "
    SELECT 
        households.id AS household_id, 
        households.hhstreet, 
        households.hhzone, 
        households.lot,
        households.materialused,
        households.toiletfacility,
        households.meansofcommunication,
        households.sourceofwater,   
        households.electricity,
        households.hhwith,
        households.familyincome,
        households.created_at AS household_created_at, 
        households.updated_at AS household_updated_at, 
        residents.id AS resident_id,
        residents.profilepicture,
        residents.fname,
        residents.mname,
        residents.lname,
        residents.suffix,
        residents.alias,
        residents.cnumber,
        residents.cstatus,
        residents.religion,
        residents.dbirth,
        residents.age,
        residents.gender,
        residents.education,
        residents.occupation,
        residents.beneficiary,
        residents.pregnant,
        residents.disability,
        residents.hhtype,
        
        -- Count of household members
        (SELECT COUNT(*) FROM residents r WHERE r.household_id = households.id) AS HouseholdMembersCount,
        -- Count of underaged individuals
        (SELECT COUNT(*) FROM residents r WHERE r.household_id = households.id AND r.age < 18) AS UnderagedCount,
        -- Count of seniors
        (SELECT COUNT(*) FROM residents r WHERE r.household_id = households.id AND r.age >= 60) AS SeniorCount,
        -- Count of pregnant individuals
        (SELECT COUNT(*) FROM residents r WHERE r.household_id = households.id AND r.pregnant = 'Yes') AS PregnantCount,
        -- Count of PWDs
        (SELECT COUNT(*) FROM residents r WHERE r.household_id = households.id AND r.disability IN ('Visual Impairment', 'Hearing Impairment', 'Speech Impairment', 'Physical Disability', 'Intellectual Disability', 'Psychosocial Disability', 'Learning Disability', 'Multiple Disabilities', 'Others')) AS PWDCount,
        
        -- Total counts
        (SELECT COUNT(*) FROM residents) AS TotalPopulation,
        (SELECT COUNT(DISTINCT households.id) FROM households) AS TotalFamilies,
        (SELECT COUNT(*) FROM residents WHERE gender = 'Female') AS TotalFemales,
        (SELECT COUNT(*) FROM residents WHERE gender = 'Male') AS TotalMales,
        (SELECT COUNT(*) FROM residents WHERE gender IN ('LGBT', 'Non-binary', 'Transman', 'Transwoman')) AS TotalLGBTQIA,
        (SELECT COUNT(*) FROM residents WHERE age < 18) AS TotalUnderaged,
        (SELECT COUNT(*) FROM residents WHERE age >= 60) AS TotalSeniors,
        (SELECT COUNT(*) FROM residents WHERE disability IN ('Visual Impairment', 'Hearing Impairment', 'Speech Impairment', 'Physical Disability', 'Intellectual Disability', 'Psychosocial Disability', 'Learning Disability', 'Multiple Disabilities', 'Others')) AS TotalPWDs
        
    FROM households 
    LEFT JOIN residents ON households.id = residents.household_id
";

$result = $conn->query($sql);

$records = []; 

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $household_id = $row['household_id'];
        
        // If the household doesn't exist in the records array, create it
        if (!isset($records[$household_id])) {
            $records[$household_id] = [
                'household_id' => $household_id,
                'hhstreet' => $row['hhstreet'],
                'hhzone' => $row['hhzone'],
                'lot' => $row['lot'],
                'materialused' => $row['materialused'],
                'toiletfacility' => $row['toiletfacility'],
                'meansofcommunication' => $row['meansofcommunication'],
                'sourceofwater' => $row['sourceofwater'],
                'electricity' => $row['electricity'],
                'hhwith' => $row['hhwith'],
                'familyincome' => $row['familyincome'],
                'HouseholdMembersCount' => $row['HouseholdMembersCount'],
                'UnderagedCount' => $row['UnderagedCount'],
                'SeniorCount' => $row['SeniorCount'],
                'PregnantCount' => $row['PregnantCount'],
                'PWDCount' => $row['PWDCount'],
                'TotalPopulation' => $row['TotalPopulation'],
                'TotalFamilies' => $row['TotalFamilies'],
                'TotalFemales' => $row['TotalFemales'],
                'TotalMales' => $row['TotalMales'],
                'TotalLGBTQIA' => $row['TotalLGBTQIA'],
                'TotalUnderaged' => $row['TotalUnderaged'],
                'TotalSeniors' => $row['TotalSeniors'],
                'TotalPWDs' => $row['TotalPWDs'],
                'household_created_at' => $row['household_created_at'], 
                'household_updated_at' => $row['household_updated_at'],
                'residents' => [] // Initialize residents array
            ];
        }
        
        // Add resident data to the household
        if ($row['resident_id'] !== null) {
            $records[$household_id]['residents'][] = [
                'resident_id' => $row['resident_id'], // Include resident_id
                'profilepicture' => $row['profilepicture'],
                'fname' => $row['fname'],
                'mname' => $row['mname'],
                'lname' => $row['lname'],
                'suffix' => $row['suffix'],
                'alias' => $row['alias'],
                'cnumber' => $row['cnumber'],
                'cstatus' => $row['cstatus'],
                'religion' => $row['religion'],
                'dbirth' => $row['dbirth'],
                'age' => $row['age'],
                'gender' => $row['gender'],
                'education' => $row['education'],
                'occupation' => $row['occupation'],
                'beneficiary' => $row['beneficiary'],
                'pregnant' => $row['pregnant'],
                'disability' => $row['disability'],
                'hhtype' => $row['hhtype'],
            ];
        }
    }
}

// Re-index the records array to be a simple array
$records = array_values($records);

echo json_encode($records);

$conn->close();

