procedure Increment(var number: integer);
begin
  Inc(number);
end;

begin
  var input: object := 42;
  if input is integer(var value) then
  begin
    Increment(value);
    Assert(value = 43);
  end
  else
    Assert(false);
end.
