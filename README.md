NetworkModularisation

Modularising the network project with TDD


 Instead of creating success and error object, its always better to create an enum to have less maintenance for diff kinds of result, as at a time it will be only one kind of result
 
 Network library is unaware of common errors and responses, the viewmodel receives the respoonse and convert it into the expected enum responses which can be handled by the views
 
 As the data expected from Api has image as the key name and the the param name is imageURL in FeedItem
 To keep FeedItem generic in RemoteFeedLoader the mapping is done to avoid the changes in the FeedLoader module on API change
 
 For requestURLs an array is taken in order to track how many reqquests are made and in what order they are made
 
 By default struct's default initialiser is internal, if it needs to be used outside module, it has to be provided explicitly

Importing testable module, benefits by taking internal entities also


URLProtocol:

Intercepting/mocking network request
Every time we perform URLRequest, there is URL Loading system to handle those requests.
As part of URL Loading system, there is an abstract class class URLProtocol which inherits from NSObject. 
If we create our own class subclassing URLProtocol and register it, we can start intercepting URL requests.

All we have to do is, implement Abstract method of URLProtocol class

For eg. for the test cases, we can intercept the request so we never go to cloud. It doesn’t matter which network library we are using AFNetworking, Maya or something else.

NSURLProtocolClient provides the interface to the URL loading system, the HTTPProtocol abstract class has instance of it.

