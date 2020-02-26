class Action {
  int o;
  int v;
  int c;
  int d;
  int r;
  int a;
  int len;

  Action(this.o, this.v, this.c, this.d, this.r, this.a,this.len);

  @override
  String toString() {
    // TODO: implement toString
    return '{\'o\':$o,\'v\':$v,\'c\':$c,\'d\':$d,\'r\':$r,\'a\':$a}';
  }
}
