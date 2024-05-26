//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2024 BIA-Technologies Limited Liability Company
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

Процедура Записать(УровеньЛога, Сообщение, Приоритет) Экспорт
	
	Контекст = Контекст();
	Если НЕ ЛогированиеВключено(Контекст, Приоритет) Тогда
		Возврат;
	КонецЕсли;
	
#Если Клиент Тогда
	КонтекстИсполнения = "Клиент";
#Иначе
	КонтекстИсполнения = "Сервер";
#КонецЕсли
	Текст = СтрШаблон("%1 [%2][%3]: %4", ЮТОбщий.ПредставлениеУниверсальнойДата(), КонтекстИсполнения, УровеньЛога, Сообщение);
#Если Клиент Тогда
	ЗаписатьСообщения(Контекст, ЮТКоллекции.ЗначениеВМассиве(Текст));
#Иначе
	// Для серверной базы все равно нужно накапливать сообшения, если включен вывод в консоль
	Если ЮТест.Окружение().ФайловаяБаза Или Контекст.ФайлЛогаДоступенНаСервере Тогда
		ЗаписатьСообщения(Контекст, ЮТКоллекции.ЗначениеВМассиве(Текст));
	Иначе
		Контекст.НакопленныеЗаписи.Добавить(Текст);
	КонецЕсли;
#КонецЕсли
	
КонецПроцедуры

Процедура ВывестиСерверныеСообщения() Экспорт
	
#Если Клиент Тогда
	Контекст = Контекст();
	Если Контекст = Неопределено ИЛИ НЕ Контекст.Включено ИЛИ Контекст.ФайлЛогаДоступенНаСервере Тогда
		Возврат;
	КонецЕсли;
	
	Сообщения = ЮТЛогированиеСлужебныйВызовСервера.НакопленныеСообщенияЛогирования(Истина);
	ЗаписатьСообщения(Контекст, Сообщения);
#Иначе
	ВызватьИсключение ЮТИсключения.МетодНеДоступен("ВывестиСерверныеСообщения");
#КонецЕсли
	
КонецПроцедуры

Функция НакопленныеСообщенияЛогирования(Очистить = Ложь) Экспорт
	
	Контекст = Контекст();
	
	Сообщения = Контекст.НакопленныеЗаписи;
	
	Если Очистить Тогда
		Контекст.НакопленныеЗаписи = Новый Массив();
	КонецЕсли;
	
	Возврат Сообщения;
	
КонецФункции

#Область ОбработчикиСобытий

// Инициализация.
//
// Параметры:
//  ПараметрыЗапуска - см. ЮТФабрика.ПараметрыЗапуска
Процедура Инициализация(ПараметрыЗапуска) Экспорт
	
	УровниЛога = ЮТЛогирование.УровниЛога();
	
	ДанныеКонтекста = НовыйДанныеКонтекста();
	ДанныеКонтекста.ФайлЛога = ЮТКоллекции.ЗначениеСтруктуры(ПараметрыЗапуска.logging, "file");
	ДанныеКонтекста.ВыводВКонсоль = ЮТКоллекции.ЗначениеСтруктуры(ПараметрыЗапуска.logging, "console", Ложь);
	ДанныеКонтекста.Включено = ЮТКоллекции.ЗначениеСтруктуры(ПараметрыЗапуска.logging, "enable", Неопределено);
	УровеньЛога = ЮТКоллекции.ЗначениеСтруктуры(ПараметрыЗапуска.logging, "level", УровниЛога.Отладка);
	
	Если ДанныеКонтекста.Включено = Неопределено Тогда
		ДанныеКонтекста.Включено = ДанныеКонтекста.ВыводВКонсоль ИЛИ ЗначениеЗаполнено(ДанныеКонтекста.ФайлЛога);
	КонецЕсли;
	
	Если НЕ ДанныеКонтекста.Включено Тогда
		ЮТКонтекстСлужебный.УстановитьЗначениеКонтекста(ИмяКонтекстаЛогирования(), ДанныеКонтекста, Истина);
		Возврат;
	КонецЕсли;
	
	Если СтрСравнить(УровеньЛога, УровниЛога.Ошибка) = 0 Тогда
		ДанныеКонтекста.УровеньЛога = 99;
	ИначеЕсли СтрСравнить(УровеньЛога, УровниЛога.Информация) = 0 Тогда
		ДанныеКонтекста.УровеньЛога = 10;
	ИначеЕсли СтрСравнить(УровеньЛога, УровниЛога.Предупреждение) = 0 Тогда
		ДанныеКонтекста.УровеньЛога = 20;
	Иначе
		ДанныеКонтекста.УровеньЛога = 0;
	КонецЕсли;
	
	ЗначениеПроверки = Строка(Новый УникальныйИдентификатор());
	ЗаписатьСообщения(ДанныеКонтекста, ЮТКоллекции.ЗначениеВМассиве(ЗначениеПроверки), Ложь);
	
	ДанныеКонтекста.ФайлЛогаДоступенНаСервере = ЮТЛогированиеСлужебныйВызовСервера.ФайлЛогаДоступенНаСервере(ДанныеКонтекста.ФайлЛога, ЗначениеПроверки);
	
	ЮТКонтекстСлужебный.УстановитьЗначениеКонтекста(ИмяКонтекстаЛогирования(), ДанныеКонтекста, Истина);
	
	Разделитель = "------------------------------------------------------";
	ЗаписатьСообщения(ДанныеКонтекста, ЮТКоллекции.ЗначениеВМассиве(Разделитель), Ложь);
	
	ЮТЛогирование.Информация("Старт");
	
