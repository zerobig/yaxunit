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

Функция СоздатьЗапись(Знач Менеджер, Знач Данные, Знач ПараметрыЗаписи, Знач ВернутьОбъект) Экспорт
	
	Менеджер = ЮТОбщий.Менеджер(Менеджер);
	ПараметрыЗаписи = ПараметрыЗаписи(ПараметрыЗаписи);
	
	Объект = НовыйОбъект(Менеджер, Данные, ПараметрыЗаписи.ДополнительныеСвойства);
	
	КлючЗаписи = ЗаписатьОбъект(Объект, ПараметрыЗаписи);
	
	Если ВернутьОбъект Тогда
		Возврат Объект;
	Иначе
		Возврат КлючЗаписи;
	КонецЕсли;
	
КонецФункции

// Создает новый объект и заполняет его данными
// 
// Параметры:
//  Менеджер - Произвольный
//  Данные - Структура - Данные заполнения объекта
//  ДополнительныеСвойства - Структура - Дополнительные свойства объекта
// 
// Возвращаемое значение:
//  Произвольный - Созданный объект
Функция НовыйОбъект(Знач Менеджер, Знач Данные, Знач ДополнительныеСвойства = Неопределено) Экспорт
	
	Менеджер = ЮТОбщий.Менеджер(Менеджер);
	
	ОписаниеОбъектаМетаданных = ЮТМетаданные.ОписаниеОбъектаМетаданных(Менеджер);
	
	Объект = СоздатьОбъект(Менеджер, ОписаниеОбъектаМетаданных.ОписаниеТипа, Данные);
	ЗаполнитьЗначенияСвойств(Объект, Данные);
	
	Если ОписаниеОбъектаМетаданных.ОписаниеТипа.ТабличныеЧасти Тогда
		
		Для Каждого ОписаниеТабличнойЧасти Из ОписаниеОбъектаМетаданных.ТабличныеЧасти Цикл
			
			ИмяТабличнойЧасти = ОписаниеТабличнойЧасти.Ключ;
			Если НЕ Данные.Свойство(ИмяТабличнойЧасти) Тогда
				Продолжить;
			КонецЕсли;
			
			Для Каждого Запись Из Данные[ИмяТабличнойЧасти] Цикл
				Строка = Объект[ИмяТабличнойЧасти].Добавить();
				ЗаполнитьЗначенияСвойств(Строка, Запись);
			КонецЦикла;
			
		КонецЦикла;
		
	КонецЕсли;
	
	ЗаполнитьБазовыеРеквизиты(Объект, ОписаниеОбъектаМетаданных);
	
	Если ОписаниеОбъектаМетаданных.ОписаниеТипа.Ссылочный И ДополнительныеСвойства <> Неопределено Тогда
		ЮТОбщий.ОбъединитьВСтруктуру(Объект.ДополнительныеСвойства, ДополнительныеСвойства);
	КонецЕсли;
	
	Возврат Объект;
	
КонецФункции

Процедура Удалить(Знач Ссылки) Экспорт
	
	Если ТипЗнч(Ссылки) <> Тип("Массив") Тогда
		Ссылки = ЮТОбщий.ЗначениеВМассиве(Ссылки);
	КонецЕсли;
	
	СсылочныеТипы = ЮТОбщий.ОписаниеТиповЛюбаяСсылка();
	Ошибки = Новый Массив;
	
	Для Каждого Ссылка Из Ссылки Цикл
		
		ТипЗначения = ТипЗнч(Ссылка);
		Если Ссылка = Неопределено ИЛИ СтрНачинаетсяС(ЮТОбщий.ПредставлениеТипа(ТипЗначения), "Enum") Тогда
			Продолжить;
		КонецЕсли;
		
		Попытка
			Если СсылочныеТипы.СодержитТип(ТипЗначения) Тогда
				Объект = Ссылка.ПолучитьОбъект();
				Если Объект <> Неопределено Тогда
					Объект.Удалить();
				КонецЕсли;
			Иначе
				Менеджер = ЮТОбщий.Менеджер(ТипЗначения);
				Запись = Менеджер.СоздатьМенеджерЗаписи();
				ЗаполнитьЗначенияСвойств(Запись, Ссылка);
				Запись.Прочитать();
				Запись.Удалить();
			КонецЕсли;
		Исключение
			
			Ошибки.Добавить(ЮТРегистрацияОшибок.ПредставлениеОшибки("Удаление " + Ссылка, ИнформацияОбОшибке()));
			
		КонецПопытки;
		
	КонецЦикла;
	
	ОбновитьНумерациюОбъектов();
	
	Если ЗначениеЗаполнено(Ошибки) Тогда
		ВызватьИсключение СтрСоединить(Ошибки, Символы.ПС);
	КонецЕсли;
	
