<?php
/*************************************************
 * Get Submitted Evaluations API
 * Fetches all submitted assessments by a specific user
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

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    
    // Get submitted_by parameter
    if (!isset($_GET['submitted_by']) || empty($_GET['submitted_by'])) {
        $response["message"] = "Missing required parameter: submitted_by";
        echo json_encode($response);
        exit;
    }
    
    $submitted_by = $conn->real_escape_string($_GET['submitted_by']);
    
    // Query to get all submitted evaluations with full details
    $sql = "SELECT 
                sad.id,
                sad.student_id,
                s.name as student_name,
                sad.assessment_detail_id,
                ad.description,
                ad.total_marks,
                sad.obtained_marks,
                sad.comments,
                sad.evaluation,
                sad.submitted_by,
                sad.created_at,
                at.assessment_title
            FROM student_assessment_detail sad
            INNER JOIN assessment_details ad ON sad.assessment_detail_id = ad.id
            INNER JOIN assessment_table at ON ad.assessment_id = at.id
            INNER JOIN student s ON sad.student_id = s.id
            WHERE sad.submitted_by = ?
            ORDER BY sad.created_at DESC";
    
    $stmt = $conn->prepare($sql);
    
    if (!$stmt) {
        $response["message"] = "Prepare failed: " . $conn->error;
        echo json_encode($response);
        exit;
    }
    
    $stmt->bind_param("s", $submitted_by);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result) {
        $evaluations = [];
        while ($row = $result->fetch_assoc()) {
            $evaluations[] = [
                'id' => (int)$row['id'],
                'student_id' => (int)$row['student_id'],
                'student_name' => $row['student_name'],
                'assessment_detail_id' => (int)$row['assessment_detail_id'],
                'assessment_title' => $row['assessment_title'],
                'description' => $row['description'],
                'total_marks' => (int)$row['total_marks'],
                'obtained_marks' => (int)$row['obtained_marks'],
                'comments' => $row['comments'] ?? '',
                'evaluation' => $row['evaluation'] ?? '',
                'submitted_by' => $row['submitted_by'],
                'created_at' => $row['created_at']
            ];
        }
        
        $response["success"] = true;
        $response["data"] = $evaluations;
        $response["message"] = "Evaluations retrieved successfully";
    } else {
        $response["message"] = "Query failed: " . $stmt->error;
    }
    
    $stmt->close();
    
} else {
    $response["message"] = "Only GET request is allowed";
}

// ================= SEND RESPONSE =================
echo json_encode($response);

// ================= CLOSE CONNECTION =================
$conn->close();
?>
