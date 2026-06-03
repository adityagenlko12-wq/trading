<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

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
    $token = 'eyJ0eXAiOiJKV1QiLCJrZXlfaWQiOiJza192MS4wIiwiYWxnIjoiSFMyNTYifQ.eyJzdWIiOiI1NEMzSEgiLCJqdGkiOiI2YTFlZmY4YTk5NmRjNDYzNWI2ZjhhZDQiLCJpc011bHRpQ2xpZW50IjpmYWxzZSwiaXNQbHVzUGxhbiI6ZmFsc2UsImlhdCI6MTc4MDQxNjM5NCwiaXNzIjoidWRhcGktZ2F0ZXdheS1zZXJ2aWNlIiwiZXhwIjoxNzgwNDM3NjAwfQ.fEs1bLTc7R6OvCScxxfsVzV5ApiSP1YZerHdQzm-fMg';
    
    $config = json_encode([
        'access_token' => [
            'title' => 'Access Token',
            'value' => $token
        ]
    ]);
    
    // First let's make sure the row exists (seed it if not, or update)
    $stmt = $pdo->prepare("UPDATE currency_data_providers SET configuration = :config, status = 1, is_default = 1 WHERE alias = 'Upstox'");
    $stmt->execute(['config' => $config]);
    
    echo "TOKEN_UPDATE_SUCCESS";
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage();
}
