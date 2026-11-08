procedure Deconstruct<T>(self: List<T>; var head: T); extensionmethod;
begin
  head := self[0];
end;

begin
  var input: object := Arr(42).ToList;
  match input with
    List<integer>(var head: integer): Assert(head = 42);
    else Assert(false);
  end;
end.
