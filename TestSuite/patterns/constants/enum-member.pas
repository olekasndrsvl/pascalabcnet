type
  Color = (Red, Green);

begin
  var input := Green;
  match input with
    Red: Assert(false);
    Green: Assert(true);
    else Assert(false);
  end;
end.
