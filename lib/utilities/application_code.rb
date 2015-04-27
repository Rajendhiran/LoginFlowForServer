module Utilities
  module ApplicationCode
    SUCCESS = 0 # http `ok` is 200, but common practice for other industries is 0.

    BAD_REQUEST = 40000 # general bad request and this is generally invalid input parameters from client
    BAD_REQUEST_EMPTY_PARAMS = 40001 # required parameters are empty
    BAD_REQUEST_DUPLICATE_RECORD = 40002 # duplicate record
    BAD_REQUEST_DUPLICATE_RECORD_FB = 40003 # duplicate record for facebook

    UNAUTHORIZED = 40100 # general unauthorized request
    UNAUTHORIZED_UNVERIFIED = 40101 # record/user is not verified/confirmed

    RECORD_NOT_FOUND = 40400 # general record not found
    RECORD_NOT_FOUND_BY_EMAIL = 40401 # record/user not found by email
    RECORD_NOT_FOUND_BY_ID = 40402 # record not found by ID

    UNPROCESSABLE_ENTITY = 42200 # server cannot save the entity due to validation

    INVALID_TOKEN = 49800 # general invalid token
    INVALID_TOKEN_EXPIRED = 49801 # invalid expired token
    INVALID_TOKEN_THIRD_PARTY = 49802 # general invalid token for 3rd party. e.g. facebook's token
    INVALID_PASSWORD = 49803 # invalid password, not validation
  end
end

