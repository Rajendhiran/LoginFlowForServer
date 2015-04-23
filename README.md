# The Login Flow [Server's Perspective]
The goal of this document is to provide an overview of a consistent way for **Login Process** between `server` and `client`. It focuses on the flows, common practices and conventions of industry of authentication mechanisms rather than specific technology stack frameworks such as [Ruby on Rails](http://rubyonrails.org/), [Sails.js](http://sailsjs.org/), [Laravel](http://laravel.com/) and whatnots.

## Prototype
The prototype of this login workflow can be found at [https://login-flow.herokuapp.com](https://login-flow.herokuapp.com). This prototype is meant for *mobile developers* (aka. `client` application) to implement the client side of the login process in their respective platform. *Server developers* can also leverage of the existing flow code as a guide to implement the server side as well.

This sample project is written in *Ruby on Rails* as a generic approach to bridge between server and client and therefore server developers should feel free **NOT** to *strictly* follow everything here. However, one should note that other than specific implementations, we should stick to common API contract interface elaborated below.

## Login Types
The current suggested **Login Process** types now are:

* Login through **email** and **password**: user needs to sign in with his/her email and password. It means user needs to register and verify their email before they can successfully login.
* Login through **Facebook**: user can login through Facebook in which the `server` redirects user to Facebook Login page with permission request. Once permissions are granted, user will be redirected back to web as *logged in* user of the application.

These two login types are the basic building block to be used across the applications for consistency and convenience. It helps our sale teams to consistently provide options for clients and helps our engineering teams to quickly set up authentication system in a single standard workflow for 2359 Media.

From server point of view, we will implement one way of login flow only. We combine both login types for every project. On the other hand, client/mobile can choose the number of ways to support based on the project.

## Terminologies
* `client`: mobile client (android/ios) connecting to server for retrieve data. This is the API consumer.
* `server`: API provider (Rails/NodeJS/php) that provides services for clients. Generally it is a central repository storing data and necessary information about clients. Moreover, all business logics are implemented here. One should note that client can communicate with server transparently: meaning that client does not need to know how server is implemented (either in Ruby, Java, and the likes) as long as server offers the contract API interface.
* `access_token`: a scramble piece of string to authenticate and authorize data consumer. Simply put, `access_token` can be considered as *physical key* to unlock the door (server gate) before you can enter the building (server). This `access_token` is provided by `server` and to be used by `client`. `client` needs to attach this `access_token` information for every request to `server`. This token can be embedded in HTTP header, query string, or body of the request.
* access token `bearer`: is the term used in **OAuth** protocol to refer to the API consumer. We will just assume that `bearer` and `client` are the same entity in this context.

## How `client` retrieves data from `server`
When `client` wants to retrieve/requestion information from `server`, it follows the following flow:

```
1. client ----(request data)----> server
2. server receives request from clients
3. server checks if `access_token` is provided or valid
  if access_token is valid
    return intended data
  else
    return error result indicating the possible problems
  end
```

Not every request requires `access_token` or some sort of authentication. This is because there are some requests that cannot be required to provide authentication such as *Registering New User*. Therefore, one should pay attention to the **required** *parameters* prefixed with asterisk `*`. The `access_token` is a *time-sensitive* token in which it will expire at some point in the future. Hence, `client` **MUST** take into consideration for this case.

Our scenario so far is limited to *stateless* HTTP protocol in which `client` initiate the action to the `server`. This flow is different from **bidirectional** flow in which `server` can push data to the `client` when necessary. Since our login process does not require *reactive* state from server, we will not include this feature in our workflow here.


## How `client` requests `access_token` from `server`
`client` is the API consumer from the API provider `server`, and `server` has role to provide `access_token` on demand. When `client` does not have `access_token` or receives error response from `server` due to invalid or expired `access_token`, it needs to request for new `access_token` through API call (either by *Facebook* or *email/password* methods). We **DO NOT** support **TOKEN RENEWAL** through API because we want to simplify the flow and amount of API endpoints.

```
1. client ----(login through API call by `Facebook` or `email/password`)----> server
2. server validates and returns `access_token`
```

P.S: This is **NOT** OAuth *acting on behalf of* flow, meaning that the `server` you are developing is not a 3<sup>nd</sup> party application requesting user's resource on another resource server/endpoint;  your `server` application is the *resource server* itself. Therefore `client` does not need to provide information such as `client_id` and `client_secret`. For more information about this flow, you can check it [here]
(https://tools.ietf.org/html/rfc6749#section-1.3.3)


### Facebook Login
This login is through Facebook's `token` which is different from our `server`'s `access_token`. The assumption here is that `client` is integrated with Facebook SDK and therefore it can retrieve Facebook's `token` with some preset permissions.

```
0. client (mobile app) integrates Facebook SDK
---------------------------------
1. end user tries to access server's resource but yet logged in
2. client redirects end user to login and authorize permissions in Facebook
3. client receives Facebook's token
4. client requests login to server with Facebook's token
5. server returns access_token
```

* Endpoint: `/api/v1/oauth/token`
* Method: `POST`
* Params: `*grant_type` = `password`, `*facebook_token`
* Note: you must supply the parameter `grant_type` with value of `password` to consistently match with OAuth  credential login type.

Response with (success) HTTP status: `200`
```json
{
  "access_token": "fc9f440034c112bfc3ca8d43d0c7fdae0eb1c1ea5d3f7c0afdd2f9451c8906cc",
  "token_type": "bearer",
  "expires_in": 2592000,
  "created_at": 1428481781
}
```

Response with (failed) HTTP status: `401`
```json
{
  "status_code": 49802,
  "error": {
    "message": "facebook_invalid_token: Invalid Facebook token"
  }
}
```

If we pay attention to expiry in successful response, we see that it varies from application to application. Thus for the sake of simplicity and consistency, we would like to suggest token expiry period to be **30 Days** from the moment `server` replies this successful response.

For debugging purpose, you can always access your personal Facebook Developer page to retrieve temporary Facebook token through [Graph API Explorer](https://developers.facebook.com/tools/explorer).


### Email/Password Login
This login is through `email/password`. This is very similar to the above Facebook's login method, but instead of `client` does the heavy job of redirecting user to Facebook page to grant permission, `client` just needs to represent `email` and `password` input fields for user to key in and relay this information to the server for validation.

```
1. client requests login to server with `email/password`
2. server returns `access_token`
```

* Endpoint: `/api/v1/oauth/token`
* Method: `POST`
* Params: `*grant_type` = `password`, `*username`, `*password`
* Note:
  * you must supply the parameter `grant_type` with value of `password` to consistently match with OAuth  credential login type.
  * `username`: this is an email. The reason we use the parameter name as `username` instead of `email` is that standard OAuth specs and other implementation use `username`, and therefore this is for consistency purpose.

Response with (success) HTTP status: `200`
```json
{
  "access_token": "fc9f440034c112bfc3ca8d43d0c7fdae0eb1c1ea5d3f7c0afdd2f9451c8906cc",
  "token_type": "bearer",
  "expires_in": 2592000,
  "created_at": 1428481781
}
```
This should not a stranger to you from Facebook login explained above. However, there are a few edge cases for *failed* cases in email/password flow:

Response with (failed [email is not found in server's database]) HTTP status: `401`
```json
{
  "status_code": 40401,
  "error": {
    "message": "username_password_user_does_not_exist: User does not exist"
  }
}
```

Response with (failed [password supplied is not valid]) HTTP status: `401`
```json
{
  "status_code": 49802,
  "error": {
    "message": "username_password_invalid_password: Invalid password"
  }
}
```

Response with (failed [password is valid but email is not verified]) HTTP status: `401`
```json
{
  "status_code": 40101,
  "error": {
    "message": "username_password_user_not_verified: User is not verified"
  }
}
```


One should note that the endpoints to request for `access_token` by *Facebook* and *email/password* are the same, namely `/api/v1/oauth/token`. However, Facebook login flow will take precedented if parameter `facebook_token` is given. As `client`, you should handle this as two separated cases for different login types.


### Other 3<sup>rd</sup> Party Login
Our goal here is to support *Facebook* and *Email/Password*, and therefore other third party authentications such Twitter or Google is considered as further customization. Additional support of login type should follow the suit of Facebook.


## Database Schema
In this login workflow, we do not dictate the database vendor or type (relational, document, key/value, graph) to be used, and it is really your choice for appropriate scenario in different applications. However, there should be a consistent database schema vectors that allow uniform implementation across applications.

In general applications that require authentication, we need to define some model or database table **user**. Conventionally, we define table as `users` (plural) and model as `User` (singular). This table/model holds information about end users who consume the application, and most of times, it is considered to be a `God` model/class because your application is commonly centered around the user. Therefore, there are high couplings between `User` model and other models.

You do not have to name your user model as `User`, and you probably call it as `Member`. Nonetheless, almost all applications refer this model as `User`; thus we should just follow the crowd.

## Consistent Fields in `users` Table
You have the choice to do whatever you want, but it will be very inconsistent with code used in this document, and therefore we suggest that you stick to the following names:
* The table of **user** model is `users` (modeled as `User`). You can define something else like `member`, but it's not recommended here.
* The required fields in this `users` table are `email` and `fid` (Facebook id as string). You can define *social network* table as an association for extensibility purpose in order to use other third party authentications, but we will focus on Facebook integration which is hard-wired in this table.


### Register New User Through Email/Password
User can register through API with the following details:

* Endpoint: `/api/v1/user`
* Method: `POST`
* Params: `*email`, `*password`

For successful response with HTTP status of `200`:
```javascript
{
  "status_code": 0,
  "status": "success"
}
```

For failed response (can't save because of validation) with HTTP status of `400`:
```javascript
{
    "status_code": 42200,
    "error": {
        "message": "Attributes are invalid",
        "full_messages": [
            "Name can't be blank"
        ]
    }
}
```

For failed response (email already exists) with HTTP status of `400`:
```javascript
{
    "status_code": 40002,
    "error": {
        "message": "Email already exists"
    }
}
```

Note: if user logins with Facebook (her email is already registered from Facebook), then it falls under category *Email already exists*.


### Update Email/Password
We allow user to update their `email` and `password` accordingly (user already logged in the app and posessed `access_token`). However we only use a single endpoint as follow:

* Endpoint: `/api/v1/user`
* Method: `PUT` or `PATCH`
* Params: `*access_token`, (`*email` | `*password`, `*old_password`)
* NOTE: this action is mutual exclusive between `email` and `password`. It only update **ONE** *attribute* at any one time. Parameter `email` is prioritized; it means that if this param `email` is given, it will ignore *change password* option. Therefore client should have two separated calls: one is for changing `email` and another is for changing `password`. `old_password` is required for *changing password* case.

For successful response with HTTP status of `200`:
```javascript
{
  "status_code": 0,
  "status": "success"
}
```

For failed response (invalid `access_token`) with HTTP status of `401`:
```javascript
{
    "status_code": 49800,
    "error": {
        "message": "Invalid access_token"
    }
}
```

For failed response (try to update the same email as existing) with HTTP status of `400`:
```javascript
{
  "status_code": 42200,
  "error": {
    "message": "Attributes are invalid",
    "full_messages": [
      "Trying to update the same email"
    ]
  }
}
```

For failed response (try to update email which already exists in other people's account) with HTTP status of `400`:
```javascript
{
  "status_code": 42200,
  "error": {
    "message": "Attributes are invalid",
    "full_messages": [
        "Email has already been taken"
    ]
  }
}
```

For failed response (no email or password provided) with HTTP status of `400`:
```javascript
{
  "status_code": 42200,
  "error": {
    "message": "Attributes are invalid",
    "full_messages": [
      "Nothing is updated"
    ]
  }
}
```


### Reset Password
This happens when user requests for *forget password* feature. The flow of this is that `client` mobile application calls forgetting password API which in turn sends out email to the user to verify authenticity of request. This is as far as the client app does the job, and the rest will be based upon web interface.

```
1. app requests password change (through API) to server.
2. server sends out email for user to verify
3. user receives email and activates the link
4. user (standing on the page from previous clicked email link) changes the new password.
5. page shows 'success action' and does nothing else
6. user needs to switch to the app manually
```

#### Resetting Password API
Server needs to implement the following API so that client can request in case of forgetting password:

* Endpoint: `/api/v1/user/forget_password`
* Method: `POST`
* Params: `*email`

For successful response with HTTP status of `200`:
```javascript
{
  "status_code": 0,
  "status": "success"
}
```

For failed response with HTTP status of `400`:
```javascript
{
  "status_code": 40400,
  "error": {
      "message": "Record not found"
  }
}
```

#### Resending Verification Email
This API is the same as *resetting password* API. You just need to issue the *same* call request as this is transparent from user of view.


### Sync Facebook account after logging Email/Password
This is used when user wants to *synchronize*/*link* her Facebook login to `email` that she's currently logged in.

* Endpoint: `/api/v1/user/sync_facebook`
* Method: `PUT`
* Params: `*access_token`, `*facebook_token`

For successful response with HTTP status of `200`:
```javascript
{
  "status_code": 0,
  "status": "success"
}
```

For failed response (invalid token) with HTTP status of `400`:
```javascript
{
  "status_code": 49802,
  "error": {
    "message": "Invalid Facebook Token"
  }
}
```

For failed response (account has been linked before) with HTTP status of `400`:
```javascript
{
  "status_code": 40003,
  "error": {
    "message": "Facebook account has been linked before"
  }
}
```


## Error Code Standardization
A common practice in API is that we have notion of **HTTP Status Code** and **Application Status Code**.

*HTTP Status Code* refers to the standard reference universally used in HTTP protocol to notify the client (browser/app) about server's response status. i.e. To tell if request is successful, there is something wrong with request inputs, or server went into the wrong state.

*Application Status Code* refers to specific application state once server responds to the client. e.g. Server can reply with HTTP status code of `400` (`Bad Request`) to hint the client that there might be something wrong with inputs of the request, but it does not specifically mention what the wrong input is. Application status code comes into play for this by specifically stating the application status code as (*say* `49801`) which means *token is expired* defined in certain application.

HTTP status code is understood by standard libraries used to manipulate the blocks of code. However, Application status code is defined on application basis and its definition really depends on organization itself. Since it is repetitive across applications that we develop, and to minimize confusion for client usage, we propose the following *Application Status Code*:

```ruby
SUCCESS = 0 # http `ok` is 200, but common practice for other industries is 0.

BAD_REQUEST = 40000 # general bad request and this is generally invalid input parameters from client
BAD_REQUEST_EMPTY_PARAMS = 40001 # required parameters are empty
BAD_REQUEST_DUPLICATE_RECORD = 40002 # duplicate record
BAD_REQUEST_DUPLICATE_RECORD_FB = 40003 # duplicate record for Facebook

UNAUTHORIZED = 40100 # general unauthorized request
UNAUTHORIZED_UNVERIFIED = 40101 # record/user is not verified/confirmed

RECORD_NOT_FOUND = 40400 # general record not found
RECORD_NOT_FOUND_BY_EMAIL = 40401 # record/user not found by email
RECORD_NOT_FOUND_BY_ID = 40402 # record not found by ID

UNPROCESSABLE_ENTITY = 42200 # server cannot save the entity due to validation

INVALID_TOKEN = 49800 # general invalid token
INVALID_TOKEN_EXPIRED = 49801 # invalid expired token
INVALID_TOKEN_THIRD_PARTY = 49802 # general invalid token for 3rd party. e.g. Facebook's token
INVALID_PASSWORD = 49802 # invalid password, not validation
```

The rational is that we peg prefix HTTP status code with 2 digits of specific error type depending on the nature of HTTP status code. e.g. `RECORD_NOT_FOUND = 40400` corresponds to HTTP status code of `404` meaning `Not Found`. The last two digits can be used to identify the specific nature of the error type in which this case `00` is general case of record not found in database.

For consistency, we will try to provide as many *Application Status Code* as possible, but you are free to define custom status code on application basis too.



## Implementation
The flow of this login is supposed to be used or referenced by any server side framework.

### Rails Implementation
To Simplify the process, we use two gems
* [Devise](https://github.com/plataformatec/devise): Authentication for Rails application
* [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper): OAuth2 resource provider

In `Gemfile`, you can just use it as
```ruby
source 'https://rubygems.org'
# other gems here
gem 'devise'
gem 'doorkeeper'
```

After `bundle install`, you can follow the instructions in both gems. The instruction below will assume that you follow the following settings:

```bash
$> rails generate devise:install
$> rails generate devise user
$> rails generate doorkeeper:install
$> rake db:migrate
```

We are not focusing on `Devise` or `Doorkeeper` usages. We only focus on the flow of api login from mobile applications.



### Doorkeeper settings
There are many types of OAuth authentication supports to retrieve access token. In this strategy, we will use [Resource Owner Password Credentials](https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Resource-Owner-Password-Credentials-flow) flow. In this flow, a token is requested in exchange for the resource owner credentials (username and password):

For Doorkeeper 2.1+, you'll need to add `password` as an acceptable grant type. In your initializer after the `Doorkeeper.configure` block, add:
```ruby
Doorkeeper.configuration.token_grant_types << "password"
```
Newer version of devise don't provide `authenticate!` anymore. But you can use something like the following:

```ruby
Doorkeeper.configure do
  resource_owner_from_credentials do |routes|
    if params[:facebook_token]
      # we use Facebook helper here which can be found in app/services/facebook.rb
      user = Facebook.authenticate(params[:facebook_token])
      fail Doorkeeper::Errors::Facebook::InvalidToken unless user.present?
    else
      user = User.find_by_email params[:username]
      fail Doorkeeper::Errors::UsernamePassword::UserDoesNotExist unless user.present?
      fail Doorkeeper::Errors::UsernamePassword::InvalidPassword unless user.valid_password?(params[:password])
      fail Doorkeeper::Errors::UsernamePassword::UserNotVerified unless user.confirmed?
    end

    user
  end
end
```

At client side (mobile application), we can use the following request:

```
POST: https://<hostname>/api/v1/oauth/token
form-data:
  grant-type: password
  username: <username>
  password: <password>
```

Client side does not need to supply `client_id` and `client_secret`, and the app in `/oauth/applications` is not needed to be created.






Since we don't need to manage applications `/oauth/applications`, we can disable the routes as follow:
```ruby
Rails.application.routes.draw do
  use_doorkeeper scope: 'api/v1/oauth' do
    skip_controllers :applications, :authorized_applications, :authorizations
  end
end
```
You can read more detail at [https://github.com/doorkeeper-gem/doorkeeper/wiki/Customizing-routes](https://github.com/doorkeeper-gem/doorkeeper/wiki/Customizing-routes)

You can overwrite default blank response for unauthorized request (invald token) for doorkeeper as below:

```ruby
class Api::ApiController < ActionController::Base
  # this method is to overwrite the default behavior of empty body when unauthorized
  def doorkeeper_unauthorized_render_options
    { json: { status_code: 4031, error: { message: "Invalid access_token" } } }
  end
end
```

### Resetting Password for `Devise`
We can implement resetting password in `devise` by using controller `PasswordsController` and views `passwords`. This is **NOT** to be confused with *editing password once user logged in* in system. Editing password is not Resetting password, and editing password is a web feature; thus it needs to be configured with controller `RegistrationsController`. Before you can edit/customize controller or view, you need to generate both of them as following:

```bash
$> rails generate devise:views # generate default views folder 'app/views/devise'
$> rails generate devise:views users # generate views folder 'app/views/users'
$> rails generate devise:views admins # generate views folder 'app/views/admin'
```

If you have more than one Devise model in your application (such as `User` and `Admin`), you will notice that Devise uses the same views for all models. Fortunately, Devise offers an easy way to customize views. All you need to do is set `config.scoped_views = true` inside the `config/initializers/devise.rb` file.

After doing so, you will be able to have views based on the role like `users/sessions/new` and `admins/sessions/new`. If no view is found within the scope, Devise will use the default view at `devise/sessions/new`.

To generate controller with scope, you can use:

```
rails generate devise:controllers [scope]
```
Example:

```bash
$> rails generate devise:controllers custom_devise # this will scope all controllers (confirmations, passwords, ...) in app/controllers/custom_devise
```

So for resetting password, you might only need to care about view file `app/views/devise/passwords/edit.html.erb` and controller `app/controller/custom_devise/passwords_controller.rb`. You can edit the view file in such a way to satisfy the design. Do remember to consider exception summary.

By default behavior of devise after correctly resetting password, it will redirected the user to last visited page or root page; therefore, we need to update this in order to comply above description of resetting password in general by displaying successful message and do nothing else after successfully resetting the password.

First of all, we need to set `config/routes.rb` to consume `app/controllers/custom_devise/passwords_controller.rb`:

```ruby
Rails.application.routes.draw do
  devise_for :users, controllers: {
    passwords: "custom_devise/passwords" # to use customize passwords controller
  }
  get 'successful_password_reset' => 'home#successful_password_reset' # you customize this to whatever you want.
end
```

In `app/controllers/custom_devise/passwords_controller.rb`, you can just update method `after_resetting_password_path_for`:


```ruby
## originally commented out
# def after_resetting_password_path_for(resource)
#   super(resource)
# end

def after_resetting_password_path_for(resource)
  successful_password_reset_path # set the path you want to redirect after successfully resetting the password.
end
```













=====
# TODO
* reading the agreeable specs and update
