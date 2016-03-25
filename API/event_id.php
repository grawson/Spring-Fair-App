<?php

include "Database.php";
include "Modules.php";

//create connection to database
$database = new Database();
$con = $database->connect();

//get array of IDs
$ids = array();
if (!empty($_POST)) {
    $ids = $_POST["ids"];
}

//query for events
$query = "SELECT * 
        FROM events
        WHERE id IN (".implode(',',$ids).")
        ORDER BY date, start_time";
$modules = new Modules();
$results = $modules->query_2d($con, $query);
echo json_encode($results);

// Close connections
mysqli_close($con);
