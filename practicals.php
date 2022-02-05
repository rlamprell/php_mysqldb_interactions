<?php 
/* This class governs all Form and associated db interactions */

class formInteractions {
	
	// db connection and array of modules
	private $pdo;
	
	// hold the drop down items
	private $modules;
	private $times;
	
	// hold the last error
	private $errName;
	private $errEmail;
	private $bookingStr;
	
	public function __construct($connection) {
		
		$this->pdo = $connection;
	}
	

	// get the seats available across all tutorials
	public function getAllAvailableSpaces() {
		
		try {
			// Check if the student is already signed up to the tutorial
			$query = 'CALL get_All_Available_Seats()';

			// call the stored procedure
			$sp = $this->pdo->prepare($query);
			$sp->execute();

			$available = array();
			
			// Get the return from the query
			foreach ($sp as $mod) {
				$available[] = $mod['Available'];
			}

			// if no seats available return false
			if ($available[0] < 1) {
				
				return false;
			} 
			
			// else return true (at least one place available)
			return true;
		}
		catch (PDOException $err) {
			die("error: " . $err->getMessage()); 
		}
	}


	// get the modules from the db
	public function getModules() {
		
		try {
			// stored procedure name
			$query = 'CALL get_Modules()';

			// call the stored proc 
			$sp = $this->pdo->prepare($query);
			$sp->execute();
			
			$this->modules = array();
			
			foreach ($sp as $mod) {
				$this->modules[] = $mod['moduleName'];
			}
		}
		catch (PDOException $err) {
			die("error: " . $err->getMessage()); 
		}
	}
	
	
	// move the current selection to the front of the list
	private function moveModuleToFront($itemToMove) {
		
		// find where this value exists (assumes unique)
		$index = array_search($itemToMove, $this->modules);
		
		// swap this value to the front of the array
		$this->swapModules(0, $index);

		// ensure the remainder of the list is sorted
		$this->customSort();
	}
	
	
	// sort all the values excluding the first
	private function customSort() {

		// exclude index[0] as that's what we want at the start
		// -1 to ensure we don't exceed the limits of the array
		// -- this is essentially an offset bubblesort
		$arrLen = sizeof($this->modules);
		for ($i=0; $i<$arrLen-1; $i++) {

			for ($j=1; $j<$arrLen-$i-1; $j++) {

				$current			= $this->modules[$j];
				$next 				= $this->modules[$j+1];
				$currentIsLarger 	= strcmp($current, $next) > 0;

				if ($currentIsLarger) {

					$this->swapModules($j, $j+1);
				}
			}
		}
	}
	
	
	// swap two arr index values
	private function swapModules($first, $second) {
		
		$temp 					= $this->modules[$first];
		
		$this->modules[$first] 	= $this->modules[$second];
		$this->modules[$second] = $temp;
	}
	
	
	// return all the module options from the db array
	public function getModuleOptions($mod_selection) {
		
		// if selected, push the value to the top of the list
		if(isset($mod_selection)){
			
			$this->moveModuleToFront($mod_selection);
		} 

		return $this->modules;
	}
	
	
	// Take in the mod selected and return the output
	public function getTimeOptions($time_selection) {
		
		// default value if before user selection of a module
		$mod_selection = $this->modules[0];


		// call the stored procedure
		$query = 'CALL get_Module_Times(:mod_selection)';
		$sp = $this->pdo->prepare($query);
		
		// bind the parameters
		$sp->bindParam(':mod_selection', $mod_selection);
		
		// run
		$sp->execute();
		
		$this->times = array();
		
		foreach ($sp as $time) {

			/* store the id and timestamp */
			$this->times[] = array($time['id'], $time['Availability']);
		}
		
		// if the $time_selection isset and is not the first index, swap them
		if (isset($time_selection)) {

			$index = array_search($time_selection, array_column($this->times, '1'));

			// if not the first value then swap
			// -- This does not sort! So if more than 2 time values are entered in future a sort will be needed
			if ($index!=0) {
				
				$temp = $this->times[0];
				$this->times[0] = $this->times[$index];
				$this->times[$index] = $temp;
			}
		}
        
		return $this->times;
	}
	

