begin
  var first: object := 17;
  var second: object := 42;

  if first is integer(var value) then
    Assert(value = 17)
  else
    Assert(false);

  if second is integer(var value) then
    Assert(value = 42)
  else
    Assert(false);
end.
