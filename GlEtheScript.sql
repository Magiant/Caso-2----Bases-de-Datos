--
-- PostgreSQL database dump
--

\restrict zwBrAUxtOovcTDRPV0VcHZv2XgDBJZSqfMgTa9fZFwQBTJSZa8VdJTBgLZVEnvv

-- Dumped from database version 17.5 (Debian 17.5-1.pgdg110+1)
-- Dumped by pg_dump version 18.1

-- Started on 2026-05-03 19:44:20

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 19742)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 4753 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- TOC entry 725 (class 1255 OID 21885)
-- Name: add_detalle_importacion(integer, integer, numeric, numeric, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_detalle_importacion(IN p_importacionid integer, IN p_productoid integer, IN p_quantity numeric, IN p_preciounitario numeric, IN p_exchangerateid integer, IN p_usuarioid integer)
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


ALTER PROCEDURE public.add_detalle_importacion(IN p_importacionid integer, IN p_productoid integer, IN p_quantity numeric, IN p_preciounitario numeric, IN p_exchangerateid integer, IN p_usuarioid integer) OWNER TO postgres;

--
-- TOC entry 689 (class 1255 OID 21884)
-- Name: crear_importacion(integer, integer, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.crear_importacion(IN p_proveedorid integer, IN p_paisid integer, IN p_descripcion character varying, IN p_usuarioid integer, OUT p_importacionid integer)
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


ALTER PROCEDURE public.crear_importacion(IN p_proveedorid integer, IN p_paisid integer, IN p_descripcion character varying, IN p_usuarioid integer, OUT p_importacionid integer) OWNER TO postgres;

--
-- TOC entry 640 (class 1255 OID 21886)
-- Name: create_lote(integer, integer, integer, numeric, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.create_lote(IN p_productoxproveedorid integer, IN p_lotenumber integer, IN p_quantity integer, IN p_unitcost numeric, IN p_currencyid integer, IN p_exchangerateid integer, IN p_usuarioid integer)
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


ALTER PROCEDURE public.create_lote(IN p_productoxproveedorid integer, IN p_lotenumber integer, IN p_quantity integer, IN p_unitcost numeric, IN p_currencyid integer, IN p_exchangerateid integer, IN p_usuarioid integer) OWNER TO postgres;

--
-- TOC entry 830 (class 1255 OID 21887)
-- Name: create_transaccion(integer, numeric, integer, integer, bigint, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.create_transaccion(IN p_tipotransaccionid integer, IN p_monto numeric, IN p_currencyid integer, IN p_exchangerateid integer, IN p_referenceid bigint, IN p_usuarioid integer)
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


ALTER PROCEDURE public.create_transaccion(IN p_tipotransaccionid integer, IN p_monto numeric, IN p_currencyid integer, IN p_exchangerateid integer, IN p_referenceid bigint, IN p_usuarioid integer) OWNER TO postgres;

--
-- TOC entry 817 (class 1255 OID 21888)
-- Name: full_import_process(integer, integer, integer, integer, numeric, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.full_import_process(IN p_proveedorid integer, IN p_paisid integer, IN p_productoid integer, IN p_quantity integer, IN p_precio numeric, IN p_exchangerateid integer, IN p_usuarioid integer)
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


ALTER PROCEDURE public.full_import_process(IN p_proveedorid integer, IN p_paisid integer, IN p_productoid integer, IN p_quantity integer, IN p_precio numeric, IN p_exchangerateid integer, IN p_usuarioid integer) OWNER TO postgres;

--
-- TOC entry 359 (class 1255 OID 21865)
-- Name: insert_categoria(text, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_categoria(IN p_nombre text, IN p_userid integer)
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


ALTER PROCEDURE public.insert_categoria(IN p_nombre text, IN p_userid integer) OWNER TO postgres;

--
-- TOC entry 905 (class 1255 OID 21870)
-- Name: insert_currency(text, text, integer, boolean, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_currency(IN p_nombre text, IN p_simbolo text, IN p_paisid integer, IN p_base boolean, IN p_userid integer)
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


ALTER PROCEDURE public.insert_currency(IN p_nombre text, IN p_simbolo text, IN p_paisid integer, IN p_base boolean, IN p_userid integer) OWNER TO postgres;

--
-- TOC entry 608 (class 1255 OID 21869)
-- Name: insert_impuesto(numeric, text, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_impuesto(IN p_valor numeric, IN p_descripcion text, IN p_userid integer)
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


ALTER PROCEDURE public.insert_impuesto(IN p_valor numeric, IN p_descripcion text, IN p_userid integer) OWNER TO postgres;

--
-- TOC entry 704 (class 1255 OID 21866)
-- Name: insert_pais(text, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_pais(IN p_nombre text, IN p_userid integer)
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


ALTER PROCEDURE public.insert_pais(IN p_nombre text, IN p_userid integer) OWNER TO postgres;

--
-- TOC entry 1071 (class 1255 OID 21871)
-- Name: insert_tipo_transaccion(text, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_tipo_transaccion(IN p_nombre text, IN p_userid integer)
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


ALTER PROCEDURE public.insert_tipo_transaccion(IN p_nombre text, IN p_userid integer) OWNER TO postgres;

--
-- TOC entry 1045 (class 1255 OID 21872)
-- Name: registrar_proveedor(text, integer, text, text, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.registrar_proveedor(IN p_nombre text, IN p_addressid integer, IN p_contacto text, IN p_email text, IN p_userid integer)
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


ALTER PROCEDURE public.registrar_proveedor(IN p_nombre text, IN p_addressid integer, IN p_contacto text, IN p_email text, IN p_userid integer) OWNER TO postgres;

--
-- TOC entry 368 (class 1255 OID 21863)
-- Name: sp_log(text, text, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_log(IN p_action_name text, IN p_message text, IN p_userid integer DEFAULT NULL::integer)
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


ALTER PROCEDURE public.sp_log(IN p_action_name text, IN p_message text, IN p_userid integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 296 (class 1259 OID 21638)
-- Name: actions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.actions (
    actionid integer NOT NULL,
    actiontypename character varying(100) NOT NULL
);


ALTER TABLE public.actions OWNER TO postgres;

--
-- TOC entry 295 (class 1259 OID 21637)
-- Name: actions_actionid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.actions_actionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.actions_actionid_seq OWNER TO postgres;

--
-- TOC entry 4754 (class 0 OID 0)
-- Dependencies: 295
-- Name: actions_actionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.actions_actionid_seq OWNED BY public.actions.actionid;


--
-- TOC entry 238 (class 1259 OID 21138)
-- Name: addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.addresses (
    addressid integer NOT NULL,
    addressinformation character varying(200),
    location public.geography(Point,4326),
    zipcode character varying(30),
    cityid integer,
    estado boolean DEFAULT true,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.addresses OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 21137)
-- Name: addresses_addressid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.addresses_addressid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.addresses_addressid_seq OWNER TO postgres;

--
-- TOC entry 4755 (class 0 OID 0)
-- Dependencies: 237
-- Name: addresses_addressid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.addresses_addressid_seq OWNED BY public.addresses.addressid;


--
-- TOC entry 244 (class 1259 OID 21188)
-- Name: brands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.brands (
    brandid integer NOT NULL,
    brandname character varying(40),
    brandcreationdate timestamp without time zone,
    brandupdatedate timestamp without time zone,
    branddeletingdate timestamp without time zone,
    userid integer,
    deleted boolean DEFAULT false
);


ALTER TABLE public.brands OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 21187)
-- Name: brands_brandid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.brands_brandid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.brands_brandid_seq OWNER TO postgres;

--
-- TOC entry 4756 (class 0 OID 0)
-- Dependencies: 243
-- Name: brands_brandid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.brands_brandid_seq OWNED BY public.brands.brandid;


--
-- TOC entry 308 (class 1259 OID 21744)
-- Name: bulks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bulks (
    bulkid integer NOT NULL,
    bulktotalprice numeric(12,2),
    importacionid integer,
    loteid integer,
    sizeid integer,
    userid integer,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastupdate timestamp without time zone,
    checksum bytea,
    estado boolean DEFAULT true,
    notas character varying(300)
);


ALTER TABLE public.bulks OWNER TO postgres;

--
-- TOC entry 307 (class 1259 OID 21743)
-- Name: bulks_bulkid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bulks_bulkid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bulks_bulkid_seq OWNER TO postgres;

--
-- TOC entry 4757 (class 0 OID 0)
-- Dependencies: 307
-- Name: bulks_bulkid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bulks_bulkid_seq OWNED BY public.bulks.bulkid;


--
-- TOC entry 310 (class 1259 OID 21775)
-- Name: bulkstrackings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bulkstrackings (
    bulktrackingid integer NOT NULL,
    bulkid integer,
    puertorigenid integer,
    puertodestinoid integer,
    bulktrackingsalida timestamp without time zone,
    bulktrackingllegada timestamp without time zone,
    userid integer,
    deviceid integer,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastupdate timestamp without time zone,
    estado boolean DEFAULT true
);


ALTER TABLE public.bulkstrackings OWNER TO postgres;

--
-- TOC entry 309 (class 1259 OID 21774)
-- Name: bulkstrackings_bulktrackingid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bulkstrackings_bulktrackingid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bulkstrackings_bulktrackingid_seq OWNER TO postgres;

--
-- TOC entry 4758 (class 0 OID 0)
-- Dependencies: 309
-- Name: bulkstrackings_bulktrackingid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bulkstrackings_bulktrackingid_seq OWNED BY public.bulkstrackings.bulktrackingid;


--
-- TOC entry 256 (class 1259 OID 21266)
-- Name: caracteristicas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.caracteristicas (
    caracteristicaid integer NOT NULL,
    tipodecaracteristicaid integer,
    caracteristicaname character varying(40),
    paisid integer,
    caracteristicadescripcion character varying(150)
);


ALTER TABLE public.caracteristicas OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 21265)
-- Name: caracteristicas_caracteristicaid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.caracteristicas_caracteristicaid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.caracteristicas_caracteristicaid_seq OWNER TO postgres;

--
-- TOC entry 4759 (class 0 OID 0)
-- Dependencies: 255
-- Name: caracteristicas_caracteristicaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.caracteristicas_caracteristicaid_seq OWNED BY public.caracteristicas.caracteristicaid;


--
-- TOC entry 258 (class 1259 OID 21283)
-- Name: caracteristicaxproducto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.caracteristicaxproducto (
    caracteristicaxproductoid integer NOT NULL,
    productoid integer,
    caracteristicaid integer,
    estado boolean DEFAULT true,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.caracteristicaxproducto OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 21282)
-- Name: caracteristicaxproducto_caracteristicaxproductoid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.caracteristicaxproducto_caracteristicaxproductoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.caracteristicaxproducto_caracteristicaxproductoid_seq OWNER TO postgres;

--
-- TOC entry 4760 (class 0 OID 0)
-- Dependencies: 257
-- Name: caracteristicaxproducto_caracteristicaxproductoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.caracteristicaxproducto_caracteristicaxproductoid_seq OWNED BY public.caracteristicaxproducto.caracteristicaxproductoid;


--
-- TOC entry 232 (class 1259 OID 21090)
-- Name: ciudades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ciudades (
    ciudadid integer NOT NULL,
    ciudadname character varying(30) NOT NULL,
    paisid integer,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estado boolean DEFAULT true
);


ALTER TABLE public.ciudades OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 21089)
-- Name: ciudades_ciudadid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ciudades_ciudadid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ciudades_ciudadid_seq OWNER TO postgres;

--
-- TOC entry 4761 (class 0 OID 0)
-- Dependencies: 231
-- Name: ciudades_ciudadid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ciudades_ciudadid_seq OWNED BY public.ciudades.ciudadid;


--
-- TOC entry 236 (class 1259 OID 21121)
-- Name: ciudadesdestino; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ciudadesdestino (
    ciudaddestinoid integer NOT NULL,
    ciudadid integer,
    paisid integer
);


ALTER TABLE public.ciudadesdestino OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 21120)
-- Name: ciudadesdestino_ciudaddestinoid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ciudadesdestino_ciudaddestinoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ciudadesdestino_ciudaddestinoid_seq OWNER TO postgres;

--
-- TOC entry 4762 (class 0 OID 0)
-- Dependencies: 235
-- Name: ciudadesdestino_ciudaddestinoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ciudadesdestino_ciudaddestinoid_seq OWNED BY public.ciudadesdestino.ciudaddestinoid;


--
-- TOC entry 234 (class 1259 OID 21104)
-- Name: ciudadesorigen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ciudadesorigen (
    ciudadorigenid integer NOT NULL,
    ciudadid integer,
    paisid integer
);


ALTER TABLE public.ciudadesorigen OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 21103)
-- Name: ciudadesorigen_ciudadorigenid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ciudadesorigen_ciudadorigenid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ciudadesorigen_ciudadorigenid_seq OWNER TO postgres;

--
-- TOC entry 4763 (class 0 OID 0)
-- Dependencies: 233
-- Name: ciudadesorigen_ciudadorigenid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ciudadesorigen_ciudadorigenid_seq OWNED BY public.ciudadesorigen.ciudadorigenid;


--
-- TOC entry 268 (class 1259 OID 21372)
-- Name: contacttypes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contacttypes (
    contacttypeid integer NOT NULL,
    contacttypename character varying(20)
);


ALTER TABLE public.contacttypes OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 21371)
-- Name: contacttypes_contacttypeid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contacttypes_contacttypeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacttypes_contacttypeid_seq OWNER TO postgres;

--
-- TOC entry 4764 (class 0 OID 0)
-- Dependencies: 267
-- Name: contacttypes_contacttypeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contacttypes_contacttypeid_seq OWNED BY public.contacttypes.contacttypeid;


--
-- TOC entry 260 (class 1259 OID 21302)
-- Name: currencies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.currencies (
    currencyid integer NOT NULL,
    currencyname character varying(20),
    currencysimbol character varying(10),
    paisid integer,
    currencybase boolean DEFAULT false,
    estado boolean DEFAULT true
);


ALTER TABLE public.currencies OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 21301)
-- Name: currencies_currencyid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.currencies_currencyid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.currencies_currencyid_seq OWNER TO postgres;

--
-- TOC entry 4765 (class 0 OID 0)
-- Dependencies: 259
-- Name: currencies_currencyid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.currencies_currencyid_seq OWNED BY public.currencies.currencyid;


--
-- TOC entry 286 (class 1259 OID 21532)
-- Name: descuentosporproducto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.descuentosporproducto (
    descuentoporproductoid integer NOT NULL,
    descuentoporproductopercent numeric(5,2),
    productid integer,
    estado boolean DEFAULT true,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    checksum bytea
);


ALTER TABLE public.descuentosporproducto OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 21531)
-- Name: descuentosporproducto_descuentoporproductoid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.descuentosporproducto_descuentoporproductoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.descuentosporproducto_descuentoporproductoid_seq OWNER TO postgres;

--
-- TOC entry 4766 (class 0 OID 0)
-- Dependencies: 285
-- Name: descuentosporproducto_descuentoporproductoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.descuentosporproducto_descuentoporproductoid_seq OWNED BY public.descuentosporproducto.descuentoporproductoid;


--
-- TOC entry 294 (class 1259 OID 21608)
-- Name: detalledeimportacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalledeimportacion (
    detalledeimportacionid integer NOT NULL,
    importacionid integer,
    productoid integer,
    quantity numeric(12,2),
    preciounitario numeric(12,2),
    subtotal numeric(12,2),
    exchangerateid integer,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    userid integer,
    checksum bytea
);


ALTER TABLE public.detalledeimportacion OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 21607)
-- Name: detalledeimportacion_detalledeimportacionid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.detalledeimportacion_detalledeimportacionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.detalledeimportacion_detalledeimportacionid_seq OWNER TO postgres;

--
-- TOC entry 4767 (class 0 OID 0)
-- Dependencies: 293
-- Name: detalledeimportacion_detalledeimportacionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.detalledeimportacion_detalledeimportacionid_seq OWNED BY public.detalledeimportacion.detalledeimportacionid;


--
-- TOC entry 226 (class 1259 OID 21055)
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices (
    deviceid integer NOT NULL,
    devicename character varying(50),
    ipaddress character varying(45),
    checksum bytea,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estado boolean DEFAULT true
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 21054)
-- Name: devices_deviceid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.devices_deviceid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.devices_deviceid_seq OWNER TO postgres;

--
-- TOC entry 4768 (class 0 OID 0)
-- Dependencies: 225
-- Name: devices_deviceid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_deviceid_seq OWNED BY public.devices.deviceid;


--
-- TOC entry 262 (class 1259 OID 21316)
-- Name: exchangerates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exchangerates (
    exchangerateid integer NOT NULL,
    currencyid1 integer,
    currencyid2 integer,
    exchangeraterate numeric(12,2),
    exchangeratefrom timestamp without time zone,
    exchangerateto timestamp without time zone,
    checksum bytea,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estado boolean DEFAULT true,
    iscurrent boolean DEFAULT true
);


ALTER TABLE public.exchangerates OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 21315)
-- Name: exchangerates_exchangerateid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.exchangerates_exchangerateid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exchangerates_exchangerateid_seq OWNER TO postgres;

--
-- TOC entry 4769 (class 0 OID 0)
-- Dependencies: 261
-- Name: exchangerates_exchangerateid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.exchangerates_exchangerateid_seq OWNED BY public.exchangerates.exchangerateid;


--
-- TOC entry 292 (class 1259 OID 21590)
-- Name: importaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.importaciones (
    importacionid integer NOT NULL,
    proveedorid integer,
    paisid integer,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    totalmoney numeric(12,2),
    descripcion character varying(300)
);


ALTER TABLE public.importaciones OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 21589)
-- Name: importaciones_importacionid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.importaciones_importacionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.importaciones_importacionid_seq OWNER TO postgres;

--
-- TOC entry 4770 (class 0 OID 0)
-- Dependencies: 291
-- Name: importaciones_importacionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.importaciones_importacionid_seq OWNED BY public.importaciones.importacionid;


--
-- TOC entry 288 (class 1259 OID 21548)
-- Name: impuestos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.impuestos (
    impuestoid integer NOT NULL,
    impuestovalue numeric(10,2),
    impuestodescripcion character varying(200),
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastupdate timestamp without time zone,
    userid integer,
    checksum bytea,
    estado boolean DEFAULT true
);


ALTER TABLE public.impuestos OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 21547)
-- Name: impuestos_impuestoid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.impuestos_impuestoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.impuestos_impuestoid_seq OWNER TO postgres;

--
-- TOC entry 4771 (class 0 OID 0)
-- Dependencies: 287
-- Name: impuestos_impuestoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.impuestos_impuestoid_seq OWNED BY public.impuestos.impuestoid;


--
-- TOC entry 290 (class 1259 OID 21564)
-- Name: impuestosporpais; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.impuestosporpais (
    impuestosporpaisid integer NOT NULL,
    productid integer,
    paisid integer,
    impuestoid integer,
    estado boolean DEFAULT true,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    checksum bytea
);


ALTER TABLE public.impuestosporpais OWNER TO postgres;

--
-- TOC entry 289 (class 1259 OID 21563)
-- Name: impuestosporpais_impuestosporpaisid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.impuestosporpais_impuestosporpaisid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.impuestosporpais_impuestosporpaisid_seq OWNER TO postgres;

--
-- TOC entry 4772 (class 0 OID 0)
-- Dependencies: 289
-- Name: impuestosporpais_impuestosporpaisid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.impuestosporpais_impuestosporpaisid_seq OWNED BY public.impuestosporpais.impuestosporpaisid;


--
-- TOC entry 298 (class 1259 OID 21645)
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    logid integer NOT NULL,
    actionid integer,
    userid integer,
    posttime timestamp without time zone DEFAULT now(),
    lastupdate timestamp without time zone DEFAULT now(),
    description character varying(200)
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- TOC entry 297 (class 1259 OID 21644)
-- Name: logs_logid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.logs_logid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.logs_logid_seq OWNER TO postgres;

--
-- TOC entry 4773 (class 0 OID 0)
-- Dependencies: 297
-- Name: logs_logid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.logs_logid_seq OWNED BY public.logs.logid;


--
-- TOC entry 274 (class 1259 OID 21416)
-- Name: lotes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lotes (
    loteid integer NOT NULL,
    productoxproveedorid integer,
    lotenumber integer,
    lotequantity integer,
    loteamount numeric(12,2),
    currencybaseid integer,
    lotecurrencyamount numeric(12,2),
    exchangerateid integer,
    exchangerateused numeric(12,2),
    checksum bytea,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lotelastupdate timestamp without time zone
);


ALTER TABLE public.lotes OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 21415)
-- Name: lotes_loteid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lotes_loteid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lotes_loteid_seq OWNER TO postgres;

