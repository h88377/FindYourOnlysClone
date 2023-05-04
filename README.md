# FindYourOnlysClone

## About
This is a clone version of my project `FindYourOnlys`. The purpose of this clone is to demonstrate what I learn after I graduated from AppWorks School. Currently it only includes pets adopt list and detail scenes. If you want to see the original version, please refer to the link as below.
<p align="left">
    <a href="https://apps.apple.com/tw/app/findyouronlys/id1619734464">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"></a>
</p>



## Design decision
### Test suite
* Implemented test-driven-development to make sure all behaviors worked as intended. Includes unit tests and integration tests to cover components' behavior in isolation and collaboration between components.
* Moved infrastructure integration tests (Network/Database) into separated targets and only run them in continueous delivering pipeline (`CI` scheme) to keep the feedback of the test suite as fast as possible. 
 
### System design
* Implemented modular system by creating feature (business), UI, API and Cache layers and composed them in the app layer (composition). This way, they can be separated into different modules if needed.

**Feature layer (Business logic)**
* Defined feature abstraction components instead of concrete type. This way, system can be more flexible when facing requirements changes by creating different implementation of the abstraction and compose them differently without altering the existed components.  
* Also, it allows development can be proceeded in parallel. For instance, once team decides the definition of the `PetImageDataLoader` abstration, UI, API and Cache layer can be developed in parallel.

**UI layer (Includes Presentation layer)**
* Implemented MVVM as UI architecture to separated iOS-specific components (import UIKit) from feature logic (platform-agnostic) by using platform-agnostic presentation components (ViewModel). This way, I can reuse the presentation component across platforms if needed.
* Used closure as binding strategy to achieve simplest way of binding. 
* Implemented multiple MVVMs in one scene to avoid components hold too many responsibilities (massive view controller).
* Used closure callback to send UIViewController navigation event to its client intead of creating another UIViewController within an UIViewController.

**API/Cache layer**
* Hid the infrastructure frameworks' details by depending on an infrastructure-specific abstraction. This way, I can easily switch the frameworks based on the needs without altering current system.
* Separated the frameworks' details from business logic also make the framework components easy to test, develop and maintain since it just obey the command to save/load data.
* Created layer-specific model to avoid leaking framework-specific logic into feature layer. For instance, avoiding feature model to conform `Decodable` protocol.

**App layer (Composition)**
* Acted as all layers' clients to initialize all components this application needs.
* Also composited, decorated components differently based on the requirements.

## Requirements
> Xcode 13 or later  
> iOS 13.0 or later  
> Swift 4 or later

## Contact
Wayne Cheng｜h88377@gmail.com   

## Licence
FindYourOnlysClone is released under the MIT license.
