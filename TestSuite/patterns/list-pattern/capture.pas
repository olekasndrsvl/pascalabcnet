begin
  var items := Arr(1, 2, 3);
  match items with
    [1, var middle, 3]: Assert(middle = 2);
    else Assert(false);
  end;
end.
