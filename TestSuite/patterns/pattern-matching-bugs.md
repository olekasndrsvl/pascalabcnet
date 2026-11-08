# Ошибки и расхождения pattern matching

Текущий этап — [инвентаризация заявлений и существовавших тестов](pattern-matching-status.md). Приведённые ниже объяснения относятся к предыдущему этапу и не заменяют сверку того, что было обещано и чем уже покрывалось.

Состояние на 1 ноября 2026 года, commit `82c740d45`, Windows / .NET Framework. Все перечисленные наблюдения воспроизведены на компиляторе, собранном из исходников. «Внутренняя ошибка» ниже означает выдачу исключения/стека вместо нормальной диагностики, а не обязательно аварийное завершение процесса с кодом ОС.

[Общий отчёт и штатный запуск](pattern-matching-audit.md).

Новые воспроизведения находятся в обычном `TestSuite` (отрицательные — в `TestSuite/errors`). Известные сбои помечены стандартным `//exclude`, чтобы не ломать общий прогон: для повторного воспроизведения убрать эту первую строку и запустить штатный TestRunner с фильтром имени. Ожидаемое поведение в телах тестов не изменено.

Приоритеты: P1 — неверное выполнение или исключение в допустимом сценарии; P2 — отказ, диагностика или несовместимость поддержанных форм. Приоритеты — оценка аудита, не статус issue tracker. Исправления компилятора в этот набор изменений не входят.

## PM001 — извлечение элементов до проверки длины (P1)

Воспроизведения: [pattern_audit_collection_short_capture.pas](../../TestSuite/pattern_audit_collection_short_capture.pas), [pattern_audit_nested_collection_short.pas](../../TestSuite/pattern_audit_nested_collection_short.pas).

```pascal
var a := Arr(1);
match a with
  [var first, var second]: assert(false);
  else ;
end;
```

Ожидается переход в `else`; получается `IndexOutOfRangeException`. Тот же эффект имеется у коллекции внутри деконструкторного паттерна.

В [PatternsDesugaringVisitor.cs](../../SyntaxVisitors/PatternsVisitors/PatternsDesugaringVisitor.cs) методы `GetCollectionItemsEqualCheckBeforeGap`/`AfterGap` создают инициализированные `var_statement`; `ProcessDesugaringForCollectionPattern` выносит их перед проверкой условия. Проверка точной длины не защищает эти чтения. Направление исправления: создавать извлечённые значения только после проверки ненулевого входа и достаточной длины.

## PM002 — минимальная длина с `..` не участвует в проверке (P1)

Воспроизведения: [pattern_audit_collection_gap_short.pas](../../TestSuite/pattern_audit_collection_gap_short.pas), [pattern_audit_collection_gap_empty.pas](../../TestSuite/pattern_audit_collection_gap_empty.pas).

```pascal
match Arr(1) with
  [1, .., 1]: assert(false);
  else ;
end;
```

Ожидается несовпадение: два явно заданных элемента требуют длину хотя бы 2. Фактически префикс и суффикс сопоставляются одному элементу и ветка выбирается. Для пустого массива и `[1, ..]` получается выход за границы.

`DesugarCollectionPattern` вычисляет `CollectionLengthCheck`, но `ProcessDesugaringForCollectionPattern` его не добавляет в итоговую проверку. Нужно включить ограничение длины перед индексированием, в том числе когда все компоненты — `_`/`var`.

Контроль: `pattern_audit_collection_zero_gap` подтверждает, что нулевой размер самого пропуска допустим; запрещать его для обхода ошибки нельзя.

## PM003 — структурное сопоставление `nil` небезопасно и непоследовательно (P1)

Воспроизведения: [pattern_audit_collection_nil.pas](../../TestSuite/pattern_audit_collection_nil.pas), [pattern_audit_collection_gap_only_nil.pas](../../TestSuite/pattern_audit_collection_gap_only_nil.pas).

Для `a: array of integer := nil` паттерн `[var x]` получает `NullReferenceException`, а `[..]` совпадает. Ожидание аудита: оба структурных паттерна должны не совпасть; для пустого ненулевого массива `[..]` должен совпасть.

Основание: в работе Погорелова, §2.4, с. 23–24, `[..]` описывает возможно пустую коллекцию и противопоставлен `nil`. Если язык выбирает другую семантику, это нужно явно специфицировать; исключение для обычного несовпадения всё равно требует обработки.

В преобразовании нет общей проверки ненулевого входа; для `[..]` условие превращается в `true`. Добавление только проверки длины недостаточно для полного определения поведения `nil`.

## PM004 — потеря короткого вычисления в присваивании (P1)

Воспроизведения: [pattern_audit_short_circuit_assignment.pas](../../TestSuite/pattern_audit_short_circuit_assignment.pas), [pattern_audit_short_circuit_assignment_or.pas](../../TestSuite/pattern_audit_short_circuit_assignment_or.pas).

