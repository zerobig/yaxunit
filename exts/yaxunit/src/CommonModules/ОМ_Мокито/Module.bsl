//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2022 BIA-Technologies Limited Liability Company
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

// @strict-types

#Область СлужебныйПрограммныйИнтерфейс

Процедура ИсполняемыеСценарии() Экспорт
	
	ЮТТесты
		.ДобавитьТест("Обучение")
		.ДобавитьТест("Проверить")
		.ДобавитьТест("МокированиеМетодовСсылочныхОбъектов")
		.ДобавитьТест("НастройкаСерверныхМоковСКлиента")
	;
	
КонецПроцедуры

Процедура Обучение() Экспорт
	
	Описание = "Обучение через явный вызов метода";
	
	Мокито.Обучение(РаботаСHTTP)
		.Когда(РаботаСHTTP.ОтправитьОбъектНаСервер(Мокито.ЛюбойПараметр(), Мокито.ЛюбойПараметр()))
		.Вернуть(1)
		.Когда(РаботаСHTTP.ОтправитьОбъектНаСервер(Справочники.ИсточникиДанных.FTP, 2))
		.Вернуть(10)
		.Прогон();
	
	ЮТУтверждения.Что(РаботаСHTTP.ОтправитьОбъектНаСервер(Справочники.ИсточникиДанных.FTP, 2), Описание + ". Кейс 1")
		.Равно(10);
	ЮТУтверждения.Что(РаботаСHTTP.ОтправитьОбъектНаСервер(Справочники.ИсточникиДанных.FTP, 1), Описание + ". Кейс 2")
		.Равно(1);
	
	Описание = "Обучение через указание имени и набора параметров";
	Мокито.Обучение(РаботаСHTTP)
		.Когда("ОтправитьОбъектНаСервер", Мокито.МассивПараметров(Мокито.ЛюбойПараметр(), Мокито.ЛюбойПараметр()))
		.Вернуть(20)
		.Когда("ОтправитьОбъектНаСервер", Мокито.МассивПараметров(Справочники.ИсточникиДанных.FTP, 2))
		.Вернуть(2)
		.Прогон();
		
	ЮТУтверждения.Что(РаботаСHTTP.ОтправитьОбъектНаСервер(Справочники.ИсточникиДанных.FTP, 2), Описание + ". Кейс 1")
		.Равно(2);
	ЮТУтверждения.Что(РаботаСHTTP.ОтправитьОбъектНаСервер(Справочники.ИсточникиДанных.FTP, 1), Описание + ". Кейс 2")
		.Равно(20);
	
КонецПроцедуры

Процедура Проверить() Экспорт
	
	ЛюбойПараметр = Мокито.ЛюбойПараметр();
	ТипИсточникДанных = Тип("СправочникСсылка.ИсточникиДанных");
	
	Мокито.Обучение(РаботаСHTTP)
		.Когда(РаботаСHTTP.ОтправитьОбъектНаСервер(ЛюбойПараметр, ЛюбойПараметр))
		.Вернуть(1)
		.Когда(РаботаСHTTP.ОтправитьОбъектНаСервер(Справочники.ИсточникиДанных.FTP, 2))
		.Вернуть(10)
		.Прогон();
	
	РаботаСHTTP.ОтправитьОбъектНаСервер("Справочники.ИсточникиДанных.FTP", Неопределено);
	РаботаСHTTP.ОтправитьОбъектНаСервер(Справочники.ИсточникиДанных.FTP, 2);
	РаботаСHTTP.ОтправитьОбъектНаСервер(1, 2);
	
	Мокито.Проверить(РаботаСHTTP)
		.КоличествоВызовов(РаботаСHTTP.ОтправитьОбъектНаСервер(ЛюбойПараметр, Мокито.ЧисловойПараметр())).Больше(1).Равно(2)
		.КоличествоВызовов("ОтправитьОбъектНаСервер").Заполнено().Равно(3).Меньше(6)
		.КоличествоВызовов("ОтправитьЗапросHTTP").Пусто().Меньше(1)
		.КоличествоВызовов(РаботаСHTTP.ОтправитьОбъектНаСервер(1, 2)).Равно(1)
		.КоличествоВызовов(РаботаСHTTP.ОтправитьОбъектНаСервер(ЛюбойПараметр, ЛюбойПараметр)).Равно(3)
		.КоличествоВызовов(РаботаСHTTP.ОтправитьОбъектНаСервер(Мокито.ТипизированныйПараметр(ТипИсточникДанных), ЛюбойПараметр)).Равно(1)
	;
	
