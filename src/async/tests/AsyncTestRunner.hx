package async.tests;
import haxe.unit.TestCase;
import haxe.unit.TestResult;
import haxe.unit.TestRunner;
import haxe.unit.TestStatus;

/**
 * ...
 * @author TiagoLr
 */
class AsyncTestRunner extends haxe.unit.TestRunner{

	var onComplete:Void->Void;
	var caseIndex:Int = 0;
	var testIndex:Int = 0;
	var cl:Dynamic;
	var fields:Array<String>;
	var testCase:TestCase;
	var oldTrace:Dynamic;
	
	#if flash9
	static var tf : flash.text.TextField = null;
	#elseif flash
	static var tf : flash.TextField = null;
	#end
	
	public static dynamic function print( v : Dynamic ) untyped {
		TestRunner.print(v);
	}

	private static function customTrace( v, ?p : haxe.PosInfos ) {
		TestRunner.customTrace(v, p);
	}
	
	public function new(onComplete:Void->Void) {
		
		result = new TestResult();
		cases = new List();
		
		if (!Reflect.isFunction(onComplete)) {
			throw "onComplete must be a function";
		}
		
		this.onComplete = onComplete;
		super();
	}
	
	override public function add( c:TestCase ) : Void {
		super.add(c);
	}
	
	override public function run() : Bool {
		caseIndex = 0;
		result = new TestResult();
		
		nextCase();
		
		return true;
	}
	
	function nextCase() {
		testIndex = 0;
		if (caseIndex < cases.length) {
			oldTrace = haxe.Log.trace;
			haxe.Log.trace = customTrace;
			testCase = Lambda.array(cases)[caseIndex];
			cl = Type.getClass(testCase);
			print( "Class: "+Type.getClassName(cl)+" ");
			if (Std.is(testCase, AsyncTestCase)) {
				cast (testCase, AsyncTestCase).runner = this;
			}
			fields = Type.getInstanceFields(cl);
			caseIndex++;
			nextTest();
		} else {
			finish();
		}
	}
	
	function finish() {
		print(result.toString());
		onComplete();
	}
	
	function nextTest() {
		if (testIndex < fields.length) {
			
			// run test
			var f = fields[testIndex];
			var fname = f;
			var field = Reflect.field(testCase, f);
			testIndex++;
			
			if ( StringTools.startsWith(fname, "test") && Reflect.isFunction(field) ) {
				testCase.currentTest = new TestStatus();
				testCase.currentTest.classname = Type.getClassName(cl);
				testCase.currentTest.method = fname;
				testCase.setup();

				try {
					Reflect.callMethod(testCase, field, new Array());
					if (Std.is(testCase, AsyncTestCase) && cast(testCase, AsyncTestCase).openAsyncs.length > 0) {
						return; // wait for async callback to terminate test.
					}
					endTest(); // end synchronous test
				}catch ( e : TestStatus ){
					endTest(e); // end synchronous test
				}catch ( e : Dynamic ){
					endTest(e); // end synchronous test
				}
				
			} else {
				nextTest(); // field is not test, evaluate next field
			}
		} else {
			// all tests finished, next test case.
			print("\n");
			haxe.Log.trace = oldTrace;
			nextCase();
		}
	}
	
	@:allow(async.tests.AsyncTestCase)
	function endTest(e:Dynamic = null) {
		if (Std.is(e,TestStatus)) {
			print("F");
			testCase.currentTest.backtrace = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
		} else if (e != null) {
			print("E");
			#if js
			if( e.message != null ){
				testCase.currentTest.error = "exception thrown : "+e+" ["+e.message+"]";
			}else{
				testCase.currentTest.error = "exception thrown : "+e;
			}
			#else
			testCase.currentTest.error = "exception thrown : "+e;
			#end
			testCase.currentTest.backtrace = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
		} else {
			if( testCase.currentTest.done ){
				testCase.currentTest.success = true;
				print(".");
			} else {
				testCase.currentTest.success = false;
				testCase.currentTest.error = "(warning) no assert";
				print("W");
			}
		}
		
		result.add(testCase.currentTest);
		if (Std.is(testCase, AsyncTestCase)) {
			cast(testCase, AsyncTestCase).clearAsyncs();
		}
		testCase.tearDown(); 
		nextTest();
	}
	
}