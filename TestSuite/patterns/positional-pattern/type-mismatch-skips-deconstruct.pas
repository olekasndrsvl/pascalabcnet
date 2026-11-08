type
  Point = class
    procedure Deconstruct(var x, y: integer);
    begin
      Assert(false);
    end;
  end;

begin
  var input: object := 'hello';
  match input with
    Point(var x, var y): Assert(false);
    else Assert(true);
  end;
end.