КонецПроцедуры

Функция ФикцияЗначенияБазы(Знач ТипЗначения, Знач РеквизитыЗаполнения = Неопределено) Экспорт
	
	ОбъектМетаданных = Метаданные.НайтиПоТипу(ТипЗначения);
	
	Если ОбъектМетаданных = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если Метаданные.Перечисления.Содержит(ОбъектМетаданных) Тогда
		
		Возврат СлучайноеЗначениеПеречисления(ОбъектМетаданных);
		
	КонецЕсли;
	
	ОписаниеОбъектаМетаданных = ЮТМетаданные.ОписаниеОбъектаМетаданных(ОбъектМетаданных);
	ОписаниеТипа = ОписаниеОбъектаМетаданных.ОписаниеТипа;
	
	Если ЮТОбщийВызовСервера.ЭтоАнглийскийВстроенныйЯзык() Тогда
		ИмяТипаМенеджера = СтрШаблон("%1Manager.%2", ОписаниеТипа.Имя, ОбъектМетаданных.Имя);
	Иначе
		ИмяТипаМенеджера = СтрШаблон("%1Менеджер.%2", ОписаниеТипа.Имя, ОбъектМетаданных.Имя);
	КонецЕсли;
	Менеджер = Новый (ИмяТипаМенеджера);
	
	Объект = СоздатьОбъект(Менеджер, ОписаниеТипа, РеквизитыЗаполнения);
	
	Если ЗначениеЗаполнено(РеквизитыЗаполнения) Тогда
		ЗаполнитьЗначенияСвойств(Объект, РеквизитыЗаполнения);
	КонецЕсли;
	
	ЗаполнитьБазовыеРеквизиты(Объект, ОписаниеОбъектаМетаданных);
	
	Возврат ЗаписатьОбъект(Объект, ПараметрыЗаписи());
	
КонецФункции

Функция ЗагрузитьИзМакета(Знач Макет,
						  Знач ОписанияТипов,
						  Знач КэшЗначений,
						  Знач ЗаменяемыеЗначения,
						  Знач ПараметрыЗаполнения,
						  Знач ТаблицаЗначений) Экспорт
	
	Таблица = ЮТТестовыеДанные_ТаблицыЗначений.ЗагрузитьИзМакета(Макет,
																 ОписанияТипов,
																 КэшЗначений,
																 ЗаменяемыеЗначения,
																 ПараметрыЗаполнения);
	
	Если ТаблицаЗначений Тогда
		Возврат Таблица;
	КонецЕсли;
	
	Реквизиты = СтрСоединить(ЮТОбщий.ВыгрузитьЗначения(Таблица.Колонки, "Имя"), ",");
	Результат = Новый Массив(Таблица.Количество());
	
	Для Инд = 0 По Таблица.Количество() - 1 Цикл
		Запись = Новый Структура(Реквизиты);
		ЗаполнитьЗначенияСвойств(Запись, Таблица[Инд]);
		Результат[Инд] = Запись;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция СлучайноеЗначениеПеречисления(Знач Перечисление) Экспорт
	
	Менеджер = ЮТОбщий.Менеджер(Перечисление);
	
	НомерЗначения = ЮТТестовыеДанные.СлучайноеПоложительноеЧисло(Менеджер.Количество());
	Возврат Менеджер.Получить(НомерЗначения - 1);
	
