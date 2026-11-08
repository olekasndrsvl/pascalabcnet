type
  Point = class
    procedure Deconstruct(var x, y: integer);
    begin
      x := 17;
      y := 42;
    end;
  end;

begin
  var input := new Point;
  match input with
    Point(0, _): Assert(false);
    Point(17, _): Assert(true);
    else Assert(false);
  end;
end.
