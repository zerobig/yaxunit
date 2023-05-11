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

#Область СлужебныйПрограммныйИнтерфейс

Функция РезультатЗапроса(ОписаниеЗапроса, ДляКлиента) Экспорт
	
	Запрос = Запрос(ОписаниеЗапроса);
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ ДляКлиента Тогда
		Возврат РезультатЗапроса.Выгрузить();
	ИначеЕсли РезультатЗапроса.Пустой() Тогда
		Возврат Новый Массив();
	КонецЕсли;
	
	Ключи = СтрСоединить(ЮТОбщий.ВыгрузитьЗначения(РезультатЗапроса.Колонки, "Имя"), ",");
	Результат = Новый Массив();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Запись = Новый Структура(Ключи);
		ЗаполнитьЗначенияСвойств(Запись, Выборка);
		Результат.Добавить(Запись);
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Результат пустой.
// 
// Параметры:
//  ОписаниеЗапроса - см. ЮТЗапросы.ОписаниеЗапроса
// 
// Возвращаемое значение:
//  Булево - Результат пустой
Функция РезультатПустой(Знач ОписаниеЗапроса) Экспорт
	
	Запрос = Запрос(ОписаниеЗапроса);
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса.Пустой();
	
КонецФункции

// Возвращает значения реквизитов ссылки
// 
// Параметры:
//  Ссылка - ЛюбаяСсылка
//  ИменаРеквизитов - Строка
//  ОдинРеквизит - Булево
// 
// Возвращаемое значение:
//  Структура Из Произвольный - Значения реквизитов ссылки, про значений получения множества реквизитов
//  Произвольный - Значения реквизитов ссылки, если при получении значения одного реквизита
Функция ЗначенияРеквизитов(Ссылка, ИменаРеквизитов, ОдинРеквизит) Экспорт
	
	ИмяТаблицы = Ссылка.Метаданные().ПолноеИмя();
	
	ТекстЗапроса = СтрШаблон("ВЫБРАТЬ ПЕРВЫЕ 1 %1 ИЗ %2 ГДЕ Ссылка = &Ссылка", ИменаРеквизитов, ИмяТаблицы);
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Если ОдинРеквизит Тогда
		Возврат ЗначениеИзЗапроса(Запрос, 0);
	Иначе
		Возврат ЗначенияИзЗапроса(Запрос, ИменаРеквизитов);
	КонецЕсли;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Запрос.
// 
// Параметры:
//  ОписаниеЗапроса - см. ЮТЗапросы.ОписаниеЗапроса
// 
// Возвращаемое значение:
//  Запрос
Функция Запрос(ОписаниеЗапроса)
	
	Строки = Новый Массив();
	Строки.Добавить("ВЫБРАТЬ ");
	
	Если ОписаниеЗапроса.КоличествоЗаписей <> Неопределено Тогда
		Строки.Добавить("ПЕРВЫЕ " + ЮТОбщий.ЧислоВСтроку(ОписаниеЗапроса.КоличествоЗаписей));
	КонецЕсли;
	
	ВыбираемыеПоля = Новый Массив();
	Для Каждого Выражение Из ОписаниеЗапроса.ВыбираемыеПоля Цикл
		Поле = СтрШаблон("	%1 КАК %2", ?(Выражение.Значение = Неопределено, Выражение.Ключ, Выражение.Значение), Выражение.Ключ);
		ВыбираемыеПоля.Добавить(Поле);
	КонецЦикла;
	
	Если НЕ ВыбираемыеПоля.Количество() Тогда
		ВыбираемыеПоля.Добавить("1 КАК Поле");
	КонецЕсли;
	
	Строки.Добавить(СтрСоединить(ВыбираемыеПоля, "," + Символы.ПС));
	Строки.Добавить("ИЗ " + ОписаниеЗапроса.ИмяТаблицы);
	
	Если ОписаниеЗапроса.Условия.Количество() Тогда
		Строки.Добавить("ГДЕ (");
		Строки.Добавить(СтрСоединить(ОписаниеЗапроса.Условия, ") И (" + Символы.ПС));
		Строки.Добавить(")");
	КонецЕсли;
	
	Запрос = Новый Запрос(СтрСоединить(Строки, Символы.ПС));
	ЮТОбщий.ОбъединитьВСтруктуру(Запрос.Параметры, ОписаниеЗапроса.ЗначенияПараметров);
	
	Возврат Запрос;
	
КонецФункции

Функция ЗначенияИзЗапроса(Запрос, Реквизиты)
	
	Результат = Новый Структура(Реквизиты);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		ЗаполнитьЗначенияСвойств(Результат, Выборка);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ЗначениеИзЗапроса(Запрос, Реквизит)
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка[Реквизит];
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции

#КонецОбласти
