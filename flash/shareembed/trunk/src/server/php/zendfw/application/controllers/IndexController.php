<?
require_once 'Zend/Controller/Action.php';
require_once 'Zend/Session/Namespace.php';

class IndexController extends Zend_Controller_Action
{

	protected $config;
	protected $session;
	

    
    protected function initConfig()
    {
    	$this->config = Zend_Registry::get('config');
    }
    
    protected function initSession()
    {
    	Zend_Session::setOptions($this->config->tokenSession->toArray());
    	Zend_Session::start();
    	
    	$this->_session = new Zend_Session_Namespace('TokenCheck');
    	
    }
    
	
    
    public function init()
    {
    	$this->initConfig();
        $this->initSession();
        
       
    }
    
    public function preDispatch()
    {
             

    }
    
    public function indexAction()
    {		
		
		$this->_session->referringURL =  "http://".$_SERVER["HTTP_HOST"].$_SERVER["REQUEST_URI"];
    	$this->view->emailToken = $this->_helper->csrf->getToken();	
    }
    
    
    public function tokenAction()
    {
    	//error_reporting(0);
    	$this->_helper->viewRenderer->setNoRender();
    	
    	if ($this->_session->referringURL == $_SERVER["HTTP_REFERER"] && isset($_SERVER["HTTP_REFERER"]))
    	{
        	$this->getResponse()->appendBody(Zend_Json::encode(array("token"=>$this->_helper->csrf->getToken())));
    	} elseif (!isset($_SERVER["HTTP_REFERER"])) {
    		throw new Zend_Service_Exception(Zend_Json::encode(array("error"=>'No referer')));
    	} else {
    		throw new Zend_Service_Exception(Zend_Json::encode(array("error"=>sprintf("Referer %s is not allowed",$_SERVER["HTTP_REFERER"]))));
    	}
    }
    
    
    
	
}
?>