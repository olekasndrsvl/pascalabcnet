begin
  var executed := false;
  match 2 with
    1: executed := true;
  end;
  Assert(not executed);
end.
