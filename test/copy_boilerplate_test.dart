import 'package:unittest/unittest.dart';
import 'package:boilerplate/boilerplate.dart';
import 'package:boilerplate/copy_boilerplate.dart';

@MirrorsUsed(targets: const[A, B, C, D], override: "*")
import 'dart:mirrors';

class A extends Boilerplate with CopyBoilerplate {
  int i;
  int j;
  A({this.i, this.j});
}

class B extends Boilerplate with CopyBoilerplate {
  int i;
  int j;
  B(this.i, {this.j});
}

class C extends Boilerplate with CopyBoilerplate {
  int i;
  int j;
  C(this.i, this.j);
}

class D extends Boilerplate with CopyBoilerplate {
  int i;
  int j;
  D();
}

void main() {

  var a = new A(i: 10, j: 20);
  print(a);
  print(a.copy(i: 100));
  print(a.copy(i: 100, j: 30));
    
  var b = new B(10, j: 20);
  print(b);
  print(b.copy(i: 100));

  var c = new C(10, 20);
  print(c);
  print(c.copy(i: 100));
  
  var d = new D();
  print(d);
  print(d.copy(i: 100));
  
  print("Hello, World!");
}
