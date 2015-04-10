# The Login Flow
The goal of this document is to provide a consistent way for login process across the server platforms (Rails, NodeJS, php, ...).

## Login Types
The current suggested login process types now are
* Login through `email` and `password`
* Login through `facebook`

## Single Way of Login Flow
From server point of view, we will implement one way of login only. We combine both login types for every project. On the other hand, client/mobile can choose the number of ways to support based on the project.

## Terminologies
* `client`: mobile client (android/ios) connecting to server for retrieve data
* `server`: api provider (Rails/NodeJS/php)
* `access_token`: a scramble piece of string to authenticate and authorize data consumer. This `access_token` is provided by `server` and to be used by `client`. `client` needs to attach this `access_token` information for every request to `server`. This token can be embedded in HTTP header, query string, or body of the request.
* access token `bearer`: is the term used in OAuth to refer to the api consumer. We will just assume that `bearer` and `client` are the same entity.

## How `client` retrieves data from `server`

```
1. client ----(request data)----> server
2. server checks if access_token is provided or access_token is valid
3. server checks
  if access_token is valid
    return intended data
  else
    return error json
  end
```

## How `client` retrieves `access_token` from `server`

When `client` receives error response from `server` due to invalid or expired `token`, it needs to request for new `access_token` through login form (by either facebook or email/password methods). We **DO NOT** support **TOKEN RENEWAL** through api.

```
1. client ----(login through facebook or email/password)----> server
2. server validates and returns access_token
```

P.S. This is **NOT** OAuth *acting on behalf of* flow, and therefore `client` does not need to provide information such as `client_id` and `client_secret`.

### Facebook Login
This login is through facebook's `token` which is different from our `server`'s `access_token`. The assumption here is that `client` is integrated with facebook SDK and therefore it can retrieve facebook's `token` with some preset permissions.


```
0. client integrates facebook SDK
1. client redirects end user to login and authorize permissions in facebook
2. client receives facebook's token
3. client requests login to server with facebook's token
4. server returns access_token
```
Facebook login's parameters:
* `facebook_token`

### Email/Password Login
This login is through `email/password`.

```
1. client requests login to server with email/password
2. server returns access_token
```

Email login's parameters:
* `username`: this is an email. The reason we use the parameter name as `username` instead of `email` is that standard OAuth specs and other implementation use `username`, and therefore this is for consistency purpose.
* `password`

### Consistent Fields in `users` Table
You have the choice to do whatever you want, but it will be very inconsistent with code used in this document, and therefore we suggest that you stick to the following names:
* The table of `user` model is `models` (model as `User`). You can define something else like `member`, but it's not recommended here.
* The required fields in this `users` table are `email` and `fid` (facebook id as string). You can define social network table as an association for extensibility purpose in order to use other third party authentications, but we will focus on facebook integration which is hard wired in this table.

### Other 3<sup>rd</sup> Party Login
Our goal here is to support Facebook and Email/Password, and therefore other third party authentications such Twitter or Google is considered as further customization.

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
    "status_code": 4022,
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
    "status_code": 4010,
    "error": {
        "message": "Email already exists"
    }
}
```

### Update Email/Password
We allow user to update their email and password accordingly (user already logged in the app and contained `access_token`). However we only use a single endpoint as follow:

* Endpoint: `/api/v1/user`
* Method: `PUT` or `PATCH`
* Params: `*access_token`, (`*email` | `*password`, `*old_password`)
* NOTE: this action is mutual exclusive between `email` and `password`. It only update one attribute at any one time. Param `email` is prioritized; it means that if this param `email` is given, it will ignore *change password* option. Therefore client should have two separated calls: one is for changing `email` and another is for changing `password`. `old_password` is required for changing password case.

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
    "status_code": 4031,
    "error": {
        "message": "Invalid access_token"
    }
}
```

For failed response (try to update the same email as existing) with HTTP status of `400`:
```javascript
{
  "status_code": 4022,
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
  "status_code": 4022,
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
  "status_code": 4022,
  "error": {
    "message": "Attributes are invalid",
    "full_messages": [
      "Nothing is updated"
    ]
  }
}
```






### Reset Password
This happens when user requests for *forget password* feature. The flow of this is that `client` mobile application calls forgetting password api which in turn sends out email to the user to verify authenticity of request. This is as far as the client app does the job, and the rest will be based upon web interface.

```
1. App requests password change (through api) to server.
2. Server sends out email for user to verify
3. User receives email and activates the link
4. User (standing on the page from previous clicked email link) changes the new password.
5. The page shows 'success action' and does nothing else
6. User needs to switch to the app manually
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

For failed response with HTTP status of `401`:
```javascript
{
  "status_code": 4004,
  "error": {
      "message": "Record not found"
  }
}
```


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
      user if user.present?
    else
      user = User.find_by_email params[:username]
      user if user && user.valid_password?(params[:password])
    end
  end
end
```

At client side (mobile application), we can use the following request:

```
POST: https://<hostname>/oauth/token
form-data:
  grant-type: password
  username: <username>
  password: <password>
```

Client side does not need to supply `client_id` and `client_secret`, and the app in `/oauth/applications` is not needed to be created.

Below is the default response after successfully & unsuccessfully requesting token:

HTTP status: `200`
```json
{
  "access_token": "fc9f440034c112bfc3ca8d43d0c7fdae0eb1c1ea5d3f7c0afdd2f9451c8906cc",
  "token_type": "bearer",
  "expires_in": 2592000,
  "created_at": 1428481781
}
```

HTTP status: `401`
```json
{
  "error": "invalid_grant",
  "error_description": "The provided authorization grant is invalid, expired, revoked, does not match the redirection URI used in the authorization request, or was issued to another client."
}
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
* customize doorkeeper error message to make it consistent
