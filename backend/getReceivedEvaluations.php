<?php
// ENABLE ERROR REPORTING FOR DEBUGGING
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");
include 'db_connection.php'; // Ensure you have your DB connection here
$student_id = isset($_GET['student_id']) ? $_GET['student_id'] : '';
if (empty($student_id)) {
    echo json_encode(['success' => false, 'message' => 'Student ID is required']);
    exit;
}
// Query to get evaluations received by this student
// Corrected Table Names based on existing backend files:
// - student_assessment_detail (alias sad) - NO student_name column here
// - assessment_details (alias ad)
// - assessment_table (alias at)
// - student (alias s) - This is where student_name comes from
$sql = "SELECT 
            sad.id,
            sad.student_id,
            s.name as student_name,
            sad.assessment_detail_id,
            sad.obtained_marks,
            sad.comments,
            sad.evaluation,
            sad.submitted_by,
            sad.created_at,
            ad.description as criteria_description,
            ad.total_marks,
            at.assessment_title
        FROM student_assessment_detail sad
        JOIN assessment_details ad ON sad.assessment_detail_id = ad.id
        JOIN assessment_table at ON ad.assessment_id = at.id
        JOIN student s ON sad.student_id = s.id
        WHERE sad.student_id = ?
        ORDER BY sad.created_at DESC";
if ($stmt = $conn->prepare($sql)) {
    $stmt->bind_param("s", $student_id);
    
    if (!$stmt->execute()) {
        echo json_encode(['success' => false, 'message' => 'Query execution failed: ' . $stmt->error]);
        exit;
    }
    $result = $stmt->get_result();
    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    echo json_encode(['success' => true, 'data' => $data]);
    $stmt->close();
} else {
    echo json_encode(['success' => false, 'message' => 'Prepare statement failed: ' . $conn->error]);
}
$conn->close();
?>