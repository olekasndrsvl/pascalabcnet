begin
  var selected := 0;
  match 2 with
    2: selected := 1;
    2, 3: selected := 2;
    else Assert(false);
  end;
  Assert(selected = 1);
end.
