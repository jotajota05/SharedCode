# SharedCode

In this repository you can find chunks of code for two projects that I'm currently working on. Android code written in Java ans iOS code written in Swift. This classes display functionalities to be re-used across the applications.

## iOS - Swift

There is 3 classes in this folder:

* [AppDelegate.swift] - My current AppDelegate for my application with some global methods that executes when the application starts or when the user LogOut.
* [Singleton.swift] - Class than handle multiple operations and hold global variables that are going to be used in the application execution.
* [PhotoUtils.swift] - Class than handle multiple operations related with Photos management and edition in the application.

## Android - Java

There is 4 classes in this folder:

* [ApplicationController.java] - Class than handle multiple operations and hold global variables that are going to be used in the application execution.
* [DatabaseDataSource.java] - Class that implements all the methods to insert, get or update values in the SQLite datababes used to store registration requests in OffLine Mode (The appication store request to be send it in the future)
* [DatabaseController.java] - Class that defines the creation of the SQLite database
* [LoginConnector.java] - Class that performs Log in operations, calling the corresponding REST Web Service 

[ApplicationController.java]: <https://github.com/jotajota05/SharedCode/blob/master/android/ApplicationController.java>
[DatabaseDataSource.java]: <https://github.com/jotajota05/SharedCode/blob/master/android/DatabaseDataSource.java>
[DatabaseController.java]: <https://github.com/jotajota05/SharedCode/blob/master/android/DatabaseController.java>
[LoginConnector.java]: <https://github.com/jotajota05/SharedCode/blob/master/android/LoginConnector.java>
[AppDelegate.swift]: <https://github.com/jotajota05/SharedCode/blob/master/ios/AppDelegate.swift>
[Singleton.swift]: <https://github.com/jotajota05/SharedCode/blob/master/ios/Singleton.swift>
[PhotoUtils.swift]: <https://github.com/jotajota05/SharedCode/blob/master/ios/PhotoUtils.swift>
