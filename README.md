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
		
		// creates delegate to 'moreAsserts', time-out after 300 miliseconds
		var asyncDel = createAsyncDel(onAssetsLoaded, 300);
		
		// executing the delegate, returns onAssetsLoaded function
		// test only ends when delegate finishes executing or timesout
		urlLoader.addEventListener(Event.COMPLETE, createAsync(onTestsLoaded, 300));
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
It generates a special callback, like a delegate that when invoked performs certain operations to guarantee that the test doesent terminate until the callback has finished or timeout occured.

```actionscript
// another alternative to perform same action
var t = createAsync(onTestsLoaded, 300);
urdLoader.addEventListener(Event.COMPLETE, t);
```

**!--Important--!** For simplicity, when ```createAsync()``` is called, the timeout starts counting immediatelly, so as a tip always create "asyncs" right before their execution. (this situation may change in the future).

#Notes

* Methods passed to ```createAsync()``` have the signature ```Dynamic->Void``` (other signatures maybe available in the future).
* **AsyncTestRunner** can run std TestCase and **AsyncTestCase** can run from std TestRunner (no async calls tho).



[haxe unit tests]:http://old.haxe.org/doc/cross/unit
