NetworkModularisation

[![Build Status](https://travis-ci.com/shilpabansal/NetworkModularisation.svg?branch=main)](https://travis-ci.com/shilpabansal/NetworkModularisation)

________________________________________________________________________________________
Modularising the network project with TDD

 Instead of creating success and error object, its always better to create an enum to have less maintenance for diff kinds of result, as at a time it will be only one kind of result
 
 Network library is unaware of common errors and responses, the viewmodel receives the respoonse and convert it into the expected enum responses which can be handled by the views
 
 As the data expected from Api has image as the key name and the the param name is imageURL in FeedItem
 To keep FeedItem generic in RemoteFeedLoader the mapping is done to avoid the changes in the FeedLoader module on API change
 
 For requestURLs an array is taken in order to track how many reqquests are made and in what order they are made
 
 By default struct's default initialiser is internal, if it needs to be used outside module, it has to be provided explicitly

Importing testable module, benefits by taking internal entities also
________________________________________________________________________________________


________________________________________________________________________________________
URLProtocol:

Intercepting/mocking network request
Every time we perform URLRequest, there is URL Loading system to handle those requests.
As part of URL Loading system, there is an abstract class class URLProtocol which inherits from NSObject. 
If we create our own class subclassing URLProtocol and register it, we can start intercepting URL requests.

All we have to do is, implement Abstract method of URLProtocol class

For eg. for the test cases, we can intercept the request so we never go to cloud. It doesn’t matter which network library we are using AFNetworking, Maya or something else.

NSURLProtocolClient provides the interface to the URL loading system, the HTTPProtocol abstract class has instance of it.
________________________________________________________________________________________








________________________________________________________________________________________
App Transport Security

App Transport Security blocks every request that is made over HTTP and enforces a number of rules for requests that are made over HTTPS. Apple added App Transport Security to improve the privacy and security of applications that connect to the web. App Transport Security blocks every request that is made over an insecure connection. With requests made over HTTP as long as you realize that the data is sent as cleartext and that is by definition insecure. With App Transport Security, Apple attempts to convince or encourage developers to make their applications more secure by making secure connections the default.
More details: https://cocoacasts.com/app-transport-security-has-blocked-my-request
________________________________________________________________________________________










________________________________________________________________________________________
Continous integration using travis

Check below commands using command line to see if command is working fine
1. To check simulator and sdk details:         xcodebuild -showsdks
2. xcodebuild clean build test -project NetworkModularization.xcodeproj -scheme "CI" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphonesimulator14.3 -destination 'platform=iOS Simulator,name=iPhone 12 Pro Max,OS=14.3'



3. Create .travis.yml file:             touch .travis.yml

4. Put below content in  .travis.yml
    os: osx
    osx_image: xcode12.3
    langauge: swift
    script: xcodebuild clean build test -project NetworkModularization.xcodeproj -scheme "CI" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphonesimulator14.3 -destination 'platform=iOS Simulator,name=iPhone 12 Pro Max,OS=14.3'


5. signed up travis account
6. link with github
7. Push travis config file to git repo

whenever there will be any push to git repo, travis job will be started