--
-- TOC entry 4774 (class 0 OID 0)
-- Dependencies: 273
-- Name: lotes_loteid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lotes_loteid_seq OWNED BY public.lotes.loteid;


--
-- TOC entry 276 (class 1259 OID 21441)
-- Name: mediodepagos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mediodepagos (
    mediodepagoid integer NOT NULL,
    mediodepagoname character varying(40),
    estado boolean DEFAULT true,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deviceid integer,
    userid integer,
    checksum bytea,
    mediodepagoparametros jsonb
);


ALTER TABLE public.mediodepagos OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 21440)
-- Name: mediodepagos_mediodepagoid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mediodepagos_mediodepagoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mediodepagos_mediodepagoid_seq OWNER TO postgres;

--
-- TOC entry 4775 (class 0 OID 0)
-- Dependencies: 275
-- Name: mediodepagos_mediodepagoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mediodepagos_mediodepagoid_seq OWNED BY public.mediodepagos.mediodepagoid;


--
-- TOC entry 246 (class 1259 OID 21201)
-- Name: origynbrands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.origynbrands (
    origynbrandid integer NOT NULL,
    brandid integer,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastupdate timestamp without time zone,
    estado boolean DEFAULT true,
    userid integer
);


ALTER TABLE public.origynbrands OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 21200)
-- Name: origynbrands_origynbrandid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.origynbrands_origynbrandid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.origynbrands_origynbrandid_seq OWNER TO postgres;