КонецПроцедуры

Процедура МокированиеМетодовСсылочныхОбъектов() Экспорт
	
	Результат = Новый УникальныйИдентификатор();
	// Мокирование обработки проведения (выключение алгоритма проведения)
	Документ = ЮТТестовыеДанные.СоздатьДокумент(Документы.ЧекККМ);
	Мокито.Обучение(Документ)
		.Когда("ОбработкаПроведения").Пропустить()
		.Прогон();
	Объект = Документ.ПолучитьОбъект();
	Объект.ВОжидании = Истина;
	Объект.Записать(РежимЗаписиДокумента.Проведение);
	
	Мокито.Проверить(Объект).КоличествоВызовов("ОбработкаПроведения").Заполнено();
	Мокито.Проверить(Документ).КоличествоВызовов("ОбработкаПроведения").Заполнено();
	
	Справочник = ЮТТестовыеДанные.СоздатьЭлемент(Справочники.ДополнительныеПараметрыЖурналаДействийПользователя);
	СправочникОбъект = Справочник.ПолучитьОбъект();
	
	// Мокирование экспортного метода объекта, указание имени метода
	Описание = "Мокирование экспортного метода объекта, указание имени метода";
	Мокито.Обучение(Справочник)
		.Когда("ПолучитьСтруктуруИзХранилища").Вернуть(Результат)
		.Прогон();
	
	ЮТУтверждения.Что(СправочникОбъект.ПолучитьСтруктуруИзХранилища(), Описание)
		.Равно(Результат);
	
	Мокито.Проверить(Справочник).КоличествоВызовов("ПолучитьСтруктуруИзХранилища").Заполнено();
	
	// Мокирование экспортного метода объекта, явный вызов метода
	Мокито.Сбросить();
	Описание = "Мокирование экспортного метода объекта, явный вызов метода";
	Мокито.Обучение(СправочникОбъект)
		.Когда(СправочникОбъект.ПолучитьСтруктуруИзХранилища()).Вернуть(Результат)
		.Прогон();
	
	ЮТУтверждения.Что(Справочник.ПолучитьОбъект().ПолучитьСтруктуруИзХранилища(), Описание)
		.Равно(Результат);
	
	Мокито.Проверить(Справочник).КоличествоВызовов("ПолучитьСтруктуруИзХранилища").Заполнено(Описание);
	
	// Мокирование приватного метода
	Мокито.Сбросить();
	Описание = "Мокирование приватного метода";
	Справочник = ЮТТестовыеДанные.СоздатьЭлемент(Справочники.ИсточникиДанных);
	СправочникОбъект = Справочник.ПолучитьОбъект();
	Пароль = "123";
	Пользователь = "админ";
	
	СправочникОбъект.Пользователь = Пользователь;
	СправочникОбъект.Пароль = Пароль;
	СправочникОбъект.Записать();
	ЮТУтверждения.Что(СправочникОбъект, Описание + ". До мокирования")
		.Свойство("Пользователь").Равно(Пользователь)
		.Свойство("Пароль").НеЗаполнено();
	
	Мокито.Обучение(СправочникОбъект)
		.Когда("ПеренестиДанныеВБезопасноеХранилище").Пропустить()
		.Прогон();
	
	СправочникОбъект.Пользователь = Пользователь;
	СправочникОбъект.Пароль = Пароль;
	СправочникОбъект.Записать();
	ЮТУтверждения.Что(СправочникОбъект, Описание + ". После мокирования")
		.Свойство("Пользователь").Равно(Пользователь)
		.Свойство("Пароль").Равно(Пароль);
	
	// Мокирование модуля менеджера
	Мокито.Сбросить();
	Описание = "Мокирование модуля менеджера";
	Мокито.Обучение(Справочники.ИсточникиДанных)
		.Когда(Справочники.ИсточникиДанных.СохраненныеБезопасныеДанные(Справочник)).Вернуть(Результат)
		.Прогон();
	
	ЮТУтверждения.Что(Справочники.ИсточникиДанных.СохраненныеБезопасныеДанные(Справочник), Описание)
		.Равно(Результат);

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#КонецОбласти
