begin
  var selected := false;
  match 2 with
    1: Assert(false);
    else selected := true;
  end;
  Assert(selected);
end.
