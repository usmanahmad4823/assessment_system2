<?php
/*************************************************
 * Get Students API
 * Fetches all students
 *************************************************/

// ================= CORS HEADERS =================
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ================= INCLUDE DB CONNECTION =================
require_once "db_connection.php";

// ================= MAIN LOGIC =================
$response = [
    "success" => false,
    "data" => [],
    "message" => ""
];

$sql = "SELECT id, name, rollno FROM student ORDER BY rollno ASC";
$result = $conn->query($sql);

if ($result === false) {
    $response["message"] = "Query execution failed";
    echo json_encode($response);
    exit;
}

// Fetch data if records exist
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $response["data"][] = [
            "id" => (int)$row["id"],
            "name" => $row["name"],
            "rollno" => $row["rollno"]
        ];
    }
}

$response["success"] = true;
$response["message"] = "Students fetched successfully";

// ================= SEND RESPONSE =================
echo json_encode($response);

// ================= CLOSE CONNECTION =================
$conn->close();
?>
