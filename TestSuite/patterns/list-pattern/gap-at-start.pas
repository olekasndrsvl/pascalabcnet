begin
  var items := Arr(1, 2, 3, 4);
  match items with
    [.., 3, 4]: Assert(true);
    else Assert(false);
  end;
end.
