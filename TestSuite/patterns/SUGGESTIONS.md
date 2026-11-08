# Предложения по улучшению

Анализ сложности реализации предложений ниже пока не проводил

### Аналог switch-операции (match-операция)
Пример:
```csharp
static int GetSourceLabel<T>(IEnumerable<T> source) => source switch
{
    Array array => 1,
    ICollection<T> collection => 2,
    _ => 3,
};
```
Наверное нужно сделать что-то аналогичное:
```csharp
int GetSourceLabel<T>(IEnumerable<T> source) => source match ( Array array => 1, ICollection<T> collection => 2, _ => 3, );
```
### Var-pattern
```C#
static bool IsAcceptable(int id, int absLimit) => SimulateDataFetch(id) is var results 
    && results.Min() >= -absLimit 
    && results.Max() <= absLimit;
```
Сейчас в PascalABC.NET можно только так использовать `is Тип(var имя)`, в С# как видно из примера выше, 
взятого из документации можно просто сделать `is var value`. Тем самым результат вычисления выражения слева от is можно
удобно переиспользовать для вычисления дальнейших условий. (см. пример)

### Const-pattern и Logical-pattern
Сейчас в PascalABC.NET можно писать так
```C#
match x with
  1, 2, 3: Println('Совпало');
  else Println('Не совпало');
end;
```
При отсутствии логических паттернов, такого функционала более чем достаточно. Ведь конструкция вида:
```C#
match x with
  1 and 2 and 3: Println('Совпало');
  else Println('Не совпало');
end;
```
Имеет мало смысла, а конструкция
```C#
match x with
  1 or 2 or 3: Println('Совпало');
  else Println('Не совпало');
end;
```
является полным эквивалентом самой первой среди приведенных. Интерес это все начинает представлять,
когда мы вводим логические паттерны: > < >= <= == !=
Тогда открываются возможности делать следующее:
```C#
static string Classify(double measurement) => measurement switch
{
    < -40.0 => "Too low",
    >= -40.0 and < 0 => "Low",
    >= 0 and < 10.0 => "Acceptable",
    >= 10.0 and < 20.0 => "High",
    >= 20.0 => "Too high",
    double.NaN => "Unknown",
};
```

Есть предложение придумать как оставить синтаксис с запятыми и при этом добавить логические операторы.


### Property pattern

Отсутствует как таковой. 
Пример в C#:
```c#
static bool IsConferenceDay(DateTime date) => date is { Year: 2020, Month: 5, Day: 19 or 20 or 21 };
```

Т.к фигурных скобок у нас нет можно придумать нечто вида
```c#
bool IsConferenceDay(DateTime date) => date is ( Year: 2020, Month: 5, Day: 19 or 20 or 21 );
```

### Positional pattern
Есть и работает, но с классами и кортежами не так все хорошо. 
Классы разбираются так:
```csharp
match p with
  Point(var x, var y): Println(x, y);
end;
```
Кортежи так:
```csharp
begin
  match (1,2) with
    (var x, var y): Println(x, y);
  end;
end.
```

Хотя в C# все единообразно:
```csharp
public readonly struct Point
{
    public int X { get; }
    public int Y { get; }

    public Point(int x, int y) => (X, Y) = (x, y);

    public void Deconstruct(out int x, out int y) => (x, y) = (X, Y);
}

static string Classify(Point point) => point switch
{
    (0, 0) => "Origin",
    (1, 0) => "positive X basis end",
    (0, 1) => "positive Y basis end",
    _ => "Just a point",
};
```

```csharp
static decimal GetGroupTicketPriceDiscount(int groupSize, DateTime visitDate)
    => (groupSize, visitDate.DayOfWeek) switch
    {
        (<= 0, _) => throw new ArgumentException("Group size must be positive."),
        (_, DayOfWeek.Saturday or DayOfWeek.Sunday) => 0.0m,
        (>= 5 and < 10, DayOfWeek.Monday) => 20.0m,
        (>= 10, DayOfWeek.Monday) => 30.0m,
        (>= 5 and < 10, _) => 12.0m,
        (>= 10, _) => 15.0m,
        _ => 0.0m,
    };
```

### Parenthesized pattern
Отсуствует, можно добавить, чтобы логическими паттернами пользоваться на все 100%
```csharp
if (input is not (float or double))
{
    return;
}
```

