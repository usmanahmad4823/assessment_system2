<?php
// ================= DATABASE CONFIG =================
$host = "localhost";
$username = "devnrvku_usmanahmad";          // change if needed
$password = "@namecheap.com";              // change if needed
$database = "devnrvku_assesment_system2"; // 🔴 replace with your DB name

 

// Create connection
$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    echo json_encode([
        "success" => false,
        "message" => "Database connection failed"
    ]);
    exit;
}
?>
