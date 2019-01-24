CREATE FUNCTION order_started() RETURNS TRIGGER AS $order_started$
    BEGIN
        INSERT INTO ЗАКАЗЫ_ЛОГИ(ИД_ЗАКАЗА, КТО_ИЗМ, СТАТУС, ВРЕМЯ_ИЗМ)
        VALUES (NEW.ИД, 'ИД_СОТРУДНИКА’', 'ПРИНЯТ', CURRENT_TIMESTAMP);
        RETURN NEW;
    END;
$order_started$ LANGUAGE plpgsql;

CREATE TRIGGER order_started AFTER INSERT ON ЗАКАЗЫ
    FOR EACH ROW EXECUTE PROCEDURE order_started();

    CREATE FUNCTION check_workers_logs() RETURNS TRIGGER AS $check_workers_logs$
        BEGIN
             IF NEW.ЗАРПЛАТА_В_ЧАС < 0 THEN
                 RAISE EXCEPTION 'Как бы плохо сотрудник не работал, зарплата не может быть отрицательной';
             END IF;
             RETURN NEW;
        END;
    $check_workers_logs$ LANGUAGE plpgsql;

    CREATE TRIGGER check_workers_logs BEFORE INSERT OR UPDATE ON ЛОГИ_СОТРУДНИКА
        FOR EACH ROW EXECUTE PROCEDURE check_workers_logs();

        CREATE FUNCTION check_work_hours() RETURNS TRIGGER AS $check_work_hours$
            BEGIN
                IF (SELECT COUNT(*) FROM НАРАБОТАННОЕ_ВРЕМЯ WHERE НАРАБОТАННОЕ_ВРЕМЯ.ИД_СОТРУДНИК = NEW.ИД_СОТРУДНИК AND НАРАБОТАННОЕ_ВРЕМЯ.ДАТА = NEW.ДАТА) >= '1' THEN
                    RAISE EXCEPTION 'Ему/Ей хватит одной зарплаты';
                END IF;
                IF NEW.ВРЕМЯ_РАБОТЫ > (INTERVAL '24' HOUR) THEN
                    RAISE EXCEPTION 'Интервал работы не должен быть больше суток';
                END IF;
                IF (SELECT СТАТУС FROM ЛОГИ_СОТРУДНИКА WHERE ЛОГИ_СОТРУДНИКА.ИД_СОТРУДНИК = NEW.ИД_СОТРУДНИК ORDER BY ДАТА_ЛОГА LIMIT 1)!= 'РАБОТАЕТ' THEN
                    RAISE EXCEPTION 'Статус этого сотрудника не подходит для работы';
                END IF;
                RETURN NEW;
            END;
        $check_work_hours$ LANGUAGE plpgsql;

        CREATE TRIGGER check_work_hours BEFORE INSERT OR UPDATE ON НАРАБОТАННОЕ_ВРЕМЯ
            FOR EACH ROW EXECUTE PROCEDURE check_work_hours();

            CREATE FUNCTION order_finished() RETURNS TRIGGER AS $order_finished$
                BEGIN
                    IF NEW.СТАТУС = 'ЗАКРЫТ' THEN
                        UPDATE ЗАКАЗЫ SET ВРЕМЯ_ЗАКРЫТИЯ = NOW(), ПОЛНАЯ_СТОИМОСТЬ = (SELECT SUM(БЛЮДА.ЦЕНА * КОЛИЧЕСТВО) FROM ЗАКАЗ_БЛЮДО JOIN БЛЮДА ON ЗАКАЗ_БЛЮДО.ИД_БЛЮДА = БЛЮДА.ИД WHERE ИД_ЗАКАЗА = OLD.ИД_ЗАКАЗА) WHERE ИД = OLD.ИД_ЗАКАЗА;
                    END IF;
                    RETURN NEW;
                END;
            $order_finished$ LANGUAGE plpgsql;

            CREATE TRIGGER order_finished AFTER INSERT OR UPDATE ON ЗАКАЗЫ_ЛОГИ
                FOR EACH ROW EXECUTE PROCEDURE order_finished();

                CREATE FUNCTION extract_product_on_order() RETURNS TRIGGER AS $extract_product_on_order$
                        BEGIN
                            INSERT INTO ПОПОЛНЕНИЕ_РАСХОД_ПРОДУКТОВ(ИД_ПРОДУКТ, ВХОД_ВЫХОД, КОЛИЧЕСТВО, ДАТА_ИЗМ)
                            VALUES (NEW.ИД_ПРОДУКТ, 'ВЫХОД', NEW.КОЛИЧЕСТВО, CURRENT_TIMESTAMP);
                            RETURN NEW;
                        END;
                    $check_work_hours$ LANGUAGE plpgsql;

                    CREATE TRIGGER extract_product_on_order AFTER INSERT ON БЛЮДА_ПРОДУКТЫ
                        FOR EACH ROW EXECUTE PROCEDURE extract_product_on_order();
                        
