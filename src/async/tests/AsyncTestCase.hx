package async.tests;
import haxe.Timer;
import haxe.unit.TestCase;
import haxe.unit.TestStatus;
import haxe.unit.TestStatus;

/**
 * ...
 * @author TiagoLr
 */
@:allow(async.tests.AsyncTestRunner)
class AsyncTestCase extends TestCase {

	
	private var openAsyncs:Array<Int>;
	private var runner:AsyncTestRunner;
	private var asyncCount:Int = 0; // incremental counter to generate unique asyncCall id's
	
	public function new() {
		super();
		clearAsyncs();
	}
	
	/**
	 * Creates a delegate to the method provided.
	 * Execute the delegate asynchronously call the method during test. 
	 * @param	method		The method to be executed assynchronously.
	 * @param	timeout		The timeout after executing the delegate.
	 * @return				Delegate to method provided.
	 */
	public function createAsync(method:Dynamic->Void, timeout:Int = 300) : Dynamic -> Void {
		
		if (!Reflect.isFunction(method)) {
			throw "Method passed is not a function.";
		}
		
		if (runner == null) {
			throw "Async delegates only work inside AsyncTestRunner";
		}
		
		// pre-condition async is added to openAsyncs when it starts.
		// post-contidion async is removed from openAsyncs when it finishes.
		var id = asyncCount++;
		openAsyncs.push(id);
		
		// create async timeout, if timeout is reached
		// while this async call is opened the test fails.
		Timer.delay(function () {
			if (isAsyncOpen(id)) {
				currentTest.error   = "Async call timeout";
				currentTest.success = false;
				runner.endTest(currentTest);
			}
		}, timeout);
		
		// returns async function to be called
		return function (d:Dynamic) { 
			if (!isAsyncOpen(id)) {
				return; // no point calling this method as this async call is no longer valid. 
			}
			try { 
				openAsyncs.remove(id);
				method(d); 
				if (openAsyncs.length == 0) {
					runner.endTest();
				}
			} catch ( e : TestStatus ) {
				runner.endTest(e);
			}catch ( e : Dynamic ) {
				runner.endTest(e);
			}
		};
	}
	
	function clearAsyncs() {
		openAsyncs = new Array<Int>();
	}
	
	function isAsyncOpen(id:Int) {
		return openAsyncs.indexOf(id) != -1;
	}
}
