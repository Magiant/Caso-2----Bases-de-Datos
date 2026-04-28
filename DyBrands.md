---------------------------------------------------------------------

Caso #2: Bases de Datos | Miércoles 7:30 - 9:20 | Viernes 7:30 - 9:20

-> Estudiante: Kenni González Blandón
-> Carné     : 2024201088
-> Semestre  : 1
-> Año       : 2026

---------------------------------------------------------------------

Caso #2 - Etheria Global & Dynamic Brands Group


- Database engine : -> MySQL 97


- Database name   : -> DyBrands

- Database context: -> Un holding comercial que opera bajo el modelo de negocio híbrido de importación y ventas digitales de alta gama necesita un sistema que le permita modelar los datos y controlar el flujo de información que se da al manejar los registros de cada proceso de negocio que se lleva a cabo. Existen dos empresas que trabajan en este negocio, una es Etheria Global y la otra es Dynamic Brands, que cumplen roles diferentes. Se debe llevar a cabo un software de bases de datos que permita compartir información desde la base de datos de una empresa a la de la otra empresa. Es necesario llevar un registro que la trazabilidad en cada orden que se haga, así como salvar el historial de todas las entidades involucradas en el proceso de entrega del pedido. El sistema debe ser capaz de tener en cuenta los tipos de cambios en las monedas de cada país a donde se vaya a enviar el pedido así como los impuestos que aplcan sobre cada producto que se transporta.


# Tables 


## Addresses
- addressid serial auto-increment PK
- addressinformatio varchar(200)
- location geography
- zipcode varchar(30)
- cityid FK
- estado boolean
- posttime timestamp


## Usuarios 
- usuarioid serial auto-increase 00
- usuarioname varchar(20)
- usuariofirstname varchar(20)
- usuariosecname varchar(20)
- addressid Fk
- posttime timestamp
- lastupdate timestamp
- estado boolean


## Usuarios Logins
- usuariologinid serial auto-increase PK
- usuariologinpassword varbinary(150)
- usuariologinfecha timestamp
- deviceid FK
- usuarioid FK
- posttime timestamp
- lastupdate timestamp


## Clientes
- clienteid serial auto-increase 00
- usuarioid FK
- posttime timestamp
- lastupdate timestamp
- estado boolean


## Paises
- paisid serial auto-increase PK
- paisname vrachar(20)
- estado boolean
- posttime timestamp


## Ciudades
- ciudadid serial auto-increase PK
- ciudadname varchar(30)
- paisid FK
- posttime timestamp 
- estado boolean


## Logos 
- logoid serial auto-increase PK
- mediafileid FK
- logocreated timestamp
- posttime timestamp
- estado boolean
- checksum byte


## MediaTypes
- mediatypeid serial auto-increment PK
- mediatypename varchar(40)
- estado boolean
- posttime timestamp


## Media Files 
- mediafileid serial auto-increment PK 
- mediafilename varchar(200)
- mediatypeid FK
- mediafilesize bigint
- posttime timestamp
- checksum byte
- userid FK
- deviceid FK


## Enfoques
- enfoqueid serial auto-increase PK
- enfoquename varchar(50)
- enfoquedescripcion varchar(200)
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


## Sities
- sitieid serial auto-increment PK
- logoid FK
- enfoqueid FK
- paisid FK
- userid FK
- deviceid FK
- posttime timestamp
- estado boolean
- checksum
- lastupdate timestamp


## Sities Logs
- sitielogid serial auto-increment PK
- sitielogtypeid FK
- estado boolean
- userid FK
- checksum byte
- posttime timestamp
- closetime timestamp
- deviceid FK


## Sities Logs types 
- sitielogtypeid serial auto-increment PK
- sitielogtypename varchar(40)
- estado boolean
- posttime timestamp


## Sities configurations
- sitieconfigurationid serial auto-increment PK
- sitieid FK
- currencyid Fk
- posttime timestamp
- lasupdate timestamp
- checksum


## Catalogos 
- catalogoid serial autp-increment PK
- catalogoname varchar(40)
- brandid FK
- sitieid FK
- catalogofrom timestamp
- catalogoto timestamp
- posttime timestamp
- checksum byte
- estado boolean


## Productos por catalogos
- productoxcatalogoid serial auto-increment PK
- productoid FK
- catalogoid FK
- estado boolean
- userid FK
- deviceid FK
- posttime timestamp
- checksum byte


## Descuentos por productos
- descuentoporproductoid serial auto-increment PK
- descuento decimal(10, 2)
- productid FK
- posttime timestamp
- lastupdate timestamp
- userid FK
- checksum byte


## Impuesto por países
- impuestoporpaisid serial auto-increase PK
- productid FK
- paisid FK
- impuestoid FK
- estado boolean
- posttime timestamp
- lastupdate timestamp
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


## Descuentos por productos
- descuentoporproductoid serial auto-increase PK
- productid FK
- descuentoid FK
- estado boolean
- posttime timestamp
- lastupdate timestamp
- checksum bytea
- estado boolean


