---------------------------------------------------------------------

Caso #2: Bases de Datos | Miércoles 7:30 - 9:20 | Viernes 7:30 - 9:20

-> Estudiante: Kenni González Blandón
-> Carné     : 2024201088
-> Semestre  : 1
-> Año       : 2026

---------------------------------------------------------------------

Caso #2 - Etheria Global & Dynamic Brands Group


- Database engine : -> PostgreSQL 18


- Database name   : -> GlEthe

- Database context: -> Un holding comercial que opera bajo el modelo de negocio híbrido de importación y ventas digitales de alta gama necesita un sistema que le permita modelar los datos y controlar el flujo de información que se da al manejar los registros de cada proceso de negocio que se lleva a cabo. Existen dos empresas que trabajan en este negocio, una es Etheria Global y la otra es Dynamic Brands, que cumplen roles diferentes. Se debe llevar a cabo un software de bases de datos que permita compartir información desde la base de datos de una empresa a la de la otra empresa. Es necesario llevar un registro que la trazabilidad en cada orden que se haga, así como salvar el historial de todas las entidades involucradas en el proceso de entrega del pedido. El sistema debe ser capaz de tener en cuenta los tipos de cambios en las monedas de cada país a donde se vaya a enviar el pedido así como los impuestos que aplcan sobre cada producto que se transporta.



# Tables


## Usuarios 
- usuarioid serial auto-increase 00
- usuarioname varchar(20)
- usuariofirstname varchar(20)
- usuariosecname varchar(20)
- addressid Fk
- posttime timestamp
- lastupdate timestamp
- estado boolean


## UsuariosLogins
- usuariologinid serial auto-increase PK
- usuariologinpassword varbinary(150)
- usuariologinfecha timestamp
- deviceid FK
- usuarioid FK
- posttime timestamp
- lastupdate timestamp


## Caracteristicas variables 
- caracteristicaid serial auto-increment PK
- tipodecaracteristicaid FK
- caracteristicaname varchar(40)  ||-> Guarda el nombre del type de la caracteristica, por ejemplo: Aroma - Romero
- paisid FK    -> puede o no tener pais
- caracteristicadescripcion varchar(150)


## Tipos de caracteristicas
- tipodecaracteristicaid serial auto-increment PK
- tipodecaracteristicaname varchar(30)  ||->  beneficio, aroma, ingrediente


## Carcteristica por producto
- caracteristicaxproductoid serial auto-increment PK
- productoid FK
- caracteristicaid FK
- estado boolean
- posttime timestamp


## Brands
- brandid serial auto-increment pk 
- brandname varchar(40)
- brandcreationdate TIMESTAMP
- brandupdatedate TIMESTAMP
- branddeletingdate TIMESTAMP
- userid FK
- deleted BOOLEAN


## OrigynBrands
- origynbrand serial auto-increase PK
- brandid FK
- posttime timestamp
- lastupdate timestamp
- estado boolean
- userid FK


## Paises
- paisid serial auto-increase PK
- paisname vrachar(20)
- estado boolean
- posttime timestamp


## Paises origen
- paisorigenid serial auto-increase PK
- paisid FK


## Paises destino
- paisdestinoid serial auto-increase PK
- paisid FK


## Ciudades
- ciudadid serial auto-increase PK
- ciudadname varchar(30)
- paisid FK
- posttime timestamp 
- estado boolean


## Ciudades origen
- ciudadorigenid serial auto-increment PK
- ciudadid FK
- paisid FK


## Ciudades destino
- ciudaddestinoid serial auto-increment PK
- ciudadid FK
- paisid FK


## Addresses
- addressid serial auto-increment PK
- addressinformatio varchar(200)
- location geography
- zipcode varchar(30)
- cityid FK
- estado boolean
- posttime timestamp


## Products 
- productid seial auto-increase PK
- productname varchar(40)
- productodescripcion varchar(150)
- productcategory FK
- posttime byte
- price decimal(12, 2)
- measureid FK
- estado boolean 


## ProductsCategories
- productcategory serial auto-increase PK
- productcategoyname varchar(30)


## Producto por precio
- productxpriceid serial auto-increment PK
- productid FK
- currencyid FK
- productxpricevalidfrom timestamp
- productxpricevalidto timestamp
- checksum byte
- posttime timestamp
- device varchar(20)


## Sizes
- sizeid serial auto-increment pk
- sizeunit smallint
- sizeunitmeasure varchar(20)
- sizecreationdate TIMESTAMP
- sizeupdatedate TIMESTAMP
- sizedeletingdate TIMESTAMP
- userid FK
- deleted BOOLEAN


## Proveedores
- proveedorid serial auto-increase PK
- proveedorname varchar(40)
- proveedoridfiscal varchar(20)
- addressid FK
- estado boolean
- posttime timestamp
- lastupdate timestamp


## ContactTypes
- contacttypeid serial auto-increment PK
- contacttypename varchar(20)


## ProveedoresContacts
- proveedorxcontactid serial auto-increment PK
- proveedorid FK
- contacttypeid FK
- value varchar(80)
- estado boolean
- posttime timestamp
- lastupdate timestamp


