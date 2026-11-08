begin
  var items := Arr(1, 99, 3);
  match items with
    [1, _, 3]: Assert(true);
    else Assert(false);
  end;
end.
