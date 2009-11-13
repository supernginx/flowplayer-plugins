<?
require_once 'Zend/Loader/AutoLoader.php';
require_once 'Zend/Controller/Front.php';
require_once 'Zend/Config/Xml.php';
require_once 'Zend/Controller/Router/Route.php';



$autoloader = Zend_Loader_Autoloader::getInstance();

$config = new Zend_Config_Xml('../application/config/config.xml', 'production');

$auth = Zend_Auth::getInstance();

$registry = Zend_Registry::getInstance();
$registry->set('auth',$auth);
$registry->set('config', $config);

Zend_Controller_Front::run('../application/controllers');

?>