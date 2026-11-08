begin
  var input := 2.5;
  match input with
    2.0: Assert(false);
    2.5: Assert(true);
    else Assert(false);
  end;
end.
