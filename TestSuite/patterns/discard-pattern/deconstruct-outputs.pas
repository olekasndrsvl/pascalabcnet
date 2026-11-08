var calls := 0;

type
  Pair = class
    procedure Deconstruct(var first: integer; var second: string);
    begin
      Inc(calls);
      first := 17;
      second := 'ignored';
    end;
  end;

begin
  var input: object := new Pair;
  if input is Pair(_, _) then
    Assert(calls = 1)
  else
    Assert(false);
end.
