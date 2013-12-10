<?php
/**
 * Include the API PHP file for neo4j
 */
 
namespace Everyman\Neo4j;
require("phar://neo4jphp.phar");
// These constants may be changed without breaking existing hashes.
define("PBKDF2_HASH_ALGORITHM", "sha256");
define("PBKDF2_ITERATIONS", 1000);
define("PBKDF2_SALT_BYTE_SIZE", 24);
define("PBKDF2_HASH_BYTE_SIZE", 24);

define("HASH_SECTIONS", 4);
define("HASH_ALGORITHM_INDEX", 0);
define("HASH_ITERATION_INDEX", 1);
define("HASH_SALT_INDEX", 2);
define("HASH_PBKDF2_INDEX", 3);


/**
 *	Create a graphDb connection 
 */
$client= new Client();

	//get the index
	$userIndex = new Index\NodeIndex($client, 'Users');
	$userIndex->save();
	
if(strcasecmp($_SERVER['REQUEST_METHOD'], 'POST')==0 && isset($_REQUEST['cat']) && strcasecmp($_REQUEST['cat'], 'Login')==0){
	$postContent = json_decode(@file_get_contents('php://input'));
    $email=$userIndex->findOne('email',$postContent->email);	
	if (sizeof($email)!=0){
		if(validate_password($postContent->password,$email->getProperty('password'))==1){
			print $email->getId();
		}else{
			print "FALSE";
		}
	}else{
		print "FALSE";
	}	
}else if(strcasecmp($_SERVER['REQUEST_METHOD'], 'POST')==0){
	// register method
/
	//get the json string post content
	$postContent = json_decode(@file_get_contents('php://input'));
	
	//create the node
	$userNode= $client->makeNode();
	
	//sets the property on the node
	$userNode->setProperty('email', $postContent->email)->setProperty('password',create_hash($postContent->password));
	
	//actually add the node in the db
	$userNode->save();
	
	//get properties on the node
	$userProps= $userNode->getProperties();
	
	$response= $userIndex->add($userNode, 'email', $userProps['email']);
	echo $response;
}else if( strcasecmp($_GET['method'],'getUserInfo') == 0){
	$userNode=$client->getNode($_GET['id']);
	foreach ($userNode->getProperties() as $key => $value) {
    echo "$key: $value\n";
	}
}else if(strcasecmp($_GET['method'], 'updateUser') ==0){
	//get the json string post content
	$postContent = json_decode(@file_get_contents('php://input'));
	
//	$index= new IndexService($graphDb);
	$user=$userIndex->findOne('email',$postContent->email);
	//$nodes= $index->getNodes("Users", "email", $_GET['email'] );

	if(sizeof($user) >0){
		if(strcasecmp($postContent->field, 'password') ==0){
			$hashword = $postContent->value;
			$user->setProperty('password', create_hash(hashword));
			$user->save();
			foreach ($user->getProperties() as $key => $value) {
				echo "$key: $value\n";
			}
			//continue this if/else statement for all other fields in the statement
			/*
			localhost?method=updateUser&user=paul
			{"field":"password", "value":"######"}
			*/
		}else if(strcasecmp($postContent->field, 'name') ==0){
			$user->setProperty('name', $postContent->value);
			$user->save();
			echo $user->getProperties();
		}else if(strcasecmp($postContent->field, 'company') ==0){
			$user->setProperty('company', $postContent->value);
			$user->save();
			foreach ($user->getProperties() as $key => $value) {
				echo "$key: $value\n";
			}
		}else if(strcasecmp($postContent->field, 'phone') ==0){
			$user->setProperty('phone', $postContent->value);
			$user->save();
			foreach ($user->getProperties() as $key => $value) {
				echo "$key: $value\n";
			}
		}else if(strcasecmp($postContent->field, 'title') ==0){
			$user->setProperty('title', $postContent->value);
			$user->save();
			foreach ($user->getProperties() as $key => $value) {
				echo "$key: $value\n";
			}
		}else if(strcasecmp($postContent->field, 'location') ==0){
			$user->setProperty('location', $postContent->value);
			$user->save();
			foreach ($user->getProperties() as $key => $value) {
				echo "$key: $value\n";
			}
		}else if(strcasecmp($postContent->field, 'email') ==0){
			$user->setProperty('email', $postContent->value);
			$user->save();
			foreach ($user->getProperties() as $key => $value) {
				echo "$key: $value\n";
			}
		}else{
			echo "no node updated";
		}
		

	}else{
		echo "FALSE node not found";
	}
}else{
	echo $_SERVER['REQUEST_METHOD'] ." request method not found";
}