--
-- TOC entry 4776 (class 0 OID 0)
-- Dependencies: 245
-- Name: origynbrands_origynbrandid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.origynbrands_origynbrandid_seq OWNED BY public.origynbrands.origynbrandid;


--
-- TOC entry 224 (class 1259 OID 20825)
-- Name: paises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paises (
    paisid integer NOT NULL,
    paisname character varying(20) NOT NULL,
    estado boolean DEFAULT true,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.paises OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 20824)
-- Name: paises_paisid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.paises_paisid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paises_paisid_seq OWNER TO postgres;

--
-- TOC entry 4777 (class 0 OID 0)
-- Dependencies: 223
-- Name: paises_paisid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.paises_paisid_seq OWNED BY public.paises.paisid;


--
-- TOC entry 230 (class 1259 OID 21078)
-- Name: paisesdestino; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paisesdestino (
    paisdestinoid integer NOT NULL,
    paisid integer
);


ALTER TABLE public.paisesdestino OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 21077)
-- Name: paisesdestino_paisdestinoid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.paisesdestino_paisdestinoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paisesdestino_paisdestinoid_seq OWNER TO postgres;

--
-- TOC entry 4778 (class 0 OID 0)
-- Dependencies: 229
-- Name: paisesdestino_paisdestinoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.paisesdestino_paisdestinoid_seq OWNED BY public.paisesdestino.paisdestinoid;


--
-- TOC entry 228 (class 1259 OID 21066)
-- Name: paisesorigen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paisesorigen (
    paisorigenid integer NOT NULL,
    paisid integer
);


ALTER TABLE public.paisesorigen OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 21065)
-- Name: paisesorigen_paisorigenid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.paisesorigen_paisorigenid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paisesorigen_paisorigenid_seq OWNER TO postgres;

--
-- TOC entry 4779 (class 0 OID 0)
-- Dependencies: 227
-- Name: paisesorigen_paisorigenid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.paisesorigen_paisorigenid_seq OWNED BY public.paisesorigen.paisorigenid;


--
-- TOC entry 248 (class 1259 OID 21220)
-- Name: productcategories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productcategories (
    productcategoryid integer NOT NULL,
    productcategoryname character varying(30)
);


ALTER TABLE public.productcategories OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 21219)
-- Name: productcategories_productcategoryid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productcategories_productcategoryid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productcategories_productcategoryid_seq OWNER TO postgres;

--
-- TOC entry 4780 (class 0 OID 0)
-- Dependencies: 247
-- Name: productcategories_productcategoryid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productcategories_productcategoryid_seq OWNED BY public.productcategories.productcategoryid;


--
-- TOC entry 272 (class 1259 OID 21398)
-- Name: productoxproveedor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productoxproveedor (
    productoxproveedorid integer NOT NULL,
    productid integer,
    proveedorid integer,
    productoxproveedortime timestamp without time zone,
    estado boolean DEFAULT true
);


ALTER TABLE public.productoxproveedor OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 21397)
-- Name: productoxproveedor_productoxproveedorid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productoxproveedor_productoxproveedorid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productoxproveedor_productoxproveedorid_seq OWNER TO postgres;

--
-- TOC entry 4781 (class 0 OID 0)
-- Dependencies: 271
-- Name: productoxproveedor_productoxproveedorid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productoxproveedor_productoxproveedorid_seq OWNED BY public.productoxproveedor.productoxproveedorid;


--
-- TOC entry 252 (class 1259 OID 21240)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    productid integer NOT NULL,
    productname character varying(40),
    productodescripcion character varying(150),
    productcategoryid integer,
    price numeric(12,2),
    sizeid integer,
    estado boolean DEFAULT true,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 21239)
-- Name: products_productid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_productid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_productid_seq OWNER TO postgres;

--
-- TOC entry 4782 (class 0 OID 0)
-- Dependencies: 251
-- Name: products_productid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_productid_seq OWNED BY public.products.productid;


--
-- TOC entry 264 (class 1259 OID 21338)
-- Name: productxprice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productxprice (
    productxpriceid integer NOT NULL,
    productid integer,
    currencyid integer,
    productxpricevalidfrom timestamp without time zone,
    productxpricevalidto timestamp without time zone,
    checksum bytea,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    device integer NOT NULL
);


ALTER TABLE public.productxprice OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 21337)
-- Name: productxprice_productxpriceid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productxprice_productxpriceid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productxprice_productxpriceid_seq OWNER TO postgres;

--
-- TOC entry 4783 (class 0 OID 0)
-- Dependencies: 263
-- Name: productxprice_productxpriceid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productxprice_productxpriceid_seq OWNED BY public.productxprice.productxpriceid;


--
-- TOC entry 266 (class 1259 OID 21358)
-- Name: proveedores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proveedores (
    proveedorid integer NOT NULL,
    proveedorname character varying(40),
    proveedoridfiscal character varying(20),
    addressid integer,
    estado boolean DEFAULT true,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastupdate timestamp without time zone
);


ALTER TABLE public.proveedores OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 21357)
-- Name: proveedores_proveedorid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.proveedores_proveedorid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proveedores_proveedorid_seq OWNER TO postgres;

--
-- TOC entry 4784 (class 0 OID 0)
-- Dependencies: 265
-- Name: proveedores_proveedorid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proveedores_proveedorid_seq OWNED BY public.proveedores.proveedorid;


--
-- TOC entry 270 (class 1259 OID 21379)
-- Name: proveedorescontacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proveedorescontacts (
    proveedorxcontactid integer NOT NULL,
    proveedorid integer,
    contacttypeid integer,
    value character varying(80),
    estado boolean DEFAULT true,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastupdate timestamp without time zone
);


ALTER TABLE public.proveedorescontacts OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 21378)
-- Name: proveedorescontacts_proveedorxcontactid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.proveedorescontacts_proveedorxcontactid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proveedorescontacts_proveedorxcontactid_seq OWNER TO postgres;

--
-- TOC entry 4785 (class 0 OID 0)
-- Dependencies: 269
-- Name: proveedorescontacts_proveedorxcontactid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proveedorescontacts_proveedorxcontactid_seq OWNED BY public.proveedorescontacts.proveedorxcontactid;


--
-- TOC entry 306 (class 1259 OID 21725)
-- Name: puertosdestino; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.puertosdestino (
    puertodestinoid integer NOT NULL,
    puertoid integer,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastupdate timestamp without time zone,
    userid integer,
    estado boolean DEFAULT true
);


