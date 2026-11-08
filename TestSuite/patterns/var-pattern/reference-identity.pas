type
  Container = class
    Value: integer;
  end;

begin
  var original := new Container;
  var input: object := original;
  if input is Container(var captured) then
    captured.Value := 42
  else
    Assert(false);

  Assert(original.Value = 42);
end.
