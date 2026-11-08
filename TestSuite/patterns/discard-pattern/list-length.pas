begin
  var items := Arr(17, 42);
  match items with
    [_]: Assert(false);
    [_, _, _]: Assert(false);
    [_, _]: Assert(true);
    else Assert(false);
  end;
end.