# 400 Bad Request
# The server cannot or will not process the request due to something that is perceived to be a client error (e.g., malformed request syntax, invalid request message framing, or deceptive request routing).[14]
# 401 Unauthorized
# Similar to 403 Forbidden, but specifically for use when authentication is required and has failed or has not yet been provided. The response must include a WWW-Authenticate header field containing a challenge applicable to the requested resource. See Basic access authentication and Digest access authentication.
# 402 Payment Required
# Reserved for future use. The original intention was that this code might be used as part of some form of digital cash or micropayment scheme, but that has not happened, and this code is not usually used. YouTube uses this status if a particular IP address has made excessive requests, and requires the person to enter a CAPTCHA.[citation needed] Some work has been done to implement payments via the digital currency Bitcoin automatically on a 402 request.[citation needed]
# 403 Forbidden
# The request was a valid request, but the server is refusing to respond to it. Unlike a 401 Unauthorized response, authenticating will make no difference.
# 404 Not Found
# The requested resource could not be found but may be available again in the future. Subsequent requests by the client are permissible.
# 405 Method Not Allowed
# A request was made of a resource using a request method not supported by that resource; for example, using GET on a form which requires data to be presented via POST, or using PUT on a read-only resource.
# 406 Not Acceptable
# The requested resource is only capable of generating content not acceptable according to the Accept headers sent in the request.
# 407 Proxy Authentication Required
# The client must first authenticate itself with the proxy.
# 408 Request Timeout
# The server timed out waiting for the request. According to HTTP specifications: "The client did not produce a request within the time that the server was prepared to wait. The client MAY repeat the request without modifications at any later time."
# 409 Conflict
# Indicates that the request could not be processed because of conflict in the request, such as an edit conflict in the case of multiple updates.
# 410 Gone
# Indicates that the resource requested is no longer available and will not be available again. This should be used when a resource has been intentionally removed and the resource should be purged. Upon receiving a 410 status code, the client should not request the resource again in the future. Clients such as search engines should remove the resource from their indices.[15] Most use cases do not require clients and search engines to purge the resource, and a "404 Not Found" may be used instead.
# 411 Length Required
# The request did not specify the length of its content, which is required by the requested resource.
# 412 Precondition Failed
# The server does not meet one of the preconditions that the requester put on the request.
# 413 Request Entity Too Large
# The request is larger than the server is willing or able to process.
# 414 Request-URI Too Long
# The URI provided was too long for the server to process. Often the result of too much data being encoded as a query-string of a GET request, in which case it should be converted to a POST request.
# 415 Unsupported Media Type
# The request entity has a media type which the server or resource does not support. For example, the client uploads an image as image/svg+xml, but the server requires that images use a different format.
# 416 Requested Range Not Satisfiable
# The client has asked for a portion of the file (byte serving), but the server cannot supply that portion. For example, if the client asked for a part of the file that lies beyond the end of the file.
# 417 Expectation Failed
# The server cannot meet the requirements of the Expect request-header field.
# 418 I'm a teapot (RFC 2324)
# This code was defined in 1998 as one of the traditional IETF April Fools' jokes, in RFC 2324, Hyper Text Coffee Pot Control Protocol, and is not expected to be implemented by actual HTTP servers. The RFC specifies this code should be returned by tea pots requested to brew coffee.
# 419 Authentication Timeout (not in RFC 2616)
# Not a part of the HTTP standard, 419 Authentication Timeout denotes that previously valid authentication has expired. It is used as an alternative to 401 Unauthorized in order to differentiate from otherwise authenticated clients being denied access to specific server resources.[citation needed]
# 420 Method Failure (Spring Framework)
# Not part of the HTTP standard, but defined by Spring in the HttpStatus class to be used when a method failed. This status code is deprecated by Spring.
# 420 Enhance Your Calm (Twitter)
# Not part of the HTTP standard, but returned by version 1 of the Twitter Search and Trends API when the client is being rate limited.[16] Other services may wish to implement the 429 Too Many Requests response code instead.
# 422 Unprocessable Entity (WebDAV; RFC 4918)
# The request was well-formed but was unable to be followed due to semantic errors.[4]
# 423 Locked (WebDAV; RFC 4918)
# The resource that is being accessed is locked.[4]
# 424 Failed Dependency (WebDAV; RFC 4918)
# The request failed due to failure of a previous request (e.g., a PROPPATCH).[4]
# 426 Upgrade Required
# The client should switch to a different protocol such as TLS/1.0, given in the Upgrade header field.
# 428 Precondition Required (RFC 6585)
# The origin server requires the request to be conditional. Intended to prevent "the 'lost update' problem, where a client GETs a resource's state, modifies it, and PUTs it back to the server, when meanwhile a third party has modified the state on the server, leading to a conflict."[17]
# 429 Too Many Requests (RFC 6585)
# The user has sent too many requests in a given amount of time. Intended for use with rate limiting schemes.[17]
# 431 Request Header Fields Too Large (RFC 6585)
# The server is unwilling to process the request because either an individual header field, or all the header fields collectively, are too large.[17]
# 440 Login Timeout (Microsoft)
# A Microsoft extension. Indicates that your session has expired.[18]
# 444 No Response (Nginx)
# Used in Nginx logs to indicate that the server has returned no information to the client and closed the connection (useful as a deterrent for malware).
# 449 Retry With (Microsoft)
# A Microsoft extension. The request should be retried after performing the appropriate action.[19]
# 450 Blocked by Windows Parental Controls (Microsoft)
# A Microsoft extension. This error is given when Windows Parental Controls are turned on and are blocking access to the given webpage.[20]
# 451 Unavailable For Legal Reasons (Internet draft)
# Defined in the internet draft "A New HTTP Status Code for Legally-restricted Resources".[21] Intended to be used when resource access is denied for legal reasons, e.g. censorship or government-mandated blocked access. A reference to the 1953 dystopian novel Fahrenheit 451, where books are outlawed.[22]
# 451 Redirect (Microsoft)
# Used in Exchange ActiveSync if there either is a more efficient server to use or the server cannot access the users' mailbox.[23]
# The client is supposed to re-run the HTTP Autodiscovery protocol to find a better suited server.[24]
# 494 Request Header Too Large (Nginx)
# Nginx internal code similar to 431 but it was introduced earlier in version 0.9.4 (on January 21, 2011).[25][original research?]
# 495 Cert Error (Nginx)
# Nginx internal code used when SSL client certificate error occurred to distinguish it from 4XX in a log and an error page redirection.
# 496 No Cert (Nginx)
# Nginx internal code used when client didn't provide certificate to distinguish it from 4XX in a log and an error page redirection.
# 497 HTTP to HTTPS (Nginx)
# Nginx internal code used for the plain HTTP requests that are sent to HTTPS port to distinguish it from 4XX in a log and an error page redirection.
# 498 Token expired/invalid (Esri)
# Returned by ArcGIS for Server. A code of 498 indicates an expired or otherwise invalid token.[26]
# 499 Client Closed Request (Nginx)
# Used in Nginx logs to indicate when the connection has been closed by client while the server is still processing its request, making server unable to send a status code back.[27]
# 499 Token required (Esri)
