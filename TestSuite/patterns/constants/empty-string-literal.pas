begin
  var input: string := '';
  match input with
    'hello': Assert(false);
    '': Assert(true);
    else Assert(false);
  end;
end.
