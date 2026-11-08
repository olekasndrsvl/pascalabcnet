begin
  var items := Arr(1, 2, 3);
  match items with
    [1, 2]: Assert(false);
    [1, 2, 3, 4]: Assert(false);
    else Assert(true);
  end;
end.
