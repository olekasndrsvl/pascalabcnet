var calls := 0;

function GetValue: object;
begin
  Inc(calls);
  Result := 42;
end;

begin
  if GetValue() is integer(var value) then
    Assert(value = 42)
  else
    Assert(false);

  Assert(calls = 1);
end.
