//!Внутриблочные переменные не могут иметь те же имена, что и переменные из блока верхнего уровня
begin
  var value := 10;
  var input: object := 42;

  if input is integer(var value) then
    Assert(value = 42);
end.