	// check the user name is valid
	public function userNameIsValid($name) {
		
		// no blank names
		if ($name==null) {
			
			$this->errName = 'Name cannot be blank.';
			return false;
		}
		
		// $name is only allowed to contain a-z, A-Z, hypens, apostrophes amd spaces 
		if(!preg_match("/^[a-zA-Z- ' ']+$/", $name) == 1) {
    		
			$this->errName = 'Name can only contain letters (a-z), hypens, apostrophes and spaces.';
			return false;
		}

		// the first character must also be a letter
		if(!preg_match("/^[a-zA-Z]+$/", $name[0]) == 1) {
			
			$this->errName = 'Name must start with a letter.';
			return false;
		}

		// check there is no sequence of two or more hypens or apostrophes
		for ($i=0; $i<strlen($name)-1; $i++) {
			
			// this and next value in the string
			$current_value 	= $name[$i];
			$next_value 	= $name[$i+1];
			
			// if curr and next values are either chars then false
			if (($current_value	=="'" || $current_value	=='-') &&
				($next_value	=="'" || $next_value	=='-')) {
				
				$this->errName = 'Name cannot contain a sequence of two or more hypens and apostrophes';
				return false;		
			}
		}

		// no exceptions triggered - valid		
		return true;
	}
	
	
	// check the email is valid 
	public function emailIsValid($email) {
		
		// no null emails
		if ($email==null) {
			
			$this->errEmail = "The email field cannot be null.";
			return false;
		}
		
		// check that there is one and only one instance of '@'
		$atCount = substr_count($email, '@');
		if ($atCount != 1 || $atCount == null) {
			
			$this->errEmail = "Email cannot have more than one '@'.";
			return false;
		}
		
		// find the @ position
		$mid = strpos($email, '@');
		
		// if the @ is at the start or the end then it's invalid
		if ($mid==0 || $mid==strlen($email)-1) {
			
			$this->errEmail = "Your email's '@' should be surrouded by characters.";
			return false;
		}
		
		// split the string into lhs and rhs the @
		$lhs = substr($email, 0, 	 $mid);
		$rhs = substr($email, $mid+1, strlen($email)-1);
		
		// check if both sides of the email are valid
		$lhs_res = $this->emailSideIsValid($lhs);
		$rhs_res = $this->emailSideIsValid($rhs);
		
		// return false if invalid
		if ($lhs_res==0 || $rhs_res==0) {
			
			return false;
		}
		
		// no exceptions triggered - valid
		return true;
	}
	
	
	// check email strings - used by emailIsValid
	private function emailSideIsValid($side) {
		
		// email strings should only contain a-z, A-Z, dots or hypens.
		if(	!preg_match("/^[a-zA-Z-.]+$/", $side)== 1) {
			
			$this->errEmail = "Either side of the '@' must contain only a-z, dots and/or hyphens.";
			return false;
		}
		
		// each side of the '@' cannot end in a dot or a hypen
		$last_char = $side[strlen($side)-1];
		if($last_char=="-" || $last_char=='.') {
			
			$this->errEmail = "Strings on both sides of the '@' must not end in a dot or hyphen.";
			return false;
		}
		
		// made it through without error
		return true;
	}
	

