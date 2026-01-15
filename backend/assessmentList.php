<?php
/*************************************************
 * Assessment List API
 * Fetches all assessments from ppt_table
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

// ================= GET ACTION =================
$action = isset($_GET['action']) ? $_GET['action'] : 'get_all';

// ================= MAIN LOGIC =================
$response = [
    "success" => false,
    "data" => [],
    "message" => ""
];

if ($action === 'get_all') {
    // Get all assessments
    $sql = "SELECT id, assessment_title, password FROM assessment_table ORDER BY id DESC";
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
                "assessment_title" => $row["assessment_title"],
                "password" => $row["password"]
            ];
        }
    }

    $response["success"] = true;
    $response["message"] = "Assessment list fetched successfully";

} elseif ($action === 'get_details') {
    // Get assessment details
    $assessment_id = isset($_GET['id']) ? intval($_GET['id']) : 0;

    if ($assessment_id == 0) {
        $response["message"] = "Assessment ID is required";
        echo json_encode($response);
        exit;
    }

    $sql = "SELECT id, assessment_id, description, total_marks, is_comment FROM assessment_details WHERE assessment_id = ? ORDER BY id";
    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        $response["message"] = "Prepare failed: " . $conn->error;
        echo json_encode($response);
        exit;
    }

    $stmt->bind_param("i", $assessment_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $response["data"][] = [
                "id" => (int)$row["id"],
                "assessment_id" => (int)$row["assessment_id"],
                "description" => $row["description"],
                "total_marks" => (int)$row["total_marks"],
                "is_comment" => $row["is_comment"]
            ];
        }
    }

    $response["success"] = true;
    $response["message"] = "Assessment details fetched successfully";
    $stmt->close();

} else {
    $response["message"] = "Invalid action";
}

// ================= SEND RESPONSE =================
echo json_encode($response);

// ================= CLOSE CONNECTION =================
$conn->close();
?>
