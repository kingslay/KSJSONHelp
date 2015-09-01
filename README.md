# 		KSJSONHelp

KSJSONHelp is a lightweight and pure Swift implemented library for 

.convert dictionary to model

.convert model to dictionary

## Requirements

- Swift 2


- Xcode 7

## Installation

### Carthage

Carthage is a decentralized dependency manager for Cocoa application. To install the carthage tool, you can use Homebrew.

``` shell
$ brew update

$ brew install carthage
```



To integrate KSJSONHelp into your Xcode project using Carthage, specify it in your Cartfile:

`github "kingslay/KSJSONHelp"`

Then, run the following command to build the KSJSONHelp framework:

`$ carthage update`

At last, you need to set up your Xcode project manually to add the KSJSONHelp framework.

On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop each framework you want to use from the Carthage/Build folder on disk.

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script with the following content:

/usr/local/bin/carthage copy-frameworks

and add the paths to the frameworks you want to use under “Input Files”:

$(SRCROOT)/Carthage/Build/iOS/KSJSONHelp.framework

For more information about how to use Carthage, please see its project page.



