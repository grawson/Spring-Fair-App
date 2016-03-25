<?php

/**
 * Class contains common modules. 
 */
class Modules {

    /**
     * Add query results to a 1D array
     * @param  mysqli $con database connection
     * @param  String $sql sql statement
     * @return array      The results in a 1D array
     */
    public function query_1d($con, $sql) {

        // Check if there are results
        if ($result = mysqli_query($con, $sql)) {
        
            //arrays to hold data found
            $resultArray = array();
         
            // Loop through each row in the result set
            while($row = $result->fetch_object()) {
                // Add each row into our results array
                array_push($resultArray, $row);
            }
         
            return $resultArray;
        }
    }

    /**
     * Add query results to a 2D array
     * @param  mysqli $con database connection
     * @param  String $sql sql statement
     * @return array      The results in a 2D array
     */
    public function query_2d($con, $sql) {

        // Check if there are results
        if ($result = mysqli_query($con, $sql)) {
        
            // If so, then create a results array and a temporary one
            // to hold the data
            $resultArray = array(); //2d array, rows = date, time = cols
            $tempArray = array();
            $currDate = "";
         
            // Loop through each row in the result set
            // create an array with all the events of a specific date
            // once a new date is seen, add the set of dates created to a 2d array
            while($row = $result->fetch_object()) {

                if (strcmp($currDate, "{$row->date}") != 0) {  //if dates are not equal
                    $currDate = "{$row->date}";

                    if (!empty($tempArray)) {
                        array_push($resultArray, $tempArray);
                    }
                    $tempArray = array();   //clear array
                }
                array_push($tempArray, $row); //add row to temp array
            }

            //push the last set of rows
            if (!empty($tempArray)) {
                array_push($resultArray, $tempArray);
            }

            return $resultArray;
        }
    }
}

