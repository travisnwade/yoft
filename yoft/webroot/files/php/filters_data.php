<?php
// Connect to your SQLite database
$db = new SQLite3('submissions.db');

// Get the JSON data from the frontend
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Build the SQL query based on the filter criteria
$query = "SELECT emotion, text, timestamp FROM submissions WHERE 1=1";

// Apply the filters if they are set
if (!empty($data['startDate'])) {
    $query .= " AND timestamp >= '" . $data['startDate'] . "'";
}

if (!empty($data['endDate'])) {
    $query .= " AND timestamp <= '" . $data['endDate'] . "'";
}

if (!empty($data['emotion'])) {
    $query .= " AND emotion = '" . $data['emotion'] . "'";
}

if (!empty($data['dayOfWeek'])) {
    $dayNumber = date('w', strtotime($data['dayOfWeek']));
    $query .= " AND strftime('%w', timestamp) = '$dayNumber'";
}

if (!empty($data['month'])) {
    $query .= " AND strftime('%m', timestamp) = '" . sprintf("%02d", $data['month']) . "'";
}

// Execute the query and fetch results
$results = $db->query($query);

// Store results in an array
$data = [];
while ($row = $results->fetchArray(SQLITE3_ASSOC)) {
    $data[] = $row;
}

// Return the data in JSON format
header('Content-Type: application/json');
echo json_encode($data);
