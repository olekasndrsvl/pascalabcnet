begin
  var input := true;
  match input with
    false: Assert(false);
    true: Assert(true);
    else Assert(false);
  end;
end.
