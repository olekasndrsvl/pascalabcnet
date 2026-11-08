type
  Pair = class
    Left: integer := 17;
    Right: integer := 42;

    procedure Deconstruct(var first, second: integer);
    begin
      first := Left;
      second := Right;
    end;
  end;

begin
  var input: object := new Pair;
  if input is Pair(var left, var right) then
  begin
    Assert(left = 17);
    Assert(right = 42);
  end
  else
    Assert(false);
end.