/*
 * Password Hashing With PBKDF2 (http://crackstation.net/hashing-security.htm).
 * Copyright (c) 2013, Taylor Hornby
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, 
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation 
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 */



function create_hash($password)
{
    // format: algorithm:iterations:salt:hash
    $salt = base64_encode(mcrypt_create_iv(PBKDF2_SALT_BYTE_SIZE, MCRYPT_DEV_URANDOM));
    return PBKDF2_HASH_ALGORITHM . ":" . PBKDF2_ITERATIONS . ":" .  $salt . ":" .
        base64_encode(pbkdf2(
            PBKDF2_HASH_ALGORITHM,
            $password,
            $salt,
            PBKDF2_ITERATIONS,
            PBKDF2_HASH_BYTE_SIZE,
            true
        ));
}

function validate_password($password, $correct_hash)
{
    $params = explode(":", $correct_hash);
    if(count($params) < HASH_SECTIONS)
       return false;
    $pbkdf2 = base64_decode($params[HASH_PBKDF2_INDEX]);
    return slow_equals(
        $pbkdf2,
        pbkdf2(
            $params[HASH_ALGORITHM_INDEX],
            $password,
            $params[HASH_SALT_INDEX],
            (int)$params[HASH_ITERATION_INDEX],
            strlen($pbkdf2),
            true
        )
    );
}

// Compares two strings $a and $b in length-constant time.
function slow_equals($a, $b)
{
    $diff = strlen($a) ^ strlen($b);
    for($i = 0; $i < strlen($a) && $i < strlen($b); $i++)
    {
        $diff |= ord($a[$i]) ^ ord($b[$i]);
    }
    return $diff === 0;
}

/*
 * PBKDF2 key derivation function as defined by RSA's PKCS #5: https://www.ietf.org/rfc/rfc2898.txt
 * $algorithm - The hash algorithm to use. Recommended: SHA256
 * $password - The password.
 * $salt - A salt that is unique to the password.
 * $count - Iteration count. Higher is better, but slower. Recommended: At least 1000.
 * $key_length - The length of the derived key in bytes.
 * $raw_output - If true, the key is returned in raw binary format. Hex encoded otherwise.
 * Returns: A $key_length-byte key derived from the password and salt.
 *
 * Test vectors can be found here: https://www.ietf.org/rfc/rfc6070.txt
 *
 * This implementation of PBKDF2 was originally created by https://defuse.ca
 * With improvements by http://www.variations-of-shadow.com
 */
function pbkdf2($algorithm, $password, $salt, $count, $key_length, $raw_output = false)
{
    $algorithm = strtolower($algorithm);
    if(!in_array($algorithm, hash_algos(), true))
        trigger_error('PBKDF2 ERROR: Invalid hash algorithm.', E_USER_ERROR);
    if($count <= 0 || $key_length <= 0)
        trigger_error('PBKDF2 ERROR: Invalid parameters.', E_USER_ERROR);

    if (function_exists("hash_pbkdf2")) {
        // The output length is in NIBBLES (4-bits) if $raw_output is false!
        if (!$raw_output) {
            $key_length = $key_length * 2;
        }
        return hash_pbkdf2($algorithm, $password, $salt, $count, $key_length, $raw_output);
    }

    $hash_length = strlen(hash($algorithm, "", true));
    $block_count = ceil($key_length / $hash_length);

    $output = "";
    for($i = 1; $i <= $block_count; $i++) {
        // $i encoded as 4 bytes, big endian.
        $last = $salt . pack("N", $i);
        // first iteration
        $last = $xorsum = hash_hmac($algorithm, $last, $password, true);
        // perform the other $count - 1 iterations
        for ($j = 1; $j < $count; $j++) {
            $xorsum ^= ($last = hash_hmac($algorithm, $last, $password, true));
        }
        $output .= $xorsum;
    }

    if($raw_output)
        return substr($output, 0, $key_length);
    else
        return bin2hex(substr($output, 0, $key_length));
}



?>
