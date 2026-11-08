begin
  var items: array of integer := nil;
  match items with
    [1]: Assert(false);
    else Assert(true);
  end;
end.