	// reserve a slot for a user
	// the user must not already be signed up to this tutorial
	// there must be a spot available
	public function reserveSlot($time_selection, $studentEmail, $studentName) {
		
		// Attempt to insert into the db
		try {

			// Return the tutorial id number
			// -- key is actually always 0 because of the index swap above
			$key = array_search($time_selection, array_column($this->times, '1'));

			// tutorial id time 
			$tutId = $this->times[$key][0];

			// tutorial name at this location
			$tutTime = $this->times[$key][1];

			//is the student already signed up to this tutorial?
			if ($this->alreadySignedUp($tutId, $studentEmail)==0) {
				
				$this->bookingStr = "User already signed up for this tutorial.";
				return false;
			}
			
			// are any seats free? 
			// -- if the time_selected does not match time in the array, somebody else has booked before the user
			if ($this->seatsAreFree($tutId)==0 || $tutTime!=$time_selection) {
				
				$this->bookingStr = "No seats available.";
				return false;
			}
			
			// setup for transaction
			$this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
			$this->pdo->beginTransaction();
			
			// name of the stored procedure and params
			$stored_proc = $this->pdo->prepare("CALL reserve_Seat(:tutid, :studentEmail, :studentName)");
			
			// bind all the variables to the params
			$stored_proc->bindParam(':tutid', $tutId);
			$stored_proc->bindParam(':studentName', $studentName);
			$stored_proc->bindParam(':studentEmail', $studentEmail);
			
			// execute the stored procedure
			$stored_proc->execute();
			
			// commit to the action
			$this->pdo->commit();
			
			// No issues encountered - booking made
			return true;
		}
		// an error has been hit
		catch (PDOException $err) {
			
			// rollback on error
			$this->pdo->rollBack();
			// don't kill the application as the user may be able to make an alternate booking
			$this->bookingStr = "error: " . $err->getMessage();
			return false;
		}
	}
	
	
	// is the user already signed up for this module at this time?
	private function alreadySignedUp($tutId, $studentEmail) {
		
		// Check if the student is already signed up to the tutorial
		$sp = $this->pdo->prepare("CALL is_Signed_Up_For(:tutId, :studentEmail)");
		
		$sp->bindParam(':tutId', $tutId);
		$sp->bindParam(':studentEmail', $studentEmail);
		
		$sp->execute();
		$rows = $sp->rowCount();
		
		// if there is a return, the student is already signed up
		if ($rows > 0) {
			
			return false;
		}
		
		return true;
	}
	
	
	// are there any seats free for this tutorial?
	private function seatsAreFree($tutId) {

		$sql_ = "CALL get_Tutorial_Availability(:tutId)";

		$query = $this->pdo->prepare($sql_);
		$query->bindParam(':tutId', $tutId);

		$query->execute();

		$q = $query->fetchAll();
		
		// return how many free seats there are in the selected tutorial
		foreach ($q as $seats) {
			
			$freeSeats = (int)$seats['freeSeats'];
			if ($freeSeats < 1 ) {

				return false;
			}
		}
		
		return true;
	}


	// get the last error associated with the email input
	public function getEmailError() {
	
		if ($this->errEmail!=null) {
			
			return $this->errEmail;
		}
		
		return null;
	}
	

	// get the last error associated with the name input
	public function getNameError() {
		
		if ($this->errName!=null) {
			
			return $this->errName;
		}
		
		return null;
	}


	// get the booking string
	public function getBookingInfo() {

		if ($this->bookingStr!=null) {

			return $this->bookingStr;
		}

		return null;
	}
}
?>


<?php
/* This class provides the connection to the mySql server using PDO */
class dbConnection {
	
	// db connection
	private $pdo;

	// db connection params
	private $userName;
	private $dbName;
	private $password;
	private $hostName;
	

	// setup the db connect and check it works
	public function __construct($host, $db, $user, $pass) {
		
		$this->userName = $user;
		$this->password = $pass;
		$this->dbName 	= $db;
		$this->hostName = $host;
		
		try {
			// establish db connection using parameters
			$this->pdo = new PDO("mysql:host=$this->hostName; dbname=$this->dbName", $this->userName, $this->password);
			
			// using mysql which supports prepared statements
			$this->pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, FALSE);

		}
		// throw an error if the connection fails
		catch (PDOException $err) {
			die("error: " . $err->getMessage()); 
		}
	}
	

	// return the connection
	public function getConnection() {
		
		return $this->pdo;
	}
}
?>