КонецПроцедуры

// Обработка события "ПередЧтениеСценариев"
Процедура ПередЧтениеСценариев() Экспорт
	
	ЮТЛогирование.Информация("Загрузка сценариев");
	
КонецПроцедуры

// Перед чтением сценариев модуля.
//
// Параметры:
//  МетаданныеМодуля - см. ЮТФабрикаСлужебный.ОписаниеМодуля
//  ИсполняемыеСценарии - см. ЮТТесты.СценарииМодуля
Процедура ПередЧтениемСценариевМодуля(МетаданныеМодуля, ИсполняемыеСценарии) Экспорт
	
	ЮТЛогирование.Информация(СтрШаблон("Загрузка сценариев модуля `%1`", МетаданныеМодуля.Имя));
	
КонецПроцедуры

// Перед чтением сценариев модуля.
//
// Параметры:
//  МетаданныеМодуля - см. ЮТФабрикаСлужебный.ОписаниеМодуля
Процедура ПослеЧтенияСценариевМодуля(ОписаниеТестовогоМодуля) Экспорт
	
	ЮТЛогирование.Информация(СтрШаблон("Загрузка сценариев модуля завершена `%1`", ОписаниеТестовогоМодуля.МетаданныеМодуля.Имя));
	
КонецПроцедуры

// Обработка события "ПослеЧтенияСценариев"
// Параметры:
//  Сценарии - Массив из см. ЮТФабрикаСлужебный.ОписаниеТестовогоМодуля - Набор описаний тестовых модулей, которые содержат информацию о запускаемых тестах
Процедура ПослеЧтенияСценариев(Сценарии) Экспорт
	
	ЮТЛогирование.Информация("Загрузка сценариев завершена.");
	
КонецПроцедуры

// Обработка события "ПослеФормированияИсполняемыхНаборовТестов"
// Параметры:
//  ИсполняемыеТестовыеМодули - Массив из см. ЮТФабрикаСлужебный.ОписаниеИсполняемогоТестовогоМодуля - Набор исполняемых наборов
Процедура ПослеФормированияИсполняемыхНаборовТестов(ИсполняемыеТестовыеМодули) Экспорт
	
	Количество = 0;
	
	Для Каждого ТестовыйМодуль Из ИсполняемыеТестовыеМодули Цикл
		
		Для Каждого Набор Из ТестовыйМодуль.НаборыТестов Цикл
			
			Если Набор.Выполнять Тогда
				ЮТОбщий.Инкремент(Количество, Набор.Тесты.Количество());
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
	ЮТКонтекстСлужебный.УстановитьЗначениеКонтекста(ИмяКонтекстаЛогирования() + ".ОбщееКоличествоТестов", Количество, Истина);
	
КонецПроцедуры

