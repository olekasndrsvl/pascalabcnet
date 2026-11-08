begin
  var input := (17, 'ignored', true);
  match input with
    (_, _, _): Assert(true);
    else Assert(false);
  end;
end.