```pascal
var matched := false and (Touch() is integer(var x));
```

`Touch` увеличивает счётчик. Ожидается 0 вызовов, получается 1. Аналогично при `true or (...)`. Само итоговое булево значение может оставаться верным, но побочный эффект уже произошёл.

`ExtendedIsDesugaringVisitor` работает с `if_node`; `DesugarIsExpressionInAssignment` выносит вычисление паттерна перед присваиванием. Требуется сохранить управление вычислением операндов во всех разрешённых контекстах.

Контроль: `pattern_audit_short_circuit_if` и существующие `patterns-extended-is-short` проходят. Ошибка не означает, что любое короткое вычисление с `is` сломано.

## PM005 — константные параметры игнорируются в результате присваиваемого `is` (P1)

Воспроизведение: [pattern_audit_is_const_parameter_assignment.pas](../../TestSuite/pattern_audit_is_const_parameter_assignment.pas).

```pascal
// Pair.Deconstruct возвращает 1 и 2.
var matched := new Pair is Pair(9, var y);
assert(not matched);
```

Ожидается `false`, получается `true`. В `DesugarIsExpression` формируется `const_params_check`, но ветка `DesugarIsExpressionInAssignment` использует успех проверки типа/Deconstruct и не включает это дополнительное условие. Следует объединять результат с проверками параметров во всех поддержанных контекстах, не только в `if`.

## PM006 — сравнение результата `is` вызывает внутреннюю ошибку (P2)

Воспроизведение: [pattern_audit_is_under_comparison.pas](../../TestSuite/pattern_audit_is_under_comparison.pas).

```pascal
if (obj is integer(var x)) = true then
  assert(x = 42);
```

Получается `NullReferenceException` в `WalkingVisitorNew.ReplaceUsingParent`, вызванном из `ExtendedIsDesugaringVisitor.visit(if_node)`. Визитор распознаёт наличие расширенного `is` внутри `bin_expr`, но создаёт замену только для `LogicalAND` и `LogicalOR`. Для операции равенства замена остаётся `null`.

Нужно либо корректно обработать этот контекст, либо выдать нормальную диагностику. Передача `null` в замену узла недопустима. Контроль: `pattern_audit_is_negated` проходит.

## PM007 — повторение имени в паттерне вызывает исключение словаря (P2)

Воспроизведение: [err_pattern_audit_duplicate_capture.pas](../../TestSuite/errors/err_pattern_audit_duplicate_capture.pas).

```pascal
if new Pair is Pair(var x, var x) then ;
```

Программа должна получить обычную ошибку повторного объявления с координатами. Фактически выдаётся `System.ArgumentException: Элемент с тем же ключом уже был добавлен` из `PatternsDesugaringVisitor.visit(is_pattern_expr)` на `dict.Add`.

Нужна проверка повторения имени до добавления в словарь с учётом нечувствительности языка к регистру. Отрицательный тест намеренно не принимает внутреннее исключение за корректный отказ компиляции.

## PM008 — кортеж из семи элементов отклоняется паттерном (P2)

Воспроизведение: [pattern_audit_tuple_seven_elements.pas](../../TestSuite/pattern_audit_tuple_seven_elements.pas). Контроль: `pattern_audit_tuple_six_elements` проходит.

Сам кортеж из семи элементов допустим, но такой же по арности паттерн получает сообщение «Количество элементов кортежа не должно быть больше 7».

В [ABCPascal.y](../../Parsers/PascalABCParserNewSaushkin/ABCPascal.y) действие `tuple_pattern` проверяет число всех параметров на `> 6`. Действие построения значения кортежа проверяет список после первого элемента, а затем добавляет первый элемент: та же константа там соответствует максимуму 7. Нужна согласованная проверка полной арности. После изменения `.y` следует обновить сгенерированный парсер принятой в проекте процедурой.

## PM009 — числовое равенство констант отличается внутри структурных паттернов (P1)

Воспроизведения: [pattern_audit_tuple_constant_conversion.pas](../../TestSuite/pattern_audit_tuple_constant_conversion.pas), [pattern_audit_collection_constant_conversion.pas](../../TestSuite/pattern_audit_collection_constant_conversion.pas).

Для элемента типа `byte` со значением 1 обычная проверка `element = 1` успешна. Паттерны `(1, 2)` и `[1, 2]` для соответствующих значений выбирают `else`.

Семантическая проверка допускает преобразование типов, но `DesugarTuplePattern` и коллекционные вспомогательные методы вызывают `object.Equals`. Упакованные `byte(1)` и `integer(1)` не равны по этому методу. При этом существующий скалярный `patterns-const-match-convert-types` проходит.