// Перед всеми тестами.
//
// Параметры:
//  ОписаниеСобытия - см. ЮТФабрикаСлужебный.ОписаниеСобытияИсполненияТестов
Процедура ПередВсемиТестами(ОписаниеСобытия) Экспорт
	
#Если Клиент Тогда
	Контекст = Контекст();
	ПрогрессКлиент = Контекст.КоличествоВыполненныхТестов;
	ПрогрессСервер = ЮТКонтекстСлужебный.ЗначениеКонтекста(ИмяКонтекстаЛогирования() + ".КоличествоВыполненныхТестов", Истина);
	
	Если ПрогрессКлиент < ПрогрессСервер Тогда
		Контекст.КоличествоВыполненныхТестов = ПрогрессСервер;
	КонецЕсли;
#КонецЕсли
	ЮТЛогирование.Информация(СтрШаблон("Запуск тестов модуля `%1`", ОписаниеСобытия.Модуль.МетаданныеМодуля.ПолноеИмя));
	
КонецПроцедуры

// Перед тестовым набором.
//
// Параметры:
//  ОписаниеСобытия - см. ЮТФабрикаСлужебный.ОписаниеСобытияИсполненияТестов
Процедура ПередТестовымНабором(ОписаниеСобытия) Экспорт
	
	ЮТЛогирование.Информация(СтрШаблон("Запуск тестов набора `%1`", ОписаниеСобытия.Набор.Имя));
	
КонецПроцедуры

// Перед каждым тестом.
//
// Параметры:
//  ОписаниеСобытия - см. ЮТФабрикаСлужебный.ОписаниеСобытияИсполненияТестов
Процедура ПередКаждымТестом(ОписаниеСобытия) Экспорт
	
	ЮТЛогирование.Информация(СтрШаблон("Запуск теста `%1`", ОписаниеСобытия.Тест.Имя));
	
КонецПроцедуры

// Перед каждым тестом.
//
// Параметры:
//  ОписаниеСобытия - см. ЮТФабрикаСлужебный.ОписаниеСобытияИсполненияТестов
Процедура ПослеКаждогоТеста(ОписаниеСобытия) Экспорт
	
	Контекст = Контекст();
	Если НЕ ЛогированиеВключено(Контекст) Тогда
		Возврат;
	КонецЕсли;
	
	ЮТОбщий.Инкремент(Контекст.КоличествоВыполненныхТестов);
	ЮТЛогирование.Информация(СтрШаблон("%1 Завершен тест `%2`", Прогресс(), ОписаниеСобытия.Тест.Имя));
	
КонецПроцедуры

// Перед каждым тестом.
//
// Параметры:
//  ОписаниеСобытия - см. ЮТФабрикаСлужебный.ОписаниеСобытияИсполненияТестов
Процедура ПослеТестовогоНабора(ОписаниеСобытия) Экспорт
	
	ЮТЛогирование.Информация(СтрШаблон("Завершен тестовый набор `%1`", ОписаниеСобытия.Набор.Имя));
	
КонецПроцедуры

// Перед каждым тестом.
//
// Параметры:
//  ОписаниеСобытия - см. ЮТФабрикаСлужебный.ОписаниеСобытияИсполненияТестов
Процедура ПослеВсехТестов(ОписаниеСобытия) Экспорт
	
	Контекст = Контекст();
	Если НЕ ЛогированиеВключено(Контекст) Тогда
		Возврат;
	КонецЕсли;
#Если Клиент Тогда
	ЮТКонтекстСлужебный.УстановитьЗначениеКонтекста(ИмяКонтекстаЛогирования() + ".КоличествоВыполненныхТестов", Контекст.КоличествоВыполненныхТестов, Истина);
#КонецЕсли
	
	ЮТЛогирование.Информация(СтрШаблон("Завершен модуль `%1`", ОписаниеСобытия.Модуль.МетаданныеМодуля.ПолноеИмя));
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область Запись

Функция ЛогированиеВключено(Знач Контекст = Неопределено, Приоритет = Неопределено)
	
	Если Контекст = Неопределено Тогда
		Контекст = Контекст();
	КонецЕсли;
	
	Возврат Контекст <> Неопределено И Контекст.Включено И (Приоритет = Неопределено ИЛИ Контекст.УровеньЛога <= Приоритет);
	
