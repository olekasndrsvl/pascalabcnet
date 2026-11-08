begin
  var input := 'hello';
  match input with
    'HELLO': Assert(false);
    'hello': Assert(true);
    else Assert(false);
  end;
end.
