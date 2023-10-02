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

Функция ПредставлениеТипа(Тип) Экспорт
	
#Если ВебКлиент Тогда
	ВызватьИсключение ЮТОбщий.МетодНеДоступен("ЮТТипыДанныхСлужебный.ПредставлениеТипа");
#Иначе
	//@skip-check Undefined variable
	ТипXML = СериализаторXDTO.XMLТип(Тип);
	
	Если ТипXML = Неопределено Тогда
		Возврат Строка(Тип);
	Иначе
		Возврат ТипXML.ИмяТипа;
	КонецЕсли;
#КонецЕсли
	
КонецФункции

Функция ИдентификаторТипа(Тип) Экспорт
	
#Если ВебКлиент Тогда
	ВызватьИсключение ЮТОбщий.МетодНеДоступен("ЮТТипыДанныхСлужебный.ПредставлениеТипа");
#ИначеЕсли Сервер Тогда
	Возврат ЗначениеВСтрокуВнутр(Тип); // Не все серверные типы сериализуются через СериализаторXDTO
#Иначе
	Попытка
		Запись = Новый ЗаписьJSON();
		Запись.УстановитьСтроку();
		СериализаторXDTO.ЗаписатьJSON(Запись, Тип);
		Возврат Запись.Закрыть();
	Исключение
		ЮТРегистрацияОшибок.ДобавитьПояснениеОшибки(СтрШаблон("Не удалось определить идетификатор типа для `%1`", Тип));
		ВызватьИсключение;
	КонецПопытки;
#КонецЕсли
	
КонецФункции

Функция ТипПоИдентификатору(ИдентификаторТипа) Экспорт
	
#Если ВебКлиент Тогда
	ВызватьИсключение ЮТОбщий.МетодНеДоступен("ЮТТипыДанныхСлужебный.ПредставлениеТипа");
#ИначеЕсли Сервер Тогда
	Если СтрНачинаетсяС(ИдентификаторТипа, "{") Тогда
		Возврат ЗначениеИзСтрокиВнутр(ИдентификаторТипа);
	КонецЕсли;
#КонецЕсли
	
	Возврат ТипПоПредставлению(ИдентификаторТипа);
	
КонецФункции

Функция ТипПоПредставлению(ПредставлениеТипа) Экспорт
	
#Если ВебКлиент Тогда
	ВызватьИсключение ЮТОбщий.МетодНеДоступен("ЮТТипыДанныхСлужебный.ТипПоПредставлению");
#Иначе
	Чтение = Новый ЧтениеJSON();
	Чтение.УстановитьСтроку(ПредставлениеТипа);
	Результат = СериализаторXDTO.ПрочитатьJSON(Чтение, Тип("Тип"));
	
	Если Результат = Неопределено Тогда
		ВызватьИсключение СтрШаблон("Не удалось определить тип по представлению `%1`", ПредставлениеТипа);
	КонецЕсли;
	
	Возврат Результат;
#КонецЕсли
	
КонецФункции

Функция ЭтоСсылочныйТип(Тип) Экспорт
	
	Возврат Тип <> Неопределено И ЮТОбщий.ОписаниеТиповЛюбаяСсылка().СодержитТип(Тип);
	
КонецФункции

#Область СистемныеПеречисления

Функция ЭтоСистемноеПеречисление(Тип) Экспорт
	
	Возврат ТипыСистемныхПеречислений().СодержитТип(Тип);
	
КонецФункции

Функция ТипыСистемныхПеречислений() Экспорт
	
	Возврат Новый ОписаниеТипов(
		"ВидДвиженияБухгалтерии,
		|ВидДвиженияНакопления,
		|ВидПериодаРегистраРасчета,
		|ВидСчета,
		|ВидТочкиМаршрутаБизнесПроцесса,
		|ИспользованиеГруппИЭлементов,
		|ИспользованиеСреза,
		|ИспользованиеРежимаПроведения,
		|РежимАвтоВремя,
		|РежимЗаписиДокумента,
		|РежимПроведенияДокумента,
		|ПериодичностьАгрегатаРегистраНакопления,
		|ИспользованиеАгрегатаРегистраНакопления");
	
КонецФункции

Функция ИмяСистемногоПеречисления(Тип) Экспорт
	
	Возврат Строка(Тип);
	
КонецФункции

Функция ЭтоКоллекцияПримитивныхТипов(Типы) Экспорт
	
	Для Каждого Тип Из Типы Цикл
		
		Если НЕ ЭтоПримитивныйТип(Тип) Тогда
			Возврат Ложь;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

Функция ЭтоПримитивныйТип(Тип) Экспорт
	
	ПримитивныеТипы = ЮТПовторногоИспользования.ПримитивныеТипы();
	
	ТипПараметра = ТипЗнч(Тип);
	
	Если ТипПараметра = Тип("Тип") Тогда
		Возврат ПримитивныеТипы.Найти(Тип) <> Неопределено;
	КонецЕсли;
	
	Для Каждого Тип Из Тип.Типы() Цикл
		
		Если ПримитивныеТипы.Найти(Тип) = Неопределено Тогда
			Возврат Ложь;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#КонецОбласти
