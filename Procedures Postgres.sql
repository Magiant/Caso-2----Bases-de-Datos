-- LOGs 
CREATE OR REPLACE PROCEDURE sp_log(
    p_action_name TEXT,
    p_message     TEXT,
    p_userid      INT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_actionid INT;
BEGIN
    INSERT INTO actions (actiontypename)
    VALUES (p_action_name)
    ON CONFLICT (actiontypename) DO NOTHING;

    SELECT actionid INTO v_actionid
    FROM actions
    WHERE actiontypename = p_action_name;

    INSERT INTO logs (actionid, userid, logmessage, posttime, lastupdate)
    VALUES (v_actionid, p_userid, p_message, NOW(), NOW());

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'sp_log error: %', SQLERRM;
END;
$$;

-- Categorias
CREATE OR REPLACE PROCEDURE insert_categoria(
    p_nombre TEXT,
    p_userid INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO productscategories(productcategoyname)
    VALUES (p_nombre);

    CALL sp_log('INSERT_CATEGORIA', 'Categoria: ' || p_nombre, p_userid);
EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log('ERROR_INSERT_CATEGORIA', SQLERRM, p_userid);
        RAISE;
END;
$$;

-- Paises
CREATE OR REPLACE PROCEDURE insert_pais(
    p_nombre TEXT,
    p_userid INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO paises(paisname, estado, posttime)
    VALUES (p_nombre, TRUE, NOW());

    CALL sp_log('INSERT_PAIS', 'Pais: ' || p_nombre, p_userid);
EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log('ERROR_INSERT_PAIS', SQLERRM, p_userid);
        RAISE;
END;
$$;

-- Impuestos
CREATE OR REPLACE PROCEDURE insert_impuesto(
    p_valor       NUMERIC,
    p_descripcion TEXT,
    p_userid      INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO impuestos(impuestovalue, impuestodescripcion, posttime, userid, estado)
    VALUES (p_valor, p_descripcion, NOW(), p_userid, TRUE);

    CALL sp_log('INSERT_IMPUESTO', 'Impuesto: ' || p_descripcion, p_userid);
EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log('ERROR_INSERT_IMPUESTO', SQLERRM, p_userid);
        RAISE;
END;
$$;

-- Currencies
CREATE OR REPLACE PROCEDURE insert_currency(
    p_nombre  TEXT,
    p_simbolo TEXT,
    p_paisid  INT,
    p_base    BOOLEAN,
    p_userid  INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO currencies(currencyname, currencysimbol, paisid, currencybase, estado)
    VALUES (p_nombre, p_simbolo, p_paisid, p_base, TRUE);

    CALL sp_log('INSERT_CURRENCY', 'Moneda: ' || p_nombre, p_userid);
EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log('ERROR_INSERT_CURRENCY', SQLERRM, p_userid);
        RAISE;
END;
$$;CREATE OR REPLACE PROCEDURE insert_currency(
    p_nombre  TEXT,
    p_simbolo TEXT,
    p_paisid  INT,
    p_base    BOOLEAN,
    p_userid  INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO currencies(currencyname, currencysimbol, paisid, currencybase, estado)
    VALUES (p_nombre, p_simbolo, p_paisid, p_base, TRUE);

    CALL sp_log('INSERT_CURRENCY', 'Moneda: ' || p_nombre, p_userid);
EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log('ERROR_INSERT_CURRENCY', SQLERRM, p_userid);
        RAISE;
END;
$$;

-- Transacciones 
CREATE OR REPLACE PROCEDURE insert_tipo_transaccion(
    p_nombre TEXT,
    p_userid INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tipodetransaccion(tipodetransaccionname)
    VALUES (p_nombre);

    CALL sp_log('INSERT_TIPO_TRANSACCION', 'Tipo: ' || p_nombre, p_userid);
EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log('ERROR_INSERT_TIPO_TRANSACCION', SQLERRM, p_userid);
        RAISE;
END;
$$;

-- Proveedores 
CREATE OR REPLACE PROCEDURE registrar_proveedor(
    p_nombre    TEXT,
    p_addressid INT,
    p_contacto  TEXT,
    p_email     TEXT,
    p_userid    INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_proveedor_id INT;
BEGIN
    INSERT INTO proveedores(proveedorname, addressid, posttime, estado)
    VALUES (p_nombre, p_addressid, NOW(), TRUE)
    RETURNING proveedorid INTO v_proveedor_id;

    INSERT INTO proveedorescontacts(proveedorid, contacttypeid, value, posttime, estado)
    VALUES (v_proveedor_id, 1, p_email, NOW(), TRUE);


    CALL sp_log('REGISTRAR_PROVEEDOR', 'Proveedor ID: ' || v_proveedor_id, p_userid);
EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log('ERROR_REGISTRAR_PROVEEDOR', SQLERRM, p_userid);
        RAISE;
END;
$$;

-- Nuevo
-- Importaciones
CREATE OR REPLACE PROCEDURE crear_importacion(
    p_proveedorid INT,
    p_paisid INT,
    p_descripcion VARCHAR,
    p_usuarioid INT,
    OUT p_importacionid INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM proveedores WHERE proveedorid = p_proveedorid) THEN
        RAISE EXCEPTION 'Proveedor no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM paises WHERE paisid = p_paisid) THEN
        RAISE EXCEPTION 'País no existe';
    END IF;

    INSERT INTO importaciones(proveedorid, paisid, posttime, totalmoney, descripcion)
    VALUES (p_proveedorid, p_paisid, NOW(), 0, p_descripcion)
    RETURNING importacionid INTO p_importacionid;

    CALL sp_log('CREATE_IMPORTACION', 'Importacion ID: ' || p_importacionid, p_usuarioid);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log('ERROR_CREATE_IMPORTACION', SQLERRM, p_usuarioid);
        RAISE;
END;
$$;

-- Detalles de importacion
CREATE OR REPLACE PROCEDURE add_detalle_importacion(
    p_importacionid INT,
    p_productoid INT,
    p_quantity NUMERIC,
    p_preciounitario NUMERIC,
    p_exchangerateid INT,
    p_usuarioid INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_subtotal NUMERIC;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM importaciones WHERE importacionid = p_importacionid) THEN
        RAISE EXCEPTION 'Importación no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM products WHERE productid = p_productoid) THEN
        RAISE EXCEPTION 'Producto no existe';
    END IF;

    v_subtotal := p_quantity * p_preciounitario;

    INSERT INTO detallesdeimportacion(
        importacionid,
        productid,
        quantity,
        preciounitario,
        subtotal,
        exchangerateid,
        posttime,
        userid
    )
    VALUES (
        p_importacionid,
        p_productoid,
        p_quantity,
        p_preciounitario,
        v_subtotal,
        p_exchangerateid,
        NOW(),
        p_usuarioid
    );

    UPDATE importaciones
    SET totalmoney = COALESCE(totalmoney,0) + v_subtotal
    WHERE importacionid = p_importacionid;

    CALL sp_log('ADD_DETALLE_IMPORTACION', 
                'Detalle agregado a importación ' || p_importacionid || 
                ' con producto ' || p_productoid || 
                ', subtotal: ' || v_subtotal, 
                p_usuarioid);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log('ERROR_ADD_DETALLE_IMPORTACION', SQLERRM, p_usuarioid);
        RAISE;
END;
$$;

-- Lotes
CREATE OR REPLACE PROCEDURE create_lote(
    p_productoxproveedorid INT,
    p_lotenumber INT,
    p_quantity INT,
    p_unitcost NUMERIC,
    p_currencyid INT,
    p_exchangerateid INT,
    p_usuarioid INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM productoxproveedor WHERE productoxproveedorid = p_productoxproveedorid
    ) THEN
        RAISE EXCEPTION 'Relación producto-proveedor no existe';
    END IF;

    v_total := p_quantity * p_unitcost; -- Calculo el total

    INSERT INTO lotes(
        productoxproveedorid,
        lotenumber,
        lotequantity,
        loteamount,
        currencybaseid,
        exchangerateid,
        exchangerateused,
        posttime,
        lotelastupdate
    )
    VALUES (
        p_productoxproveedorid,
        p_lotenumber,
        p_quantity,
        v_total,
        p_currencyid,
        p_exchangerateid,
        1, -- indicador de tipo de cambio usado
        NOW(),
        NOW()
    );

    CALL sp_log('CREATE_LOTE',
                'Lote creado para relación ' || p_productoxproveedorid ||
                ', número de lote ' || p_lotenumber ||
                ', cantidad ' || p_quantity ||
                ', total: ' || v_total,
                p_usuarioid);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log('ERROR_CREATE_LOTE', SQLERRM, p_usuarioid);
        RAISE;
END;
$$;

-- Transacciones
CREATE OR REPLACE PROCEDURE create_transaccion(
    p_tipotransaccionid INT,
    p_monto NUMERIC,
    p_currencyid INT,
    p_exchangerateid INT,
    p_referenceid BIGINT,
    p_usuarioid INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_amount_changed NUMERIC;
    v_rate NUMERIC;
BEGIN
    SELECT exchangeraterate
    INTO v_rate
    FROM exchangerates
    WHERE exchangerateid = p_exchangerateid;

    IF v_rate IS NULL THEN
        RAISE EXCEPTION 'Tipo de cambio no válido';
    END IF;

    v_amount_changed := p_monto * v_rate;

    INSERT INTO transacciones(
        tipotransaccionid,
        monto,
        currencyid,
        exchangerateid,
        referenceid,
        amountchanged,
        transacciondate,
        estado,
        posttime,
        userid
    )
    VALUES (
        p_tipotransaccionid,
        p_monto,
        p_currencyid,
        p_exchangerateid,
        p_referenceid,
        v_amount_changed,
        NOW(),
        TRUE,
        NOW(),
        p_usuarioid
    );

    CALL sp_log('CREATE_TRANSACCION',
                'Transacción creada con tipo ' || p_tipotransaccionid ||
                ', monto: ' || p_monto ||
                ', convertido: ' || v_amount_changed,
                p_usuarioid);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log('ERROR_CREATE_TRANSACCION', SQLERRM, p_usuarioid);
        RAISE;
END;
$$;

-- Importacion completa
CREATE OR REPLACE PROCEDURE full_import_process(
    p_proveedorid INT,
    p_paisid INT,
    p_productoid INT,
    p_quantity INT,
    p_precio NUMERIC,
    p_exchangerateid INT,
    p_usuarioid INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_importacionid INT;
    v_rate NUMERIC;
BEGIN
    CALL create_importacion(
        p_proveedorid,
        p_paisid,
        'Importación automática',
        p_usuarioid,
        v_importacionid
    );

    SELECT exchangeraterate
    INTO v_rate
    FROM exchangerates
    WHERE exchangerateid = p_exchangerateid
      AND isCurrent = TRUE;

    IF v_rate IS NULL THEN
        RAISE EXCEPTION 'Tipo de cambio no válido o no vigente';
    END IF;

    CALL add_detalle_importacion(
        v_importacionid,
        p_productoid,
        p_quantity,
        p_precio,
        p_exchangerateid,
        p_usuarioid
    );

    CALL sp_log('FULL_IMPORT_PROCESS',
                'Proceso completo ejecutado para importación ' || v_importacionid ||
                ', producto ' || p_productoid ||
                ', cantidad ' || p_quantity ||
                ', precio unitario ' || p_precio ||
                ', exchangerateid ' || p_exchangerateid,
                p_usuarioid);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log('ERROR_FULL_IMPORT', SQLERRM, p_usuarioid);
        RAISE;
END;
$$;
