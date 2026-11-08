begin
  var items := Arr(1, 2, 3).ToList;
  match items with
    [1, 2, 3]: Assert(true);
    else Assert(false);
  end;
end.
