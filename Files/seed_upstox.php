<?php
error_reporting(E_ALL);
ini_get('display_errors');

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
     echo "Database connected successfully.<br>";

     // 1. Deactivate existing providers
     $pdo->exec("UPDATE currency_data_providers SET is_default = 0, status = 0");
     echo "Existing providers deactivated.<br>";

     // 2. Insert Upstox provider
     $stmt = $pdo->prepare("INSERT INTO currency_data_providers (id, name, alias, configuration, type, status, help, image, is_default, instruction, created_at, updated_at) 
        VALUES (:id, :name, :alias, :configuration, :type, :status, :help, :image, :is_default, :instruction, NOW(), NOW())
        ON DUPLICATE KEY UPDATE name=:name_update, alias=:alias_update, configuration=:config_update, status=:status_update, is_default=:default_update");
     
     $stmt->execute([
         'id' => 3,
         'name' => 'Upstox',
         'alias' => 'Upstox',
         'configuration' => json_encode([
             'access_token' => [
                 'title' => 'Access Token',
                 'value' => 'eyJ0eXAiOiJKV1QiLCJrZXlfaWQiOiJza192MS4wIiwiYWxnIjoiSFMyNTYifQ.eyJzdWIiOiI1NEMzSEgiLCJqdGkiOiI2YTFlZmY4YTk5NmRjNDYzNWI2ZjhhZDQiLCJpc011bHRpQ2xpZW50IjpmYWxzZSwiaXNQbHVzUGxhbiI6ZmFsc2UsImlhdCI6MTc4MDQxNjM5NCwiaXNzIjoidWRhcGktZ2F0ZXdheS1zZXJ2aWNlIiwiZXhwIjoxNzgwNDM3NjAwfQ.fEs1bLTc7R6OvCScxxfsVzV5ApiSP1YZerHdQzm-fMg'
             ]
         ]),
         'type' => 1,
         'status' => 1,
         'help' => 'Configure Upstox API credentials. Visit Upstox developer center to generate access token.',
         'image' => 'upstox.png',
         'is_default' => 1,
         'instruction' => '<ul class="list-group list-group-flush"><li class="list-group-item">Go to Upstox Developer Portal</li><li class="list-group-item">Register your app and authenticate to get your access token</li><li class="list-group-item">Insert your Access Token here</li></ul>',
         'name_update' => 'Upstox',
         'alias_update' => 'Upstox',
         'config_update' => json_encode([
             'access_token' => [
                 'title' => 'Access Token',
                 'value' => 'eyJ0eXAiOiJKV1QiLCJrZXlfaWQiOiJza192MS4wIiwiYWxnIjoiSFMyNTYifQ.eyJzdWIiOiI1NEMzSEgiLCJqdGkiOiI2YTFlZmY4YTk5NmRjNDYzNWI2ZjhhZDQiLCJpc011bHRpQ2xpZW50IjpmYWxzZSwiaXNQbHVzUGxhbiI6ZmFsc2UsImlhdCI6MTc4MDQxNjM5NCwiaXNzIjoidWRhcGktZ2F0ZXdheS1zZXJ2aWNlIiwiZXhwIjoxNzgwNDM3NjAwfQ.fEs1bLTc7R6OvCScxxfsVzV5ApiSP1YZerHdQzm-fMg'
             ]
         ]),
         'status_update' => 1,
         'default_update' => 1
     ]);

     echo "<strong>Upstox provider successfully seeded and set as default!</strong><br>";

} catch (\PDOException $e) {
     echo "Database Error: " . $e->getMessage() . "<br>";
}
