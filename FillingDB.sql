CREATE TYPE СТАТУСЫ_ЗАКАЗА  AS ENUM ('ПРИНЯТ', 'ГОТОВИТСЯ', 'ЗАКРЫТ', 'ОТМЕНЕН', 'ОТКАЗАН');
CREATE TYPE СТАТУСЫ_СОТРУДНИКА AS ENUM ('РАБОТАЕТ', 'НА БОЛЬНИЧНОМ', 'В ДЕКРЕТЕ', 'В ОТПУСКЕ', 'НЕ РАБОТАЕТ');
CREATE TYPE ВХОД_ИЛИ_ВЫХОД AS ENUM ('ВХОД', 'ВЫХОД');
CREATE TABLE ЗОНЫ_СКЛАДА(
    ИД SERIAL PRIMARY KEY,
    ОПИСАНИЕ TEXT NOT NULL
    );
CREATE TABLE ПРОДУКТЫ(
    ИД SERIAL PRIMARY KEY,
    ОПИСАНИЕ TEXT NOT NULL,
    ЕД_ИЗМ VARCHAR(40) NOT NULL,
    ИД_ЗОНЫ_СКЛАДА INTEGER REFERENCES ЗОНЫ_СКЛАДА(ИД) ON DELETE RESTRICT,
    ТОЧКА_ЗАКАЗА INTEGER NOT NULL
    );

CREATE TABLE БЛЮДА(
    ИД SERIAL PRIMARY KEY,
    НАЗВАНИЕ VARCHAR(100) NOT NULL,
    ЦЕНА INTEGER NOT NULL,
    АКЦИЯ VARCHAR(100) NOT NULL,
    ВХОД_В_ТЕК_МЕНЮ BOOLEAN NOT NULL,
    ОПИСАНИЕ TEXT NOT NULL
);
CREATE TABLE БЛЮДА_ПРОДУКТЫ(
    ИД_БЛЮДО INTEGER REFERENCES БЛЮДА(ИД) ON DELETE CASCADE,
    ИД_ПРОДУКТ INTEGER REFERENCES ПРОДУКТЫ(ИД) ON DELETE CASCADE,
    КОЛИЧЕСТВО INTEGER NOT NULL,
    PRIMARY KEY (ИД_БЛЮДО, ИД_ПРОДУКТ)
);
CREATE TABLE СОТРУДНИКИ(
    НОМЕР_ПАСПОРТА INTEGER UNIQUE NOT NULL PRIMARY KEY,
    ИМЯ VARCHAR(40) NOT NULL,
    ФАМИЛИЯ VARCHAR(40) NOT NULL,
    ОТЧЕСТВО VARCHAR(40),
    ПОЛ VARCHAR(40),
    ДАТА_РОЖДЕНИЯ TIMESTAMP
);
CREATE TABLE ЛОГИ_СОТРУДНИКА(
    ИД_СОТРУДНИК INTEGER REFERENCES СОТРУДНИКИ(НОМЕР_ПАСПОРТА) ON DELETE RESTRICT,
    КВАЛИФИКАЦИЯ VARCHAR(40) NOT NULL,
    СТАТУС СТАТУСЫ_СОТРУДНИКА NOT NULL,
    ЗАРПЛАТА_В_ЧАС INTEGER NOT NULL,
    ДАТА_ПРИЕМА DATE NOT NULL,
    ДАТА_УВОЛНЕНИЯ DATE,
    ДАТА_ЛОГА TIMESTAMP NOT NULL
);
CREATE TABLE НАРАБОТАННОЕ_ВРЕМЯ(
    ИД_СОТРУДНИК INTEGER REFERENCES СОТРУДНИКИ(НОМЕР_ПАСПОРТА) ON DELETE RESTRICT,
    ВРЕМЯ_РАБОТЫ INTERVAL NOT NULL,
    ДАТА DATE NOT NULL
);
CREATE TABLE РАСПИСАНИЕ(
    ДАТА DATE NOT NULL,
    ИД_СОТРУДНИК INTEGER REFERENCES СОТРУДНИКИ(НОМЕР_ПАСПОРТА) ON DELETE RESTRICT
);
CREATE TABLE ЗАКАЗЫ(
    ИД SERIAL PRIMARY KEY,
    ВРЕМЯ_ЗАКРЫТИЯ TIMESTAMP,
    ПОЛНАЯ_СТОИМОСТЬ INTEGER NOT NULL,
    ОБР_СВЯЗЬ VARCHAR(100)
);
CREATE TABLE ЗАКАЗЫ_ЛОГИ(
    ИД_ЗАКАЗА INTEGER REFERENCES ЗАКАЗЫ(ИД),
    КТО_ИЗМ INTEGER REFERENCES СОТРУДНИКИ(НОМЕР_ПАСПОРТА),
    СТАТУС СТАТУСЫ_ЗАКАЗА NOT NULL DEFAULT 'ПРИНЯТ',
    ВРЕМЯ_ИЗМ TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (ВРЕМЯ_ИЗМ <= NOW())
);
CREATE TABLE ЗАКАЗ_БЛЮДО(
    ИД_ЗАКАЗА INTEGER REFERENCES ЗАКАЗЫ(ИД) ON DELETE CASCADE,
    ИД_БЛЮДА INTEGER REFERENCES БЛЮДА(ИД) ON DELETE RESTRICT,
    КОЛИЧЕСТВО INTEGER NOT NULL,
    PRIMARY KEY (ИД_ЗАКАЗА, ИД_БЛЮДА)
);
CREATE TABLE ПОПОЛНЕНИЕ_РАСХОД_ПРОДУКТОВ(
    ИД_ПОПОЛНЕНИЕ_РАСХОД SERIAL PRIMARY KEY,
    ИД_ПРОДУКТ INTEGER REFERENCES ПРОДУКТЫ(ИД) ON DELETE RESTRICT,
    ВХОД_ВЫХОД ВХОД_ИЛИ_ВЫХОД NOT NULL,
    КОЛИЧЕСТВО INTEGER NOT NULL,
    ДАТА_ИЗМ DATE NOT NULL DEFAULT NOW(),
    ИД_ЗАКАЗА INTEGER REFERENCES ЗАКАЗЫ(ИД),
    КТО_ИЗМ INTEGER REFERENCES СОТРУДНИКИ(НОМЕР_ПАСПОРТА),
    ГОДЕН_ДО TIMESTAMP
);
