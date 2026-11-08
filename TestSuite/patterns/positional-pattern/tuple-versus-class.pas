var deconstructCalls := 0;

type
  Pair = class
    Left: integer := 17;
    Right: integer := 42;

    procedure Deconstruct(var first, second: integer);
    begin
      Inc(deconstructCalls);
      first := Right;
      second := Left;
    end;
  end;

begin
  var tupleValue := (17, 42);
  match tupleValue with
    (var first, var second): Assert((first = 17) and (second = 42));
    else Assert(false);
  end;
  Assert(deconstructCalls = 0);

  var classValue := new Pair;
  match classValue with
    Pair(var first, var second): Assert((first = 42) and (second = 17));
    else Assert(false);
  end;
  Assert(deconstructCalls = 1);
end.