ALTER TABLE public.puertosdestino OWNER TO postgres;

--
-- TOC entry 305 (class 1259 OID 21724)
-- Name: puertosdestino_puertodestinoid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.puertosdestino_puertodestinoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.puertosdestino_puertodestinoid_seq OWNER TO postgres;

--
-- TOC entry 4786 (class 0 OID 0)
-- Dependencies: 305
-- Name: puertosdestino_puertodestinoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.puertosdestino_puertodestinoid_seq OWNED BY public.puertosdestino.puertodestinoid;


--
-- TOC entry 304 (class 1259 OID 21706)
-- Name: puertosorigen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.puertosorigen (
    puertorigenid integer NOT NULL,
    puertoid integer,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastupdate timestamp without time zone,
    userid integer,
    estado boolean DEFAULT true
);


ALTER TABLE public.puertosorigen OWNER TO postgres;

--
-- TOC entry 303 (class 1259 OID 21705)
-- Name: puertosorigen_puertorigenid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.puertosorigen_puertorigenid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.puertosorigen_puertorigenid_seq OWNER TO postgres;

--
-- TOC entry 4787 (class 0 OID 0)
-- Dependencies: 303
-- Name: puertosorigen_puertorigenid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.puertosorigen_puertorigenid_seq OWNED BY public.puertosorigen.puertorigenid;


--
-- TOC entry 302 (class 1259 OID 21682)
-- Name: puertosporciudad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.puertosporciudad (
    puertosporciudadid integer NOT NULL,
    puertosporciudadname character varying(40),
    ciudadid integer,
    puertotypeid integer,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastupdate timestamp without time zone,
    userid integer,
    estado boolean DEFAULT true
);


ALTER TABLE public.puertosporciudad OWNER TO postgres;

--
-- TOC entry 301 (class 1259 OID 21681)
-- Name: puertosporciudad_puertosporciudadid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.puertosporciudad_puertosporciudadid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.puertosporciudad_puertosporciudadid_seq OWNER TO postgres;

--
-- TOC entry 4788 (class 0 OID 0)
-- Dependencies: 301
-- Name: puertosporciudad_puertosporciudadid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.puertosporciudad_puertosporciudadid_seq OWNED BY public.puertosporciudad.puertosporciudadid;


--
-- TOC entry 300 (class 1259 OID 21668)
-- Name: puertostypes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.puertostypes (
    puertotypeid integer NOT NULL,
    puertotypetype smallint,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastupdate timestamp without time zone,
    estado boolean DEFAULT true,
    userid integer
);


ALTER TABLE public.puertostypes OWNER TO postgres;

--
-- TOC entry 299 (class 1259 OID 21667)
-- Name: puertostypes_puertotypeid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.puertostypes_puertotypeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.puertostypes_puertotypeid_seq OWNER TO postgres;

--
-- TOC entry 4789 (class 0 OID 0)
-- Dependencies: 299
-- Name: puertostypes_puertotypeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.puertostypes_puertotypeid_seq OWNED BY public.puertostypes.puertotypeid;


--
-- TOC entry 250 (class 1259 OID 21227)
-- Name: sizes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sizes (
    sizeid integer NOT NULL,
    sizeunit smallint,
    sizeunitmeasure character varying(20),
    sizecreationdate timestamp without time zone,
    sizeupdatedate timestamp without time zone,
    sizedeletingdate timestamp without time zone,
    userid integer,
    deleted boolean DEFAULT false
);


ALTER TABLE public.sizes OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 21226)
-- Name: sizes_sizeid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sizes_sizeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sizes_sizeid_seq OWNER TO postgres;

--
-- TOC entry 4790 (class 0 OID 0)
-- Dependencies: 249
-- Name: sizes_sizeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sizes_sizeid_seq OWNED BY public.sizes.sizeid;


--
-- TOC entry 280 (class 1259 OID 21469)
-- Name: sourceobjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sourceobjects (
    sourceobjectid integer NOT NULL,
    sourceobjectname character varying(30),
    estado boolean DEFAULT true,
    lastupdate timestamp without time zone
);


ALTER TABLE public.sourceobjects OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 21468)
-- Name: sourceobjects_sourceobjectid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sourceobjects_sourceobjectid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sourceobjects_sourceobjectid_seq OWNER TO postgres;

--
-- TOC entry 4791 (class 0 OID 0)
-- Dependencies: 279
-- Name: sourceobjects_sourceobjectid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sourceobjects_sourceobjectid_seq OWNED BY public.sourceobjects.sourceobjectid;


--
-- TOC entry 278 (class 1259 OID 21462)
-- Name: tipodetransacciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipodetransacciones (
    tipodetransaccionid integer NOT NULL,
    tipodetransaccionname character varying(30)
);


ALTER TABLE public.tipodetransacciones OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 21461)
-- Name: tipodetransacciones_tipodetransaccionid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tipodetransacciones_tipodetransaccionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tipodetransacciones_tipodetransaccionid_seq OWNER TO postgres;

--
-- TOC entry 4792 (class 0 OID 0)
-- Dependencies: 277
-- Name: tipodetransacciones_tipodetransaccionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tipodetransacciones_tipodetransaccionid_seq OWNED BY public.tipodetransacciones.tipodetransaccionid;


--
-- TOC entry 254 (class 1259 OID 21259)
-- Name: tiposdecaracteristicas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tiposdecaracteristicas (
    tipodecaracteristicaid integer NOT NULL,
    tipodecaracteristicaname character varying(30)
);


ALTER TABLE public.tiposdecaracteristicas OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 21258)
-- Name: tiposdecaracteristicas_tipodecaracteristicaid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tiposdecaracteristicas_tipodecaracteristicaid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tiposdecaracteristicas_tipodecaracteristicaid_seq OWNER TO postgres;

--
-- TOC entry 4793 (class 0 OID 0)
-- Dependencies: 253
-- Name: tiposdecaracteristicas_tipodecaracteristicaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tiposdecaracteristicas_tipodecaracteristicaid_seq OWNED BY public.tiposdecaracteristicas.tipodecaracteristicaid;


--
-- TOC entry 282 (class 1259 OID 21477)
-- Name: transaccioncodes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transaccioncodes (
    transaccioncodeid integer NOT NULL,
    transaccioncodevalue character varying(100),
    transaccioncodedescripcion character varying(200),
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estado boolean DEFAULT true
);


ALTER TABLE public.transaccioncodes OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 21476)
-- Name: transaccioncodes_transaccioncodeid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transaccioncodes_transaccioncodeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transaccioncodes_transaccioncodeid_seq OWNER TO postgres;

--
-- TOC entry 4794 (class 0 OID 0)
-- Dependencies: 281
-- Name: transaccioncodes_transaccioncodeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transaccioncodes_transaccioncodeid_seq OWNED BY public.transaccioncodes.transaccioncodeid;


--
-- TOC entry 284 (class 1259 OID 21486)
-- Name: transacciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transacciones (
    transaccionid integer NOT NULL,
    tipotransaccionid integer,
    monto numeric(12,2),
    currencyid integer,
    exchangerateid integer,
    sourceobjectid integer,
    referenceid bigint,
    amountchanged numeric(12,2),
    transaccioncodeid integer,
    transacciondate timestamp without time zone,
    estado boolean DEFAULT true,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    userid integer,
    checksum bytea,
    deviceid integer,
    movimientoid integer,
    detalle character varying(100)
);


ALTER TABLE public.transacciones OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 21485)
-- Name: transacciones_transaccionid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transacciones_transaccionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transacciones_transaccionid_seq OWNER TO postgres;

--
-- TOC entry 4795 (class 0 OID 0)
-- Dependencies: 283
-- Name: transacciones_transaccionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transacciones_transaccionid_seq OWNED BY public.transacciones.transaccionid;


--
-- TOC entry 240 (class 1259 OID 21154)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    usuarioid integer NOT NULL,
    usuarioname character varying(20),
    usuariofirstname character varying(20),
    usuariosecname character varying(20),
    addressid integer,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastupdate timestamp without time zone,
    estado boolean DEFAULT true
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 21153)
-- Name: usuarios_usuarioid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_usuarioid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_usuarioid_seq OWNER TO postgres;

--
-- TOC entry 4796 (class 0 OID 0)
-- Dependencies: 239
-- Name: usuarios_usuarioid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_usuarioid_seq OWNED BY public.usuarios.usuarioid;


--
-- TOC entry 242 (class 1259 OID 21168)
-- Name: usuarioslogins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarioslogins (
    usuariologinid integer NOT NULL,
    usuariologinpassword bytea,
    usuariologinfecha timestamp without time zone,
    deviceid integer,
    usuarioid integer,
    posttime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastupdate timestamp without time zone
);


ALTER TABLE public.usuarioslogins OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 21167)
-- Name: usuarioslogins_usuariologinid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarioslogins_usuariologinid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarioslogins_usuariologinid_seq OWNER TO postgres;

--
-- TOC entry 4797 (class 0 OID 0)
-- Dependencies: 241
-- Name: usuarioslogins_usuariologinid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarioslogins_usuariologinid_seq OWNED BY public.usuarioslogins.usuariologinid;


--
-- TOC entry 4409 (class 2604 OID 21641)
-- Name: actions actionid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actions ALTER COLUMN actionid SET DEFAULT nextval('public.actions_actionid_seq'::regclass);


--
-- TOC entry 4340 (class 2604 OID 21141)
-- Name: addresses addressid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses ALTER COLUMN addressid SET DEFAULT nextval('public.addresses_addressid_seq'::regclass);


