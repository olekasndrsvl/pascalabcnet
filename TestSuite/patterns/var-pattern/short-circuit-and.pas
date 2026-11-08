var calls := 0;

function Check(value: integer): boolean;
begin
  Inc(calls);
  Assert(value = 42);
  Result := true;
end;

procedure Verify(input: object; expected: boolean);
begin
  if (input is integer(var captured)) and Check(captured) then
    Assert(expected)
  else
    Assert(not expected);
end;

begin
  Verify(42, true);
  Assert(calls = 1);

  Verify('hello', false);
  Assert(calls = 1);
end.