КонецФункции

Процедура УстановитьЗначенияРеквизитов(Знач Ссылка, Знач ЗначенияРеквизитов, Знач ПараметрыЗаписи = Неопределено) Экспорт
	
	Объект = Ссылка.ПолучитьОбъект();
	ПараметрыЗаписи = ПараметрыЗаписи(ПараметрыЗаписи);
	
	Для Каждого Элемент Из ЗначенияРеквизитов Цикл
		Объект[Элемент.Ключ] = Элемент.Значение;
	КонецЦикла;
	
	ЗаписатьОбъект(Объект, ПараметрыЗаписи);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Создать объект.
// 
// Параметры: ОписаниеМенеджера - 
// См. ОписаниеМенеджера
//  Менеджер - Произвольный - Менеджер
//  ОписаниеТипа - см. ЮТМетаданные.ОписаниеОбъектаМетаданных
//  Данные - Структура
// Возвращаемое значение:
//  Произвольный - Создать объект
Функция СоздатьОбъект(Менеджер, ОписаниеТипа, Данные)
	
	Если ОписаниеТипа.Конструктор = "СоздатьЭлемент" Тогда
		
		ЭтоГруппа = ?(Данные = Неопределено, Ложь, ЮТОбщий.ЗначениеСтруктуры(Данные, "ЭтоГруппа", Ложь));
		Если ЭтоГруппа Тогда
			Результат = Менеджер.СоздатьГруппу();
		Иначе
			Результат = Менеджер.СоздатьЭлемент();
		КонецЕсли;
		
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьДокумент" Тогда
		Результат = Менеджер.СоздатьДокумент();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьСчет" Тогда
		Результат = Менеджер.СоздатьСчет();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьВидРасчета" Тогда
		Результат = Менеджер.СоздатьВидРасчета();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьУзел" Тогда
		Результат = Менеджер.СоздатьУзел();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьНаборЗаписей" Тогда
		Результат = Менеджер.СоздатьНаборЗаписей();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьМенеджерЗаписи" Тогда
		Результат = Менеджер.СоздатьМенеджерЗаписи();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьБизнесПроцесс" Тогда
		Результат = Менеджер.СоздатьБизнесПроцесс();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьЗадачу" Тогда
		Результат = Менеджер.СоздатьЗадачу();
	Иначе
		ВызватьИсключение СтрШаблон("Для %1 не поддерживается создание записей ИБ", ОписаниеТипа.Имя);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Записать объект.
// 
// Параметры:
//  Объект - Произвольный -  Объект
//  ПараметрыЗаписи - см. ЮТОбщий.ПараметрыЗаписи
// 
// Возвращаемое значение:
//  ЛюбаяСсылка
Функция ЗаписатьОбъект(Объект, ПараметрыЗаписи)
	
	Если ПараметрыЗаписи.ОбменДаннымиЗагрузка Тогда
		Объект.ОбменДанными.Загрузка = Истина;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПараметрыЗаписи.ДополнительныеСвойства) Тогда
		ЮТОбщий.ОбъединитьВСтруктуру(Объект.ДополнительныеСвойства, ПараметрыЗаписи.ДополнительныеСвойства);
	КонецЕсли;
	
	Попытка
		
		Если ПараметрыЗаписи.РежимЗаписи <> Неопределено Тогда
			Объект.Записать(ПараметрыЗаписи.РежимЗаписи);
		Иначе
			Объект.Записать();
		КонецЕсли;
		
		Если ПараметрыЗаписи.ОбменДаннымиЗагрузка Тогда
			Объект.ОбменДанными.Загрузка = Ложь;
		КонецЕсли;
		
		Возврат КлючЗаписи(Объект);
		
	Исключение
		
		ЮТРегистрацияОшибок.ДобавитьПояснениеОшибки(СтрШаблон("Не удалось записать объект `%1` (%2)", Объект, ТипЗнч(Объект)));
		ВызватьИсключение;
		
	КонецПопытки;
	
