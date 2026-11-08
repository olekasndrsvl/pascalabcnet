begin
  var items := Arr(1, 2, 3);
  match items with
    [1, 2, 3]: Assert(true);
    else Assert(false);
  end;
end.
