begin
  var items := Arr(1);
  match items with
    [1, .., 1]: Assert(false);
    else Assert(true);
  end;
end.
