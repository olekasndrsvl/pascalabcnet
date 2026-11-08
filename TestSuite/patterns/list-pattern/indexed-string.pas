begin
  var items := 'abc';
  match items with
    ['a', 'b', 'c']: Assert(true);
    else Assert(false);
  end;
end.
