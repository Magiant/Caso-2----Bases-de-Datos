-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: dybrands
-- ------------------------------------------------------
-- Server version	9.7.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'aae3b5c6-3f8d-11f1-a540-f2c81309f09b:1-63';

--
-- Table structure for table `actions`
--

DROP TABLE IF EXISTS `actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `actions` (
  `actionid` int NOT NULL AUTO_INCREMENT,
  `actiontypename` varchar(20) NOT NULL,
  PRIMARY KEY (`actionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `addressid` int NOT NULL AUTO_INCREMENT,
  `addressinformation` varchar(200) NOT NULL,
  `location` point DEFAULT NULL,
  `zipcode` varchar(30) DEFAULT NULL,
  `ciudadid` int NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`addressid`),
  KEY `ciudadid` (`ciudadid`),
  CONSTRAINT `addresses_ibfk_1` FOREIGN KEY (`ciudadid`) REFERENCES `ciudades` (`ciudadid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catalogos`
--

DROP TABLE IF EXISTS `catalogos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catalogos` (
  `catalogoid` int NOT NULL AUTO_INCREMENT,
  `catalogoname` varchar(40) NOT NULL,
  `sitioid` int NOT NULL,
  `catalogofrom` timestamp NULL DEFAULT NULL,
  `catalogoto` timestamp NULL DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `checksum` blob,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`catalogoid`),
  KEY `sitioid` (`sitioid`),
  CONSTRAINT `catalogos_ibfk_1` FOREIGN KEY (`sitioid`) REFERENCES `sitios` (`sitioid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `certificadosorigen`
--

DROP TABLE IF EXISTS `certificadosorigen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `certificadosorigen` (
  `certificadodeorigenid` int NOT NULL AUTO_INCREMENT,
  `paisid` int NOT NULL,
  `vigente` tinyint(1) DEFAULT '1',
  `fechacertificado` timestamp NULL DEFAULT NULL,
  `usuarioid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `codigoarancelarioid` int NOT NULL,
  `quantity` decimal(10,2) DEFAULT NULL,
  `peso` decimal(10,2) DEFAULT NULL,
  `certificadoemisor` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`certificadodeorigenid`),
  KEY `paisid` (`paisid`),
  KEY `usuarioid` (`usuarioid`),
  KEY `deviceid` (`deviceid`),
  KEY `fk_certificadosorigen_codigoarancelario` (`codigoarancelarioid`),
  CONSTRAINT `certificadosorigen_ibfk_1` FOREIGN KEY (`paisid`) REFERENCES `paises` (`paisid`),
  CONSTRAINT `certificadosorigen_ibfk_2` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `certificadosorigen_ibfk_3` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`),
  CONSTRAINT `fk_certificadosorigen_codigoarancelario` FOREIGN KEY (`codigoarancelarioid`) REFERENCES `codigosarancelarios` (`codigoarancelarioid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ciudades`
--

DROP TABLE IF EXISTS `ciudades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ciudades` (
  `ciudadid` int NOT NULL AUTO_INCREMENT,
  `ciudadname` varchar(60) NOT NULL,
  `paisid` int NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ciudadid`),
  KEY `paisid` (`paisid`),
  CONSTRAINT `ciudades_ibfk_1` FOREIGN KEY (`paisid`) REFERENCES `paises` (`paisid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `clienteid` int NOT NULL AUTO_INCREMENT,
  `usuarioid` int NOT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`clienteid`),
  KEY `usuarioid` (`usuarioid`),
  CONSTRAINT `clientes_ibfk_1` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `codigosarancelarios`
--

DROP TABLE IF EXISTS `codigosarancelarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `codigosarancelarios` (
  `codigoarancelarioid` int NOT NULL AUTO_INCREMENT,
  `productid` int NOT NULL,
  `codigoarancelariopercent` decimal(10,2) DEFAULT NULL,
  `paisid` int NOT NULL,
  `codigoarancelariofecha` timestamp NULL DEFAULT NULL,
  `usuarioid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `codigoarancelariotype` int NOT NULL,
  PRIMARY KEY (`codigoarancelarioid`),
  KEY `productid` (`productid`),
  KEY `paisid` (`paisid`),
  KEY `usuarioid` (`usuarioid`),
  KEY `deviceid` (`deviceid`),
  KEY `fk_codigos_type` (`codigoarancelariotype`),
  CONSTRAINT `codigosarancelarios_ibfk_1` FOREIGN KEY (`productid`) REFERENCES `products` (`productid`),
  CONSTRAINT `codigosarancelarios_ibfk_2` FOREIGN KEY (`paisid`) REFERENCES `paises` (`paisid`),
  CONSTRAINT `codigosarancelarios_ibfk_3` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `codigosarancelarios_ibfk_4` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`),
  CONSTRAINT `fk_codigos_type` FOREIGN KEY (`codigoarancelariotype`) REFERENCES `codigosarancelariostypes` (`codigoarancelariotypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `codigosarancelariostypes`
--

DROP TABLE IF EXISTS `codigosarancelariostypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `codigosarancelariostypes` (
  `codigoarancelariotypeid` int NOT NULL AUTO_INCREMENT,
  `codigoarancelariocode` varchar(30) NOT NULL,
  `codigoarancelariodescripcion` varchar(150) NOT NULL,
  PRIMARY KEY (`codigoarancelariotypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contacttypes`
--

DROP TABLE IF EXISTS `contacttypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contacttypes` (
  `contacttypeid` int NOT NULL AUTO_INCREMENT,
  `contacttypename` varchar(20) NOT NULL,
  PRIMARY KEY (`contacttypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `couriers`
--

DROP TABLE IF EXISTS `couriers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `couriers` (
  `courierid` int NOT NULL AUTO_INCREMENT,
  `couriername` varchar(40) NOT NULL,
  `ciudadid` int DEFAULT NULL,
  `alcanceinternacional` tinyint(1) DEFAULT '0',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `usuarioid` int DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `lastupdate` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`courierid`),
  KEY `ciudadid` (`ciudadid`),
  KEY `usuarioid` (`usuarioid`),
  CONSTRAINT `couriers_ibfk_1` FOREIGN KEY (`ciudadid`) REFERENCES `ciudades` (`ciudadid`),
  CONSTRAINT `couriers_ibfk_2` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `courierscontacts`
--

DROP TABLE IF EXISTS `courierscontacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `courierscontacts` (
  `courierxcontactid` int NOT NULL AUTO_INCREMENT,
  `courierid` int NOT NULL,
  `contacttypeid` int NOT NULL,
  `contactvalue` varchar(80) NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`courierxcontactid`),
  KEY `courierid` (`courierid`),
  KEY `contacttypeid` (`contacttypeid`),
  CONSTRAINT `courierscontacts_ibfk_1` FOREIGN KEY (`courierid`) REFERENCES `couriers` (`courierid`),
  CONSTRAINT `courierscontacts_ibfk_2` FOREIGN KEY (`contacttypeid`) REFERENCES `contacttypes` (`contacttypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `currencies`
--

DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `currencies` (
  `currencyid` int NOT NULL AUTO_INCREMENT,
  `currencyname` varchar(20) NOT NULL,
  `currencysymbol` varchar(10) NOT NULL,
  `paisid` int NOT NULL,
  `currencybase` tinyint(1) DEFAULT '0',
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`currencyid`),
  KEY `paisid` (`paisid`),
  CONSTRAINT `currencies_ibfk_1` FOREIGN KEY (`paisid`) REFERENCES `paises` (`paisid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `declaracionesaduaneras`
--

DROP TABLE IF EXISTS `declaracionesaduaneras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `declaracionesaduaneras` (
  `declaracionaduaneraid` int NOT NULL AUTO_INCREMENT,
  `declaracioncodigo` varchar(30) DEFAULT NULL,
  `paisorigenid` int NOT NULL,
  `paisdestinoid` int NOT NULL,
  `productid` int NOT NULL,
  `codigoarancelarioid` int NOT NULL,
  `declaracionfecha` timestamp NULL DEFAULT NULL,
  `usuarioid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`declaracionaduaneraid`),
  KEY `paisorigenid` (`paisorigenid`),
  KEY `paisdestinoid` (`paisdestinoid`),
  KEY `productid` (`productid`),
  KEY `codigoarancelarioid` (`codigoarancelarioid`),
  KEY `usuarioid` (`usuarioid`),
  KEY `deviceid` (`deviceid`),
  CONSTRAINT `declaracionesaduaneras_ibfk_1` FOREIGN KEY (`paisorigenid`) REFERENCES `paises` (`paisid`),
  CONSTRAINT `declaracionesaduaneras_ibfk_2` FOREIGN KEY (`paisdestinoid`) REFERENCES `paises` (`paisid`),
  CONSTRAINT `declaracionesaduaneras_ibfk_3` FOREIGN KEY (`productid`) REFERENCES `products` (`productid`),
  CONSTRAINT `declaracionesaduaneras_ibfk_4` FOREIGN KEY (`codigoarancelarioid`) REFERENCES `codigosarancelarios` (`codigoarancelarioid`),
  CONSTRAINT `declaracionesaduaneras_ibfk_5` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `declaracionesaduaneras_ibfk_6` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `descuentoporproducto`
--

DROP TABLE IF EXISTS `descuentoporproducto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `descuentoporproducto` (
  `descuentoporproductoid` int NOT NULL AUTO_INCREMENT,
  `productid` int NOT NULL,
  `descuentoid` int NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `checksum` blob,
  PRIMARY KEY (`descuentoporproductoid`),
  KEY `productid` (`productid`),
  KEY `descuentoid` (`descuentoid`),
  CONSTRAINT `descuentoporproducto_ibfk_1` FOREIGN KEY (`productid`) REFERENCES `products` (`productid`),
  CONSTRAINT `descuentoporproducto_ibfk_2` FOREIGN KEY (`descuentoid`) REFERENCES `descuentos` (`descuentoid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `descuentos`
--

DROP TABLE IF EXISTS `descuentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `descuentos` (
  `descuentoid` int NOT NULL AUTO_INCREMENT,
  `descuentovalue` decimal(10,2) NOT NULL,
  `descuentodescripcion` varchar(200) DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `usuarioid` int DEFAULT NULL,
  `checksum` blob,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`descuentoid`),
  KEY `usuarioid` (`usuarioid`),
  CONSTRAINT `descuentos_ibfk_1` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `devices`
--

DROP TABLE IF EXISTS `devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `devices` (
  `deviceid` int NOT NULL AUTO_INCREMENT,
  `devicename` varchar(50) DEFAULT NULL,
  `addressid` int DEFAULT NULL,
  `devicedescription` varchar(150) DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`deviceid`),
  KEY `addressid` (`addressid`),
  CONSTRAINT `devices_ibfk_1` FOREIGN KEY (`addressid`) REFERENCES `addresses` (`addressid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `enfoques`
--

DROP TABLE IF EXISTS `enfoques`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `enfoques` (
  `enfoqueid` int NOT NULL AUTO_INCREMENT,
  `enfoquename` varchar(50) NOT NULL,
  `enfoquedescripcion` varchar(200) DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`enfoqueid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `estadosdepedidos`
--

DROP TABLE IF EXISTS `estadosdepedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estadosdepedidos` (
  `estadodepedidoid` int NOT NULL AUTO_INCREMENT,
  `estadodepedidoname` varchar(30) NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`estadodepedidoid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exchangerates`
--

DROP TABLE IF EXISTS `exchangerates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exchangerates` (
  `exchangerateid` int NOT NULL AUTO_INCREMENT,
  `currencyid1` int NOT NULL,
  `currencyid2` int NOT NULL,
  `exchangeraterate` decimal(18,6) NOT NULL,
  `exchangeratefrom` timestamp NOT NULL,
  `exchangerateto` timestamp NULL DEFAULT NULL,
  `checksum` blob,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) DEFAULT '1',
  `iscurrent` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`exchangerateid`),
  KEY `currencyid1` (`currencyid1`),
  KEY `currencyid2` (`currencyid2`),
  CONSTRAINT `exchangerates_ibfk_1` FOREIGN KEY (`currencyid1`) REFERENCES `currencies` (`currencyid`),
  CONSTRAINT `exchangerates_ibfk_2` FOREIGN KEY (`currencyid2`) REFERENCES `currencies` (`currencyid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `impuestoporpais`
--

DROP TABLE IF EXISTS `impuestoporpais`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `impuestoporpais` (
  `impuestoporpaisid` int NOT NULL AUTO_INCREMENT,
  `productid` int NOT NULL,
  `paisid` int NOT NULL,
  `impuestoid` int NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `checksum` blob,
  PRIMARY KEY (`impuestoporpaisid`),
  KEY `productid` (`productid`),
  KEY `paisid` (`paisid`),
  KEY `impuestoid` (`impuestoid`),
  CONSTRAINT `impuestoporpais_ibfk_1` FOREIGN KEY (`productid`) REFERENCES `products` (`productid`),
  CONSTRAINT `impuestoporpais_ibfk_2` FOREIGN KEY (`paisid`) REFERENCES `paises` (`paisid`),
  CONSTRAINT `impuestoporpais_ibfk_3` FOREIGN KEY (`impuestoid`) REFERENCES `impuestos` (`impuestoid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `impuestos`
--

DROP TABLE IF EXISTS `impuestos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `impuestos` (
  `impuestoid` int NOT NULL AUTO_INCREMENT,
  `impuestovalue` decimal(10,2) NOT NULL,
  `impuestodescripcion` varchar(200) DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `usuarioid` int DEFAULT NULL,
  `checksum` blob,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`impuestoid`),
  KEY `usuarioid` (`usuarioid`),
  CONSTRAINT `impuestos_ibfk_1` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `logos`
--

DROP TABLE IF EXISTS `logos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logos` (
  `logoid` int NOT NULL AUTO_INCREMENT,
  `mediafileid` int NOT NULL,
  `logocreated` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) DEFAULT '1',
  `checksum` blob,
  PRIMARY KEY (`logoid`),
  KEY `mediafileid` (`mediafileid`),
  CONSTRAINT `logos_ibfk_1` FOREIGN KEY (`mediafileid`) REFERENCES `mediafiles` (`mediafileid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logs` (
  `logid` int NOT NULL AUTO_INCREMENT,
  `productid` int DEFAULT NULL,
  `actionid` int DEFAULT NULL,
  `userid` int DEFAULT NULL,
  `productquantity` int DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`logid`),
  KEY `fk_logs_product` (`productid`),
  KEY `fk_logs_action` (`actionid`),
  KEY `fk_logs_usuario` (`userid`),
  CONSTRAINT `fk_logs_action` FOREIGN KEY (`actionid`) REFERENCES `actions` (`actionid`),
  CONSTRAINT `fk_logs_product` FOREIGN KEY (`productid`) REFERENCES `products` (`productid`),
  CONSTRAINT `fk_logs_usuario` FOREIGN KEY (`userid`) REFERENCES `usuarios` (`usuarioid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mediafiles`
--

DROP TABLE IF EXISTS `mediafiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mediafiles` (
  `mediafileid` int NOT NULL AUTO_INCREMENT,
  `mediafilename` varchar(200) NOT NULL,
  `mediatypeid` int NOT NULL,
  `mediafilesize` bigint DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `checksum` blob,
  `usuarioid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  PRIMARY KEY (`mediafileid`),
  KEY `mediatypeid` (`mediatypeid`),
  KEY `usuarioid` (`usuarioid`),
  KEY `deviceid` (`deviceid`),
  CONSTRAINT `mediafiles_ibfk_1` FOREIGN KEY (`mediatypeid`) REFERENCES `mediatypes` (`mediatypeid`),
  CONSTRAINT `mediafiles_ibfk_2` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `mediafiles_ibfk_3` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mediatypes`
--

DROP TABLE IF EXISTS `mediatypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mediatypes` (
  `mediatypeid` int NOT NULL AUTO_INCREMENT,
  `mediatypename` varchar(40) NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`mediatypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mediospago`
--

DROP TABLE IF EXISTS `mediospago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mediospago` (
  `mediodepagoid` int NOT NULL AUTO_INCREMENT,
  `mediodepagoname` varchar(40) NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `deviceid` int DEFAULT NULL,
  `usuarioid` int DEFAULT NULL,
  `checksum` blob,
  `mediodepagoparametros` json DEFAULT NULL,
  PRIMARY KEY (`mediodepagoid`),
  KEY `deviceid` (`deviceid`),
  KEY `usuarioid` (`usuarioid`),
  CONSTRAINT `mediospago_ibfk_1` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`),
  CONSTRAINT `mediospago_ibfk_2` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ordenes`
--

DROP TABLE IF EXISTS `ordenes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ordenes` (
  `ordenid` bigint unsigned NOT NULL AUTO_INCREMENT,
  `paisid` int DEFAULT NULL,
  `cityid` int DEFAULT NULL,
  `pedidoid` int DEFAULT NULL,
  `descuentoporproductoid` int DEFAULT NULL,
  `impuestoporpaisid` int DEFAULT NULL,
  `adressorigenid` int DEFAULT NULL,
  `requisitolegalid` int DEFAULT NULL,
  `userid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) DEFAULT '1',
  `cheksum` blob,
  PRIMARY KEY (`ordenid`),
  UNIQUE KEY `ordenid` (`ordenid`),
  KEY `paisid` (`paisid`),
  KEY `cityid` (`cityid`),
  KEY `pedidoid` (`pedidoid`),
  KEY `descuentoporproductoid` (`descuentoporproductoid`),
  KEY `impuestoporpaisid` (`impuestoporpaisid`),
  KEY `adressorigenid` (`adressorigenid`),
  KEY `requisitolegalid` (`requisitolegalid`),
  KEY `userid` (`userid`),
  KEY `deviceid` (`deviceid`),
  CONSTRAINT `ordenes_ibfk_1` FOREIGN KEY (`paisid`) REFERENCES `paises` (`paisid`),
  CONSTRAINT `ordenes_ibfk_2` FOREIGN KEY (`cityid`) REFERENCES `ciudades` (`ciudadid`),
  CONSTRAINT `ordenes_ibfk_3` FOREIGN KEY (`pedidoid`) REFERENCES `pedidos` (`pedidoid`),
  CONSTRAINT `ordenes_ibfk_4` FOREIGN KEY (`descuentoporproductoid`) REFERENCES `descuentoporproducto` (`descuentoporproductoid`),
  CONSTRAINT `ordenes_ibfk_5` FOREIGN KEY (`impuestoporpaisid`) REFERENCES `impuestoporpais` (`impuestoporpaisid`),
  CONSTRAINT `ordenes_ibfk_6` FOREIGN KEY (`adressorigenid`) REFERENCES `addresses` (`addressid`),
  CONSTRAINT `ordenes_ibfk_7` FOREIGN KEY (`requisitolegalid`) REFERENCES `requisitoslegales` (`requisitolegalid`),
  CONSTRAINT `ordenes_ibfk_8` FOREIGN KEY (`userid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `ordenes_ibfk_9` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ordertrackings`
--

DROP TABLE IF EXISTS `ordertrackings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ordertrackings` (
  `ordertrackingid` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ciudadorigenid` int DEFAULT NULL,
  `ciudaddestinoid` int DEFAULT NULL,
  `courierid` int DEFAULT NULL,
  `ordenid` bigint unsigned DEFAULT NULL,
  `orderTrackingfecha` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `userid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) DEFAULT '1',
  `orderTrackingdescription` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`ordertrackingid`),
  UNIQUE KEY `ordertrackingid` (`ordertrackingid`),
  KEY `ciudadorigenid` (`ciudadorigenid`),
  KEY `ciudaddestinoid` (`ciudaddestinoid`),
  KEY `courierid` (`courierid`),
  KEY `ordenid` (`ordenid`),
  KEY `userid` (`userid`),
  KEY `deviceid` (`deviceid`),
  CONSTRAINT `ordertrackings_ibfk_1` FOREIGN KEY (`ciudadorigenid`) REFERENCES `ciudades` (`ciudadid`),
  CONSTRAINT `ordertrackings_ibfk_2` FOREIGN KEY (`ciudaddestinoid`) REFERENCES `ciudades` (`ciudadid`),
  CONSTRAINT `ordertrackings_ibfk_3` FOREIGN KEY (`courierid`) REFERENCES `couriers` (`courierid`),
  CONSTRAINT `ordertrackings_ibfk_4` FOREIGN KEY (`ordenid`) REFERENCES `ordenes` (`ordenid`),
  CONSTRAINT `ordertrackings_ibfk_5` FOREIGN KEY (`userid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `ordertrackings_ibfk_6` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `paises`
--

DROP TABLE IF EXISTS `paises`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paises` (
  `paisid` int NOT NULL AUTO_INCREMENT,
  `paisname` varchar(50) NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`paisid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedidos` (
  `pedidoid` int NOT NULL AUTO_INCREMENT,
  `clienteid` int NOT NULL,
  `pedidofecha` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `pedidoentrega` timestamp NULL DEFAULT NULL,
  `usuarioid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  `checksum` blob,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `estadodepedidoid` int DEFAULT NULL,
  PRIMARY KEY (`pedidoid`),
  KEY `clienteid` (`clienteid`),
  KEY `usuarioid` (`usuarioid`),
  KEY `deviceid` (`deviceid`),
  KEY `estadodepedidoid` (`estadodepedidoid`),
  CONSTRAINT `pedidos_ibfk_1` FOREIGN KEY (`clienteid`) REFERENCES `clientes` (`clienteid`),
  CONSTRAINT `pedidos_ibfk_2` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `pedidos_ibfk_3` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`),
  CONSTRAINT `pedidos_ibfk_4` FOREIGN KEY (`estadodepedidoid`) REFERENCES `estadosdepedidos` (`estadodepedidoid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `productcategories`
--

DROP TABLE IF EXISTS `productcategories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productcategories` (
  `productcategoryid` int NOT NULL AUTO_INCREMENT,
  `productcategoryname` varchar(30) NOT NULL,
  PRIMARY KEY (`productcategoryid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `productoporcatalogo`
--

DROP TABLE IF EXISTS `productoporcatalogo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productoporcatalogo` (
  `productoxcatalogoid` int NOT NULL AUTO_INCREMENT,
  `productid` int NOT NULL,
  `catalogoid` int NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `usuarioid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `checksum` blob,
  PRIMARY KEY (`productoxcatalogoid`),
  KEY `productid` (`productid`),
  KEY `catalogoid` (`catalogoid`),
  KEY `usuarioid` (`usuarioid`),
  KEY `deviceid` (`deviceid`),
  CONSTRAINT `productoporcatalogo_ibfk_1` FOREIGN KEY (`productid`) REFERENCES `products` (`productid`),
  CONSTRAINT `productoporcatalogo_ibfk_2` FOREIGN KEY (`catalogoid`) REFERENCES `catalogos` (`catalogoid`),
  CONSTRAINT `productoporcatalogo_ibfk_3` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `productoporcatalogo_ibfk_4` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `productoporprecio`
--

DROP TABLE IF EXISTS `productoporprecio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productoporprecio` (
  `productxpriceid` int NOT NULL AUTO_INCREMENT,
  `productid` int NOT NULL,
  `currencyid` int DEFAULT NULL,
  `price` decimal(12,2) NOT NULL,
  `validfrom` timestamp NULL DEFAULT NULL,
  `validto` timestamp NULL DEFAULT NULL,
  `checksum` blob,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `device` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`productxpriceid`),
  KEY `currencyid` (`currencyid`),
  KEY `productid` (`productid`),
  CONSTRAINT `productoporprecio_ibfk_1` FOREIGN KEY (`currencyid`) REFERENCES `currencies` (`currencyid`),
  CONSTRAINT `productoporprecio_ibfk_2` FOREIGN KEY (`productid`) REFERENCES `products` (`productid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `productid` int NOT NULL AUTO_INCREMENT,
  `productname` varchar(40) NOT NULL,
  `productdescription` varchar(150) DEFAULT NULL,
  `productcategoryid` int DEFAULT NULL,
  `price` decimal(12,2) DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`productid`),
  KEY `productcategoryid` (`productcategoryid`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`productcategoryid`) REFERENCES `productcategories` (`productcategoryid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `registrossanitarios`
--

DROP TABLE IF EXISTS `registrossanitarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `registrossanitarios` (
  `registrosanitarioid` int NOT NULL AUTO_INCREMENT,
  `productid` int NOT NULL,
  `paisid` int NOT NULL,
  `emisor` varchar(40) DEFAULT NULL,
  `fechaemision` timestamp NULL DEFAULT NULL,
  `fechaexpiracion` timestamp NULL DEFAULT NULL,
  `usuarioid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `registrosanitariotypeid` int NOT NULL,
  PRIMARY KEY (`registrosanitarioid`),
  KEY `productid` (`productid`),
  KEY `paisid` (`paisid`),
  KEY `usuarioid` (`usuarioid`),
  KEY `deviceid` (`deviceid`),
  KEY `fk_registrossanitarios_registrosanitariotype` (`registrosanitariotypeid`),
  CONSTRAINT `fk_registrossanitarios_registrosanitariotype` FOREIGN KEY (`registrosanitariotypeid`) REFERENCES `registrossanitariostypes` (`registrosanitariotypeid`),
  CONSTRAINT `registrossanitarios_ibfk_1` FOREIGN KEY (`productid`) REFERENCES `products` (`productid`),
  CONSTRAINT `registrossanitarios_ibfk_2` FOREIGN KEY (`paisid`) REFERENCES `paises` (`paisid`),
  CONSTRAINT `registrossanitarios_ibfk_3` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `registrossanitarios_ibfk_4` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `registrossanitariostypes`
--

DROP TABLE IF EXISTS `registrossanitariostypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `registrossanitariostypes` (
  `registrosanitariotypeid` int NOT NULL AUTO_INCREMENT,
  `registrosanitariotypecode` varchar(60) NOT NULL,
  `registrosanitariotypedescription` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`registrosanitariotypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `requisitoslegales`
--

DROP TABLE IF EXISTS `requisitoslegales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `requisitoslegales` (
  `requisitolegalid` int NOT NULL AUTO_INCREMENT,
  `certificadodeorigenid` int DEFAULT NULL,
  `declaracionaduaneraid` int DEFAULT NULL,
  `codigoarancelarioid` int DEFAULT NULL,
  `usuarioid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`requisitolegalid`),
  KEY `certificadodeorigenid` (`certificadodeorigenid`),
  KEY `declaracionaduaneraid` (`declaracionaduaneraid`),
  KEY `codigoarancelarioid` (`codigoarancelarioid`),
  KEY `usuarioid` (`usuarioid`),
  KEY `deviceid` (`deviceid`),
  CONSTRAINT `requisitoslegales_ibfk_1` FOREIGN KEY (`certificadodeorigenid`) REFERENCES `certificadosorigen` (`certificadodeorigenid`),
  CONSTRAINT `requisitoslegales_ibfk_2` FOREIGN KEY (`declaracionaduaneraid`) REFERENCES `declaracionesaduaneras` (`declaracionaduaneraid`),
  CONSTRAINT `requisitoslegales_ibfk_3` FOREIGN KEY (`codigoarancelarioid`) REFERENCES `codigosarancelarios` (`codigoarancelarioid`),
  CONSTRAINT `requisitoslegales_ibfk_4` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `requisitoslegales_ibfk_5` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `serviciosofrecidos`
--

DROP TABLE IF EXISTS `serviciosofrecidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `serviciosofrecidos` (
  `servicioid` int NOT NULL AUTO_INCREMENT,
  `courierid` int NOT NULL,
  `servicioname` varchar(40) NOT NULL,
  `serviciodescripcion` varchar(200) DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `usuarioid` int DEFAULT NULL,
  PRIMARY KEY (`servicioid`),
  KEY `courierid` (`courierid`),
  KEY `usuarioid` (`usuarioid`),
  CONSTRAINT `serviciosofrecidos_ibfk_1` FOREIGN KEY (`courierid`) REFERENCES `couriers` (`courierid`),
  CONSTRAINT `serviciosofrecidos_ibfk_2` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sitios`
--

DROP TABLE IF EXISTS `sitios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sitios` (
  `sitioid` int NOT NULL AUTO_INCREMENT,
  `logoid` int DEFAULT NULL,
  `paisid` int DEFAULT NULL,
  `usuarioid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `checksum` blob,
  `enfoqueid` int DEFAULT NULL,
  `currency_1` int NOT NULL,
  `currency_2` int NOT NULL,
  `exchangerateid` int NOT NULL,
  PRIMARY KEY (`sitioid`),
  KEY `logoid` (`logoid`),
  KEY `paisid` (`paisid`),
  KEY `usuarioid` (`usuarioid`),
  KEY `deviceid` (`deviceid`),
  KEY `enfoqueid` (`enfoqueid`),
  KEY `fk_sitios_currency1` (`currency_1`),
  KEY `fk_sitios_currency2` (`currency_2`),
  KEY `fk_sitios_exchangerates` (`exchangerateid`),
  CONSTRAINT `fk_sitios_currency1` FOREIGN KEY (`currency_1`) REFERENCES `currencies` (`currencyid`),
  CONSTRAINT `fk_sitios_currency2` FOREIGN KEY (`currency_2`) REFERENCES `currencies` (`currencyid`),
  CONSTRAINT `fk_sitios_exchangerates` FOREIGN KEY (`exchangerateid`) REFERENCES `exchangerates` (`exchangerateid`),
  CONSTRAINT `sitios_ibfk_1` FOREIGN KEY (`logoid`) REFERENCES `logos` (`logoid`),
  CONSTRAINT `sitios_ibfk_2` FOREIGN KEY (`paisid`) REFERENCES `paises` (`paisid`),
  CONSTRAINT `sitios_ibfk_3` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `sitios_ibfk_4` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`),
  CONSTRAINT `sitios_ibfk_5` FOREIGN KEY (`enfoqueid`) REFERENCES `enfoques` (`enfoqueid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sitioslogs`
--

DROP TABLE IF EXISTS `sitioslogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sitioslogs` (
  `sitiologid` int NOT NULL AUTO_INCREMENT,
  `sitioid` int NOT NULL,
  `sitiologtypeid` int NOT NULL,
  `usuarioid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  `checksum` blob,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `closetime` timestamp NULL DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`sitiologid`),
  KEY `sitioid` (`sitioid`),
  KEY `sitiologtypeid` (`sitiologtypeid`),
  KEY `usuarioid` (`usuarioid`),
  KEY `deviceid` (`deviceid`),
  CONSTRAINT `sitioslogs_ibfk_1` FOREIGN KEY (`sitioid`) REFERENCES `sitios` (`sitioid`),
  CONSTRAINT `sitioslogs_ibfk_2` FOREIGN KEY (`sitiologtypeid`) REFERENCES `sitioslogtypes` (`sitiologtypeid`),
  CONSTRAINT `sitioslogs_ibfk_3` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `sitioslogs_ibfk_4` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sitioslogtypes`
--

DROP TABLE IF EXISTS `sitioslogtypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sitioslogtypes` (
  `sitiologtypeid` int NOT NULL AUTO_INCREMENT,
  `sitiologtypename` varchar(40) NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sitiologtypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `usuarioid` int NOT NULL AUTO_INCREMENT,
  `usuarioname` varchar(20) NOT NULL,
  `usuariofirstname` varchar(20) DEFAULT NULL,
  `usuariosecname` varchar(20) DEFAULT NULL,
  `addressid` int DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`usuarioid`),
  KEY `addressid` (`addressid`),
  CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`addressid`) REFERENCES `addresses` (`addressid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usuarioslogins`
--

DROP TABLE IF EXISTS `usuarioslogins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarioslogins` (
  `usuariologinid` int NOT NULL AUTO_INCREMENT,
  `usuariologinpassword` varbinary(150) NOT NULL,
  `usuariologinfecha` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `deviceid` int DEFAULT NULL,
  `usuarioid` int NOT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`usuariologinid`),
  KEY `deviceid` (`deviceid`),
  KEY `usuarioid` (`usuarioid`),
  CONSTRAINT `usuarioslogins_ibfk_1` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`),
  CONSTRAINT `usuarioslogins_ibfk_2` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ventasfinales`
--

DROP TABLE IF EXISTS `ventasfinales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ventasfinales` (
  `ventafinalid` int NOT NULL AUTO_INCREMENT,
  `pedidoid` int NOT NULL,
  `courierid` int DEFAULT NULL,
  `mediodepagoid` int DEFAULT NULL,
  `montototal` decimal(12,2) NOT NULL,
  `fechadepago` timestamp NULL DEFAULT NULL,
  `usuarioid` int DEFAULT NULL,
  `deviceid` int DEFAULT NULL,
  `posttime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `lastupdate` timestamp NULL DEFAULT NULL,
  `checksum` blob,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`ventafinalid`),
  KEY `pedidoid` (`pedidoid`),
  KEY `courierid` (`courierid`),
  KEY `mediodepagoid` (`mediodepagoid`),
  KEY `usuarioid` (`usuarioid`),
  KEY `deviceid` (`deviceid`),
  CONSTRAINT `ventasfinales_ibfk_1` FOREIGN KEY (`pedidoid`) REFERENCES `pedidos` (`pedidoid`),
  CONSTRAINT `ventasfinales_ibfk_2` FOREIGN KEY (`courierid`) REFERENCES `couriers` (`courierid`),
  CONSTRAINT `ventasfinales_ibfk_3` FOREIGN KEY (`mediodepagoid`) REFERENCES `mediospago` (`mediodepagoid`),
  CONSTRAINT `ventasfinales_ibfk_4` FOREIGN KEY (`usuarioid`) REFERENCES `usuarios` (`usuarioid`),
  CONSTRAINT `ventasfinales_ibfk_5` FOREIGN KEY (`deviceid`) REFERENCES `devices` (`deviceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-03 21:03:21
