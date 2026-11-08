begin
  var input: object := 42;
  if input is integer(var value) then
    Assert(value = 42)
  else
    Assert(false);
end.
