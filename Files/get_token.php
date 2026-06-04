<?php
// get_token.php - Securely fetch active Upstox access token from database

header('Content-Type: application/json');

if (empty($_GET['key']) || $_GET['key'] !== 'vinance2024secret') {
    http_response_code(403);
    echo json_encode(["status" => "error", "message" => "Unauthorized"]);
    exit;
}

$host = 'localhost';
$db   = 'omprouvr_trading';
$user = 'omprouvr_trading';
$pass = 'Newpass@12346';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
    $stmt = $pdo->prepare("SELECT configuration FROM currency_data_providers WHERE alias = 'Upstox' LIMIT 1");
    $stmt->execute();
    $row = $stmt->fetch();
    
    if ($row) {
        $config = json_decode($row['configuration'], true);
        $token = $config['access_token']['value'] ?? '';
        echo json_encode(["status" => "success", "token" => $token]);
    } else {
        echo json_encode(["status" => "error", "message" => "Provider Upstox not found"]);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
