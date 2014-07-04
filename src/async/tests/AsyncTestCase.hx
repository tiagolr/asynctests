package async.tests;
import haxe.Timer;
import haxe.unit.TestCase;
import haxe.unit.TestStatus;
import haxe.unit.TestStatus;

/**
 * ...
 * @author TiagoLr
 */
class AsyncTestCase extends TestCase {

	@:allow(async.tests.AsyncTestRunner)
	private var openAsyncs:Array<Int>;
	@:allow(async.tests.AsyncTestRunner)
	private var runner:AsyncTestRunner;
	
	public function new() {
		super();
		openAsyncs = new Array<Int>();
	}
	
	public function asyncCall(method:Dynamic->Void, timeout:Int) : Dynamic -> Void {
		
		if (runner == null) {
			throw "Async delegates only work inside AsyncTestRunner";
		}
		
		var id = openAsyncs.length;
		if (isAsyncOpen(id)) {
			return method; // this call is outdated.
		}
		
		// pre-condition async is added to openAsyncs when it starts.
		// post-contidion async is removed from openAsyncs when it finishes.
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
				return; 
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
	
	override public function tearDown():Void {
		openAsyncs = new Array<Int>();
		super.tearDown();
	}
	
	
	function isAsyncOpen(id:Int) {
		return openAsyncs.indexOf(id) != -1;
	}
}
