<?
require_once 'Zend/Controller/Action.php';
require_once 'Zend/Session/Namespace.php';

class IndexController extends Zend_Controller_Action
{
	protected $auth;
	protected $config;
	protected $session;
	
	protected function initAuth()
    {
    	$this->auth = Zend_Registry::get('auth');
    }
    
    protected function initConfig()
    {
    	$this->config = Zend_Registry::get('config');
    }
    
    protected function initSession()
    {
    	$this->session = $this->auth->getStorage()->read();
    }
    
    public function init()
    {
    	$this->initConfig();
        //$this->checkAuth();
        $this->initAuth();
        $this->initSession();
        
        if ($this->config->mail->backend == "smtp")
        {
        	$tr = new Zend_Mail_Transport_Smtp($this->config->mail->smtp->host, $this->config->mail->smtp->options->toArray());
			Zend_Mail::setDefaultTransport($tr);
        }
    }
    
    public function preDispatch()
    {
             
       $this->_helper->viewRenderer->setNoRender();

            
       $this->subject = $this->_request->getParam('subject');
       $this->message = $this->_request->getParam('message');
       $this->name = $this->_request->getParam('name');
       $this->email = $this->_request->getParam('email');
       $this->to = $this->_request->getParam('to');
    }
    
    public function indexAction()
    {
		if ($this->_request->isPost())
		{
	    	$mail = new Zend_Mail();
	    	$mail->setHeaderEncoding(Zend_Mime::ENCODING_BASE64);
			$mail->setBodyText($this->subject);
			$mail->setFrom($this->email, $this->name);
			
			$emails = explode(",", $this->to);

			
			foreach ($emails as $value)
			{
				$mail->addTo($value);
			}
			
	
			$mail->setSubject($this->subject);
			$mail->setBodyText($this->message);
			$mail->setBodyHtml($this->message);
	
			$mail->send();
		} 
    }
    
    
    
    
	
}
?>