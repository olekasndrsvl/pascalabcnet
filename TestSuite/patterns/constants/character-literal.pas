begin
  var input: char := 'x';
  match input with
    'X': Assert(false);
    'x': Assert(true);
    else Assert(false);
  end;
end.