<?php
/*	This is class contains ultility functions to reduce code in the main */

class htmlBuilder {

	// append an item to the html
	public function appendHere($doc, $where, $what) {

		$item 	= $doc->getElementById($where);
		$append = $doc->createElement('p', $what); 

		$item->appendChild($append);
    }
    
    // append each item to the dropdowns
    public function populateDropDown($doc, $form, $placement, $name) {

        //get the element you want to append to
        $box 	    = $doc->getElementById($placement);

        // get the mods
        $selection 	= filter_input(INPUT_POST, $name);
        
        // check the input type
        if ($name=='mod') {
            $items	= $form->getModuleOptions($selection);

            // append each module to the first drop down
            foreach ($items as $item) {
        
                $append	= $doc->createElement('option', $item);
                $box->appendChild($append);
            }
        }
        else if ($name=='time') {
            $items      = $form->getTimeOptions($selection);

            // append each module to the first drop down
            foreach ($items as $item) {
        
                $append	= $doc->createElement('option', $item[1]);
                $box->appendChild($append);
            }
        }
        else {

            echo 'error - no matching query for items';
            exit;
        }
    }
}
?>


<?php 
/* 	This is the main, produces the html structure
	Calls from the classes above to
		- communicate with mySql database
		- establish if there are spaces available on any of the tutorials/practical sessions
		- populate the form drop downs
		- validate the form textbox inputs
		- request a booking

	Last Modified: 	16/12/2020
	By:			 	Rob Lamprell
*/

// start the user session
session_start();

// db info
$host = 'studdb.csc.liv.ac.uk';
$db   = 'sgrlampr';
$user = 'sgrlampr';
$pass = 'tiggie23';

// create connection 
$db 	= new dbConnection($host, $db, $user, $pass);
$pdo 	= $db->getConnection();

// initate form rules
$form	= new formInteractions($pdo);
$htmlB	= new htmlBuilder();

// if there are no seats free at all
$spacesAvailable = $form->getAllAvailableSpaces();
if (!$spacesAvailable) {
	
	echo 'Sorry, all practical sessions are fully booked.';
	exit;
}

// Name and email inputs (from previous entries)
$studentName 	= filter_input(INPUT_POST, 'fullName');
$studentEmail 	= filter_input(INPUT_POST, 'email');

// html base for input form
// sets out the structure of the page
$html = 
'
<!DOCTYPE html>
<html lang="en-GB">
<html>
	<head>
		<!--Tab text-->
		<title>Rob Lamprell - Practical Sessions</title>
		
		<!--meta data-->
		<meta charset="UTF-8">
	
		<meta name="author"         content="Rob Lamprell">
		<meta name="description"    content="A form to book practical sessions each week">
		<meta name="keywords"       content="Forms, Practicals, PHP">

	</head>

	<!--Webpage-->
	<body>
		<header>
			<h1>Practical Session Bookings</h1>
		</header>

		<main>
			<!--A Form for a student to choose a tutorial time-->
			<section>
			<h1>Fill in the form below and press submit: </h1>
			<form method="POST" action="practicals.php">
			
				<!--Choose a Module-->
				<label for="Modules">Choose a Module:</label>
				<!--On Selection get the times associated with the new module-->
				<select name="mod" id="module" onchange="this.form.submit()">
				</select>
				
				<!--Choose a Time-->
				<br><br>
				<label for="Times">Choose a Time:</label>
				<select name="time" id="times">
				</select>
				
				<!--Enter your name-->
				<br><br>
				<label for="name">Name:</label>
				<input type="text" name="fullName" id="name" value="' . $studentName . '">
				<label id="nameErr"></label>
				
				<!--Enter your email-->
				<br><br>
				<label for="email">email:</label>
				<input type="text" name="email" id="email" value ="'. $studentEmail . '">
				<label id="emailErr"></label>
				
				<!--Submit the form-->
				<br><br>
				<input type="hidden" name="update">
				<input type="submit" name="reserve" value="Submit" onClick="window.location.reload()">
				<label id="requestOutcome"></label>
				
			</form>
			</section>
		</main>       
	</body>
