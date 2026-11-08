begin
  var input := 42;
  match input with
    41: Assert(false);
    42: Assert(true);
    else Assert(false);
  end;
end.