КонецФункции

Процедура ЗаписатьСообщения(Контекст, Сообщения, Дописывать = Истина)
	
#Если ВебКлиент Тогда
	ВызватьИсключение ЮТИсключения.МетодНеДоступен("ЗаписатьСообщения");
#Иначе
	Если Контекст.ВыводВКонсоль Тогда
		ЗаписатьЛогВКонсоль(Сообщения);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Контекст.ФайлЛога) Тогда
		ЗаписатьЛогВФайл(Контекст.ФайлЛога, Сообщения, Дописывать);
	КонецЕсли;
#КонецЕсли
	
КонецПроцедуры

Процедура ЗаписатьЛогВФайл(ФайлЛога, Сообщения, Дописывать = Истина)
	
#Если ВебКлиент Тогда
	ВызватьИсключение ЮТИсключения.МетодНеДоступен("ЗаписатьЛогВФайл");
#Иначе
	Запись = Новый ЗаписьТекста(ФайлЛога, КодировкаТекста.UTF8, , Дописывать);
	
	Для Каждого Сообщение Из Сообщения Цикл
		Запись.ЗаписатьСтроку(Сообщение);
	КонецЦикла;
	
	Запись.Закрыть();
#КонецЕсли
	
КонецПроцедуры

Процедура ЗаписатьЛогВКонсоль(Сообщения)
	
#Если ВебКлиент Тогда
	ВызватьИсключение ЮТИсключения.МетодНеДоступен("ЗаписатьЛогВКонсоль");
#Иначе
	//@skip-check empty-except-statement
	Попытка
		Для Каждого Сообщение Из Сообщения Цикл
			ЮТОбщий.ВывестиВКонсоль(Сообщение);
		КонецЦикла;
	Исключение
		// Игнорируем ошибку
	КонецПопытки;
#КонецЕсли
	
КонецПроцедуры

Функция Прогресс()
	
	Контекст = Контекст();
	Прогресс = Окр(100 * Контекст.КоличествоВыполненныхТестов / Контекст.ОбщееКоличествоТестов, 0);
	
	Возврат СтрШаблон("%1%% (%2/%3)", Прогресс, Контекст.КоличествоВыполненныхТестов, Контекст.ОбщееКоличествоТестов);
	
КонецФункции

#КонецОбласти

#Область Контекст

// Контекст.
//
// Возвращаемое значение:
//  см. НовыйДанныеКонтекста
Функция Контекст()
	
	Возврат ЮТКонтекстСлужебный.ЗначениеКонтекста(ИмяКонтекстаЛогирования());
	
КонецФункции

Функция ИмяКонтекстаЛогирования()
	
	Возврат "КонтекстЛогирования";
	
КонецФункции

// Новый данные контекста.
//
// Возвращаемое значение:
//  Структура - Новый данные контекста:
// * Включено - Булево - Логирование включено
// * ФайлЛога - Неопределено - Файл вывода лога
// * ВыводВКонсоль- Булево - Вывод лога в консоль
// * ФайлЛогаДоступенНаСервере - Булево - Файл лога доступен на сервере
// * НакопленныеЗаписи - Массив из Строка - Буфер для серверных сообщений
// * ОбщееКоличествоТестов - Число
// * КоличествоВыполненныхТестов - Число
// * УровеньЛога - Число - Уровень логирования
Функция НовыйДанныеКонтекста()
	
	ДанныеКонтекста = Новый Структура();
	ДанныеКонтекста.Вставить("Включено", Ложь);
	ДанныеКонтекста.Вставить("ФайлЛога", Неопределено);
	ДанныеКонтекста.Вставить("ВыводВКонсоль", Ложь);
	ДанныеКонтекста.Вставить("ФайлЛогаДоступенНаСервере", Ложь);
	ДанныеКонтекста.Вставить("НакопленныеЗаписи", Новый Массив());
	ДанныеКонтекста.Вставить("ОбщееКоличествоТестов", 0);
	ДанныеКонтекста.Вставить("КоличествоВыполненныхТестов", 0);
	ДанныеКонтекста.Вставить("УровеньЛога", 0);
	
	Возврат ДанныеКонтекста;
	
КонецФункции

#КонецОбласти

#КонецОбласти
