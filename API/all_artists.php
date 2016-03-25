<?php

include "Database.php";
include "Modules.php";

//create connection to database
$database = new Database();
$con = $database->connect();

//query for events
$query = "SELECT * FROM artists ORDER BY date, start_time";
$modules = new Modules();
$results = $modules->query_2d($con, $query);
echo json_encode($results);
 
// Close connections
mysqli_close($con);
