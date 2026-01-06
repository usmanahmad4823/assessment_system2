<?php
header('Content-Type: application/json');

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


// Include database connection
include 'db_connection.php';

try {
    // Fetch all records from ppt_details
    $query = "SELECT id, ppt_id, description, total_marks, is_comment FROM ppt_details";
    $result = $conn->query($query);

    if (!$result) {
        throw new Exception($conn->error);
    }

    $details = [];
    while ($row = $result->fetch_assoc()) {
        $details[] = $row;
    }

    echo json_encode([
        "success" => true,
        "data" => $details
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}

$conn->close();
