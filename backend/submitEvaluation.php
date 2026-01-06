<?php
/*************************************************
 * Submit Assessment Evaluation API
 * Saves student assessment evaluation
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

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get JSON data
    $data = json_decode(file_get_contents("php://input"), true);

    // Validate required fields
    if (!isset($data['student_id']) || !isset($data['assessment_detail_id']) || !isset($data['obtained_marks'])) {
        $response["message"] = "Missing required fields";
        echo json_encode($response);
        exit;
    }

    $student_id = intval($data['student_id']);
    $assessment_detail_id = intval($data['assessment_detail_id']);
    $obtained_marks = intval($data['obtained_marks']);
    $comments = isset($data['comments']) ? $data['comments'] : '';
    $evaluation = isset($data['evaluation']) ? $data['evaluation'] : '';

    // Check if record already exists
    $check_sql = "SELECT id FROM student_assessment_detail WHERE student_id = ? AND assessment_detail_id = ?";
    $stmt_check = $conn->prepare($check_sql);
    $stmt_check->bind_param("ii", $student_id, $assessment_detail_id);
    $stmt_check->execute();
    $result_check = $stmt_check->get_result();

    if ($result_check->num_rows > 0) {
        // Update existing record
        $sql = "UPDATE student_assessment_detail SET obtained_marks = ?, comments = ?, evaluation = ? WHERE student_id = ? AND assessment_detail_id = ?";
        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            $response["message"] = "Prepare failed: " . $conn->error;
            echo json_encode($response);
            exit;
        }
        // Ensure comments and evaluation are always strings
        $comments = strval($comments);
        $evaluation = strval($evaluation);
        $stmt->bind_param("s ssii", $obtained_marks, $comments, $evaluation, $student_id, $assessment_detail_id);
        // Correction: should be int, string, string, int, int
        // But obtained_marks is int, comments is string, evaluation is string, student_id is int, assessment_detail_id is int
        // So: "issii"
        $stmt->bind_param("issii", $obtained_marks, $comments, $evaluation, $student_id, $assessment_detail_id);
        $update_result = $stmt->execute();
        if ($update_result) {
            $response["success"] = true;
            $response["message"] = "Evaluation updated successfully";
        } else {
            $response["message"] = "Update failed: " . $stmt->error;
        }
        $stmt->close();

    } else {
        // Insert new record
        $sql = "INSERT INTO student_assessment_detail (student_id, assessment_detail_id, obtained_marks, comments, evaluation) VALUES (?, ?, ?, ?, ?)";
        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            $response["message"] = "Prepare failed: " . $conn->error;
            echo json_encode($response);
            exit;
        }
        // Ensure comments and evaluation are always strings
        $comments = strval($comments);
        $evaluation = strval($evaluation);
        // Correction: should be int, int, int, string, string
        $stmt->bind_param("iiiss", $student_id, $assessment_detail_id, $obtained_marks, $comments, $evaluation);
        $insert_result = $stmt->execute();
        if ($insert_result) {
            $response["success"] = true;
            $response["data"]["id"] = $conn->insert_id;
            $response["message"] = "Evaluation saved successfully";
        } else {
            $response["message"] = "Insert failed: " . $stmt->error;
        }
        $stmt->close();
    }

    $stmt_check->close();

} else {
    $response["message"] = "Only POST request is allowed";
}

// ================= SEND RESPONSE =================
echo json_encode($response);

// ================= CLOSE CONNECTION =================
$conn->close();
?>
