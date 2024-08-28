<?php
// Set up SQLite database
$db = new SQLite3('submissions.db');

// Create the table if it doesn't exist
$db->exec("CREATE TABLE IF NOT EXISTS submissions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    emotion TEXT,
    text TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
)");

// Handle submission data
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $emotion = $_POST['emotion'];
    $text = $_POST['text'];
    $stmt = $db->prepare("INSERT INTO submissions (emotion, text) VALUES (:emotion, :text)");
    $stmt->bindValue(':emotion', $emotion, SQLITE3_TEXT);
    $stmt->bindValue(':text', $text, SQLITE3_TEXT);
    $stmt->execute();
    echo json_encode(['success' => true]);
    exit;
}

// Handle retrieval of submission history
$results = $db->query("SELECT * FROM submissions ORDER BY timestamp DESC");
$submissions = [];
while ($row = $results->fetchArray(SQLITE3_ASSOC)) {
    $submissions[] = $row;
}
echo json_encode($submissions);