## Descuentos
- descuentoid serial auto-increment PK
- descuentovalue decimal (10, 2)
- descuentodescripcion varchar(200)
- posttime timestamp
- lastupdate timestamp
- userid FK
- checksum byte
- estado boolean


## Ordenes
- ordenid serial auto-increment PK
- paisid FK
- cityid FK
- pedidoid FK
- descuentoporproductoid FK
- impuestosporpaisid FK
- adressorigenid FK
- documentodeimportacionid FK
- userid FK
- deviceid FK
- posttime timestamp
- lastupdate timestamp
- estado boolean
- cheksum byte


## Empaque de orden
- empaqueid serial auto-increment PK
- ordenid serial auto-increment PK
- requisitolegal FK
- registrosanitario FK
- paisorigenid FK
- userid FK
- deviceid FK
- posttime timestamp
- lastupdate timestamp
- estado boolean


## Requisitos Legales
- requisitolegal serial auto-increment PK
- proveedorid FK
- certificadodeorigenid FK
- declaracionaduanera FK
- codigoarancelarioid
- userid FK
- deviceid FK
- posttime timestamp
- lastupdate timestamp
- estado boolean


## Certificados de origen
- certificadodeorigenid serial auto-increment PK
- paisid FK
- certificadodeorigenvigencia boolean
- certificadodeorigenfecha timestamp
- userid FK
- deviceid FK
- posttime timestamp
- lastupdate timestamp
- estado boolean


## Declaraciones aduaneras
- declaracionaduanera serial auto-increment PK
- declaracionaduaneracodigo varchar(30)
- paisorigenid FK
- paisdestinoid FK
- productoid FK
- codigoarancelario FK
- declaracionaduanerafecha timestamp
- userid FK
- deviceid FK
- posttime timestamp
- lastupdate timestamp
- estado boolean


## Codigos Arancelarios
- codigoarancelarioid serial auto-increment PK
- productoid FK
- codigoarancelariocode varchar(20)
- codigoarancelariodescripcion varchar(100)
- codigoarancelariopercent decimal
- impuestoporpaisid FK
- paisid FK
- codigoarancelariofecha timestamp
- userid FK
- deviceid FK
- posttime timestamp
- lastupdate timestamp
- estado boolean


## Registros sanitarios
- registrosanitario serial auto-increment PK
- productoid FK
- paisid FK
- registrosanitarioemisor varchar(40)
- registrosanitariodechaemision timestamp
- registrosanitariodechaexpiracion timestamp
- userid FK
- deviceid FK
- posttime timestamp
- lastupdate timestamp
- estado boolean


## OrderTrackings
- ordertrackingid serial auto-increment PK
- ciudadorigenid FK
- ciudaddestinoid FK
- courierid FK
- brandid FK
- ordenid FK
- orderTrackingfecha timestamp
- userid FK
- deviceid FK
- posttime timestamp
- lastupdate timestamp
- estado boolean


## Pedidos
- pedidoid serial auto-increase PK
- sitieid FK
- estado boolean
- clienteid FK   -> Ocupo hacer esto de los clientes
- userid FK
- deviceid FK
- estadodelpedido FK
- pedidofecha timestamp
- pedidoentrega timestamp
- posttime timestamp
- lastupdate timestamp
- checksum byte
- estado boolean


## Estados de pedidos 
- estadodepedidoid serial auto-increment PK
- estadodepedidoname varchar(30) -> En camino, preparando, etc
- estado boolean


## Couriers
- courierid serial auto-increase PK
- couriername varchar(40)
- ciudadid FK
- contactoid FK
- alcanceinternacional boolean
- servicioid FK
- posttime timestamp
- userid FK
- estado boolean
- lastupdate timestamp


## Servicios ofrecidos
- serviciofrid serial auto-increment PK
- serviciofrname varchar(40)
- serviciofrdescripcion varchar(200)
- courierid Fk
- estado boolen
- posttime timestamp
- lastupdate timestamp
- userid FK


## ContactTypes
- contacttypeid serial auto-increment PK
- contacttypename varchar(20)


## CouriersContacts
- courierxcontactid serial auto-increment PK
- courierid FK
- contacttypeid FK
- value varchar(80)
- estado boolean
- posttime timestamp
- lastupdate timestamp


## Ventas finales
- ventafinalid serial auto-increment PK
- pedidoid FK
- courierid FK
- mediodepago FK
- montototal decimal(12, 2)
- fechadepago timestamp
- usuarioid FK
- deviceid FK
- posttime timestamp
- lastupdate timestamp
- cheksum byte
- estado boolean


## Medios de pagos
- mediodepagoid serial auto-increment PK
- mediodepagoname varchar(40)
- estado boolean
- posttime timestamp
- deviceid FK
- userid FK
- checksum byte
- mediodepagoparametros jason


## Devivces
- deviceid serial auto-increment PK
- devicename varchar(50)
- addressid FK
- devicedescripcion varchar(150)
- posttime timestamp
- lastupdate timestamp
- userid FK
- estado boolean


