
 <?php
include 'db_connect.php';

$sql = "
    SELECT 
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

        CASE WHEN residents.disability IN ('Visual Impairment', 'Hearing Impairment', 'Speech Impairment', 'Physical Disability', 'Intellectual Disability', 'Psychosocial Disability', 'Learning Disability', 'Multiple Disabilities', 'Others') THEN 1 ELSE 0 END AS pwdcheck,
        CASE WHEN residents.age < 18 THEN 1 ELSE 0 END AS underagedcheck,
        CASE WHEN residents.age >= 60 THEN 1 ELSE 0 END AS seniorcheck,
        CASE WHEN residents.pregnant IN ('Yes') THEN 1 ELSE 0 END AS pregnantcheck

        
    FROM residents
    JOIN households ON households.id = residents.household_id
    ORDER BY residents.lname, residents.fname
";

$result = $conn->query($sql);

$records = []; 

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $records[] = $row;
    }
}   

echo json_encode($records);

$conn->close();
