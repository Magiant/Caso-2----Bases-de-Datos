---------------------------------------------------------------------

Caso #2: Bases de Datos | Miércoles 7:30 - 9:20 | Viernes 7:30 - 9:20

-> Estudiante: Kenni González Blandón
-> Carné     : 2024201088
-> Semestre  : 1
-> Año       : 2026

---------------------------------------------------------------------

Caso #2 - Etheria Global & Dynamic Brands Group


- Database engine : -> PostgreSQL 18
                    -> MySQL

- Database name   : -> 
- Database context: -> 


# Tables

## Patrón de addresses
- patronaddressid serial auto-increase PK
- 

## Puertos por ciudades
- puertosporciudadid seial auto-increase PK
- puertosporciudadname varchar(40)
- patronaddressid FK
- ciudadid FK

## Aeropuertos por ciudades
- aeropuertosporciudadid serial auto-increase PK
- aeropuertosporciudadname varchar(40)
- puertosporciudadid FK
- ciudadid FK

## Couriers
- courierid serial auto-increase PK
- couriername varchar(40)
- ciudadid FK

## Currencies
- currencyid serial auto-increase PK
- currencyname varchar(20)
- paisid FK


## Currency base
- currencybaseid serial auto-increase PK
- currencyid FK


## Currency cambio
- currencychangeid serial auto-increase PK
- currencyid FK


## Currency History
- currencyhistoryid serial auto-increase PK
- exchangecurrencyhistoryid FK
- currencyhistoryestado bool
- currencyhistoryinicio timestamp
- currencyhistoryfin timestamp


## Exchage Rates
- exchagerateid serial auto-increase PK
- currencybaseid FK
- currencychangeid FK
- exchageraterate int
- inflationbase smallint
- inflationchange smallint


## Exchange currencies History
- exchangecurrencyhistoryid PK
- exchagerateid
- currencybaseid FK
- currencychangeid FK
- exchangecurrencyhistorydate timestamp
- courierid FK

## Paises
- paisid serial auto-increase PK
- paisname vrachar(20)


## Ciudades
- ciudadid serial auto-increase PK
- ciudadname varchar(30)
- paisid FK


## Products 
- productid seial auto-increase PK
- productname varchar(40)
- productcountrycode smallint
- productcategory FK
- proveedorid FK

## ProductsCategories
- productcategory serial auto-increase PK
- productcategoyname varchar(30)


## Brands
- brandid serial auto-increase PK
- brandname varchar(40)


## OrigynBrands
- origynbrand serial auto-increase PK
- brandid FK


## Proveedores
- proveedorid serial auto-increase PK
- proveedorname varchar(40)
- paisid FK
-> Información de contacto
   - proveedoremailcontacto varchar(20)
   - proveedornumerocontacto varchar(20)
   - proveedorpersonacontacto varchar(40)


## Precios por producto
- precioporproductoid serial auto-increase PK
- precioporproductovalor int
- productid FK


## Precios por producto historial
- precioporproductohistorialid serial auto-increase PK
- precioporproductoid FK
- estado boolean
- precioporproductohistorialinicio timestamp
- precioporproductohistorialfin timestamp


## Impuesto por país
