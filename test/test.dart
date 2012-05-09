#import('dart:io');
#import('test_reflect.dart', prefix: 'reflect');

main() {
  var pass = true;
  pass = test('reflect', reflect.TESTS) && pass;
  if (!pass) exit(1);
}

test(suitename, tests) {
  var failures = [];
  stdout.writeString('$suitename [');
  tests.forEach((name, test) {
    try {
      test();
      stdout.writeString('.');
    } catch (var e, var stack) {
      stdout.writeString('X');
      failures.add([name, e, stack]);
    }
  });
  stdout.writeString(']\n');
  failures.forEach((failure) {
    print("=== ${failure[0]} ===");
    print(failure[1]);
    print(failure[2]);
    print("");
  });
}