## Products por proveedores
- productoxproveedorid serial auto-increment PK
- productid FK
- proveedorid FK
- productoxproveedortime timestamp
- estado boolean


## Lotes
- loteid serial auto-increment PK
- productoxproveedorid FK
- lotenumber int
- lotequantity int
- loteamount decimnal(12, 2)
- currencybaseid FK
- lotecurrencyamount decimal(12, 2)
- exchangerateid FK
- exchangerateused decimal(12, 2)
- cheksum byte
- posttime timestamp
- lotelastupdate timestamp


## Medios de pagos
- mediodepagoid serial auto-increment PK
- mediodepagoname varchar(40)
- estado boolean
- posttime timestamp
- deviceid FK
- userid FK
- checksum byte
- mediodepagoparametros jason


## Transacciones
- transaccionid serial auto-increment PK
- tipotransaccionid FK
- monto decimal(12, 2)
- currencyid FK
- exchangerateid FK
- sourceobjectid FK
- referenceid bigint
- amountchanged decimal(12, 2)
- transaccioncode FK
- transacciondate timestamp
- estado boolean
- posttime timestamp
- userid FK
- checksum byte
- deviceid FK
- movimienyoid FK
- detalle varchar(100)


## Tipos de transacciones
- tipodetransaccionid serial auto-increment PK
- tipodetransaccionname varchar(30)


## Source Objects
- sourceobjectid serial auto-increment
- sourceobjectname varchar(30)
- estado boolean
- lastuopdate timestamp


## Codigos de transaccion
- transaccioncodeid serial auto-increment PK
- transaccioncodevalue varchar(100)
- transaccioncodedescripcion varcar(200)
- posttime timestamp
- estado boolean


## Currencies
- currencyid serial auto-increase PK
- currencyname varchar(20)
- currencysimbol varchar(10)
- paisid FK
- currencybase boolean
- estado boolean


## Exchange Rates
- exchagerateid serial auto-increase PK
- currencyid1 FK
- currencyid2 FK
- exchangeraterate decimal(12, 2)
- exchangeratefrom timestamp
- exchangerateto timestamp
- checksum byte
- posttime timestamp
- estado boolean
- iscurrent boolean


## Descuentos por productos
- descuentoporproductoid serial auto-increase PK
- descuentoporproductopercent decimal(0, 2)
- productid FK
- estado boolean
- posttime timestamp
- checksum bytea


## Impuesto por países
- impuestosporpaisid serial auto-increase PK
- productid FK
- paisid FK
- impuesto FK
- estado boolean
- posttime timestamp
- checksum bytea
- estado boolean


## Impuestos
- impuestoid serial auto-increment PK
- impuestovalue decimal (10, 2)
- impuestodescripcion varchar(200)
- posttime timestamp
- lastupdate timestamp
- userid FK
- checksum byte
- estado boolean


## Importacioes 
- importacionid serial auto-increment PK
- proveedorid FK
- paisid FK
- posttime timestamp
- totalmoney decimal(12, 2)
- descripcion varchar(300)


## Detalles de importacion 
- detalledeimportacionid serial auto-increment PK
- importacionid FK
- productoid FK
- quantity numeric(12, 2)
- preciounitario numeric(12, 2)
- subtotal numeric(12, 2)
- exchangerateid FK
- posttime timestamp
- userid FK
- checksum byte


## Logs 
- logid serial auto-increment pk
- actionid FK
- userid FK
- productquantity int
- posttime timestamp
- lastupdate timestamp


## Actions
- actionid serial auto-increment pk
- actiontypename varchar(20)


## Bulks
- bulkid serial auto-increment PK
- bulktotalprice decimal(12, 2)
- importacionid FK
- loteid FK
- sizeid FK
- userid FK
- posttime FK
- lastupdate FK
- checksum byte
- estado boolean
- notas varchar(300)


## BulksTrackings
- bulktrackingid serial auto-increment PK
- puertorigenid FK
- puertodestinoid FK
- bulktrackingsalida timestamp
- bulktrackingllegada timestamp
- userid FK
- deviceid FK
- posttime timestamp
- lastupdate timestamp
- estado boolean


## Puertos por ciudades
- puertosporciudadid seial auto-increase PK
- puertosporciudadname varchar(40)
- ciudadid FK
- puertotypeid FK
- posttime timestamp
- lastupdate timestamp
- userid FK
- estado boolean


## Puertostypes
- puertotypeid serial auto-increase PK 
- puertotypetype smallint  ||-> Puerto o aeropuerto
- posttime timestamp
- lastupdate timestamp
- estado boolean
- userid FK


## Puertos origenes 
- puertorigenid serial auto-increment PK
- puertoid FK
- posttime timestamp
- lasupdate timestamp
- useridFK
- estado boolean


## Puertos destinos 
- puertodestinoid serial auto-increment PK
- puertoid FK
- posttime timestamp
- lasupdate timestamp
- useridFK
- estado boolean


## Devices
- deviceid serial auto-increment PK
- devicename varchar(50)
- addressid FK
- devicedescripcion varchar(150)
- posttime timestamp
- lastupdate timestamp
- userid FK
- estado boolean