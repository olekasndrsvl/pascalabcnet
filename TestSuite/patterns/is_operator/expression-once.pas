var evaluations := 0;

function NextValue: object;
begin
  Inc(evaluations);
  Result := 42;
end;

begin
  Assert(NextValue() is integer);
  Assert(evaluations = 1);
end.
