var evaluations := 0;

function NextValue: integer;
begin
  Inc(evaluations);
  Result := 2;
end;

begin
  match NextValue() with
    1: Assert(false);
    2: Assert(true);
    else Assert(false);
  end;
  Assert(evaluations = 1);
end.
