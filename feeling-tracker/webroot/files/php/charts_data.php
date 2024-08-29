<?php
// Set up SQLite database
$db = new SQLite3('submissions.db');

// Retrieve submission history
$results = $db->query("SELECT emotion, timestamp FROM submissions ORDER BY timestamp DESC");
$submissions = [];
while ($row = $results->fetchArray(SQLITE3_ASSOC)) {
    $submissions[] = $row;
}
echo json_encode($submissions);
?>
