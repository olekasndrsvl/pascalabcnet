begin
  var items := Arr(1, 2, 3);
  match items with
    [1, 9, 3]: Assert(false);
    else Assert(true);
  end;
end.