КонецФункции

Процедура ЗаполнитьБазовыеРеквизиты(Объект, ОписаниеОбъектаМетаданных)
	
	АнглийскийЯзык = ЮТОбщийВызовСервера.ЭтоАнглийскийВстроенныйЯзык();
	ИмяТипаДокумент = ?(АнглийскийЯзык,"Document","Документ");
	ИмяРеквизитаКод = ?(АнглийскийЯзык,"Code","Код");
	ИмяРеквизитаНаименование = ?(АнглийскийЯзык,"Description","Наименование");
	
	ОписаниеТипа = ОписаниеОбъектаМетаданных.ОписаниеТипа;
	Если ОписаниеТипа.Имя = ИмяТипаДокумент Тогда
		Если НЕ ЗначениеЗаполнено(Объект.Дата) Тогда
			Объект.Дата = ТекущаяДатаСеанса();
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(Объект.Номер) Тогда
			Объект.УстановитьНовыйНомер();
		КонецЕсли;
	КонецЕсли;
	
	Если ОписаниеОбъектаМетаданных.Реквизиты.Свойство(ИмяРеквизитаКод)
		И ОписаниеОбъектаМетаданных.Реквизиты[ИмяРеквизитаКод].Обязательный
		И Не ЗначениеЗаполнено(Объект.Код) Тогда
		Объект.УстановитьНовыйКод();
	КонецЕсли;
	
	Если ОписаниеОбъектаМетаданных.Реквизиты.Свойство(ИмяРеквизитаНаименование)
		И ОписаниеОбъектаМетаданных.Реквизиты[ИмяРеквизитаНаименование].Обязательный
		И Не ЗначениеЗаполнено(Объект.Наименование) Тогда
		Объект.Наименование = ЮТТестовыеДанные.СлучайнаяСтрока();
	КонецЕсли;
	
КонецПроцедуры

Функция КлючЗаписи(Объект)
	
	ТипЗначения = ТипЗнч(Объект);
	
	Если ЮТТипыДанныхСлужебный.ЭтоТипОбъекта(ТипЗначения) Тогда
		
		Возврат Объект.Ссылка;
		
	ИначеЕсли ЮТТипыДанныхСлужебный.ЭтоМенеджерЗаписи(ТипЗначения) Тогда
		
		Описание = ЮТМетаданные.ОписаниеОбъектаМетаданных(Объект);
		
		КлючевыеРеквизиты = Новый Структура();
		Для Каждого Реквизит Из Описание.Реквизиты Цикл
			Если Реквизит.Значение.ЭтоКлюч Тогда
				КлючевыеРеквизиты.Вставить(Реквизит.Ключ, Объект[Реквизит.Ключ]);
			КонецЕсли;
		КонецЦикла;
		
		Менеджер = ЮТОбщий.Менеджер(Описание);
		Возврат Менеджер.СоздатьКлючЗаписи(КлючевыеРеквизиты);
		
	Иначе
		
		Сообщение = ЮТОбщий.НеподдерживаемыйПараметрМетода("ЮТТестовыеДанныеВызовСервера.КлючЗаписи", Объект);
		ВызватьИсключение Сообщение;
		
	КонецЕсли;
	
КонецФункции

Функция ПараметрыЗаписи(ВходящиеПараметрыЗаписи = Неопределено)
	
	Если ВходящиеПараметрыЗаписи = Неопределено Тогда
		Возврат ЮТОбщий.ПараметрыЗаписи();
	Иначе
		ПараметрыЗаписи = ЮТОбщий.ПараметрыЗаписи();
		ЗаполнитьЗначенияСвойств(ПараметрыЗаписи, ВходящиеПараметрыЗаписи);
		Возврат ПараметрыЗаписи;
	КонецЕсли;
	
КонецФункции

#КонецОбласти
