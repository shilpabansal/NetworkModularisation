NetworkModularisation
![ModelDigram](https://github.com/shilpabansal/NetworkModularisation/blob/main/ModalDiagram.png)
![FlowChart](https://github.com/shilpabansal/NetworkModularisation/blob/main/FlowChart.png)

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



________________________________________________________________________________________
If thread sanitisation is enabled, it detects the data race. 
A data race occurs when two or more thread access the same memory location concurrently without synchronisation and at least one access is a write.

In  test method test_getFromURL_performGetRequestFromURL
 As there is no wait for expectation for async call, the tear down method(main thread) is making stub as nil, where as stub call in URLProtolcolStub  class( via loadFeeds(background thread)) is trying to access stub. Therefore data race condition occurs.

To solve this, set expectationFulFillmentCount to 2, which will expect expectation to be called twice.
________________________________________________________________________________________






________________________________________________________________________________________

URLSession has a singleton shared session (which doesn’t have a configuration object) for basic requests. It’s not as customizable as sessions you create, but it serves as a good starting point if you have very limited requirements. You access this session by calling the shared class method. For other kinds of sessions, you create a URLSession with one of three kinds of configurations:

A default session behaves much like the shared session, but lets you configure it. You can also assign a delegate to the default session to obtain data incrementally.

Ephemeral sessions are similar to shared sessions, but don’t write caches, cookies, or credentials to disk.

Background sessions let you perform uploads and downloads of content in the background while your app isn't running.


It’s common to see iOS codebases using SCNetworkReachability, NWPathMonitor, or third-party reachability frameworks to make decisions about whether they should make a network request or not. Unfortunately, such a process is not reliable and can lead to bad customer experience.

As advised by Apple, we can use the reachability status to diagnose the cause of the failure and perform actions after a failed request. For example, you can automatically retry a failed request on a reachability callback. You can also use the current reachability status to display hints to the user, such as "Looks like you're offline." But you shouldn’t stop attempting to make a request based on the current reachability status.


waitsForConnectivity
If you use URLSession to make a data task while the user has no internet connection, your request will fail immediately and report an error. However, if you create your session with the waitsForConnectivity configuration option set to true, then the system will automatically wait some time to see if connectivity becomes available before trying the request.
For example, this creates a data task that fetches a URL only when internet connectivity is available:
let config = URLSessionConfiguration.default
config.waitsForConnectivity = true

URLSession(configuration: config).dataTask(with: yourURL) { data, response, error in
    if let error = error {
        print(error.localizedDescription)
    } ei

    // use your data here
}.resume()
By default, the system will wait seven days to see if internet connectivity becomes available, but you can control that with the timeoutIntervalForResource property on your configuration. For example, this will ask the system to wait 60 seconds:
config.timeoutIntervalForResource = 60


This property is ignored by background sessions, which always wait for connectivity.
________________________________________________________________________________________






________________________________________________________________________________________
Low data mode:
When n/w is expensive, app should be using the data conservatively 

URLSession/URLConfiguration have property  allowsConstrainedNetworkAccess
iOS lets users enable Low Data Mode for any cellular or WiFi connection, which signals to apps that they should be careful how much data they use. This might mean downloading lower-resolution images, it might mean disabling prefetching, or some other way of cutting down on bandwidth use.

By default your app does not honour the user’s low data mode setting, but you can change that by setting the allowsConstrainedNetworkAccess property to false for a given URLRequest. For example:
var request = URLRequest(url: someURL)
request.allowsConstrainedNetworkAccess = false
When that request executes iOS will immediately return an error if low data mode is enabled, which might be your cue to do another request for less data or lower-resolution images, for example. You can detect this error by typecasting it to a URLError, then checking if the networkUnavailableReason property is set to .constrained:

if let error = error as? URLError, error.networkUnavailableReason == .constrained {
    // user has activated low data mode so this request could not be satisfied
}
_______________________________________________________________________________________







________________________________________________________________________________________
allowsExpensiveNetworkAccess: 
There is a similarly named URLSession property called allowsExpensiveNetworkAccess, which determines whether network requests can be made over a personal hotspot. It’s considered expensive because often users on cellular networks have lower data caps.


Instead of limiting the network call for cellular its better to check for expensive property, which system gives, currently it checks for cellular or hotspot. 
________________________________________________________________________________________





________________________________________________________________________________________
multipathServiceType
A service type that specifies the Multi-path TCP connection policy for transmitting data over Wi-Fi and cellular interfaces.

Multipath TCP, is an extension to TCP that permits multiple interfaces to transmit a single data stream. This capability allows a seamless handover from Wi-Fi to cellular, aimed at making both interfaces more efficient and improving the user experience.
The multipathServiceType property defines which policy the Multipath TCP stack uses to schedule traffic across Wi-Fi and cellular interfaces. The default value is none, meaning Multipath TCP is disabled. You can also select handover mode, which provides seamless handover between Wi-Fi and cellular.
________________________________________________________________________________________






________________________________________________________________________________________
By default HTTP and HTTPs requests are cached in memory and disk using URLCache class
default shared instance has 4MB memory capacity and 20MB disk capacity

 The disk and memory size can be increaed for cache.
 in case we want to increase, it should be done in didFinishLoading to avoid inconsistent caching
 
 let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
 configuration.urlCache =  URLSessionConfiguration.default 
 let session = URLSession(configuration: configuration)
 URLCache.shared = cache
 ________________________________________________________________________________________




________________________________________________________________________________________
To check the default location of the caches
let documentsUrl =  fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first! as NSURL
let documentsPath = documentsUrl.path
print(documentsPath)

By default URLSession's shared object has caching available, if the data shouldn't be cached, ephemeral object can be used

the max age for cache policy can be changed.
________________________________________________________________________________________




________________________________________________________________________________________
The default caching is only done if below are true:
1. the request is HTTP/HTTPs or custom n/wing protocol that support caching
2. The request is successful, status code 200-299 range
3. Provided response came from server, not the cache
4. session config allows caching
5. The provided URLRequest object's cache policy allows caching
6. Cache header in the server's response allows caching
7. The response size is small enough to reaonably fit in cache
________________________________________________________________________________________





________________________________________________________________________________________

As all the modules are tightly coupled with FeedItem, if there is any change in FeedItem, all modules will need to changes.

To avoid this, we should be trying to decouple the modules as much as possible.
________________________________________________________________________________________