--
-- TOC entry 4348 (class 2604 OID 21191)
-- Name: brands brandid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands ALTER COLUMN brandid SET DEFAULT nextval('public.brands_brandid_seq'::regclass);


--
-- TOC entry 4425 (class 2604 OID 21747)
-- Name: bulks bulkid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulks ALTER COLUMN bulkid SET DEFAULT nextval('public.bulks_bulkid_seq'::regclass);


--
-- TOC entry 4428 (class 2604 OID 21778)
-- Name: bulkstrackings bulktrackingid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulkstrackings ALTER COLUMN bulktrackingid SET DEFAULT nextval('public.bulkstrackings_bulktrackingid_seq'::regclass);


--
-- TOC entry 4360 (class 2604 OID 21269)
-- Name: caracteristicas caracteristicaid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caracteristicas ALTER COLUMN caracteristicaid SET DEFAULT nextval('public.caracteristicas_caracteristicaid_seq'::regclass);


--
-- TOC entry 4361 (class 2604 OID 21286)
-- Name: caracteristicaxproducto caracteristicaxproductoid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caracteristicaxproducto ALTER COLUMN caracteristicaxproductoid SET DEFAULT nextval('public.caracteristicaxproducto_caracteristicaxproductoid_seq'::regclass);


--
-- TOC entry 4335 (class 2604 OID 21093)
-- Name: ciudades ciudadid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudades ALTER COLUMN ciudadid SET DEFAULT nextval('public.ciudades_ciudadid_seq'::regclass);


--
-- TOC entry 4339 (class 2604 OID 21124)
-- Name: ciudadesdestino ciudaddestinoid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudadesdestino ALTER COLUMN ciudaddestinoid SET DEFAULT nextval('public.ciudadesdestino_ciudaddestinoid_seq'::regclass);


--
-- TOC entry 4338 (class 2604 OID 21107)
-- Name: ciudadesorigen ciudadorigenid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudadesorigen ALTER COLUMN ciudadorigenid SET DEFAULT nextval('public.ciudadesorigen_ciudadorigenid_seq'::regclass);


--
-- TOC entry 4376 (class 2604 OID 21375)
-- Name: contacttypes contacttypeid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacttypes ALTER COLUMN contacttypeid SET DEFAULT nextval('public.contacttypes_contacttypeid_seq'::regclass);


--
-- TOC entry 4364 (class 2604 OID 21305)
-- Name: currencies currencyid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currencies ALTER COLUMN currencyid SET DEFAULT nextval('public.currencies_currencyid_seq'::regclass);


--
-- TOC entry 4396 (class 2604 OID 21535)
-- Name: descuentosporproducto descuentoporproductoid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.descuentosporproducto ALTER COLUMN descuentoporproductoid SET DEFAULT nextval('public.descuentosporproducto_descuentoporproductoid_seq'::regclass);


--
-- TOC entry 4407 (class 2604 OID 21611)
-- Name: detalledeimportacion detalledeimportacionid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalledeimportacion ALTER COLUMN detalledeimportacionid SET DEFAULT nextval('public.detalledeimportacion_detalledeimportacionid_seq'::regclass);


--
-- TOC entry 4330 (class 2604 OID 21058)
-- Name: devices deviceid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices ALTER COLUMN deviceid SET DEFAULT nextval('public.devices_deviceid_seq'::regclass);


--
-- TOC entry 4367 (class 2604 OID 21319)
-- Name: exchangerates exchangerateid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exchangerates ALTER COLUMN exchangerateid SET DEFAULT nextval('public.exchangerates_exchangerateid_seq'::regclass);


--
-- TOC entry 4405 (class 2604 OID 21593)
-- Name: importaciones importacionid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.importaciones ALTER COLUMN importacionid SET DEFAULT nextval('public.importaciones_importacionid_seq'::regclass);


--
-- TOC entry 4399 (class 2604 OID 21551)
-- Name: impuestos impuestoid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.impuestos ALTER COLUMN impuestoid SET DEFAULT nextval('public.impuestos_impuestoid_seq'::regclass);


--
-- TOC entry 4402 (class 2604 OID 21567)
-- Name: impuestosporpais impuestosporpaisid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.impuestosporpais ALTER COLUMN impuestosporpaisid SET DEFAULT nextval('public.impuestosporpais_impuestosporpaisid_seq'::regclass);


--
-- TOC entry 4410 (class 2604 OID 21648)
-- Name: logs logid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs ALTER COLUMN logid SET DEFAULT nextval('public.logs_logid_seq'::regclass);


--
-- TOC entry 4382 (class 2604 OID 21419)
-- Name: lotes loteid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lotes ALTER COLUMN loteid SET DEFAULT nextval('public.lotes_loteid_seq'::regclass);


--
-- TOC entry 4384 (class 2604 OID 21444)
-- Name: mediodepagos mediodepagoid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mediodepagos ALTER COLUMN mediodepagoid SET DEFAULT nextval('public.mediodepagos_mediodepagoid_seq'::regclass);


--
-- TOC entry 4350 (class 2604 OID 21204)
-- Name: origynbrands origynbrandid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.origynbrands ALTER COLUMN origynbrandid SET DEFAULT nextval('public.origynbrands_origynbrandid_seq'::regclass);


--
-- TOC entry 4327 (class 2604 OID 20828)
-- Name: paises paisid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paises ALTER COLUMN paisid SET DEFAULT nextval('public.paises_paisid_seq'::regclass);


--
-- TOC entry 4334 (class 2604 OID 21081)
-- Name: paisesdestino paisdestinoid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paisesdestino ALTER COLUMN paisdestinoid SET DEFAULT nextval('public.paisesdestino_paisdestinoid_seq'::regclass);


--
-- TOC entry 4333 (class 2604 OID 21069)
-- Name: paisesorigen paisorigenid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paisesorigen ALTER COLUMN paisorigenid SET DEFAULT nextval('public.paisesorigen_paisorigenid_seq'::regclass);


--
-- TOC entry 4353 (class 2604 OID 21223)
-- Name: productcategories productcategoryid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productcategories ALTER COLUMN productcategoryid SET DEFAULT nextval('public.productcategories_productcategoryid_seq'::regclass);


--
-- TOC entry 4380 (class 2604 OID 21401)
-- Name: productoxproveedor productoxproveedorid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productoxproveedor ALTER COLUMN productoxproveedorid SET DEFAULT nextval('public.productoxproveedor_productoxproveedorid_seq'::regclass);


--
-- TOC entry 4356 (class 2604 OID 21243)
-- Name: products productid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN productid SET DEFAULT nextval('public.products_productid_seq'::regclass);


--
-- TOC entry 4371 (class 2604 OID 21341)
-- Name: productxprice productxpriceid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productxprice ALTER COLUMN productxpriceid SET DEFAULT nextval('public.productxprice_productxpriceid_seq'::regclass);


--
-- TOC entry 4373 (class 2604 OID 21361)
-- Name: proveedores proveedorid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores ALTER COLUMN proveedorid SET DEFAULT nextval('public.proveedores_proveedorid_seq'::regclass);


--
-- TOC entry 4377 (class 2604 OID 21382)
-- Name: proveedorescontacts proveedorxcontactid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedorescontacts ALTER COLUMN proveedorxcontactid SET DEFAULT nextval('public.proveedorescontacts_proveedorxcontactid_seq'::regclass);


--
-- TOC entry 4422 (class 2604 OID 21728)
-- Name: puertosdestino puertodestinoid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosdestino ALTER COLUMN puertodestinoid SET DEFAULT nextval('public.puertosdestino_puertodestinoid_seq'::regclass);


--
-- TOC entry 4419 (class 2604 OID 21709)
-- Name: puertosorigen puertorigenid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosorigen ALTER COLUMN puertorigenid SET DEFAULT nextval('public.puertosorigen_puertorigenid_seq'::regclass);


--
-- TOC entry 4416 (class 2604 OID 21685)
-- Name: puertosporciudad puertosporciudadid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosporciudad ALTER COLUMN puertosporciudadid SET DEFAULT nextval('public.puertosporciudad_puertosporciudadid_seq'::regclass);


--
-- TOC entry 4413 (class 2604 OID 21671)
-- Name: puertostypes puertotypeid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertostypes ALTER COLUMN puertotypeid SET DEFAULT nextval('public.puertostypes_puertotypeid_seq'::regclass);


--
-- TOC entry 4354 (class 2604 OID 21230)
-- Name: sizes sizeid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sizes ALTER COLUMN sizeid SET DEFAULT nextval('public.sizes_sizeid_seq'::regclass);


--
-- TOC entry 4388 (class 2604 OID 21472)
-- Name: sourceobjects sourceobjectid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sourceobjects ALTER COLUMN sourceobjectid SET DEFAULT nextval('public.sourceobjects_sourceobjectid_seq'::regclass);


--
-- TOC entry 4387 (class 2604 OID 21465)
-- Name: tipodetransacciones tipodetransaccionid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipodetransacciones ALTER COLUMN tipodetransaccionid SET DEFAULT nextval('public.tipodetransacciones_tipodetransaccionid_seq'::regclass);


--
-- TOC entry 4359 (class 2604 OID 21262)
-- Name: tiposdecaracteristicas tipodecaracteristicaid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tiposdecaracteristicas ALTER COLUMN tipodecaracteristicaid SET DEFAULT nextval('public.tiposdecaracteristicas_tipodecaracteristicaid_seq'::regclass);


--
-- TOC entry 4390 (class 2604 OID 21480)
-- Name: transaccioncodes transaccioncodeid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaccioncodes ALTER COLUMN transaccioncodeid SET DEFAULT nextval('public.transaccioncodes_transaccioncodeid_seq'::regclass);