</html>
';

// initialise DOM
$doc = new DOMDocument(); 
$doc->loadHTML($html);


/* Populate the page based on pre-button-submit */
// get the modules from the db
$form->getModules();

// Populate Modules Drop down
$nameBox = $doc->getElementById('module');
$htmlB->populateDropDown($doc, $form, 'module', 'mod');

// Populate Times Drop down
$timeBox = $doc->getElementById('times');
$htmlB->populateDropDown($doc, $form, 'times', 'time');


// if the button is pressed display any errors
$buttonPress = filter_input(INPUT_POST, 'reserve');
if (isset($buttonPress)) {
    
    // save the name if valid
    $validName 	    = $form->userNameIsValid($studentName);
    $studentName    = ($validName  ? filter_input(INPUT_POST, 'fullName') : "");

    // save the email if valid
    $validEmail     = $form->emailIsValid($studentEmail);
    $studentEmail   = ($validEmail ? filter_input(INPUT_POST, 'email') : "");

	// get the positions of name and email
	$name 	= $doc->getElementById('name');
	$email 	= $doc->getElementById('email');
	
	// insert both as values for the input boxes
	$name->setAttribute("value", 	$studentName);
	$email->setAttribute("value", 	$studentEmail);
	
	// if invalid inform the user there was no booking - get errors
	$formIsValid = $validName && $validEmail;
	if (!$formIsValid) {
		
		$errName 		= $form->getNameError();
		$errEmail 		= $form->getEmailError();

		$bookingAttempt = "Booking Failed.  Invalid form - see above.";
	}
	
	// if the form is fine - attempt to make a booking
	else {
		
		// get the most recent selection
		$mod_selection		= filter_input(INPUT_POST, 'mod');
		$time_selection 	= filter_input(INPUT_POST, 'time');

		$bookingWasSuccess 	= $form->reserveSlot($time_selection, $studentEmail, $studentName);
		$bookingInfo 		= $form->getBookingInfo();
		
		// if the booking was a sucess then get
		if ($bookingWasSuccess) {

			$bookingAttempt = "Booking Successful!";
		}
		else {

			$bookingAttempt = "Booking Failed.";
		}

		// Append the module and time
		$bookingAttempt .= '  (' . $mod_selection . ', ' . $time_selection . ')';
	}
}

// append the name, email and output errors (or results)
$htmlB->appendHere($doc, 	'nameErr', 			$errName);
$htmlB->appendHere($doc,	'emailErr', 		$errEmail);

$htmlB->appendHere($doc,	'requestOutcome',	$bookingInfo);
$htmlB->appendHere($doc,	'requestOutcome',	$bookingAttempt);


/* Post-button-submit -- Remove previous information and re-populate incase any times/modules are fully booked now */
// if there are no seats free at all
$spacesAvailable = $form->getAllAvailableSpaces();
if (!$spacesAvailable) {

	echo $bookingAttempt;
	echo '<br>';
	echo '<br>';
	echo 'All practical sessions are fully booked.';

	exit;
}

// Remove all the drop down info from pre-booking section
while ($nameBox->hasChildNodes()) {
    $nameBox->removeChild($nameBox->firstChild);
}
while ($timeBox->hasChildNodes()) {
    $timeBox->removeChild($timeBox->firstChild);
}


// Repopulate drop-downs -- This will ensure we capture if the module is now fully booked
$form->getModules();

// Repopulate Modules Drop down
$nameBox = $doc->getElementById('module');
$htmlB->populateDropDown($doc, $form, 'module', 'mod');

// Repopulate Times Drop down
$timeBox = $doc->getElementById('times');
$htmlB->populateDropDown($doc, $form, 'times', 'time');


// print the dom to html
echo $doc->saveHTML();	

// end the session
session_unset();
session_destroy();
?>