type
  Base = class end;
  Derived = class(Base) end;

begin
  var input: object := new Derived;
  Assert(input is Base);
end.