--
-- TOC entry 4393 (class 2604 OID 21489)
-- Name: transacciones transaccionid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones ALTER COLUMN transaccionid SET DEFAULT nextval('public.transacciones_transaccionid_seq'::regclass);


--
-- TOC entry 4343 (class 2604 OID 21157)
-- Name: usuarios usuarioid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN usuarioid SET DEFAULT nextval('public.usuarios_usuarioid_seq'::regclass);


--
-- TOC entry 4346 (class 2604 OID 21171)
-- Name: usuarioslogins usuariologinid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarioslogins ALTER COLUMN usuariologinid SET DEFAULT nextval('public.usuarioslogins_usuariologinid_seq'::regclass);


--
-- TOC entry 4507 (class 2606 OID 21643)
-- Name: actions actions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (actionid);


--
-- TOC entry 4509 (class 2606 OID 21860)
-- Name: actions actions_typename_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT actions_typename_unique UNIQUE (actiontypename);


--
-- TOC entry 4449 (class 2606 OID 21147)
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (addressid);


--
-- TOC entry 4455 (class 2606 OID 21194)
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (brandid);


--
-- TOC entry 4521 (class 2606 OID 21753)
-- Name: bulks bulks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulks
    ADD CONSTRAINT bulks_pkey PRIMARY KEY (bulkid);


--
-- TOC entry 4523 (class 2606 OID 21782)
-- Name: bulkstrackings bulkstrackings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulkstrackings
    ADD CONSTRAINT bulkstrackings_pkey PRIMARY KEY (bulktrackingid);


--
-- TOC entry 4467 (class 2606 OID 21271)
-- Name: caracteristicas caracteristicas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caracteristicas
    ADD CONSTRAINT caracteristicas_pkey PRIMARY KEY (caracteristicaid);


--
-- TOC entry 4469 (class 2606 OID 21290)
-- Name: caracteristicaxproducto caracteristicaxproducto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caracteristicaxproducto
    ADD CONSTRAINT caracteristicaxproducto_pkey PRIMARY KEY (caracteristicaxproductoid);


--
-- TOC entry 4443 (class 2606 OID 21097)
-- Name: ciudades ciudades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudades
    ADD CONSTRAINT ciudades_pkey PRIMARY KEY (ciudadid);


--
-- TOC entry 4447 (class 2606 OID 21126)
-- Name: ciudadesdestino ciudadesdestino_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudadesdestino
    ADD CONSTRAINT ciudadesdestino_pkey PRIMARY KEY (ciudaddestinoid);


--
-- TOC entry 4445 (class 2606 OID 21109)
-- Name: ciudadesorigen ciudadesorigen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudadesorigen
    ADD CONSTRAINT ciudadesorigen_pkey PRIMARY KEY (ciudadorigenid);


--
-- TOC entry 4479 (class 2606 OID 21377)
-- Name: contacttypes contacttypes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacttypes
    ADD CONSTRAINT contacttypes_pkey PRIMARY KEY (contacttypeid);


--
-- TOC entry 4471 (class 2606 OID 21309)
-- Name: currencies currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_pkey PRIMARY KEY (currencyid);


--
-- TOC entry 4497 (class 2606 OID 21541)
-- Name: descuentosporproducto descuentosporproducto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.descuentosporproducto
    ADD CONSTRAINT descuentosporproducto_pkey PRIMARY KEY (descuentoporproductoid);


--
-- TOC entry 4505 (class 2606 OID 21616)
-- Name: detalledeimportacion detalledeimportacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalledeimportacion
    ADD CONSTRAINT detalledeimportacion_pkey PRIMARY KEY (detalledeimportacionid);


--
-- TOC entry 4437 (class 2606 OID 21064)
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (deviceid);


--
-- TOC entry 4473 (class 2606 OID 21326)
-- Name: exchangerates exchangerates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exchangerates
    ADD CONSTRAINT exchangerates_pkey PRIMARY KEY (exchangerateid);


--
-- TOC entry 4503 (class 2606 OID 21596)
-- Name: importaciones importaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.importaciones
    ADD CONSTRAINT importaciones_pkey PRIMARY KEY (importacionid);


--
-- TOC entry 4499 (class 2606 OID 21557)
-- Name: impuestos impuestos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.impuestos
    ADD CONSTRAINT impuestos_pkey PRIMARY KEY (impuestoid);


--
-- TOC entry 4501 (class 2606 OID 21573)
-- Name: impuestosporpais impuestosporpais_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.impuestosporpais
    ADD CONSTRAINT impuestosporpais_pkey PRIMARY KEY (impuestosporpaisid);


--
-- TOC entry 4511 (class 2606 OID 21651)
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (logid);


--
-- TOC entry 4485 (class 2606 OID 21424)
-- Name: lotes lotes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lotes
    ADD CONSTRAINT lotes_pkey PRIMARY KEY (loteid);


--
-- TOC entry 4487 (class 2606 OID 21450)
-- Name: mediodepagos mediodepagos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mediodepagos
    ADD CONSTRAINT mediodepagos_pkey PRIMARY KEY (mediodepagoid);


--
-- TOC entry 4457 (class 2606 OID 21208)
-- Name: origynbrands origynbrands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.origynbrands
    ADD CONSTRAINT origynbrands_pkey PRIMARY KEY (origynbrandid);


--
-- TOC entry 4435 (class 2606 OID 20832)
-- Name: paises paises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_pkey PRIMARY KEY (paisid);


--
-- TOC entry 4441 (class 2606 OID 21083)
-- Name: paisesdestino paisesdestino_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paisesdestino
    ADD CONSTRAINT paisesdestino_pkey PRIMARY KEY (paisdestinoid);


--
-- TOC entry 4439 (class 2606 OID 21071)
-- Name: paisesorigen paisesorigen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paisesorigen
    ADD CONSTRAINT paisesorigen_pkey PRIMARY KEY (paisorigenid);


--
-- TOC entry 4459 (class 2606 OID 21225)
-- Name: productcategories productcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productcategories
    ADD CONSTRAINT productcategories_pkey PRIMARY KEY (productcategoryid);


--
-- TOC entry 4483 (class 2606 OID 21404)
-- Name: productoxproveedor productoxproveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productoxproveedor
    ADD CONSTRAINT productoxproveedor_pkey PRIMARY KEY (productoxproveedorid);


--
-- TOC entry 4463 (class 2606 OID 21247)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (productid);


--
-- TOC entry 4475 (class 2606 OID 21346)
-- Name: productxprice productxprice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productxprice
    ADD CONSTRAINT productxprice_pkey PRIMARY KEY (productxpriceid);


--
-- TOC entry 4477 (class 2606 OID 21365)
-- Name: proveedores proveedores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_pkey PRIMARY KEY (proveedorid);


--
-- TOC entry 4481 (class 2606 OID 21386)
-- Name: proveedorescontacts proveedorescontacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedorescontacts
    ADD CONSTRAINT proveedorescontacts_pkey PRIMARY KEY (proveedorxcontactid);


--
-- TOC entry 4519 (class 2606 OID 21732)
-- Name: puertosdestino puertosdestino_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosdestino
    ADD CONSTRAINT puertosdestino_pkey PRIMARY KEY (puertodestinoid);


--
-- TOC entry 4517 (class 2606 OID 21713)
-- Name: puertosorigen puertosorigen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosorigen
    ADD CONSTRAINT puertosorigen_pkey PRIMARY KEY (puertorigenid);


--
-- TOC entry 4515 (class 2606 OID 21689)
-- Name: puertosporciudad puertosporciudad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosporciudad
    ADD CONSTRAINT puertosporciudad_pkey PRIMARY KEY (puertosporciudadid);


--
-- TOC entry 4513 (class 2606 OID 21675)
-- Name: puertostypes puertostypes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertostypes
    ADD CONSTRAINT puertostypes_pkey PRIMARY KEY (puertotypeid);


--
-- TOC entry 4461 (class 2606 OID 21233)
-- Name: sizes sizes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sizes
    ADD CONSTRAINT sizes_pkey PRIMARY KEY (sizeid);


--
-- TOC entry 4491 (class 2606 OID 21475)
-- Name: sourceobjects sourceobjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sourceobjects
    ADD CONSTRAINT sourceobjects_pkey PRIMARY KEY (sourceobjectid);


--
-- TOC entry 4489 (class 2606 OID 21467)
-- Name: tipodetransacciones tipodetransacciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipodetransacciones
    ADD CONSTRAINT tipodetransacciones_pkey PRIMARY KEY (tipodetransaccionid);


--
-- TOC entry 4465 (class 2606 OID 21264)
-- Name: tiposdecaracteristicas tiposdecaracteristicas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tiposdecaracteristicas
    ADD CONSTRAINT tiposdecaracteristicas_pkey PRIMARY KEY (tipodecaracteristicaid);


--
-- TOC entry 4493 (class 2606 OID 21484)
-- Name: transaccioncodes transaccioncodes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaccioncodes
    ADD CONSTRAINT transaccioncodes_pkey PRIMARY KEY (transaccioncodeid);


--
-- TOC entry 4495 (class 2606 OID 21495)
-- Name: transacciones transacciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones
    ADD CONSTRAINT transacciones_pkey PRIMARY KEY (transaccionid);


--
-- TOC entry 4451 (class 2606 OID 21161)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (usuarioid);


--
-- TOC entry 4453 (class 2606 OID 21176)
-- Name: usuarioslogins usuarioslogins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarioslogins
    ADD CONSTRAINT usuarioslogins_pkey PRIMARY KEY (usuariologinid);


