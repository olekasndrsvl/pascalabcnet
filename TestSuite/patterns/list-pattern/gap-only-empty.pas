begin
  var items := new integer[0];
  match items with
    [..]: Assert(true);
    else Assert(false);
  end;
end.
