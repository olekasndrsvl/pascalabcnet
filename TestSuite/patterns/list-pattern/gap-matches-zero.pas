begin
  var items := Arr(1, 2);
  match items with
    [1, .., 2]: Assert(true);
    else Assert(false);
  end;
end.
