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

- Database name   : -> EGloBrands
- Database context: -> 



# Tables


## Patrón de addresses
- patronaddressid serial auto-increase PK
- ciudadid FK
- paisid FK
- adressorigenid FK
- adressdestinoid FK


## Adresses origenes
- adressorigenid serial auto-increment PK
- puertotypeid


## Adresses destinos
- adressdestinoid serial auto-increment PK
- puertotypeid


## Ciudades origen
- ciudadorigenid serial auto-increment PK
- ciudadid FK
- paisid FK


## Ciudades destino
- ciudaddestinoid serial auto-increment PK
- ciudadid FK
- paisid FK


## Puertos por ciudades
- puertosporciudadid seial auto-increase PK
- puertosporciudadname varchar(40)
- ciudadid FK
- puertotypeid FK


## Aeropuertos por ciudades
- aeropuertosporciudadid serial auto-increase PK
- aeropuertosporciudadname varchar(40)
- ciudadid FK
- puertotypeid FK


## Puertostypes
- puertotypeid serial auto-increase PK 
- puertotypetype smallint  ||-> Puerto o Aeropuerto


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


## Product Prices
- productpriceid serial auto-increment PK
- productpriceprice integer
- productid FK


## Product prices histories
- productpricehistoryid serial auto-increment FK
- productpriceid FK
- productpricehistoryvigentfrom timestamp
- productpricehistoryvigentto timestamp
- estado boolean


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


## Descuentos por productos
- descuentoporproductoid serial auto-increment PK
- descuentoporproductopercent smallint
- productid FK


## Descuentos por producto historiales
- descuentoproductohistorialid serial auto-incease PK
- descuentoporproductoid FK
- descuentoproductohistorialfrom timestamp
- descuentoproductohistorialto timestamp
- estado boolean

## Impuesto por países
- impuestosporpaisid serial auto-increase PK
- productid FK
- paisid FK


## Historial de impuestos
- historialdeimpuestoid serial auto-increase PK
- impuestosporpaisid FK
- historialdeimpuestoinicio timestamp
- historialdeimpuestofin timestamp
- estado boolean


## Ordenes
- ordenid serial auto-increment PK
- paidid FK
- cityid FK
- ordennumerodepedido int
- descuentoporproductoid FK
- impuestosporpaisid FK
- adressorigenid FK
- documentodeimportacionid FK


## OrderTrackings
- ordertrackingid serial auto-increment PK
- ciudadorigenid FK
- ciudaddestinoid FK
- courierid FK
- ordertrackingfechapedido timestamp
- ordertrackingfechaentrega timestamp
- estado boolean


## Listas de productos
- listadeproductoid serial auto-increment PK
- ordenid FK
- productid FK
- precioporproductoid FK
- listadeproductocantidad int


