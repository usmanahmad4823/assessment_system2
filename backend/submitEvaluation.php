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

// DEBUG LOGGING
function log_debug($msg) {
    $date = date('Y-m-d H:i:s');
    file_put_contents('debug_log.txt', "[$date] $msg\n", FILE_APPEND);
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
    $input_json = file_get_contents("php://input");
    $data = json_decode($input_json, true);
    log_debug("Received payload: " . $input_json);

    // Validate required fields
    if (!isset($data['student_id']) || !isset($data['assessment_detail_id']) || !isset($data['obtained_marks'])) {
        $response["message"] = "Missing required fields";
        log_debug("Error: Missing required fields");
        echo json_encode($response);
        exit;
    }

    $student_id = intval($data['student_id']);
    $assessment_detail_id = intval($data['assessment_detail_id']);
    $obtained_marks = intval($data['obtained_marks']);
    $comments = isset($data['comments']) ? $data['comments'] : '';
    $evaluation = isset($data['evaluation']) ? $data['evaluation'] : '';
    $student_name = isset($data['student_name']) ? $data['student_name'] : 'Unknown Student';
    $submitted_by = isset($data['submitted_by']) ? $data['submitted_by'] : 'unknown';

    log_debug("Processing Student ID: $student_id (Name: $student_name), Detail ID: $assessment_detail_id");

    // 1. Check if student exists
    $check_student_sql = "SELECT id FROM student WHERE id = ?";
    $stmt_s_check = $conn->prepare($check_student_sql);
    $stmt_s_check->bind_param("i", $student_id);
    $stmt_s_check->execute();
    $res_s_check = $stmt_s_check->get_result();
    
    // 2. If student does not exist, insert them manually
    if ($res_s_check->num_rows == 0) {
        log_debug("Student $student_id not found. creating...");
        $rollno = "MAN-" . $student_id; // Generate a unique rollno
        $insert_student_sql = "INSERT INTO student (id, name, rollno) VALUES (?, ?, ?)";
        $stmt_s_insert = $conn->prepare($insert_student_sql);
        $stmt_s_insert->bind_param("iss", $student_id, $student_name, $rollno);
        if (!$stmt_s_insert->execute()) {
             $error = $stmt_s_insert->error;
             $response["message"] = "Failed to create student dependency: " . $error;
             log_debug("Error creating student: $error");
             echo json_encode($response);
             exit;
        }
        $stmt_s_insert->close();
        log_debug("Student created successfully.");
    } else {
        log_debug("Student $student_id already exists.");
    }
    $stmt_s_check->close();

    // Check if record already exists
    $check_sql = "SELECT id FROM student_assessment_detail WHERE student_id = ? AND assessment_detail_id = ?";
    $stmt_check = $conn->prepare($check_sql);
    $stmt_check->bind_param("ii", $student_id, $assessment_detail_id);
    $stmt_check->execute();
    $result_check = $stmt_check->get_result();

    if ($result_check->num_rows > 0) {
        // Update existing record
        log_debug("Updating existing evaluation.");
        $sql = "UPDATE student_assessment_detail SET obtained_marks = ?, comments = ?, evaluation = ?, submitted_by = ? WHERE student_id = ? AND assessment_detail_id = ?";
        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            $response["message"] = "Prepare failed: " . $conn->error;
            log_debug("Prepare failed: " . $conn->error);
            echo json_encode($response);
            exit;
        }
        // Ensure comments and evaluation are always strings
        $comments = strval($comments);
        $evaluation = strval($evaluation);
        $submitted_by = strval($submitted_by);
        $stmt->bind_param("isssii", $obtained_marks, $comments, $evaluation, $submitted_by, $student_id, $assessment_detail_id);
        $update_result = $stmt->execute();
        if ($update_result) {
            $response["success"] = true;
            $response["message"] = "Evaluation updated successfully";
            log_debug("Update success.");
        } else {
            $response["message"] = "Update failed: " . $stmt->error;
            log_debug("Update failed: " . $stmt->error);
        }
        $stmt->close();

    } else {
        // Insert new record
        log_debug("Inserting new evaluation.");
        $sql = "INSERT INTO student_assessment_detail (student_id, assessment_detail_id, obtained_marks, comments, evaluation, submitted_by) VALUES (?, ?, ?, ?, ?, ?)";
        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            $response["message"] = "Prepare failed: " . $conn->error;
            log_debug("Prepare failed: " . $conn->error);
            echo json_encode($response);
            exit;
        }
        // Ensure comments and evaluation are always strings
        $comments = strval($comments);
        $evaluation = strval($evaluation);
        $submitted_by = strval($submitted_by);
        // Correction: should be int, int, int, string, string, string
        $stmt->bind_param("iiisss", $student_id, $assessment_detail_id, $obtained_marks, $comments, $evaluation, $submitted_by);
        $insert_result = $stmt->execute();
        if ($insert_result) {
            $response["success"] = true;
            $response["data"]["id"] = $conn->insert_id;
            $response["message"] = "Evaluation saved successfully";
            log_debug("Insert success. ID: " . $conn->insert_id);
        } else {
            $response["message"] = "Insert failed: " . $stmt->error;
            log_debug("Insert failed: " . $stmt->error);
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
