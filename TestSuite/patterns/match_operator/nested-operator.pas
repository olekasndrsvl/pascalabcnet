begin
  var selected := false;
  match 1 with
    1:
      match 2 with
        2: selected := true;
        else Assert(false);
      end;
    else Assert(false);
  end;
  Assert(selected);
end.
