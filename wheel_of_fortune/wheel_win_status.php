<?php

include("lib/LIB_http.php");
include("lib/LIB_parse.php");


$emailHeaders = "MIME-Version: 1.0" . "\r\n";
$emailHeaders .= "Content-type:text/html;charset=UTF-8" . "\r\n";
$emailHeaders .= 'From: SERVER' . "\r\n";

$email = "<ENTER EMAIL HERE>";
$pass = "<ENTER PASSWORD HERE>";
$url = "https://www.wheeloffortune.com/account/Login";
$x = rand(100,300);
$y = rand(100,300);
$rememberMe = "false";
$returnUrl = "https://www.wheeloffortune.com/Widget/SpinTestModal";
$data = "x=".$x."&y=".$y."&RememberMe=".$rememberMe."&ReturnUrl=".$returnUrl;
$data .= "&LoginEmail=".$email."&LoginPassword=".$pass;

$curl = curl_init();
curl_setopt($curl, CURLOPT_URL, $url);
curl_setopt($curl, CURLOPT_POST, TRUE);
curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
curl_setopt($curl, CURLOPT_USERAGENT, WEBBOT_NAME);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($curl, CURLOPT_FOLLOWLOCATION, TRUE);
curl_setopt($curl, CURLOPT_COOKIEJAR, "cookies.txt");
curl_setopt($curl, CURLOPT_COOKIEFILE, "cookies.txt");

$webpage = curl_exec($curl);
curl_close($curl);


/*****************************************************/
/* SIMULATE locked/not locked out account            */
/*****************************************************/
//$webpage = "<div class=\"validation-summary-errors\">You are locked out.</div>";
//$webpage = "<div class=\"validation-summary-errors\">You have logged in.</div>";


/*****************************************************/
/* SIMULATE winner/not a winner                      */
/*****************************************************/
//$webpage = "<h3>Sorry, you are not a winner!</h3>";
//$webpage = "<h3>You are a winner!</h3>";


// ** Get SPIN ID Winner Status ** //

/*****************************************************/
/* The following HTML <div> tag displays             */
/* account errors when logging in.                   */
/* Parse that tag to grab the status of my account.  */
/*                                                   */
/* Check if account is locked out.                   */
/*****************************************************/
$acctArray = parse_array($webpage, "<div class=\"validation-summary-errors\"", "</div>");
if (isset($acctArray) && !empty($acctArray[0])) {
    $result = str_replace("<div class=\"validation-summary-errors\">","",$acctArray[0]);
    $result = str_replace("</div>","",$result);
    $acctArrayPos = strpos($result, "locked");

    if ($acctArrayPos !== false) {
        $status = "<font color='red'>There is a problem with your account.</font><br><br>";
        $status .= "Please login to troubleshoot.<br><br>https://www.wheeloffortune.com/account";
        mail($email,"Wheel of Fortune Account ERROR",$status,$emailHeaders);
    }
}

/*****************************************************/
/* The HTML <h3> tag stores the                      */
/* winner/not winner status.                         */
/* Parse that tag and grab the status                */
/* to determine if I won.                            */
/*                                                   */
/* Email me if I won. But only email me once a week  */
/* if I didn't win -- I don't needs tons of emails.  */
/*****************************************************/
$statusArray = parse_array($webpage, "<h3", "</h3>");
if (isset($statusArray) && !empty($statusArray)) {
    foreach ($statusArray as $result) {
        $result = str_replace("<h3>","",$result);
        $result = str_replace("</h3>","",$result);
        $resultPos = strpos($result, "not a winner!");

        if ($resultPos !== false) {
            $day = date("l");

            if ($day == "Friday") {
                $status = "<font color='red'><strong>STATUS:</strong></font> " . $result;
                $status .= "<br><br>You have not won this week.<br><br>https://www.wheeloffortune.com/account";
                mail($email,"Wheel of Fortune SPIN ID Weekly Report",$status,$emailHeaders);
            }
            // ** Uncomment below for "Daily Report" ** //
            /*$status = "<font color='red'><strong>STATUS:</strong></font> " . $result;
            $status .= "<br><br>NOT A WINNER<br><br>https://www.wheeloffortune.com/account";
            mail($email,"Wheel of Fortune SPIN ID Daily Report",$status,$emailHeaders);*/
        } else {
            // ** Send immediate email if won ** //
            $status = "<font color='red'><strong>STATUS:</strong></font> " . $result . "<br><br>WINNER!<br><br>";
            $status .= "<strong><u>Please login to claim prize</u></strong><br>https://www.wheeloffortune.com/account";
            mail($email,"Wheel of Fortune SPIN ID WINNER!!!",$status,$emailHeaders);
        }
    }
}
?>
