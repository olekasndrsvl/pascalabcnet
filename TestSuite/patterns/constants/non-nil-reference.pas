begin
  var input := new object;
  match input with
    nil: Assert(false);
    else Assert(true);
  end;
end.
