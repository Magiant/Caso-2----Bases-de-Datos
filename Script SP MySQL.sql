CREATE DATABASE `dybrands` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;


DELIMITER $$

CREATE PROCEDURE sp_insert_venta_final(
    IN p_pedidoid INT,
    IN p_courierid INT,
    IN p_mediodepagoid INT,
    IN p_montototal DECIMAL(12,2),
    IN p_fechadepago TIMESTAMP,
    IN p_usuarioid INT,
    IN p_deviceid INT,
    IN p_productid INT
)
BEGIN
    IF p_montototal <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Monto inválido';
    END IF;

    INSERT INTO ventasfinales(
        pedidoid,
        courierid,
        mediodepagoid,
        montototal,
        fechadepago,
        usuarioid,
        deviceid,
        productid,
        posttime,
        estado
    )
    VALUES(
        p_pedidoid,
        p_courierid,
        p_mediodepagoid,
        p_montototal,
        p_fechadepago,
        p_usuarioid,
        p_deviceid,
        p_productid,
        NOW(),
        1
    );
END$$

DELIMITER ;

-- Sitios

DELIMITER $$

CREATE PROCEDURE sp_insert_sitio(
    IN p_logoid INT,
    IN p_paisid INT,
    IN p_usuarioid INT,
    IN p_deviceid INT,
    IN p_enfoqueid INT,
    IN p_currency1 INT,
    IN p_currency2 INT,
    IN p_exchangerateid INT
)
BEGIN
    INSERT INTO sitios(
        logoid,
        paisid,
        usuarioid,
        deviceid,
        enfoqueid,
        currency_1,
        currency_2,
        exchangerateid,
        posttime,
        estado
    )
    VALUES(
        p_logoid,
        p_paisid,
        p_usuarioid,
        p_deviceid,
        p_enfoqueid,
        p_currency1,
        p_currency2,
        p_exchangerateid,
        NOW(),
        1
    );
END$$

DELIMITER ;

-- Tipo de cambio en un sitio
DELIMITER $$

CREATE PROCEDURE sp_update_exchange_sitio(
    IN p_sitioid INT,
    IN p_exchangerateid INT
)
BEGIN
    UPDATE sitios
    SET exchangerateid = p_exchangerateid,
        lastupdate = NOW()
    WHERE sitioid = p_sitioid;
END$$

DELIMITER ;

-- Validaciones
DELIMITER $$

CREATE PROCEDURE sp_registrar_venta_completa(
    IN p_pedidoid INT,
    IN p_courierid INT,
    IN p_mediodepagoid INT,
    IN p_montototal DECIMAL(12,2),
    IN p_fechadepago TIMESTAMP,
    IN p_usuarioid INT,
    IN p_deviceid INT,
    IN p_productid INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    CALL sp_insert_venta_final(
        p_pedidoid,
        p_courierid,
        p_mediodepagoid,
        p_montototal,
        p_fechadepago,
        p_usuarioid,
        p_deviceid,
        p_productid
    );

    COMMIT;
END$$

DELIMITER ;


-- Validacion de exchangerates 
DELIMITER $$

CREATE PROCEDURE sp_validar_sitios_sin_rate()
BEGIN
    SELECT sitioid
    FROM sitios
    WHERE exchangerateid IS NULL;
END$$

DELIMITER ;

-- Softs
DELIMITER $$

CREATE PROCEDURE sp_eliminar_venta_logico(
    IN p_ventafinalid INT
)
BEGIN
    UPDATE ventasfinales
    SET estado = 0,
        lastupdate = NOW()
    WHERE ventafinalid = p_ventafinalid;
END$$

DELIMITER ;

-- Ingresar paises
DELIMITER $$

CREATE PROCEDURE sp_cargar_paises()
BEGIN
    INSERT INTO paises (paisid, nombre) VALUES
    (1,'Costa Rica'),
    (2,'Mexico'),
    (3,'Colombia'),
    (4,'Argentina'),
    (5,'Chile');
END$$

DELIMITER ;

-- Currencies
DELIMITER $$

CREATE PROCEDURE sp_cargar_currencies()
BEGIN
    INSERT INTO currencies (currencyid, nombre) VALUES
    (1,'CRC'), (2,'USD');
END$$

DELIMITER ;

-- Exchangerates
DELIMITER $$

CREATE PROCEDURE sp_cargar_exchange_rates()
BEGIN
    INSERT INTO exchangerates (exchangerateid, rate) VALUES
    (1,540.5),
    (2,17.2),
    (3,4000),
    (4,900),
    (5,800);
END$$

DELIMITER ;

-- Usuarios
DELIMITER $$

CREATE PROCEDURE sp_cargar_usuarios()
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= 20 DO
        INSERT INTO usuarios (usuarioid) VALUES (i);
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Devices
DELIMITER $$

CREATE PROCEDURE sp_cargar_devices()
BEGIN
    INSERT INTO devices (deviceid) VALUES (1),(2),(3);
END$$

DELIMITER ;

-- Catalogos
DELIMITER $$

CREATE PROCEDURE sp_cargar_catalogos()
BEGIN
    INSERT INTO couriers (courierid) VALUES (1),(2),(3);
    INSERT INTO mediospago (mediodepagoid) VALUES (1),(2),(3);
END$$

DELIMITER ;

-- Pedidos
DELIMITER $$

CREATE PROCEDURE sp_cargar_pedidos()
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= 50 DO
        INSERT INTO pedidos (pedidoid) VALUES (i);
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Sitios
DELIMITER $$

CREATE PROCEDURE sp_cargar_sitios()
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= 9 DO

        CALL sp_insert_sitio(
            NULL,
            (i MOD 5) + 1,
            i,
            (i MOD 3) + 1,
            NULL,
            1,
            2,
            (i MOD 5) + 1
        );

        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Productos
DELIMITER $$

CREATE PROCEDURE sp_cargar_productos()
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= 100 DO
        INSERT INTO products (productid) VALUES (i);
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Ventas 
DELIMITER $$

CREATE PROCEDURE sp_cargar_ventas()
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= 100 DO

        CALL sp_registrar_venta_completa(
            (i MOD 50) + 1,
            (i MOD 3) + 1,
            (i MOD 3) + 1,
            (1000 + (i * 50)),
            NOW() - INTERVAL (i MOD 90) DAY,
            (i MOD 9) + 1,
            (i MOD 3) + 1,
            i
        );

        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Transaccional final
DELIMITER $$

CREATE PROCEDURE sp_carga_total_caso2()
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    CALL sp_cargar_paises();
    CALL sp_cargar_currencies();
    CALL sp_cargar_exchange_rates();
    CALL sp_cargar_usuarios();
    CALL sp_cargar_devices();
    CALL sp_cargar_catalogos();
    CALL sp_cargar_pedidos();
    CALL sp_cargar_sitios();
    CALL sp_cargar_productos();
    CALL sp_cargar_ventas();

    COMMIT;

END$$

DELIMITER ;

