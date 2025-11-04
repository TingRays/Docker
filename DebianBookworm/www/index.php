<?php
// 显示PHP信息
echo "<h1>PHP环境信息</h1>";

// 显示当前PHP版本
echo "<p>当前PHP版本: " . PHP_VERSION . "</p>";
putenv("REDIS_PASSWORD=123456");
print_r(phpinfo());
// 测试MySQL连接


$host = 'localhost';
$db = 'mysql';
$user = 'root';
$pass = '123456';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
    echo "<p style='color: green;'>MySQL连接成功</p>";
} catch (\PDOException $e) {
    throw new \PDOException($e->getMessage(), (int)$e->getCode());
    //echo "<p style='color: red;'>MySQL连接失败: " . $e->getMessage() . "</p>";
}

// 测试Redis连接
$redis = new Redis();
try {
    $redis->connect('localhost', 6379);
    $redis->auth(getenv('REDIS_PASSWORD'));
    $redis->set('test_key', 'Hello Redis');
    echo "<p style='color: green;'>Redis连接成功: " . $redis->get('test_key') . "</p>";
    
    // 显示Redis版本
    $redis_info = $redis->info();
    echo "<p>Redis版本: " . $redis_info['redis_version'] . "</p>";
} catch (Exception $e) {
    echo "<p style='color: red;'>Redis连接失败: " . $e->getMessage() . "</p>";
}

// 测试MongoDB连接
try {
    $manager = new MongoDB\Driver\Manager("mongodb://localhost:27017");
    $command = new MongoDB\Driver\Command(['ping' => 1]);
    $manager->executeCommand('admin', $command);
    echo "<p style='color: green;'>MongoDB连接成功</p>";
    
    // 显示MongoDB版本信息
    $serverInfo = $manager->executeCommand('admin', new MongoDB\Driver\Command(['buildInfo' => 1]));
    $info = current($serverInfo->toArray());
    echo "<p>MongoDB版本: " . $info->version . "</p>";
} catch (Exception $e) {
    echo "<p style='color: red;'>MongoDB连接失败: " . $e->getMessage() . "</p>";
}

// 显示已安装的PHP扩展
echo "<h2>已安装的PHP扩展</h2>";
$extensions = get_loaded_extensions();
sort($extensions);
echo "<ul>";
foreach ($extensions as $ext) {
    echo "<li>$ext</li>";
}
echo "</ul>";

// 显示PHP配置信息
echo "<h2>PHP配置信息</h2>";
echo "<pre>";
print_r([
    'memory_limit' => ini_get('memory_limit'),
    'upload_max_filesize' => ini_get('upload_max_filesize'),
    'post_max_size' => ini_get('post_max_size'),
    'max_execution_time' => ini_get('max_execution_time'),
    'opcache.enable' => ini_get('opcache.enable'),
]);
echo "</pre>";
?>