Это подтверждённая несогласованность скалярного и структурного сопоставления. Решение требует явного выбора общей семантики числовых констант; ожидаемое поведение тестов — согласованность с обычным/скалярным сравнением. Не следует расширять преобразования без проверки несовместимых типов.

## PM010 — имя извлечённой переменной переписывает имя типа (P2)

Воспроизведение: [pattern_audit_capture_same_as_type.pas](../../TestSuite/pattern_audit_capture_same_as_type.pas).

```pascal
match obj with
  Item(var item): assert(item = obj);
  else assert(false);
end;
```

Вместо нормального связывания или понятного сообщения о конфликте имён получается неизвестное внутреннее имя `$RenIsVarYield...$item`. Переименование в `PatternsDesugaringVisitor.visit(is_pattern_expr)` обходит `ident` внутри всего выражения и не различает позиции имён типов и локальных переменных.

Контроль: `pattern_audit_deconstruct_guard_short_circuit` с именем `captured`, отличным от `Item`, проходит. Тест не требует разрешать все варианты затенения, но утечка сгенерированного имени в диагностике является дефектом.

## PM011 — существующие рекурсивные примеры получают ложное повторное объявление (P2)

Воспроизведения: [patterns-type-matching1.pas](../../TestSuite/patterns/nested/patterns-type-matching1.pas), [patterns-collection-matching3.pas](../../TestSuite/patterns/nested/patterns-collection-matching3.pas).

Ожидается успешное выполнение существующих тестов. Получается `SYNTAXTREEVISITORSERROR_Повторное объявление` на рекурсивных паттернах.

**Причина пока не локализована.** В основном визиторе есть явная проверка уже переименованного идентификатора, начинающегося с `$`; она согласуется с симптомом повторного обхода. Это гипотеза, а не установленная полная причина. Воспроизведения сохранены без изменения исходных тестов.

Контрпримеры: новые `pattern_audit_recursive_branches` и `pattern_audit_is_then_recursive_match` проходят. Поэтому нельзя описывать ошибку как отказ любых нескольких рекурсивных веток или любого сочетания `is` и `match`.

## PM012 — существующий сложный generic extension-пример даёт внутреннюю ошибку (P2)

Воспроизведение: [patterns-deconstruct-generic-extension.pas](../../TestSuite/patterns/positional-pattern/patterns-deconstruct-generic-extension.pas).

Получается `NullReferenceException`, стек проходит через `syntax_tree_visitor.convert_strong(statement)` и построение семантического дерева. **Первопричина не локализована**; по этому стеку нельзя доказать конкретный дефект вывода generic-параметров.

Контроль: [pattern_audit_generic_extension_simple.pas](../../TestSuite/pattern_audit_generic_extension_simple.pas) с простым `Deconstruct<T>` для `List<T>` проходит. Ошибка относится к зафиксированному сложному примеру, а не ко всем generic-методам расширения.

## GAP001 — прямой `is` для кортежей и коллекций заявлен в работе, но недоступен

Проверки: [pattern_audit_is_collection_direct.pas](../../TestSuite/pattern_audit_is_collection_direct.pas), [pattern_audit_is_tuple_direct.pas](../../TestSuite/pattern_audit_is_tuple_direct.pas), существующий [patterns-collection-matching2.pas](../../TestSuite/patterns/collections/patterns-collection-matching2.pas).

```pascal
if a is [1, var x, 3] then ...
if pair is (1, var x) then ...
```

Парсер ожидает имя типа и отклоняет `[`/`(`. Соответствующие альтернативы `relop_expr` в `ABCPascal.y` закомментированы. Это подтверждённая граница текущего синтаксиса и расхождение с работой Погорелова, а не доказательство случайной поломки: причина отключения и её намеренность не установлены.

В `match` и внутри деконструкторных паттернов соответствующие структуры доступны. Для восстановления прямой формы одного раскомментирования недостаточно: нужно проверить неоднозначности грамматики, контексты выражений и уже найденные ошибки коллекций.

## Рекомендуемый порядок исправлений

1. PM001–PM003: общий безопасный порядок проверки коллекции — `nil`, длина, чтение элементов, вложенные паттерны.
2. PM004–PM005: единая семантика результата `is` и побочных эффектов во всех допустимых контекстах.
3. PM006–PM007: внутренние ошибки заменить корректной обработкой или диагностикой.
4. PM008–PM010: арность, согласованность числовых констант и переименование по ролям идентификаторов.
5. Минимизировать PM011–PM012, затем отдельно решить судьбу прямых `is` из GAP001.

Для каждого исправления в наборе остаётся тест ожидаемого поведения. После исправления убрать стандартный `//exclude` у соответствующего теста и подтвердить его обычным проходом `core` или `errors`. Отдельные манифесты известных отклонений не используются.
