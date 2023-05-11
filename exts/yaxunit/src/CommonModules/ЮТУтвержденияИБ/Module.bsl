//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2023 BIA-Technologies Limited Liability Company
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//©///////////////////////////////////////////////////////////////////////////©//

///////////////////////////////////////////////////////////////////
// Предоставляет методы для формирования утверждений проверяющих данные информационной базы.
// 
// Например:
// 
// ```bsl
// ЮТест.ОжидаетЧтоТаблицаБазы("Справочник.Товары")
//   .СодержитЗаписи();
// ЮТест.ОжидаетЧтоТаблицаБазы("РегистрСведений.КурсыВалют")
//   .СодержитЗаписи(ЮТест.Предикат()
//     .Реквизит("Валюта").Равно(ДанныеРегистра.Валюта));
// ```
///////////////////////////////////////////////////////////////////
#Область ПрограммныйИнтерфейс

// Инициализирует модуль для проверки утверждений.
// 
// * Запоминает/устанавливает имя проверяемой таблицы
// * Запоминает описание.
// 
// Параметры:
//  ИмяТаблицы - Строка - Имя проверяемой таблицы, например, Справочник.Товары, РегистрНакопления.ТоварыНаСкладах
//  ОписаниеПроверки - Строка - Описание проверки, которое будет выведено при возникновении ошибки
// 
// Возвращаемое значение:
//  ОбщийМодуль - Этот модуль для замыкания
// Примеры
//  ЮТест.ОжидаетЧтоТаблицаБазы("Справочник.Товары").СодержитЗаписи();
//
Функция ЧтоТаблица(ИмяТаблицы, ОписаниеПроверки = "") Экспорт
	
	Контекст = НовыйКонтекст(ИмяТаблицы);
	Контекст.ПрефиксОшибки = ОписаниеПроверки;
	
	ЮТКонтекст.УстановитьЗначениеКонтекста(ИмяКонтекста(), Контекст);
	
	Возврат ЮТУтвержденияИБ;
	
КонецФункции

// Проверяет наличие в таблице записей удовлетворяющих условиям
// 
// Параметры:
//  Предикат - ОбщийМодуль - Модуль настройки предикатов, см. ЮТест.Предикат
//           - Массив из см. ЮТФабрика.ВыражениеПредиката - Набор условий, см. ЮТПредикаты.Получить
//           - см. ЮТФабрика.ВыражениеПредиката
//           - Неопределено - Проверит, что таблица не пустая 
//  ОписаниеУтверждения - Строка - Описание конкретного утверждения
// 
// Возвращаемое значение:
//  ОбщийМодуль - Этот модуль для замыкания
Функция СодержитЗаписи(Знач Предикат = Неопределено, Знач ОписаниеУтверждения = Неопределено) Экспорт
	
	Контекст = Контекст();
	УстановитьОписаниеПроверки(Контекст, ОписаниеУтверждения);
	Результат = ЮТЗапросы.ТаблицаСодержитЗаписи(Контекст.ОбъектПроверки.Значение, Предикат);
	
	Если Не Результат Тогда
		Контекст = Контекст();
		СгенерироватьОшибкуУтверждения(Контекст, Предикат, "содержит записи");
	КонецЕсли;
	
	Возврат ЮТУтвержденияИБ;
	
КонецФункции

// Проверяет отсутствие в таблице записей удовлетворяющих условиям
// 
// Параметры:
//  Предикат - ОбщийМодуль - Условия сформированные с использованием см. ЮТест.Предикат
//           - Массив из см. ЮТФабрика.ВыражениеПредиката - Набор условий, см. ЮТПредикаты.Получить
//           - см. ЮТФабрика.ВыражениеПредиката
//           - Неопределено - Проверит, что таблица пустая 
//  ОписаниеУтверждения - Строка - Описание конкретного утверждения
// 
// Возвращаемое значение:
//  ОбщийМодуль - Этот модуль для замыкания
Функция НеСодержитЗаписи(Знач Предикат = Неопределено, Знач ОписаниеУтверждения = Неопределено) Экспорт
	
	Контекст = Контекст();
	УстановитьОписаниеПроверки(Контекст, ОписаниеУтверждения);
	Результат = НЕ ЮТЗапросы.ТаблицаСодержитЗаписи(Контекст.ОбъектПроверки.Значение, Предикат);
	
	Если Не Результат Тогда
		Контекст = Контекст();
		СгенерироватьОшибкуУтверждения(Контекст, Предикат, "не содержит записи");
	КонецЕсли;
	
	Возврат ЮТУтвержденияИБ;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область Контекст

// Контекст.
// 
// Возвращаемое значение:
//  см. НовыйКонтекст
Функция Контекст()
	
	//@skip-check constructor-function-return-section
	Возврат ЮТКонтекст.ЗначениеКонтекста(ИмяКонтекста());
	
КонецФункции

// Инициализирует контекст
// 
// Параметры:
//  ИмяТаблицы - Строка
//  
// Возвращаемое значение:
//  см. ЮТФабрика.ОписаниеПроверки
Функция НовыйКонтекст(ИмяТаблицы)
	
	Контекст = ЮТФабрика.ОписаниеПроверки(ИмяТаблицы);
	
	Возврат Контекст;
	
КонецФункции

Функция ИмяКонтекста()
	
	Возврат "КонтекстУтвержденияИБ";
	
КонецФункции

#КонецОбласти

Процедура СгенерироватьОшибкуУтверждения(Контекст, Предикат, Сообщение)
	
	Если Предикат <> Неопределено Тогда
		ПредставлениеПредиката = ЮТПредикатыКлиентСервер.ПредставлениеПредикатов(Предикат, ", ", "`%1`");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПредставлениеПредиката) Тогда
		СообщениеОбОшибке = СтрШаблон("%1 с %2", Сообщение, ПредставлениеПредиката);
	Иначе
		СообщениеОбОшибке = Сообщение;
	КонецЕсли;
	
	ЮТРегистрацияОшибок.СгенерироватьОшибкуУтверждения(Контекст, СообщениеОбОшибке, Неопределено, "проверяемая таблица");
	
КонецПроцедуры

Процедура УстановитьОписаниеПроверки(Контекст, ОписаниеПроверки)
	
	Контекст.ОписаниеПроверки = ОписаниеПроверки;
	
КонецПроцедуры

#КонецОбласти