--
-- TOC entry 4531 (class 2606 OID 21148)
-- Name: addresses addresses_cityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_cityid_fkey FOREIGN KEY (cityid) REFERENCES public.ciudades(ciudadid);


--
-- TOC entry 4535 (class 2606 OID 21195)
-- Name: brands brands_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4589 (class 2606 OID 21754)
-- Name: bulks bulks_importacionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulks
    ADD CONSTRAINT bulks_importacionid_fkey FOREIGN KEY (importacionid) REFERENCES public.importaciones(importacionid);


--
-- TOC entry 4590 (class 2606 OID 21759)
-- Name: bulks bulks_loteid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulks
    ADD CONSTRAINT bulks_loteid_fkey FOREIGN KEY (loteid) REFERENCES public.lotes(loteid);


--
-- TOC entry 4591 (class 2606 OID 21764)
-- Name: bulks bulks_sizeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulks
    ADD CONSTRAINT bulks_sizeid_fkey FOREIGN KEY (sizeid) REFERENCES public.sizes(sizeid);


--
-- TOC entry 4592 (class 2606 OID 21769)
-- Name: bulks bulks_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulks
    ADD CONSTRAINT bulks_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4593 (class 2606 OID 21783)
-- Name: bulkstrackings bulkstrackings_bulkid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulkstrackings
    ADD CONSTRAINT bulkstrackings_bulkid_fkey FOREIGN KEY (bulkid) REFERENCES public.bulks(bulkid);


--
-- TOC entry 4594 (class 2606 OID 21803)
-- Name: bulkstrackings bulkstrackings_deviceid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulkstrackings
    ADD CONSTRAINT bulkstrackings_deviceid_fkey FOREIGN KEY (deviceid) REFERENCES public.devices(deviceid);


--
-- TOC entry 4595 (class 2606 OID 21793)
-- Name: bulkstrackings bulkstrackings_puertodestinoid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulkstrackings
    ADD CONSTRAINT bulkstrackings_puertodestinoid_fkey FOREIGN KEY (puertodestinoid) REFERENCES public.puertosdestino(puertodestinoid);


--
-- TOC entry 4596 (class 2606 OID 21788)
-- Name: bulkstrackings bulkstrackings_puertorigenid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulkstrackings
    ADD CONSTRAINT bulkstrackings_puertorigenid_fkey FOREIGN KEY (puertorigenid) REFERENCES public.puertosorigen(puertorigenid);


--
-- TOC entry 4597 (class 2606 OID 21798)
-- Name: bulkstrackings bulkstrackings_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulkstrackings
    ADD CONSTRAINT bulkstrackings_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4541 (class 2606 OID 21277)
-- Name: caracteristicas caracteristicas_paisid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caracteristicas
    ADD CONSTRAINT caracteristicas_paisid_fkey FOREIGN KEY (paisid) REFERENCES public.paises(paisid);


--
-- TOC entry 4542 (class 2606 OID 21272)
-- Name: caracteristicas caracteristicas_tipodecaracteristicaid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caracteristicas
    ADD CONSTRAINT caracteristicas_tipodecaracteristicaid_fkey FOREIGN KEY (tipodecaracteristicaid) REFERENCES public.tiposdecaracteristicas(tipodecaracteristicaid);


--
-- TOC entry 4543 (class 2606 OID 21296)
-- Name: caracteristicaxproducto caracteristicaxproducto_caracteristicaid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caracteristicaxproducto
    ADD CONSTRAINT caracteristicaxproducto_caracteristicaid_fkey FOREIGN KEY (caracteristicaid) REFERENCES public.caracteristicas(caracteristicaid);


--
-- TOC entry 4544 (class 2606 OID 21291)
-- Name: caracteristicaxproducto caracteristicaxproducto_productoid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caracteristicaxproducto
    ADD CONSTRAINT caracteristicaxproducto_productoid_fkey FOREIGN KEY (productoid) REFERENCES public.products(productid);


--
-- TOC entry 4526 (class 2606 OID 21098)
-- Name: ciudades ciudades_paisid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudades
    ADD CONSTRAINT ciudades_paisid_fkey FOREIGN KEY (paisid) REFERENCES public.paises(paisid);


--
-- TOC entry 4529 (class 2606 OID 21127)
-- Name: ciudadesdestino ciudadesdestino_ciudadid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudadesdestino
    ADD CONSTRAINT ciudadesdestino_ciudadid_fkey FOREIGN KEY (ciudadid) REFERENCES public.ciudades(ciudadid);


--
-- TOC entry 4530 (class 2606 OID 21132)
-- Name: ciudadesdestino ciudadesdestino_paisid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudadesdestino
    ADD CONSTRAINT ciudadesdestino_paisid_fkey FOREIGN KEY (paisid) REFERENCES public.paises(paisid);


--
-- TOC entry 4527 (class 2606 OID 21110)
-- Name: ciudadesorigen ciudadesorigen_ciudadid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudadesorigen
    ADD CONSTRAINT ciudadesorigen_ciudadid_fkey FOREIGN KEY (ciudadid) REFERENCES public.ciudades(ciudadid);


--
-- TOC entry 4528 (class 2606 OID 21115)
-- Name: ciudadesorigen ciudadesorigen_paisid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudadesorigen
    ADD CONSTRAINT ciudadesorigen_paisid_fkey FOREIGN KEY (paisid) REFERENCES public.paises(paisid);


--
-- TOC entry 4545 (class 2606 OID 21310)
-- Name: currencies currencies_paisid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_paisid_fkey FOREIGN KEY (paisid) REFERENCES public.paises(paisid);


--
-- TOC entry 4568 (class 2606 OID 21542)
-- Name: descuentosporproducto descuentosporproducto_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.descuentosporproducto
    ADD CONSTRAINT descuentosporproducto_productid_fkey FOREIGN KEY (productid) REFERENCES public.products(productid);


--
-- TOC entry 4575 (class 2606 OID 21627)
-- Name: detalledeimportacion detalledeimportacion_exchangerateid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalledeimportacion
    ADD CONSTRAINT detalledeimportacion_exchangerateid_fkey FOREIGN KEY (exchangerateid) REFERENCES public.exchangerates(exchangerateid);


--
-- TOC entry 4576 (class 2606 OID 21617)
-- Name: detalledeimportacion detalledeimportacion_importacionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalledeimportacion
    ADD CONSTRAINT detalledeimportacion_importacionid_fkey FOREIGN KEY (importacionid) REFERENCES public.importaciones(importacionid);


--
-- TOC entry 4577 (class 2606 OID 21622)
-- Name: detalledeimportacion detalledeimportacion_productoid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalledeimportacion
    ADD CONSTRAINT detalledeimportacion_productoid_fkey FOREIGN KEY (productoid) REFERENCES public.products(productid);


--
-- TOC entry 4578 (class 2606 OID 21632)
-- Name: detalledeimportacion detalledeimportacion_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalledeimportacion
    ADD CONSTRAINT detalledeimportacion_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4546 (class 2606 OID 21327)
-- Name: exchangerates exchangerates_currencyid1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exchangerates
    ADD CONSTRAINT exchangerates_currencyid1_fkey FOREIGN KEY (currencyid1) REFERENCES public.currencies(currencyid);


--
-- TOC entry 4547 (class 2606 OID 21332)
-- Name: exchangerates exchangerates_currencyid2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exchangerates
    ADD CONSTRAINT exchangerates_currencyid2_fkey FOREIGN KEY (currencyid2) REFERENCES public.currencies(currencyid);


