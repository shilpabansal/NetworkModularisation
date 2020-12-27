NetworkModularisation

Modularising the network project with TDD


 Instead of creating success and error object, its always better to create an enum to have less maintenance for diff kinds of result, as at a time it will be only one kind of result
 
 Network library is unaware of common errors and responses, the viewmodel receives the respoonse and convert it into the expected enum responses which can be handled by the views
 
 As the data expected from Api has image as the key name and the the param name is imageURL in FeedItem
 To keep FeedItem generic in RemoteFeedLoader the mapping is done to avoid the changes in the FeedLoader module on API change
 
 For requestURLs an array is taken in order to track how many reqquests are made and in what order they are made
 
 By default struct's default initialiser is internal, if it needs to be used outside module, it has to be provided explicitly

Importing testable module, benefits by taking internal entities also

