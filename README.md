# Async-Tests

This library provides *async unit tests* to haxe by extending the standard unit tests packages.

# Install
```
haxelib install async-tests
```

## Example

This lib consists of two files:

**AsyncTestRunner** (extends haxe.unit.TestRunner) 
**AsyncTestCase** (extends haxe.unit.TestCase)

So its usage its very similar to ***standard*** [haxe unit tests].(http://old.haxe.org/doc/cross/unit)

```haxe
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
```actionscript
class MyTestCase extends AsyncTestCase {

	// All tests are async capable inside AsyncTestCase
	function testSampleAsync() {
		
		// creates delegate to 'moreAsserts', time-out after 300 miliseconds
		var asyncDel = createAsyncDel(onAssetsLoaded, 300);
		
		// executing the delegate, returns onAssetsLoaded function
		// test only ends when delegate finishes executing or timesout
		urlLoader.addEventListener(Event.COMPLETE, asyncDel());
	}
	
	function onAssetsLoaded() {
		assertTrue(true);
	}
}
```
 * **AsyncTestRunner** now receives a callback **(onComplete)** on construction for when all tests finish.
 * **AsyncTestCase** now has **createAsyncDel(callback, timeout)** that allows to call methods asynchronously.

## Notes

* When a delegate is executed it retrieves a callback, the test only terminates when the callback is executed or times-out.
* The tests are sequential, test B only starts after test A finishes or times-out.
* AsyncTestRunner can run haxe.unit.TestCase tests, asyncDelegates are not available tho.
* AsyncTestCase can run inside haxe.unit.TestRunner, asyncDelegates can not be created tho.