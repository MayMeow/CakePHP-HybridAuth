# CakePHP2.x-HybridAuth plugin
Cakephp HybridAuth Plugin created according to the tutorial http://miftyisbored.com/complete-social-login-application-tutorial-cakephp-2-3-twitter-facebook-google/

It using HybridAuth library http://hybridauth.sourceforge.net/

##The Setup

Copy Folder HybridAuth into plugins at your project

To activate this plugin you have to edit some files:

###app\config\bootstrap.php
add this to end of file
```php
CakePlugin::load('Hybridauth', array('bootstrap' => false, 'routes' => false));
```

###app\config\routes.php
we need register some paths
```php
   /**
     * HybridAuth
     */
    Router::connect('/social_login/*', array( 'controller' => 'users', 'action' => 'social_login'));
    Router::connect('/social_endpoint/*', array( 'controller' => 'users', 'action' => 'social_endpoint'));
```

##Update models
we create new model Social profile
```php
<?php
App::uses('AppModel', 'Model');
App::uses('AuthComponent', 'Controller/Component');
/**
 * SocialProfile Model
 *
 * @property User $User
 */
class SocialProfile extends AppModel {


	//The Associations below have been created with all possible keys, those that are not needed can be removed

/**
 * belongsTo associations
 *
 * @var array
 */
	public $belongsTo = array(
		'User' => array(
			'className' => 'User',
			'foreignKey' => 'user_id',
			'conditions' => '',
			'fields' => '',
			'order' => ''
		)
	);
}
```
and update User Model - add this to User.php

```php
    public $hasMany = array(
        'SocialProfile' => array(
            'className' => 'SocialProfile',
        )
    );
```
##Update Controllers
add this lines to folowing files

###app\controllers\AppController.php

```php
 session_start();
```

###app\controllers\UsersController.php
use our new component
```php
 public $components = array('Hybridauth.Hybridauth');
```

add to auth allow in before filter.
```php
 'social_login', 'social_endpoint'
```
my looks like this:
```php
  public function beforeFilter() {
        parent::beforeFilter();
        //$this->Auth->allow('add');
        $this->Auth->allow('api_add', 'add', 'login', 'logout', 'api_login', 'api_logout', 'social_login', 'social_endpoint');

		if($this->request->is('OPTIONS')) {
			$this->response->statusCode(200);
			$this->response->send();
			$this->_stop();
			return true;
		}

    }
```
next we will need to following functions
```php
 /* social login functionality */
    public function social_login($provider) {
        if( $this->Hybridauth->connect($provider) ){
            $this->_successfulHybridauth($provider,$this->Hybridauth->user_profile);
        }else{
            // error
            $this->Session->setFlash($this->Hybridauth->error);
            $this->redirect($this->Auth->loginAction);
        }
    }

    public function social_endpoint($provider) {
        $this->Hybridauth->processEndpoint();
    }

    private function _successfulHybridauth($provider, $incomingProfile){

        // #1 - check if user already authenticated using this provider before
        $this->SocialProfile->recursive = -1;
        $existingProfile = $this->SocialProfile->find('first', array(
            'conditions' => array('social_network_id' => $incomingProfile['SocialProfile']['social_network_id'], 'social_network_name' => $provider)
        ));

        if ($existingProfile) {
            // #2 - if an existing profile is available, then we set the user as connected and log them in
            $user = $this->User->find('first', array(
                'conditions' => array('id' => $existingProfile['SocialProfile']['user_id'])
            ));

            $this->_doSocialLogin($user,true);
        } else {

            // New profile.
            if ($this->Auth->loggedIn()) {
                // user is already logged-in , attach profile to logged in user.
                // create social profile linked to current user
                $incomingProfile['SocialProfile']['user_id'] = $this->Auth->user('id');
                $this->SocialProfile->save($incomingProfile);

                $this->Session->setFlash('Your ' . $incomingProfile['SocialProfile']['social_network_name'] . ' account is now linked to your account.');
                $this->redirect($this->Auth->redirectUrl());

            } else {
                // no-one logged and no profile, must be a registration.
                $user = $this->User->createFromSocialProfile($incomingProfile);
                $incomingProfile['SocialProfile']['user_id'] = $user['User']['id'];
                $this->SocialProfile->save($incomingProfile);

                // log in with the newly created user
                $this->_doSocialLogin($user);
            }
        }
    }

    private function _doSocialLogin($user, $returning = false) {

        if ($this->Auth->login($user['User'])) {
            if($returning){
                $this->Session->setFlash(__('Welcome back, '. $this->Auth->user('username')));
            } else {
                $this->Session->setFlash(__('Welcome to our community, '. $this->Auth->user('username')));
            }
            $this->redirect($this->Auth->loginRedirect);

        } else {
            $this->Session->setFlash(__('Unknown Error could not verify the user: '. $this->Auth->user('username')));
        }
    }
```

after succesful first login we wat app to create new user profile. We can do this with this function at and of file

##app\Model\User.php
```php
  public function createFromSocialProfile($incomingProfile){

        // check to ensure that we are not using an email that already exists
        $existingUser = $this->find('first', array(
            'conditions' => array('email' => $incomingProfile['SocialProfile']['email'])));

        if($existingUser){
            // this email address is already associated to a member
            return $existingUser;
        }

        // brand new user
        $socialUser['User']['email'] = $incomingProfile['SocialProfile']['email'];
        $socialUser['User']['username'] = str_replace(' ', '_',$incomingProfile['SocialProfile']['display_name']);
        $socialUser['User']['role'] = 'user'; // by default all social logins will have a role of bishop
        $socialUser['User']['password'] = date('Y-m-d h:i:s'); // although it technically means nothing, we still need a password for social. setting it to something random like the current time..
        //$socialUser['User']['created'] = date('Y-m-d h:i:s');
        //$socialUser['User']['modified'] = date('Y-m-d h:i:s');

        // save and store our ID
        $this->save($socialUser);
        $socialUser['User']['id'] = $this->id;

        return $socialUser;


    }
```
##OH i forgot :)
add this lines to end of
###app\config\core.php
```php
/** 
 * HybridAuth component
 *
 */
 Configure::write('Hybridauth', array(
    // openid providers
    "Google" => array(
        "enabled" => true,
        "keys" => array("id" => "Your-Google-Key","secret" => "Your-Google-Secret"),
    ),
    "Twitter" => array(
        "enabled" => true,
        "keys" => array("key" => "Your-Twitter-Key", "secret" => "Your-Twitter-Secret")
    ),
    "Facebook" => array(
        "enabled" => true,
        "keys" => array("id" => "Your-Facebook-Key", "secret" => "Your-Facebook-Secret"),
    ),
    "OpenID" => array(
        "enabled" => false
    ),
    "Yahoo" => array(
        "enabled" => false,
        "keys" => array("id" => "", "secret" => ""),
    ),
    "AOL" => array(
        "enabled" => false
    ),
    "Live" => array(
        "enabled" => false,
        "keys" => array("id" => "", "secret" => "")
    ),
    "MySpace" => array(
        "enabled" => false,
        "keys" => array("key" => "", "secret" => "")
    ),
    "LinkedIn" => array(
        "enabled" => false,
        "keys" => array("key" => "", "secret" => "")
    ),
    "Foursquare" => array(
        "enabled" => false,
        "keys" => array("id" => "", "secret" => "")
    ),
));
```
