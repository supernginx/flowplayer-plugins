<?

$to      = $_POST["to"];
$subject = $_POST["subject"];
$message = $_POST["message"];
$headers = "From: ".$_POST["name"]."<".$_POST["email"].">\r\n" .
    "Reply-To: ".$_POST["name"]."<".$_POST["email"].">\r\n" .
    "X-Mailer: PHP/" . phpversion();

mail($to, $subject, $message, $headers);

?>
