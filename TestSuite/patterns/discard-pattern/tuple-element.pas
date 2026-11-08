begin
  var input := (17, 'ignored', 42);
  match input with
    (17, _, 42): Assert(true);
    else Assert(false);
  end;
end.