--
-- TOC entry 4548 (class 2606 OID 21879)
-- Name: productxprice fk_productxprice_device; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productxprice
    ADD CONSTRAINT fk_productxprice_device FOREIGN KEY (device) REFERENCES public.devices(deviceid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4573 (class 2606 OID 21602)
-- Name: importaciones importaciones_paisid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.importaciones
    ADD CONSTRAINT importaciones_paisid_fkey FOREIGN KEY (paisid) REFERENCES public.paises(paisid);


--
-- TOC entry 4574 (class 2606 OID 21597)
-- Name: importaciones importaciones_proveedorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.importaciones
    ADD CONSTRAINT importaciones_proveedorid_fkey FOREIGN KEY (proveedorid) REFERENCES public.proveedores(proveedorid);


--
-- TOC entry 4569 (class 2606 OID 21558)
-- Name: impuestos impuestos_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.impuestos
    ADD CONSTRAINT impuestos_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4570 (class 2606 OID 21584)
-- Name: impuestosporpais impuestosporpais_impuestoid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.impuestosporpais
    ADD CONSTRAINT impuestosporpais_impuestoid_fkey FOREIGN KEY (impuestoid) REFERENCES public.impuestos(impuestoid);


--
-- TOC entry 4571 (class 2606 OID 21579)
-- Name: impuestosporpais impuestosporpais_paisid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.impuestosporpais
    ADD CONSTRAINT impuestosporpais_paisid_fkey FOREIGN KEY (paisid) REFERENCES public.paises(paisid);


--
-- TOC entry 4572 (class 2606 OID 21574)
-- Name: impuestosporpais impuestosporpais_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.impuestosporpais
    ADD CONSTRAINT impuestosporpais_productid_fkey FOREIGN KEY (productid) REFERENCES public.products(productid);


--
-- TOC entry 4579 (class 2606 OID 21657)
-- Name: logs logs_actionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_actionid_fkey FOREIGN KEY (actionid) REFERENCES public.actions(actionid);


--
-- TOC entry 4580 (class 2606 OID 21662)
-- Name: logs logs_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4556 (class 2606 OID 21430)
-- Name: lotes lotes_currencybaseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lotes
    ADD CONSTRAINT lotes_currencybaseid_fkey FOREIGN KEY (currencybaseid) REFERENCES public.currencies(currencyid);


--
-- TOC entry 4557 (class 2606 OID 21435)
-- Name: lotes lotes_exchangerateid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lotes
    ADD CONSTRAINT lotes_exchangerateid_fkey FOREIGN KEY (exchangerateid) REFERENCES public.exchangerates(exchangerateid);


--
-- TOC entry 4558 (class 2606 OID 21425)
-- Name: lotes lotes_productoxproveedorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lotes
    ADD CONSTRAINT lotes_productoxproveedorid_fkey FOREIGN KEY (productoxproveedorid) REFERENCES public.productoxproveedor(productoxproveedorid);


--
-- TOC entry 4559 (class 2606 OID 21451)
-- Name: mediodepagos mediodepagos_deviceid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mediodepagos
    ADD CONSTRAINT mediodepagos_deviceid_fkey FOREIGN KEY (deviceid) REFERENCES public.devices(deviceid);


--
-- TOC entry 4560 (class 2606 OID 21456)
-- Name: mediodepagos mediodepagos_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mediodepagos
    ADD CONSTRAINT mediodepagos_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4536 (class 2606 OID 21209)
-- Name: origynbrands origynbrands_brandid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.origynbrands
    ADD CONSTRAINT origynbrands_brandid_fkey FOREIGN KEY (brandid) REFERENCES public.brands(brandid);


--
-- TOC entry 4537 (class 2606 OID 21214)
-- Name: origynbrands origynbrands_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.origynbrands
    ADD CONSTRAINT origynbrands_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4525 (class 2606 OID 21084)
-- Name: paisesdestino paisesdestino_paisid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paisesdestino
    ADD CONSTRAINT paisesdestino_paisid_fkey FOREIGN KEY (paisid) REFERENCES public.paises(paisid);


--
-- TOC entry 4524 (class 2606 OID 21072)
-- Name: paisesorigen paisesorigen_paisid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paisesorigen
    ADD CONSTRAINT paisesorigen_paisid_fkey FOREIGN KEY (paisid) REFERENCES public.paises(paisid);


--
-- TOC entry 4554 (class 2606 OID 21405)
-- Name: productoxproveedor productoxproveedor_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productoxproveedor
    ADD CONSTRAINT productoxproveedor_productid_fkey FOREIGN KEY (productid) REFERENCES public.products(productid);


--
-- TOC entry 4555 (class 2606 OID 21410)
-- Name: productoxproveedor productoxproveedor_proveedorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productoxproveedor
    ADD CONSTRAINT productoxproveedor_proveedorid_fkey FOREIGN KEY (proveedorid) REFERENCES public.proveedores(proveedorid);


--
-- TOC entry 4539 (class 2606 OID 21253)
-- Name: products products_measureid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_measureid_fkey FOREIGN KEY (sizeid) REFERENCES public.sizes(sizeid);


--
-- TOC entry 4540 (class 2606 OID 21248)
-- Name: products products_productcategoryid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_productcategoryid_fkey FOREIGN KEY (productcategoryid) REFERENCES public.productcategories(productcategoryid);


--
-- TOC entry 4549 (class 2606 OID 21352)
-- Name: productxprice productxprice_currencyid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productxprice
    ADD CONSTRAINT productxprice_currencyid_fkey FOREIGN KEY (currencyid) REFERENCES public.currencies(currencyid);


--
-- TOC entry 4550 (class 2606 OID 21347)
-- Name: productxprice productxprice_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productxprice
    ADD CONSTRAINT productxprice_productid_fkey FOREIGN KEY (productid) REFERENCES public.products(productid);


--
-- TOC entry 4551 (class 2606 OID 21366)
-- Name: proveedores proveedores_addressid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_addressid_fkey FOREIGN KEY (addressid) REFERENCES public.addresses(addressid);


--
-- TOC entry 4552 (class 2606 OID 21392)
-- Name: proveedorescontacts proveedorescontacts_contacttypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedorescontacts
    ADD CONSTRAINT proveedorescontacts_contacttypeid_fkey FOREIGN KEY (contacttypeid) REFERENCES public.contacttypes(contacttypeid);


--
-- TOC entry 4553 (class 2606 OID 21387)
-- Name: proveedorescontacts proveedorescontacts_proveedorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedorescontacts
    ADD CONSTRAINT proveedorescontacts_proveedorid_fkey FOREIGN KEY (proveedorid) REFERENCES public.proveedores(proveedorid);


--
-- TOC entry 4587 (class 2606 OID 21733)
-- Name: puertosdestino puertosdestino_puertoid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosdestino
    ADD CONSTRAINT puertosdestino_puertoid_fkey FOREIGN KEY (puertoid) REFERENCES public.puertosporciudad(puertosporciudadid);


--
-- TOC entry 4588 (class 2606 OID 21738)
-- Name: puertosdestino puertosdestino_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosdestino
    ADD CONSTRAINT puertosdestino_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4585 (class 2606 OID 21714)
-- Name: puertosorigen puertosorigen_puertoid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosorigen
    ADD CONSTRAINT puertosorigen_puertoid_fkey FOREIGN KEY (puertoid) REFERENCES public.puertosporciudad(puertosporciudadid);


--
-- TOC entry 4586 (class 2606 OID 21719)
-- Name: puertosorigen puertosorigen_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosorigen
    ADD CONSTRAINT puertosorigen_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4582 (class 2606 OID 21690)
-- Name: puertosporciudad puertosporciudad_ciudadid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosporciudad
    ADD CONSTRAINT puertosporciudad_ciudadid_fkey FOREIGN KEY (ciudadid) REFERENCES public.ciudades(ciudadid);


--
-- TOC entry 4583 (class 2606 OID 21695)
-- Name: puertosporciudad puertosporciudad_puertotypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosporciudad
    ADD CONSTRAINT puertosporciudad_puertotypeid_fkey FOREIGN KEY (puertotypeid) REFERENCES public.puertostypes(puertotypeid);


--
-- TOC entry 4584 (class 2606 OID 21700)
-- Name: puertosporciudad puertosporciudad_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertosporciudad
    ADD CONSTRAINT puertosporciudad_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4581 (class 2606 OID 21676)
-- Name: puertostypes puertostypes_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puertostypes
    ADD CONSTRAINT puertostypes_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4538 (class 2606 OID 21234)
-- Name: sizes sizes_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sizes
    ADD CONSTRAINT sizes_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4561 (class 2606 OID 21501)
-- Name: transacciones transacciones_currencyid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones
    ADD CONSTRAINT transacciones_currencyid_fkey FOREIGN KEY (currencyid) REFERENCES public.currencies(currencyid);


--
-- TOC entry 4562 (class 2606 OID 21526)
-- Name: transacciones transacciones_deviceid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones
    ADD CONSTRAINT transacciones_deviceid_fkey FOREIGN KEY (deviceid) REFERENCES public.devices(deviceid);


--
-- TOC entry 4563 (class 2606 OID 21506)
-- Name: transacciones transacciones_exchangerateid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones
    ADD CONSTRAINT transacciones_exchangerateid_fkey FOREIGN KEY (exchangerateid) REFERENCES public.exchangerates(exchangerateid);


--
-- TOC entry 4564 (class 2606 OID 21511)
-- Name: transacciones transacciones_sourceobjectid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones
    ADD CONSTRAINT transacciones_sourceobjectid_fkey FOREIGN KEY (sourceobjectid) REFERENCES public.sourceobjects(sourceobjectid);


--
-- TOC entry 4565 (class 2606 OID 21496)
-- Name: transacciones transacciones_tipotransaccionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones
    ADD CONSTRAINT transacciones_tipotransaccionid_fkey FOREIGN KEY (tipotransaccionid) REFERENCES public.tipodetransacciones(tipodetransaccionid);


--
-- TOC entry 4566 (class 2606 OID 21516)
-- Name: transacciones transacciones_transaccioncodeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones
    ADD CONSTRAINT transacciones_transaccioncodeid_fkey FOREIGN KEY (transaccioncodeid) REFERENCES public.transaccioncodes(transaccioncodeid);


--
-- TOC entry 4567 (class 2606 OID 21521)
-- Name: transacciones transacciones_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones
    ADD CONSTRAINT transacciones_userid_fkey FOREIGN KEY (userid) REFERENCES public.usuarios(usuarioid);


--
-- TOC entry 4532 (class 2606 OID 21162)
-- Name: usuarios usuarios_addressid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_addressid_fkey FOREIGN KEY (addressid) REFERENCES public.addresses(addressid);


--
-- TOC entry 4533 (class 2606 OID 21177)
-- Name: usuarioslogins usuarioslogins_deviceid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarioslogins
    ADD CONSTRAINT usuarioslogins_deviceid_fkey FOREIGN KEY (deviceid) REFERENCES public.devices(deviceid);


--
-- TOC entry 4534 (class 2606 OID 21182)
-- Name: usuarioslogins usuarioslogins_usuarioid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarioslogins
    ADD CONSTRAINT usuarioslogins_usuarioid_fkey FOREIGN KEY (usuarioid) REFERENCES public.usuarios(usuarioid);


-- Completed on 2026-05-03 19:44:21

--
-- PostgreSQL database dump complete
--

\unrestrict zwBrAUxtOovcTDRPV0VcHZv2XgDBJZSqfMgTa9fZFwQBTJSZa8VdJTBgLZVEnvv

