<?php

include "Database.php";
include "Modules.php";

//create connection to database
$database = new Database();
$con = $database->connect();

//get name of location
$name = "";
if (!empty($_POST)) {
    $name = $_POST["name"];
}

//query for events
$query = "SELECT xcoordinate, ycoordinate 
        FROM coordinates
        WHERE name = '$name'";
$modules = new Modules();
$results = $modules->query_1d($con, $query);
echo json_encode($results);

// Close connections
mysqli_close($con);
