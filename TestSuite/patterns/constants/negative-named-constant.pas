const Expected = -42;

begin
  var input := -42;
  match input with
    42: Assert(false);
    Expected: Assert(true);
    else Assert(false);
  end;
end.
