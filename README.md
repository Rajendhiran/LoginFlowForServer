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
* `email`
* `password`


### Other 3<sup>rd</sup> Party Login


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
    user = User.find_by_email params[:username]
    user if user && user.valid_password?(params[:password])
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











=====
