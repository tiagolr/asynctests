# Async-Tests
This library provides **async unit tests** by extending haxe standard unit tests.
### Install
```
haxelib install async-tests
```
### Example
This lib consists of two files:

* **AsyncTestRunner** (extends haxe.unit.TestRunner) 
* **AsyncTestCase** (extends haxe.unit.TestCase)

Its usage is almost identical to using standard [haxe unit tests]

```astionscript
// Test runner class
class MyTestRunner {
	
	static function main() {
		var r = new async.tests.AsyncTestRunner(onComplete);
		r.add(new MyTestCase())
		r.run();
	}
	
	// function called when all tests finish
	static function onComplete() {
		#if (cpp || neko || php)
		Sys.exit(0);
		#end
	}
}
```
 **AsyncTestRunner** constructor receives a callback to ```onComplete```, so it can notify the when all tests finish.
```actionscript
class MyTestCase extends AsyncTestCase {

	// All tests are async capable inside AsyncTestCase
	function testSampleAsync() {
	
		// executing the delegate, returns onAssetsLoaded function
		// test only ends when delegate finishes executing or timesout
		urlLoader.addEventListener(Event.COMPLETE, createAsync(onAssetsLoaded, 300));
	}
	
	function onAssetsLoaded(o:Dynamic) {
		assertTrue(true);
	}
}
```

**AsyncTestCase** has the special method:
```actionscript
createAsync(callback:Dynamic->Void, timeout:Int):Dynamic->Void
``` 
When ```createAsync(method)``` is called, it creates another method wrapped around the original, and keeps track how mutch time it takes to invoke it.

```actionscript
// another alternative to perform same action
var t = createAsync(onTestsLoaded, 300);
urdLoader.addEventListener(Event.COMPLETE, t);
```


#Notes

* When ```createAsync()``` is called, the timeout starts counting immediatelly, so always create "asyncs" right before invoking an operation that uses them.
* Methods passed to ```createAsync()``` have the signature ```Dynamic->Void``` (other signatures maybe available in the future).
* **AsyncTestRunner** can run std TestCase and **AsyncTestCase** can run from std TestRunner (no async calls tho).



[haxe unit tests]:http://old.haxe.org/doc/cross/unit
