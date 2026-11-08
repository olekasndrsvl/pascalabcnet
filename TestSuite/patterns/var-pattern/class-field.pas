type
  Container = class
    Value: object;
  end;

begin
  var item := new Container;
  item.Value := 'hello';

  if item.Value is string(var captured) then
    Assert(captured = 'hello')
  else
    Assert(false);
end.
