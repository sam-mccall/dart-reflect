#library('test_reflect');
#import('../lib/reflect.dart');
#import('dart:uri');

get TESTS() => {
  'callFromClosure': () {
    Expect.equals(6, new Callable.fromClosure((a,b,c) => a + b + c).call(1, 2, 3));
  },
  'callFromHandler': () {
    Expect.equals(6, new Callable.fromHandler((x) => x[0] + x[1] + x[2]).call(1, 2, 3));
  },
  'callFromHandlerException': () {
    Expect.throws(() { new Callable.fromHandler((args) { throw 42; }).call(); }, (x) => x == 42);
  },
  'invokeFromClosure': () {
    Expect.equals(6, new Callable.fromClosure((a,b,c) => a + b + c).invoke([1, 2, 3]));
  },
  'invokeFromHandler': () {
    Expect.equals(6, new Callable.fromHandler((x) => x[0] + x[1] + x[2]).invoke([1, 2, 3]));
  },
  'invokeFromClosureException': () {
    Expect.throws(() { new Callable.fromClosure(() { throw 42; }).invoke([]); }, (x) => x == 42);
  },
  'libraryMethod': () {
    Expect.equals("http://host/page.html",
      new Library('dart:uri').method('merge').call('http://host/index.html', 'page.html'));
  },
  'classMethod': () {
    Expect.equals("a,b,c",
      new Library('dart:core').getClass('Strings').method('join').call(['a', 'b', 'c'], ','));
  },
  'classConstructorAnonymous': () {
    Expect.isTrue(new Library('dart:core').getClass('Exception').constructor().call("42") is Exception);
  },
  'classConstructorNamed': () {
    Expect.equals(42, new Library('dart:core').getClass('Future').constructor('immediate').call(42).value);
  },
  'instanceMethod': () {
    Expect.equals(3, new Instance.wrap([1,2,3]).method('get:length').call());
  },
  'loadLibrary': () {
    Expect.equals(42, new Library('test/test_reflect_library.dart').method('meaning').call());
  },
};