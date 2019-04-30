-- phpMyAdmin SQL Dump
-- version 4.8.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 01-02-2019 a las 22:24:14
-- Versión del servidor: 10.1.34-MariaDB
-- Versión de PHP: 7.2.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

drop database if exists deloitte_mensajeria;
create database if not exists deloitte_mensajeria;

use deloitte_mensajeria;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `deloitte_mensajeria`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarDetalle` (IN `idDetalle` INT, IN `idStatus` INT, IN `obs` TEXT, IN `idMensajero` INT)  begin
	if idMensajero is null then
		set idMensajero = (select codigoMensajero from detalleEnvio where codigoDetalleEnvio = idDetalle);
	end if;


    if idStatus <> 5 and idStatus <> 1 then
        update detalleEnvio 
        set codigoStatus = idStatus, observacion = obs, fechaRevision = curdate(), horaRevision = DATE_FORMAT(NOW(), "%H:%i:%s" ), codigoMensajero = idMensajero
        where codigoDetalleEnvio = idDetalle;
    elseif idStatus = 1 then  
        update detalleEnvio 
        set codigoStatus = idStatus, observacion = obs, fechaRegistro = curdate(), codigoMensajero = idMensajero
        where codigoDetalleEnvio = idDetalle;
    elseif idStatus = 5 then  
        update detalleEnvio 
        set codigoStatus = idStatus, observacion = obs, fechaRevision = curdate(), fechaEnviado = curdate(), codigoMensajero = idMensajero
        where codigoDetalleEnvio = idDetalle;
    end if;
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarFecha` (IN `idEnvio` INT)  begin

    update envio set estado = 1, fecha = curdate() where codigoEnvio = idEnvio;
    
    update detalleEnvio set fechaRegistro = curdate() where codigoEnvio = idEnvio;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `clientesConMasEnvios` ()  begin
select count(c.codigoCliente) as Cliente, c.nombreCliente  from detalleEnvio d
inner join clientes c on c.codigoCliente = d.codigoCliente
inner join envio e on e.codigoEnvio = d.codigoEnvio
 where e.fecha between (SELECT date_add(CURDATE(), INTERVAL -7 DAY)) and CURDATE() group by c.nombreCliente;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `clientes_Usuario` (IN `idUsuario` INT)  begin
select count(c.codigoCliente) as Cliente, c.nombreCliente  from detalleEnvio d
inner join clientes c on c.codigoCliente = d.codigoCliente
inner join envio e on e.codigoEnvio = d.codigoEnvio
where e.codigoUsuario=idUsuario and e.fecha between (SELECT date_add(CURDATE(), INTERVAL -31 DAY)) and CURDATE()
group by c.nombreCliente;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `contarDocumentosPendientes` (IN `idUsuario` INT)  begin
	select count(d.codigoDetalleEnvio) as numero
    from envio e, detalleEnvio d
    where (s.codigoStatus = 4 or s.codigoStatus = 2) and e.codigoUsuario = idUsuario;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cuentasAdministrador` ()  begin
	select u.*, r.descRol, a.descAuth, ar.descArea
	from usuario u
	inner join rol r on r.codigoRol = u.codigoRol
	inner join authUsuario a on a.codigoAuth = u.codigoAuth
    inner join area ar on ar.codigoArea = u.codigoArea
    where u.idEliminado=1 and r.descRol = 'Administrador';
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `datosNomUsuario` (IN `nom` VARCHAR(50))  begin
	select u.*, r.descRol
    from usuario u
    inner join rol r on r.codigoRol = u.codigoRol
    where u.nomUsuario = nom;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `detallesEnvio` (IN `idEnvio` INT)  begin
	select e.codigoEnvio, e.correlativoEnvio, d.codigoDetalleEnvio, d.correlativoDetalle, u.nomUsuario, e.fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion, m.nombre as mensajero
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join mensajero m on m.codigoMensajero = d.codigoMensajero
    inner join status s on s.codigoStatus = d.codigoStatus
    
    where (s.codigoStatus = 1 or s.codigoStatus = 3) and e.codigoEnvio = idEnvio
    
    order by d.codigoDetalleEnvio desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `detallesEnvioH` (IN `idEnvio` INT)  begin
	select e.codigoEnvio, d.codigoDetalleEnvio, d.correlativoDetalle, u.nomUsuario, e.fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion, m.nombre as mensajero
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join mensajero m on m.codigoMensajero = d.codigoMensajero
    inner join status s on s.codigoStatus = d.codigoStatus
    
    where e.codigoEnvio = idEnvio
    
    order by d.codigoDetalleEnvio desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `detallesEnvioLabel` (IN `idEnvio` INT)  begin
	select e.codigoEnvio, d.codigoDetalleEnvio,s.descStatus
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join status s on s.codigoStatus = d.codigoStatus
    
    where e.codigoEnvio = idEnvio
    
    order by d.codigoDetalleEnvio desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `editarArea` (IN `nom` VARCHAR(50), IN `idArea` INT)  begin
	update area
    set descArea = nom
    where codigoArea = idArea;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `editarCliente` (IN `nom` VARCHAR(128), IN `cod` VARCHAR(50), IN `ca` VARCHAR(256), IN `pob` VARCHAR(75), IN `idCliente` INT)  begin
	update clientes
    set nombreCliente = nom, calle = ca, poblacion = pob, codigo = cod
    where codigoCliente = idCliente;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `editarDocumento` (IN `nom` VARCHAR(50), IN `idDocumento` INT)  begin
	update tipoDocumento
    set descTipoDocumento = nom
    where codigoTipoDocumento = idDocumento;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `editarMensajero` (IN `nom` VARCHAR(50), IN `idMensajero` INT)  begin
	update mensajero
    set nombre = nom
    where codigoMensajero = idMensajero;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `editarUsuario` (IN `nom` VARCHAR(50), IN `ape` VARCHAR(50), IN `us` VARCHAR(50), IN `correo` VARCHAR(75), IN `rol` INT, IN `idArea` INT, IN `idUser` INT)  begin
	update usuario
    set nombre = nom, apellido = ape, nomUsuario = us, email = correo, codigoRol = rol, codigoArea = idArea
    where codigoUsuario = idUser;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `encabezadoEnvio` (IN `usuario` INT)  begin
	declare idAnterior int;
	declare horaActual time;
    declare horaPredefinida time;
    set idAnterior = (select max(codigoEnvio) from envio) + 1;
    set horaActual = cast(date_format(now(), "%H:%i:%s") as time);
    set horaPredefinida = cast('13:00:00' as time);
    
	if horaActual > horaPredefinida then 
		insert into envio values(null, concat('ED', idAnterior), usuario, curdate(), DATE_FORMAT(NOW(), "%H:%i:%s" ), 2); 
	else 
		insert into envio values(null, concat('ED', idAnterior), usuario, curdate(), DATE_FORMAT(NOW(), "%H:%i:%s" ), 1);    
	end if;
        
    select max(codigoEnvio) as codigoEnvio from envio;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `enviosPendientes` ()  begin
	select e.codigoEnvio, e.correlativoEnvio, d.codigoDetalleEnvio, d.correlativoEnvio, u.nomUsuario, e.fecha, e.hora, tt.descTipoTramite, c.nombreCliente, tc.descTipoDocumento, a.descArea, s.descStatus, d.monto, d.observacion
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join status s on s.codigoStatus = d.codigoStatus
    
    where s.codigoStatus = 1
    
    order by d.codigoDetalleEnvio desc;
    
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getEncabezadoEnvio` (IN `idEnvio` INT)  begin
	select e.codigoEnvio, e.correlativoEnvio, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, u.nomUsuario, u.codigoUsuario, u.nombre, u.apellido, e.estado
    from envio e
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
    where e.codigoEnvio = idEnvio;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `historialEnvios` ()  begin
	select Distinct(e.codigoEnvio), e.correlativoEnvio, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, u.nomUsuario, u.nombre, u.apellido from envio e
	inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join detalleEnvio d on e.codigoEnvio = d.codigoEnvio;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `user` VARCHAR(50), IN `contra` VARCHAR(75))  begin
	select u.*, r.descRol, a.descAuth, ar.descArea
	from usuario u
	inner join rol r on r.codigoRol = u.codigoRol
	inner join authUsuario a on a.codigoAuth = u.codigoAuth
    inner join area ar on ar.codigoArea = u.codigoArea
    where u.nomUsuario = user and u.pass = contra;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `misDocumentosPendientes` (IN `idUsuario` INT)  begin
	select e.codigoEnvio, d.codigoDetalleEnvio, d.correlativoDetalle, u.nomUsuario, e.fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion, d.codigoMensajero, m.nombre as mensajero
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea
    inner join mensajero m on m.codigoMensajero = d.codigoMensajero
    inner join status s on s.codigoStatus = d.codigoStatus
    
    where (s.codigoStatus = 4 or s.codigoStatus = 2) and e.codigoUsuario = idUsuario
    
    order by d.codigoDetalleEnvio desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `misEnvios` (IN `idUsuario` INT)  begin
	select Distinct(e.codigoEnvio), e.correlativoEnvio, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora
    from envio e		
	inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join detalleEnvio d on e.codigoEnvio = d.codigoEnvio
	where u.codigoUsuario = idUsuario
    order by e.codigoEnvio desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mostrarArea` ()  begin
	select * from area where idEliminado=1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mostrarClientes` ()  begin
	select * from clientes where idEliminado=1
    order by nombreCliente;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mostrarDocumentos` ()  begin
	select * from tipoDocumento where idEliminado=1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mostrarMensajeros` ()  begin
	select * from mensajero where idEliminado=1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mostrarPaquetes` ()  begin
	select Distinct(e.codigoEnvio), e.correlativoEnvio, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, u.nomUsuario, u.codigoUsuario, u.nombre, u.apellido from envio e
	inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join detalleEnvio d on e.codigoEnvio = d.codigoEnvio
	where e.estado = 1
    order by e.codigoEnvio desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mostrarPaquetesManana` ()  begin
	select Distinct(e.codigoEnvio), e.correlativoEnvio, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, u.nomUsuario, u.codigoUsuario, u.nombre, u.apellido from envio e
	inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join detalleEnvio d on e.codigoEnvio = d.codigoEnvio
	where e.estado = 2
    order by e.codigoEnvio desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mostrarUsuarios` ()  begin
	select u.*, r.descRol, a.descAuth, ar.descArea
	from usuario u
	inner join rol r on r.codigoRol = u.codigoRol
	inner join authUsuario a on a.codigoAuth = u.codigoAuth
    inner join area ar on ar.codigoArea = u.codigoArea
    where u.idEliminado=1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `numeroDocumentosPendientes` (IN `idUsuario` INT)  begin

	select count(d.codigoDetalleEnvio) as numero
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea
    inner join mensajero m on m.codigoMensajero = d.codigoMensajero
    inner join status s on s.codigoStatus = d.codigoStatus
    
    where (s.codigoStatus = 4 or s.codigoStatus = 2) and e.codigoUsuario = idUsuario;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `paquetesDiaSiguiente` ()  begin

	declare numeroPaquetes int;
    set numeroPaquetes = (select count(codigoEnvio) from envio where estado = 2 and fecha < curdate());
    
    if numeroPaquetes >= 1 then 
		select codigoEnvio from envio where estado = 2 and fecha < curdate();
	else 
		select 2 as numero;
	end if;
        
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarArea` (IN `descArea` VARCHAR(50), IN `idEli` INT)  begin
	insert into area values (null,descArea,idEli);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarCliente` (IN `codigo` VARCHAR(50), IN `nombre` VARCHAR(128), IN `ca` VARCHAR(256), IN `pob` VARCHAR(75))  begin
	insert into clientes values (null, codigo, nombre, ca, pob, 1);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarDetalleEnvio` (IN `envio` INT, IN `tramite` INT, IN `cliente` INT, IN `documento` INT, IN `area` INT, IN `mon` VARCHAR(25), IN `obs` TEXT, IN `num` VARCHAR(25))  begin
	declare idAnterior int;
    set idAnterior = (select max(codigoDetalleEnvio) from detalleEnvio) + 1;
    insert into detalleEnvio values (null, concat('DD', idAnterior), envio, tramite, cliente, documento, area, 1, num, mon, obs, curdate(), '0000-00-00', '00:00:00', '0000-00-00', 1);

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarDocumentos` (IN `nom` VARCHAR(50), IN `idEli` INT)  begin
	insert into tipoDocumento values (null, nom, idEli);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarMensajero` (IN `nombre` VARCHAR(50), IN `idEli` INT)  begin
	insert into mensajero values (null,nombre, idEli);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarUsuario` (IN `nom` VARCHAR(50), IN `ape` VARCHAR(50), IN `us` VARCHAR(50), IN `correo` VARCHAR(75), IN `contra` VARCHAR(75), IN `idArea` INT, IN `rol` INT, IN `idEli` INT)  begin
	insert into usuario values (null, nom, ape, us, correo, contra, 2, rol, idArea,idEli);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteArea` (IN `idArea` INT)  begin
select e.codigoEnvio, d.codigoDetalleEnvio,d.correlativoDetalle, u.nomUsuario, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join status s on s.codigoStatus = d.codigoStatus
where a.codigoArea=idArea order by e.fecha DESC;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteAreaDiario` (IN `idArea` INT)  begin
select e.codigoEnvio, d.codigoDetalleEnvio,d.correlativoDetalle, u.nomUsuario, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join status s on s.codigoStatus = d.codigoStatus
	where a.codigoArea=idArea and e.fecha= curdate()
	order by e.hora DESC;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteAreaPorFechas` (IN `idArea` INT, IN `fecha1` DATE, IN `fecha2` DATE)  begin
select e.codigoEnvio, d.codigoDetalleEnvio,d.correlativoDetalle, u.nomUsuario, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join status s on s.codigoStatus = d.codigoStatus
where a.codigoArea=idArea and e.fecha between fecha1 and fecha2 order by e.fecha DESC;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteDiario` ()  begin
select e.codigoEnvio, d.codigoDetalleEnvio, d.correlativoDetalle, u.nomUsuario, DATE_FORMAT(d.fechaRevision,'%d/%m/%Y') as fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join status s on s.codigoStatus = d.codigoStatus
 where fecha=CURDATE() and (s.descStatus='Completo' or s.descStatus='Pendiente')  order by fecha DESC;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteEstadoDocumento` (IN `parametro` INT)  begin
select e.codigoEnvio, d.codigoDetalleEnvio, d.correlativoDetalle, u.nomUsuario, DATE_FORMAT(d.fechaRevision,'%d/%m/%Y') as fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join status s on s.codigoStatus = d.codigoStatus
 where fecha=CURDATE() and s.codigoStatus = parametro  order by fecha DESC;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteFechas` (IN `fecha` DATE, IN `fecha2` DATE)  begin
select e.codigoEnvio, d.codigoDetalleEnvio,d.correlativoDetalle, u.nomUsuario, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join status s on s.codigoStatus = d.codigoStatus
where e.fecha between fecha and fecha2 order by e.fecha DESC;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteMensajeros` ()  begin
select e.codigoEnvio, d.codigoDetalleEnvio, d.correlativoDetalle, u.nomUsuario, DATE_FORMAT(d.fechaRevision,'%d/%m/%Y') as fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join status s on s.codigoStatus = d.codigoStatus
	where fecha=CURDATE() and s.descStatus='Recibido' order by fecha DESC;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteUsuario` (IN `idUsuario` INT)  begin
select e.codigoEnvio, d.codigoDetalleEnvio,d.correlativoDetalle, u.nomUsuario, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join status s on s.codigoStatus = d.codigoStatus
	where u.codigoUsuario=idUsuario
    order by e.fecha desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteUsuarioDiario` (IN `idUsuario` INT)  begin
select e.codigoEnvio, d.codigoDetalleEnvio,d.correlativoDetalle, u.nomUsuario, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join status s on s.codigoStatus = d.codigoStatus
	where u.codigoUsuario=idUsuario and e.fecha = curdate()	
	order by e.hora DESC;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteUsuarioPorFechas` (IN `idUsuario` INT, IN `fecha1` DATE, IN `fecha2` DATE)  begin
select e.codigoEnvio, d.codigoDetalleEnvio,d.correlativoDetalle, u.nomUsuario, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, tt.descTipoTramite, c.nombreCliente, a.descArea, tc.descTipoDocumento, d.numDoc, s.descStatus, d.monto, d.observacion
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
	inner join clientes c on c.codigoCliente = d.codigoCliente
    inner join tipoDocumento tc on tc.codigoTipoDocumento = d.codigoTipoDocumento
    inner join area a on a.codigoArea = d.codigoArea 
    inner join status s on s.codigoStatus = d.codigoStatus
where u.codigoUsuario=idUsuario and e.fecha between fecha1 and fecha2 order by e.fecha DESC;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tiposTramiteUsuario` (IN `idUsuario` INT)  begin
select count(tt.codigoTipoTramite) as Tramite, tt.descTipoTramite  from detalleEnvio d
inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
inner join envio e on e.codigoEnvio = d.codigoEnvio
where e.codigoUsuario=idUsuario and e.fecha between (SELECT date_add(CURDATE(), INTERVAL -31 DAY)) and CURDATE()
group by tt.descTipoTramite;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `usuariosEnvios` ()  begin
select count(c.codigoUsuario) as Usuario, c.nomUsuario  from envio e
inner join usuario c on c.codigoUsuario = e.codigoUsuario
 where e.fecha between (SELECT date_add(CURDATE(), INTERVAL -7 DAY)) and CURDATE() group by c.nomUsuario;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `area`
--

CREATE TABLE `area` (
  `codigoArea` int(11) NOT NULL,
  `descArea` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `idEliminado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `area`
--

INSERT INTO `area` (`codigoArea`, `descArea`, `idEliminado`) VALUES
(1, 'ABAS', 1),
(2, 'Tax y Legal', 1),
(3, 'RRHH', 1),
(4, 'Finanzas', 1),
(5, 'Tecnología', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `authusuario`
--

CREATE TABLE `authusuario` (
  `codigoAuth` int(11) NOT NULL,
  `descAuth` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `authusuario`
--

INSERT INTO `authusuario` (`codigoAuth`, `descAuth`) VALUES
(1, 'Autorizado'),
(2, 'Esperando Autorizacion'),
(3, 'Restringido');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `codigoCliente` int(11) NOT NULL,
  `codigo` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nombreCliente` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `calle` varchar(256) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `poblacion` varchar(75) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `idEliminado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`codigoCliente`, `codigo`, `nombreCliente`, `calle`, `poblacion`, `idEliminado`) VALUES
(1, '3041915', '21st Century Oncology, Inc.', '3661 South Miami Ave', 'Miami', 1),
(2, '465000', 'Carlos Gustavo López Ayala', 'Residencial y Calle Primavera #11,', 'SANTA TECLA', 1),
(3, '465001', 'Sun Chemical de Centroamérica S.A. Sun Chemical de Centroamérica S.A.', 'Blvd. Del Ejercito Nacional Km 5 1/', 'SOYAPANGO', 1),
(4, '465002', 'Abruzzo S.A. de C.V.', 'Km 16 1/2 Carretera al Puerto de La', 'LA LIBERTAD', 1),
(5, '465003', 'Multiriesgos, S.A. de C.V.', 'Calle Palmeral No. 144 Col. Toluca', 'SAN SALVADOR', 1),
(6, '465004', 'Escuela Superior de Economía y Nego', 'Km 12  1/2 Carretera al Puerto de L', 'SANTA TECLA', 1),
(7, '465005', 'Productos Carnicos S.A. de C.V.', 'Calle El Progreso, Col. Roma No. 33', 'SAN SALVADOR', 1),
(8, '465006', 'Galvanizadora Industrial Salvadoreñ', 'Boulevard de Los Proceres, Edificio', 'SAN SALVADOR', 1),
(9, '465007', 'Secreataría General del Sistema de Secreataría General del Sistema de', 'Final Bulevar Cancillería, Edificio', 'LA LIBERTAD', 1),
(10, '465008', 'Transactel El Salvador, S.A. de C.V', 'Calle Chiltiupan y 17 Av. Notre, Ce', 'SANTA TECLA', 1),
(11, '465009', 'Servicios Empresariales S.A. de C.V', '11 Calle Ote. Y Av. Cuscatancingo #', 'SAN SALVADOR', 1),
(12, '465010', 'Sociedad de Ahorro y Crédito Credic Sociedad de Ahorro y Crédito Credi', 'Alameda Manuel Enrique Araujo, Edif', 'SAN SALVADOR', 1),
(13, '465011', 'UNO El Salvador S.A.', 'Urbanización Santa Elena, Edificio', 'SAN SALVADOR', 1),
(14, '465012', 'Central de Rodamientos S.A. de C.V.', 'Blvd. Venezuela No. 3077 San Salvad', 'SAN SALVADOR', 1),
(15, '465013', 'Droguería Pisa de El Salvador S.A. Droguería Pisa de El Salvador S.A.', 'Urbanización Madre Selva II, Edific', 'SAN SALVADOR', 1),
(16, '465014', 'Banco Promerica S.A.', 'Centro Comercial La Gran Vía, Antig', 'ANTGUO CUSCATLAN', 1),
(17, '465015', 'Textiles San Andres S.A. de C.V.', 'km 32 Carretera a Santa Ana', 'SANTA ANA', 1),
(18, '465016', 'Maximiliano Humberto Dreyfus', 'San Salvador, San Salvador', 'SAN SALVADOR', 1),
(19, '465017', 'Rafael Narvaez', 'San Salvador, San Salvador', 'SAN SALVADOR', 1),
(20, '465018', 'Electricidad del Pacífico, S.A de C', 'Calle Llama del Bosque Pte. Urbaniz', 'ANTGUO CUSCATLAN', 1),
(21, '465019', 'The Network Company, S.A de C.V', 'Urbanización Madre Selva, calle Lla', 'ANTGUO CUSCATLAN', 1),
(22, '465020', 'Primer Banco de los Trabajadores', 'Blvd. De Los Héroes y Calle Berlín,', 'SAN SALVADOR', 1),
(23, '465021', 'ACACEMIHA de RL', '13 Calle Pte. Y 3Av. Norte, Frente', 'SAN SALVADOR', 1),
(24, '465022', 'Lempa Services Limitada de CV', 'KM24 Carretera a Santa Ana zona fra', 'COLON', 1),
(25, '465023', 'Empleo Seguro S.A. de C.V.', 'Km. 30 1/2 Carretera hacia Santa An', 'SAN JUAN OPICO', 1),
(26, '465024', 'Asociación Escuela Americana', 'Calle y Col. La Mascota final Calle', 'SAN SALVADOR', 1),
(27, '465025', 'Grupo Paill S.A. de C.V.', '10 Calle oriente, 8 Av. Sur, Barrio', 'SAN SALVADOR', 1),
(28, '465026', 'Compañía Hotelera Salvadoreña', '11 calle poniente entre 87 y 89 Av.', 'SAN SALVADOR', 1),
(29, '465027', 'CLI, S.A. de C.V.', 'Edificio Construmarket, Col. Lomas', 'ANTGUO CUSCATLAN', 1),
(30, '465028', 'Universidad Evangélica de El Salvad', 'Prolongación Alameda Juan Pablo II', 'SAN SALVADOR', 1),
(31, '465029', 'INTRADESA S.A. de C.V.', 'Km 7  1/2 Boulevard del Ejercito Na', 'SOYAPANGO', 1),
(32, '465030', 'GRUPO QUINBE, S.A DE C.V.', 'Sexta decima calle pte no 2217 Col.', 'SAN SALVADOR', 1),
(33, '465031', 'MARITZA ESMERALDA REYES DE VALLEJO', 'San Salvador', 'SAN SALVADOR', 1),
(34, '465032', 'RENÉ EDGARDO PÉREZ', 'Avenida 2 de Abril Norte entre 8° y', 'CHALCHUAPA', 1),
(35, '465033', 'EDT El Salvador, S.A de C.V', 'Km 19 1/2 Carretera al puerto de La', 'LA LIBERTAD', 1),
(36, '465034', 'Compañía Azucarera Salvadoreña, S.A Compañía Azucarera Salvadoreña, S.', 'Km 62 1/2, Carretera a Sonsonate, C', 'IZALCO', 1),
(37, '465035', 'Stereo Noventa y Cuatro Punto Uno F Stereo Noventa y Cuatro Punto Uno', 'Avenida Maracaibo #703, Colonia Mir', 'SAN SALVADOR', 1),
(38, '465036', 'PIEL Y CALZADO, S.A DE C.V', 'Col. Flor Blanca, Alameda Roosvelt,', 'SAN SALVADOR', 1),
(39, '465037', 'FEDECREDITO VIDA, S.A, SEGUROS DE FEDECREDITO VIDA, S.A, SEGUROS DE', '67 Avenida sur y Avenida Olímpica,', 'SAN SALVADOR', 1),
(40, '465038', 'Legal Coach S.A. de .C.V', 'Av. La Capilla No.414, Colonia San', 'SAN SALVADOR', 1),
(41, '465039', 'Terex Germany GmbH & Co, KG', 'Dusseldorf, 40597|', 'Dusseldorf', 1),
(42, '465040', 'PROYECTO BID 3170/OC-ES-MINEC', 'Centro de Gobierno, S.S.', 'SAN SALVADOR', 1),
(43, '515092', 'DEI COMERCIALIZADORA DE EL SALVADOR S.A. DE C.V.', 'Av. El Espino y Blvd sur 3ra planta', 'ANTGUO CUSCATLAN', 1),
(44, '515576', 'ARRENDADORA FINANCIERA, S.A.', '1a. C. Pte. y 67 Av. Nte. No. 100 B', 'SAN SALVADOR', 1),
(45, '515577', 'INVERSIONES FINANCIERAS BANCO AGRIC S.A', '1a. C. Pte. y 67 Av. Nte. No. 100 B', 'SAN SALVADOR', 1),
(46, '515578', 'VALORES BANAGRICOLA, S.A. DE C.V. C Casa de Corredores de Bolsa.', 'Blvd. Constitución, Edif San José d', 'SAN SALVADOR', 1),
(47, '1000000', 'D&T Netherlands Antilles', 'Scharlooweg 37-41 Willemstand Curac', 'ARUBA', 1),
(48, '1000001', 'Deloitte & Touche – Paraguay Deloitte & Touche – Paraguay', 'Estados Unidos 415 Esq. 25 de Mayo', 'PARAGUAY', 1),
(49, '1000002', 'D. Contadores Ltda.', 'Carrera 7 No. 74-09 Bogota', 'BOGOTA D.C.', 1),
(50, '1000003', 'D.R.I. International', '2 World Financial Center New York', 'NEW YORK', 1),
(51, '1000004', 'Deloitte Y Co S.A.', 'Florida 234 Piso 5 CABA C1038AAN', 'BUENOS AIRES', 1),
(52, '1000005', 'Deloitte & Touche LLP', '700, 850 - 2nd Street SW', 'CALGARY', 1),
(53, '1000006', 'Deloitte & Touche BHPB Melbourne', '180 Lonsdale Street Melbourne VIC 3', 'AUSTRALIA', 1),
(54, '1000007', 'Deloitte & Touche Boston', '200 Berkely Street Boston MA 02116', 'BOSTON', 1),
(55, '1000008', 'J306024883 Deloitte & Touche, C.A.', 'Domicilio Fiscal Av Blandin Edif. T', 'Caracas', 1),
(56, '1000009', 'Deloitte & Touche LLP Deloitte & Touche LLP', 'Four Bentall Centre 1055 Dunsmuir S', 'VANCOUVER', 1),
(57, '1000010', 'Deloitte & Touche Cayman Islands', 'Deloitte & Touche, Citrus Grove, P.', 'CAYMAN ISLANDS', 1),
(58, '1000011', 'Deloitte & Touche LLP', '111 S. Wacker Drive Suite 1800​ Chi', 'CHICAGO', 1),
(59, '1000012', 'Deloitte & Touche, S.A.', 'Centro Corporativo El Cafetal, Edif', 'BELÉN- RIVERA', 1),
(60, '1000013', 'Deloitte & Touche Ecuador Cía Ltda.', 'AV. Amazonas N35-17 J.P. Sanz Quito', 'Quito', 1),
(61, '1000015', 'Deloitte GmbH Deloitte GmbH', 'Zentraler Rechnungseingang Schwanns', 'Duesseldorf', 1),
(62, '1000016', 'Deloitte & Touche LLP', 'DACF Ltd 32 Rockefeller 42 Floor', 'HERMITAGE    NY 10112', 1),
(63, '1000017', 'Deloitte Touche LLP', '333 Clay Street. Suite 2300 Houston', 'HOUSTON', 1),
(64, '1000018', 'Deloitte & Touche LLP', '333 SE 2nd Avenue Suite 3600 Miami', 'MIAMI', 1),
(65, '1000019', 'Deloitte & Touche LLP', 'California 350 South Grand Avenue S', 'LOS ANGELES', 1),
(66, '1000020', 'Deloitte & Touche LLP', 'MN55402 - 400 One Financial Plaza 1', 'USA', 1),
(67, '1000021', 'Deloitte LLP', '2 New Street Square', 'LONDON', 1),
(68, '1000022', 'Deloitte & Touche Ltda', 'Carrera 7 No. 74-09', 'BOGOTA D.C.', 1),
(69, '1000023', 'Deloitte & Touche LLP', '925 Fourth Avenue, Suite 3300', 'Seattle', 1),
(70, '1000024', 'Deloitte Tax LLP', '30 Rockefeller Plaza New York', 'NEW YORK', 1),
(71, '1000025', 'Deloitte Tax LLP', '225 West Santa Clara Street, San Jo', 'New York', 1),
(72, '1000026', 'Deloitte & Touche S.R.L.', 'Av Las Begonias 441 Piso 6 San Isid', 'LIMA', 1),
(73, '1000027', 'Deloitte & Touche LLP', '225 West Santa Clara Street', 'SAN JOSE', 1),
(74, '1000028', 'Deloitte & Touche LLP', '250 East Fifth Street, Suite 1900', 'Cincinnati', 1),
(75, '1000029', 'Deloitte Auditores Deloitte Auditores', 'Rosario Norte No 407 P 16', 'Santiago - Chile', 1),
(76, '1000030', 'Deloitte & Touche', '333 Ludlow Street. Stamford Connect', 'STAMFORD', 1),
(77, '1000031', 'Deloitte Tax LLP Deloitte Tax LLP', 'Two Jericho Plaza – 3rd floor Jeric', 'Jericho', 1),
(78, '1000032', 'Deloitte & Associés', '185 Avenue Charles de Gaulle 92524', 'FRANCIA', 1),
(79, '1000033', 'Deloitte & Touche', '180 Strand  WC2R 1BL', 'LONDON', 1),
(80, '1000034', 'Deloitte & Touche ZF Ltda.', 'Ruta 8 Km 17.500- Zoname Montevideo', 'URUGUAY', 1),
(81, '1000035', 'Deloitte Asesores y Consultores Ltd Deloitte Asesores y Consultores Lt', 'Carrera 7 No. 74-09 Bogota', 'BOGOTA D.C.', 1),
(82, '1000036', 'Deloitte Belastingadviseurs BV', 'Orlyplein 10 1043 DP Amsterdam', 'Amsterdam', 1),
(83, '1000037', 'Deloitte Ltda.', 'Carrera 7 No. 74-09 Bogota', 'BOGOTA D.C.', 1),
(84, '1000038', 'Deloitte Consulting LLP', '111 South Wacker Drive, Chicago 606', 'CHICAGO', 1),
(85, '1000039', 'Deloitte Consulting Outsourcing LLC', '33131-2310 200 South Biscayne Boule', 'MIAMI', 1),
(86, '1000040', 'Deloitte Corporate International', 'Berkenlaan 8A  B-1831 Diegem', 'BELGIUM', 1),
(87, '1000041', 'Deloitte Inc', 'Torre Banco Panama, Piso 12 Avenida', 'PANAMA', 1),
(88, '1000042', 'Deloitte, S.L. - ESB79104469', 'Plaza Pablo Ruiz Picasso, 1, Torre', 'MADRID-ESPAÑA', 1),
(89, '1000043', 'Deloitte Tax LLP', '225 West Santa Clara Street, Suite', 'SAN JOSE - USA', 1),
(90, '1000044', 'Deloitte Tax LLP', '111. S. Wacker Drive Chicago IL 606', 'CHICAGO', 1),
(91, '1000045', 'Deloitte Tax LLP', '3320 Ridgecrest Drive, Suite 400', 'MIDLAND', 1),
(92, '1000046', 'Deloitte Financial Advisory Service', '1111 Bagby St. Ste 4500', 'Houston', 1),
(93, '1000047', 'Deloitte Tax LLP', '191 Peachtree Street, Suite 2000', 'ATLANTA', 1),
(94, '1000048', 'Deloitte Touche Tohmatsu Auditores Deloitte Touche Tohmatsu Auditores', 'Avenida Dr. Chucri Zaidan, 1.240, G', 'BRAZIL', 1),
(95, '1000049', 'Deloitte Touche S.A.', 'Managua Los Robles #29', 'Managua', 1),
(96, '1000050', 'Deloitte Touche Tohmatsu', 'Av. Carlos Gomes 403, 12° andar Sao', 'Porto Alegre', 1),
(97, '1000051', 'DTCO Panama', 'Panama 5 P Edificio Banco de Boston', 'PANAMA', 1),
(98, '1000052', 'Galaz, Yamazaki, Ruiz Urquiza, S.C. Galaz, Yamazaki, Ruiz Urquiza, S.C', 'Av. Paseo de la reforma 505, Piso 2', 'Ciudad de México', 1),
(99, '1000053', 'GRIS Y ASOCIADOS SCRL', 'CAL.BEGONIAS NRO. 441 DPTO. 6 URB.', 'LIMA', 1),
(100, '1000054', 'Lara Marambio & Asociados', 'Av Blandin Edif. Torre B.O.D Piso 2', 'MIRANDA', 1),
(101, '1000055', 'Deloitte Guatemala, S.A.', 'Euro Plaza World Business Center 5t', 'Zona 14', 1),
(102, '1000056', 'RP&C Abogados Cia Ltda', 'Los Ríos 810 y 9 de Octubre', 'Quito', 1),
(103, '1000057', 'Gomez Rutmann y Asociados Despacho Gomez Rutmann y Asociados Despacho', 'Av. Blandin Edif. Torre B.O.D. Piso', 'MIRANDA', 1),
(104, '1000058', 'Studio Tributario e Societario', 'Via Tortona, 25 , 20144  Milano', 'Milán', 1),
(105, '1000059', 'Deloitte & Co SRL Latco', 'Ruta 8 Km. 17.500 Zonamerica Edific', 'URUGUAY', 1),
(106, '1000060', 'Deloitte LLP', '5140 Yonge Street Suite 1700 M2N 6L', 'TORONTO, ONTARIO', 1),
(107, '1000061', 'Deloitte & Touche Consulting S de R', 'Col. Cuauhtemoc 065000 M Paseo La R', 'MEXICO', 1),
(108, '1000065', 'Deloitte Tax LLP', '555 West 5 street, suite 2700', 'LOS ANGELES', 1),
(109, '1000066', 'Deloitte Tax Services India Pvt. Lt', 'Road 2 Hightech City Layout RMZ Fut', 'MADHAPUR HYDERABAD', 1),
(110, '1000070', 'Deloitte Asesores Tributarios S.L.U Deloitte Asesores Tributarios S.L.', 'Plaza Pablo Ruiz Picasso, 1 Torre P', 'Madrid - España', 1),
(111, '1000071', 'Deloitte Touche Tohmatsu Consultori', 'Av. Presidente Wilson, 231 - 22° an', 'RIO DE JANEIRO', 1),
(112, '1000075', 'Deloitte AG ', 'Route de Pré-de-la-bichette 1-', 'Geneva', 1),
(113, '1000076', 'Deloitte Touche Tohmatsu', '191 Peachtree Street, N.E.Suite 150', 'ATLANTA', 1),
(114, '1000077', 'DC Outsourcing LLC', 'Spring Valley 2 Braxton Way Glen Mi', 'GLEN MILLS', 1),
(115, '1000078', 'Deloitte & Touche LLP', 'Limited 6 Shenton Way, OUE Dowtown', 'Singapore', 1),
(116, '1000080', 'Deloitte Consulting (Pty) Ltd.', 'Brooklyn House, 315 Bronkhorst Stre', 'BROOKLYN', 1),
(117, '1000085', 'Deloitte & Touche LLP', '1633 Brodway. New York, NY10019-675', 'NEW YORK', 1),
(118, '1000086', 'Deloitte & Touche LLP', '555 17th Street Suite 3600', 'Denver', 1),
(119, '1000090', 'Deloitte Dallas', '2200 Ross Avenue Ste 1600', 'DALLAS', 1),
(120, '1000091', 'Saborío & Deloitte de Costa Rica S.', 'Centro Corporativo El Cafetal, Edif', 'BELÉN- RIVERA', 1),
(121, '1000095', 'Deloitte Tax LLP', '555 Mission Street, 14th Floor San', 'SAN FRANCISCO', 1),
(122, '1000101', 'Deloitte & Touche LLP', '333 Clay Street, Suite 2300, Housto', 'Houston', 1),
(123, '1000110', 'TAJ - Societé Avocats', '181,Avenue Charles de Gaulle-92524N', 'Neuilly', 1),
(124, '1000115', 'Deloitte & Touche Tohmatsu LTD', 'Level 4.  225 George Street Sidney', 'SIDNEY', 1),
(125, '1000116', 'Deloitte Tax Advisors B-V.', 'Afdeling Crediteurenadministratie 3', 'MIDDELBURG', 1),
(126, '1000120', 'Asesores en Cumplimiento Tributario', '5ave. 5-55', 'Zona 14', 1),
(127, '1000121', 'CONSULTORIA EN SERVICIOS EXTERNOS S', '5ave. 5-55', 'Zona 14', 1),
(128, '1000122', 'DELOITTE GUATEMALA, S.A.', '5ave. 5-55', 'Zona 14', 1),
(129, '1000123', 'Deloitte Consulting de Guatemala SA', '5ave. 5-55', 'Zona 14', 1),
(130, '1000124', 'Deloitte AB', 'Box 233, 391 22 KALMAR', 'Kalmar', 1),
(131, '1000129', 'Deloitte RD, S.R.L.', 'Av. Pedro Henriquez Ureña 150 Torre', 'Santo Domingo Este', 1),
(132, '1000133', 'Deloitte & Touche Co Limited', 'Centro Corporativo El Cafetal, Edif', 'BELÉN- RIVERA', 1),
(133, '1000135', 'DELOITTE CHARLOTTE', '701 B Street swit  1900', 'Zona 1', 1),
(134, '1000150', 'Deloitte El Salvador S.A. DE C.V.', 'Edificio Avante, Penthouse oficinas', 'ANTGUO CUSCATLAN', 1),
(135, '1000164', 'Deloitte, S.A.', '560 rue Neudorf  L-2220 Luxembourg', 'Luxemburgo', 1),
(136, '1000171', 'Deloitte Tax LLP', '2901 N Central Aven Suite 1200 Phoe', 'Phoenix', 1),
(137, '1000175', 'Deloitte Tax & Consulting, Sàrl', 'Deloitte S.A., 560 Rue de Neudorf', 'Grand Duchy of Luxemburgo', 1),
(138, '1000180', 'Regus InternationalServices, S.A.', '1560 Sawgrass Corporate Pkwy Suite', 'usa', 1),
(139, '1000188', 'DELOITTE IRLANDA', 'Deloitte & Touche House Earlsfort T', 'Dublin 2', 1),
(140, '1000190', 'Deloitte & Touche LLP Deloitte & Touche LLP', '30 Rockefeller Plaza New York, NY 1', 'NEW YORK', 1),
(141, '1000191', 'Deloitte Tax LLP (Detroit)', '200 Renaissance Center, Suite 3900', 'Detroit', 1),
(142, '1000200', 'Deloitte Tax LLP - Costa Mesa', '695 Town Center Drive, Suite 1200', 'Costa Mesa, California 92626-1979', 1),
(143, '1000214', 'DELOITTE TAX LLP DELOITTE TAX LLP', '1750 Tysons Boulevard Suite 800 M', 'VIRGINIA', 1),
(144, '1000221', 'GRIS Y ASOCIADOS SCRL', 'LAS BEGONIAS 441, PISO 6', 'BOGOTA D.C.', 1),
(145, '1000281', 'Deloitte Tax LLP Deloitte Tax LLP', '555 East Wells Street, Suite 1400', 'Milwaukee', 1),
(146, '1000317', 'DELOITTE LLP', 'BLOCK 1SOUTH SURREYE LEVEL PAVILI -', 'LONDON -ENGLAND', 1),
(147, '1000343', 'DELOITTE LLP.', '2800-1055 Dunsmuir Street', 'VANCOUVER - CANADA', 1),
(148, '1000368', 'GALAZ YAMAZAKI RUIZ URQUIZA S.C.', 'Av. Paseo de La Reforma 505, PISO 2', 'Mexico', 1),
(149, '1000369', 'Deloitte Tax LLP', '2500 One PPG Place', 'Pittsburgh', 1),
(150, '1000371', 'Deloitte SA', 'Rue du Pré-de-la-Bichette 1', 'Switzerland', 1),
(151, '1000395', 'DELOITTE LLP', '2 New Street Square', 'LONDRES', 1),
(152, '1000401', 'Deloitte Financial Advisory Service', '695 Town Center Drive, Suite 1200', 'Costa Mesa', 1),
(153, '1000470', 'Deloitte & Touche S de R.L.', 'Col. Florencia Norte', 'Camasca', 1),
(154, '1000497', 'Deloitte LLP', 'Athene Place, 66 Shoe Lane, London,', 'LONDON', 1),
(155, '1000532', 'CORPORACION MULTI INVERSIONES', '5a av. 15-45 Edif. Centro Empresari', 'Zona 10', 1),
(156, '1000552', 'DELOITTE TAX LLP DELOITTE TAX LLP', '250 E 5th St. Ste 1900, Cincinnatti', 'CINCINNATTI', 1),
(157, '1000557', 'Taj - Société davocats - Member of Taj - Société davocats - Member o', '181 Avenue Charles del Gaulle 92524', 'NEUILLY', 1),
(158, '1000562', 'Deloitte AG Deloitte AG', 'General Guisan-Quai 38 P.O Box 2232', 'ZURICH', 1),
(159, '1000567', 'Deloitte Mclean', 'VA 22102 Deloitte 1750 Tyson Blvd.', 'Virginia', 1),
(160, '1000570', 'DROGUERIA AMERICANA', '7a. avenida 6-51', 'Zona 2', 1),
(161, '1000574', 'DELOITTE UK LONDON', '2 New Street Squiare, london EC4A 3', 'EC4A 3BZ', 1),
(162, '1000575', 'DELOITTE US MINNEAPOLIS', 'Deloitte Minneapolis 400 one Financ', 'Street', 1),
(163, '1000576', 'DELOITTE US PARSIPPANY', 'Deloitte Parsippany Teo Hilton Cour', 'Parsippany', 1),
(164, '1000577', 'DELOITTE US HOUSTON', '333 Clay Street Suite 2300 Tx 77002', 'Houston', 1),
(165, '1000581', 'Galaz, Yamazaki, Ruiz Urquiza, S.C.', 'AV. PASEO DE LA REFORMA, PISO 2 505', 'COLONIA CUAUHTEMOC', 1),
(166, '1000582', 'DELOITTE US SAN JOSE', 'Suite 600 226 West Santa Clara St.', 'Deloitte Tax LLP', 1),
(167, '1000583', 'DELOITTE US CHICAGO', '111 S. Wacker, Chicago, IL 60101-70', 'United States', 1),
(168, '1000584', 'DELOITTE US DENVER', '555 Seventeenth Street, Suite 3600', 'Denver', 1),
(169, '1000585', 'DELOITTE US LOS ANGELES', 'Two California  Plaza 350 South Gra', 'Deloitte Los Angeles', 1),
(170, '1000586', 'DELOITTE US MCLEAN', '1750 Tysons Blvd. Mclean Virginia U', 'Virginia', 1),
(171, '1000587', 'DELOITTE US MIDLAND', '3320 Ridgecrest Dr. Ste 400 Midland', 'United States', 1),
(172, '1000588', 'DELOITTE TAX LLP', '2200 Rose Avenue Ste. 1600', 'Dallas', 1),
(173, '1000589', 'DELOITTE JERICHO NEW YORK', 'Jericho Plaza NY 11753-1683', 'Jericho', 1),
(174, '1000590', 'DELOITTE HYDERABAD', 'RMZ Futura Plot No. 14 & 15', 'Hyderabad', 1),
(175, '1000591', 'DELOITTE DUSSELDORF', 'gMBH, pOSTFACH 30 02 26, 40402', 'Dusseldorf Deutschlabd', 1),
(176, '1000598', 'Deloitte Touche Tohmatsu Consultore', 'Av.Dr. Chucri Zaidan, 1240', 'São Paulo / SP', 1),
(177, '1000601', 'Deloitte Touche Tohmatsu Consultori Contábil e Tributária S/C Ltda.', 'Rua Alexandre Dumas 1981 2do andar', 'Sáo Paulo', 1),
(178, '1000602', 'DELOITTE US PHILADELPHIA', '1700 Market Street Philadelphia PA', 'Philadelphia', 1),
(179, '1000611', 'DELOITTE CONSULTING LLP', '25 Broadwey New York 10004', 'New York', 1),
(180, '1000631', 'Deloitte Las Vegas', '3883 H. Hughes PKWY STE 400', 'LAS VEGAS', 1),
(181, '1000646', 'Deloitte & Co S.R.L. Deloitte & Co S.R.L.', 'Florida 234 piso 5, C1005AAF', 'BUENOS AIRES', 1),
(182, '1000750', 'EMPRESA DE APOYO LOGISTICO, S.A. DE', 'CALLE CORTEZ PTE # 18 URB. MADRE SE', 'ANTGUO CUSCATLAN', 1),
(183, '1000778', 'DELOITTE LLP', '2 NEW STREET SQUARE', 'LONDON', 1),
(184, '1000795', 'Deloitte LLP', 'Deloitte LLP, Interfirm Accounts, P', 'United Kingdom', 1),
(185, '1000805', 'Deloitte & Touche GmbH', 'Franklinstrasse 50 D-60486 Frankfur', 'FRANKFURT', 1),
(186, '1000807', 'Deloitte Group Support Center B.V.', '3000 BT P.O Box 1777', 'ROTTERDAM', 1),
(187, '1000808', 'Deloitte LLP', 'Hill House, 1 Little New Street', 'United Kingdom', 1),
(188, '1000812', 'Deloitte Tax LLP', 'City Pl 185 Asylum St 33nd Floor', 'Hartford, Connecticut 06103-3402', 1),
(189, '1000817', 'Deloitte Haskins & Sells', '7th floor, Building 10, tower B', 'Gurgaon 122 002, Haryana India', 1),
(190, '1000829', 'Deloitte Tax LLP', '1111 Bagby Street, Suite 4500, Hous', 'HOUSTON', 1),
(191, '1000839', 'Deloitte Oy', 'Porkkalankatu 24', 'P.O. Box 122, 00181 Helsinki, Finla', 1),
(192, '1000855', 'Deloitte Tax LLP', 'Suite 3300 127 Public Square Clevel', 'CLEVELAND', 1),
(193, '1000865', 'Deloitte (New Zealand)', '80 Queen Street', 'Auckland', 1),
(194, '1000869', 'Deloitte Global Services Limited Deloitte Global Services Limited', 'Two Jericho Plaza - 3rd Floor Jeric', 'New York', 1),
(195, '1000880', 'Deloitte Consulting LLP', '127 Public Sq Ste 3300 OH 44114-130', 'CLEVELAN', 1),
(196, '1000885', 'Deloitte Tax LLP', '550 South Tryon Street Suite 2500 C', 'CHARLOTTE', 1),
(197, '1000914', 'Deloitte & Touche S. de R.L.', 'Edificio Plaza America 5th Floor, F', 'Tegucigalpa', 1),
(198, '1000917', 'DELOITTE AG', 'Steinengraben 22', 'BASEL', 1),
(199, '1000918', 'Deloitte Tohmatsu Tax Co.', 'Shin Tokyo Building 5F, 3-3-1', 'Tokyo, 100-8305, Japan', 1),
(200, '1000956', 'Deloitte Financial Advisory Services LLP', '191 Peachtree Street', 'ATLANTA', 1),
(201, '1000964', 'DELOITTE TAX LLP DELOITTE TAX LLP', '1111 Bagby Street, Suite 4500', 'Houston', 1),
(202, '1000979', 'DELOITTE TOUCHE TOHMATSU INDIA PRIV DELOITTE TOUCHE TOHMATSU INDIA PRI', 'Deloitte Centre,Anchorage II,100/2,', '560025,Bangalore', 1),
(203, '1000981', 'DELOITTE ASESORES Y CONSULTORES LTD DELOITTE ASESORES Y CONSULTORES LT', 'Calle 64N No 5B-146, Centroempresa', 'CALI', 1),
(204, '1000988', 'Taj Société d’Avocats FR33434480273', 'T6 place de la Pyrmide Tour Majunga', 'París', 1),
(205, '1000991', 'Panalpina, S.A. de C.V.', 'Calle Padres Aguilar No. 326 e 81 y', 'SAN SALVADOR', 1),
(206, '1000993', 'Deloitte Belastingconsulenten / Con Deloitte Belastingconsulenten / Co', 'Gateway Building Luchthaven Nationa', 'Zaventem', 1),
(207, '1001003', 'Deloitte Services LP', '4022 Sells Drive', 'Hermitage', 1),
(208, '1001010', 'Deloitte LLP', 'Hill House 1 Little New Street,Lond', 'London', 1),
(209, '1001015', 'Deloitte Tax LLP - San Diego', '655 West Broadway, Suite 700, San D', 'SAN DIEGO', 1),
(210, '1001024', 'Deloitte Tax LLP', '7900 Tysons One Place, Suite 800, M', 'US McLEan', 1),
(211, '1001049', 'Deloitte GmbH Deloitte GmbH', 'SchwannstraBe 6,  40476 Dusseldorf', 'DEUTCHSCHLAND', 1),
(212, '1001054', 'Deloitte Bedrijfsrevisoren Central Deloitte Bedrijfsrevisoren Central', 'Berkenlaan 8B,  1831', 'Diegem', 1),
(213, '1001066', 'DELOITTE TAX LLP', '27601 150 Fayetteville Street, Suit', 'California', 1),
(214, '1001076', 'DELOITTE FRANCE DELOITTE FRANCE', '181 Avenue Charles De Gaulle Neuill', 'TAJ-SOCIÉTÉ D´AVOCATS', 1),
(215, '1001114', 'Deloitte LLP Deloitte LLP', 'The Pinnacle 150 Midsummer Blvd.', 'Buckingshire', 1),
(216, '1001118', 'DELOITTE TAX LLP DELOITTE TAX LLP', '1633 Broadway, 38th Floor', 'NY', 1),
(217, '1001123', 'Deloitte Advisory, S.L. C.I.F B8646', 'Plaza Pablo Ruiz Picasso, 1 28020', 'MADRID', 1),
(218, '1001132', 'Deloitte & Touche S de R.L', 'Torre Ejecutiva Santa Mónica Oeste', 'San Pedro Sula', 1),
(219, '1001135', 'Deloitte Advisory S.L. CIF: B864664', 'Plaza Pablo Ruiz Picasso, 1 Torre P', 'Madrid – España', 1),
(220, '1001142', 'Deloitte Consulting S.L.U C.I.F B81', 'Plaza Pablo Ruiz Picasso 1, Torre P', 'MADRID', 1),
(221, '1001162', 'DELOITTE TAX LLP DELOITTE TAX LLP', '50 South Sixth Street, Suite 2800.', 'Minneapolis', 1),
(222, '1001164', 'DELOITTE MCLEAN', '1750 Tysons Boulevard Suite 800 McL', 'Virginia', 1),
(223, '1001184', 'Deloitte Tax LLP', '30 Rockefeller Plaza New York', 'new york', 1),
(224, '1001198', 'Deloitte Consultores S.A.', 'Costa del Este, Edf. Banco Panamá', 'Panamá, Rep. de Panamá', 1),
(225, '1001228', 'Deloitte Asesores y Consultores Ltd', 'Calle 16 Sur  43 A - 49 | Piso 10', 'MEDELLIN', 1),
(226, '1001231', 'ASESORES Y CONSULTORES CORPORATIVOS ASESORES Y CONSULTORES CORPORATIVO', '5 Av. Torre 4 Nivel 8 Europlaza Wor', 'Zona 14', 1),
(227, '1001248', 'Deloitte & Touche Oy, Accounts Paya', 'Porkkalankatu 24, P.O. Box 122, 001', 'Helsinki', 1),
(228, '1001265', 'Deloitte Financial Advisory Service', '30 Rockefeller Plaza New York NY 10', 'NEW YORK', 1),
(229, '1001270', 'Deloitte LLP', 'Abbey Street', 'Abbots House, Reading', 1),
(230, '1001277', 'Deloitte Advokatfirma AS', 'Fakturamottak PB 4481 Vika 8608 Mo', 'Norway', 1),
(231, '1001328', 'DELOITTE & TOUCHE LTDA.', 'Calle 16 Sur Nro. 43A-49 – Edificio', 'MEDELLIN', 1),
(232, '1001341', 'DELOITTE & TOUCHE, S.A.', 'CC El Cafetal, Edificio B, piso 2,', 'HEREDIA- HEREDIA', 1),
(233, '1001349', 'Deloitte Tax LLP Deloitte Tax LLP', '555 West 5th Street, Suite 2700 Los', 'LOS ANGELES - USA', 1),
(234, '1001350', 'DELOITTE TAX LLP', '111 Southwest 5th Avenue #3900', 'Portland', 1),
(235, '1001359', 'Deloitte Financial Advisory S.L.U Deloitte Financial Advisory S.L.U', 'Plaza Pablo Ruiz Picasso 1, Torre P', 'Madrid', 1),
(236, '1001368', 'Deloitte Consulting S.L.U. Deloitte Consulting S.L.U.', 'Plaza Pablo Ruiz Picasso 1 28020 Ma', 'Madrid', 1),
(237, '1001371', 'Deloitte Advisory SPA.', 'Rosario Norte N° 407 Of. 1601', 'LAS CONDES', 1),
(238, '1001383', 'Deloitte Consulting CR S.A.', 'Contiguo al Hotel Marriot, Centro C', 'BELÉN- RIVERA', 1),
(239, '1001408', 'Deloitte Panama', 'Calle Elvira Mendez y Vía España', 'Panamá', 1),
(240, '1001428', 'Deloitte Canada', '255 Queens Ave. suite 700 london ON', 'ONTARIO', 1),
(241, '1001472', 'DELOITTE LLP', 'Bay adelaide East, 22 Adelaide Stre', 'Toronto', 1),
(242, '1001482', 'DACF Ltd DACF Ltd', '30 Rockefeller 42 Floor New York NY', 'New York USA', 1),
(243, '1001531', 'Deloitte Tax Services, S.A.', 'Torre Bco. Panamá, Piso 12,', 'Panamá', 1),
(244, '1001584', 'Deloitte Inc. Deloitte Inc.', 'Torre Banco Panamá, Piso 12, Avenid', 'Costa del Este-Rep.Panamá-', 1),
(245, '1001624', 'Deloitte Legal', 'Torre Sevilla, planta 12, calle Gon', 'Sevilla', 1),
(246, '1001641', 'Deloitte Consulting S.A. de C.V.', 'Edificio Avante, Penthouse oficinas', 'ANTGUO CUSCATLAN', 1),
(247, '1001658', 'NEC de Colombia S.A. Sucursal El Salvador', 'Edificio World Trade Cent Local 206', 'SAN SALVADOR', 1),
(248, '1001684', 'Deloitte Tax LLP Deloitte Tax LLP', 'Suite 400 333 SE 2nd Ave Ste 3600', 'Miami', 1),
(249, '1001698', 'Deloitte Impuestos y Servicios Deloitte Impuestos y Servicios', 'Av. Paseo de la Reforma 505 P.28, C', 'Ciudad de Mexico', 1),
(250, '1001704', 'DELOITTE ASESORIA FINANCIERA, S.C.', 'Paseo de la Reforma 505, piso 28, C', 'CUAUHTEMOC', 1),
(251, '3000016', 'Aerovias del Continente Americano S Aerovias del Continente Americano', 'Av Calle 26 No.59-15 Piso 5', 'BOGOTA D.C.', 1),
(252, '3000800', 'Promigas S.A. E.S.P.', 'Calle 66 No. 67-123', 'BARRANQUILLA', 1),
(253, '3001924', 'Cinemark Panamá S.A.', 'Albrook Panamá', 'Panamá', 1),
(254, '3001926', 'Cine Food Services', 'Albrook Panamá', 'Panamá', 1),
(255, '3002375', '3M Guatemala, S. A.', 'Calz. Roosevelt 12-33 de mixco', 'Zona 3', 1),
(256, '3002390', 'Industria Alimenticias Kerns', 'Km 6.5 carretera al atlántico', 'Zona 18', 1),
(257, '3002407', 'Sanofi-Aventis De Guatemala S.A .', 'Km. 15.5 Carr. Roosevelt zona 7 de', 'Mixco', 1),
(258, '3002491', 'Disagro de Guatemala S.A .', 'Anillo Periférico 17-36', 'Zona 11', 1),
(259, '3002557', 'Hanes de Centroamérica, S.A.', 'Avenida Reforma 1-50 Edificio Refor', 'Zona 9', 1),
(260, '3002618', 'R.R. Donnelley  de Guatemala S.A. R.R. Donnelley  de Guatemala S.A.', 'Calzada Atanasio Tzul 22-00 Empresa', 'Zona 12', 1),
(261, '3002641', 'ASOCIACION PASMO', '16 Calle 0-55 10 Edificio Torre Int', 'Zona 10', 1),
(262, '3002673', 'Rayovac Guatemala S.A.', 'Colonia Santa Isabel, Jocotales', 'Zona 6', 1),
(263, '3002986', 'BANCO LAFISE SOCIEDAD ANONIMA', 'De la fuente de la Hispanidad 50 m', 'MONTES DE OCA- SAN PEDRO', 1),
(264, '3003024', 'CINEMARK COSTA RICA SOCIEDAD DE CINEMARK COSTA RICA SOCIEDAD DE', 'Multiplaza del Este', 'ESCAZÚ- SAN RAFAEL', 1),
(265, '3003119', 'COOPERATIVA DE PRODUCTORES DE LECHE COOPERATIVA DE PRODUCTORES DE LECH', 'El Coyol', 'ALAJUELA- RÍO SEGUNDO', 1),
(266, '3003181', 'GRUPO DE COMUNICACION GARNIER GRUPO DE COMUNICACION GARNIER', 'Sabana Norte 50 mts norte del Hotel', 'SAN JOSÉ- URUCA', 1),
(267, '3003196', 'HERBALIFE INTERNATIONAL COSTA RICA HERBALIFE INTERNATIONAL COSTA RICA', 'Calles 30 y 32, frente a Toyota Ren', 'SAN JOSÉ-CATEDRAL', 1),
(268, '3003645', 'INSTITUTO COSTARRICENSE DE ELECTRIC', 'Edificio Sabana, piso 13', 'SAN JOSÉ-CATEDRAL', 1),
(269, '3009996', 'Banco Centroamericano  de Banco Centroamericano  de', 'BOULEVARD SUYAPA EDIF.BCIE', 'Distrito Central', 1),
(270, '3010392', 'FEDECREDITO DE C.V.', '25 Avenida Norte y 23 Calle Ponient', 'SAN SALVADOR', 1),
(271, '3010496', 'General Electric International Inc. General Electric International Inc', 'Vedia 3616 Piso 6', 'C.A.B.A.', 1),
(272, '3010890', 'CINEMARK NICARAGUA & CIA LTDA.', 'CENTRO COMERCIAL METROCENTRO', 'Managua', 1),
(273, '3011273', 'Deloitte RD, S.R.L.', 'Rafael Augusto Sanchez No. 65, Edif', 'Santo Domingo Este', 1),
(274, '3013552', 'Kativo Chemical Industries S.A.', 'El Alto de Ochomogo de Recope 2 Km', 'SAN JOSÉ- CARMEN', 1),
(275, '3013937', 'Proteccion de Valores S.A', '4A CALLE 3-43 ZONA 13 GUATEMALA, GU', 'Zona 13', 1),
(276, '3013958', 'Credomatic de Costa Rica, S.A.', 'Calle 0 Avenidas 3 y 5, San José', 'SAN JOSÉ- CARMEN', 1),
(277, '3014735', 'BANCO DE LOS TRABAJADORES', 'Avenida Reforma 6-20 edificio Banco', 'Zona 9', 1),
(278, '3015271', 'Guatemalan Candies, S.A.', '31 calle 15-80', 'Zona 12', 1),
(279, '3015283', 'PEPSICOLA INTERAMERICANA PEPSICOLA INTERAMERICANA', '5ª. Avenida 16-62 Edificio Platina,', 'Zona 10', 1),
(280, '3015377', 'Sony Inter-American, S.A. Sucursal Sony Inter-American, S.A. Sucursal', 'Simón Bolívar(transístmica),P  Ave.', 'Panamá, Panamá.', 1),
(281, '3015436', 'COMUNICACIONES CELULARES, S.A.', 'Carretera a El Salvador (CA-1) Km 9', 'Santa Catarina Pinula', 1),
(282, '3015972', 'Productos Alimenticios Bocadeli, S. Productos Alimenticios Bocadeli, S', 'Colonia Sierra Morena 2', 'SOYAPANGO', 1),
(283, '3016167', 'Mitsubishi Corporation', 'Marunouchi Park Building, 2-6-1 Mar', 'TOKIO', 1),
(284, '3016306', 'Banco General, S.A.', 'Ave Aquilino De La Guardia, Marbell', 'Panamá, República de Panamá', 1),
(285, '3016330', 'Tecnoquímicas, S.A.', 'Cl 23 No.7 - 39 Cali - Colombia', 'CAUCASIA', 1),
(286, '3017024', 'Cinemark de El Salvador Ltda de C.V', 'Edificio Cinemark, Carretera, Panam', 'LA LIBERTAD', 1),
(287, '3017025', 'Intelfon, S.A. de C.V.', '63 Avenida Sur y Alameda Roosevelt,', 'SAN SALVADOR', 1),
(288, '3017026', 'Asociación Salvadoreña de Administradoras de Fondos de Pensio', 'Pasaje Senda Florida Norte No. 140,', 'SAN SALVADOR', 1),
(289, '3017028', 'Plastiglas, de El Salvador, S.A. de', 'km 31 Autopista a Santa Ana Parcela', 'LA LIBERTAD', 1),
(290, '3017030', 'Continental Airlines, S.A. de C.V.', 'El salvador', 'SAN SALVADOR', 1),
(291, '3017031', 'Distribuidora Salvadoreña Distribuidora Salvadoreña de Petrol', 'Centro Empresarial Fratel local 1-1', 'LA LIBERTAD', 1),
(292, '3017032', 'Pricesmart El Salvador, S.A. de C.V', 'Urbanización Madre Selva Blvd. Sur,', 'LA LIBERTAD', 1),
(293, '3017033', 'Agape de El Salvador, S.A. de C.V.', 'Kilometro 63 carretera a sonsonate', 'SAN SALVADOR', 1),
(294, '3017034', 'Sersaprosa, S.A. de C.V.', 'Alameda Manuel Enrique Araujo y cal', 'SAN SALVADOR', 1),
(295, '3017035', 'Comunicacion Directa, S.A. de C.V.', 'El salvador', 'SAN SALVADOR', 1),
(296, '3017036', 'Cobiscorp El Salvador, S.A. de C.V.', 'Calle Arturo Ambrogi No. 137 Segund', 'SAN SALVADOR', 1),
(297, '3017037', 'DDB El Salvador, S.A. de C.V.', '85 Avenida Norte No. 619 Colonia Es', 'SAN SALVADOR', 1),
(298, '3017038', 'Zumma Ratings S.A.DE.C.V. Clasifica Zumma Ratings S.A.DE.C.V. Clasific', 'Blvd. Sergio vieira de mello# 304 E', 'SAN SALVADOR', 1),
(299, '3017039', 'Evergreen Packaging de El Salvador, Evergreen Packaging de El Salvador', 'Kilometro 10 1/2 Carretera al Puert', 'LA LIBERTAD', 1),
(300, '3017040', 'Sistems Enterprise El Salvador, S.A', 'Calle Semens No. 43 Parque Industri', 'LA LIBERTAD', 1),
(301, '3017041', 'ABB, S.A. de C.V. ABB, S.A. de C.V.', '89 avenida Norte y 11 Calle Ponient', 'SAN SALVADOR', 1),
(302, '3017042', 'Atlas Distribuidores, de El Salvado S.A. de C.V.', 'Boulevard del Ejercito Nacional Km', 'SAN SALVADOR', 1),
(303, '3017043', 'Productos Alimenticios  Bocadeli, S Productos Alimenticios  Bocadeli,', 'Final Avenida Cerro Verde, Sierra M', 'SAN SALVADOR', 1),
(304, '3017044', 'Alcatel de El Salvador, S.A. de C.V', 'Colonia La Mascota, numero 316B 3er', 'SAN SALVADOR', 1),
(305, '3017045', 'BJ Services, y Cía., S. en C. de C.', 'Flexibodegas integración Bodega A-2', 'SAN SALVADOR', 1),
(306, '3017046', 'Ceramica del Pacifico, S.A. de C.V.', 'Prolong. Alameda Juan Pablo II Call', 'SAN SALVADOR', 1),
(307, '3017047', 'Compañia Farmaceutica, S.A. de C.V.', 'Final av. Melvin Jones 20 Col. Util', 'SAN SALVADOR', 1),
(308, '3017048', 'Hoteles, S.A. Hoteles, S.A.', 'Boulevard de los Heroes y calle sis', 'SAN SALVADOR', 1),
(309, '3017049', 'Syngenta Crop Protection S.A. Suc Syngenta Crop Protection S.A. Suc', 'Calle Cortez Blanco Poniente #19 Ur', 'LA LIBERTAD', 1),
(310, '3017050', 'Inversiones Bonaventure, S.A. de C.', 'Km 27 1/2 Carretera a Sonsonate Lou', 'LA LIBERTAD', 1),
(311, '3017051', 'Aureos Central América Advisers Aureos Central América Advisers', 'Boulevard del Hipodromo Edificio Gr', 'SAN SALVADOR', 1),
(312, '3017052', 'J. Walter Thompson, S.A. de C.V.', 'Calle Loma Linda, Local 251,Col. Sa', 'SAN SALVADOR', 1),
(313, '3017055', 'DHL EXPRESS (EL SALVADOR), S.A. de', 'Blvd. Santa Elena Urb. Santa Elena', 'LA LIBERTAD', 1),
(314, '3017056', 'Omnilife El Salvador, S.A. de C.V.', '45 y 51  Avenida Norte y Alameda Ju', 'SAN SALVADOR', 1),
(315, '3017057', 'Tom Sawyer, S.A. de C.V.', 'Carretera a Santa Ana, Km 36, Zona', 'LA LIBERTAD', 1),
(316, '3017059', 'CTE, S.A. de C.V.', 'Complejo Telecom Roma Edificio F Pr', 'SAN SALVADOR', 1),
(317, '3017060', 'Baker Hughes El Salvador, Ltda. de', 'Boulevard Santa Elena Calle Alegría', 'LA LIBERTAD', 1),
(318, '3017061', 'Industria de Foam, S.A. de C.V.', 'Km 34 1/2 Hacienda San Andres. Ciud', 'LA LIBERTAD', 1),
(319, '3017063', 'DISTRIBUIDORA DE ELECTRICIDAD DEL S DISTRIBUIDORA DE ELECTRICIDAD DEL', 'Final 17 AV. Norte y calle al boque', 'LA LIBERTAD', 1),
(320, '3017093', 'MINERA  ATLAS, S.A. DE C.V.', 'C. Alegria y Blvd. Sta. Elena Edif.', 'ANTGUO CUSCATLAN', 1),
(321, '3017094', 'MINMET, S.A. DE C.V. MINMET, S.A. DE C.V.', 'C. Alegria y Blvd. Sta. Elena Edif.', 'ANTGUO CUSCATLAN', 1),
(322, '3017095', 'AMCOR RIGID PLASTICS EL SALVADOR AMCOR RIGID PLASTICS EL SALVADOR, S', 'KM. 28 Carretera a Sonsonate Lourde', 'LA LIBERTAD', 1),
(323, '3017097', 'Cisco Systems Cisco Systems El Salvador, LTDA. DE', '89 Avenidad Nte. Edificio World Tra', 'SAN SALVADOR', 1),
(324, '3017098', 'REPRESENTACIONES GC, S.A. DE C.V.', 'Boulevard Del Hipodromo Gran Plaza', 'SAN SALVADOR', 1),
(325, '3017099', 'Dessau-Soprin International Inc. Dessau-Soprin International Inc.', 'Boulevard El Hipodromo  No.111 Gran', 'SAN SALVADOR', 1),
(326, '3017100', 'DANONE EL SALVADOR, S.A. DE C.V.', 'Urb. Madre Selva III Etapa, calle C', 'SAN SALVADOR', 1),
(327, '3017101', 'INMOBILIARIA EL RODEO, S.A. DE C.V.', 'Avenida Olimpica #3330 Colonia Esca', 'SAN SALVADOR', 1),
(328, '3017102', 'BEMA DE EL SALVADOR, S.A. DE C.V.', 'Boulevard Santa Elena y Call gria ,', 'LA LIBERTAD', 1),
(329, '3017113', 'Constructora e Inmobiliaria C.A. de (Conica)', 'Calle Gabriel Rosales No. 34 B Rpto', 'SAN SALVADOR', 1),
(330, '3017114', 'INVERSIONES BONAVENTURE, S.A. DE C.', 'Km 27 1/2 Carretera a Sonsonate Lou', 'LA LIBERTAD', 1),
(331, '3017126', 'F.T.L LATAM, S.A. DE C.V.', 'Km 11 Carretera al Puerto la Libert', 'LA LIBERTAD', 1),
(332, '3017153', 'Jones Lang Lasalle, S.A. de C.V.', 'Calle la Mascota, #533 Colonia San', 'SAN SALVADOR', 1),
(333, '3017459', 'VoxBone SA NV', 'Boulevard de la Cambre 33', 'Brussels B1000', 1),
(334, '3017722', 'Abbott S.A. de C.V. Abbott S.A. de C.V.', 'Calle El Mirador 89 Avenida Norte e', 'SAN SALVADOR', 1),
(335, '3017723', 'Advanced Logistics Solutions Advanced Logistics Solutions', 'Boulevard del Ejercito Nacional KM.', 'SOYAPANGO', 1),
(336, '3017724', 'Agencias Global del Mar Agencias Global del Mar S.A. de C.', 'Edificio Corp. Lote 21 Urbanización', 'LA LIBERTAD', 1),
(337, '3017725', 'Agentes de El Salvador Agentes de El Salvador S.A. de C.V', '73 Av. Norte # 3 c-poniente #3839 7', 'SAN SALVADOR', 1),
(338, '3017726', 'Air Pak S.A. de C.V. Air Pak S.A. de C.V.', 'Alameda Roosevelt No. 2419 entre 45', 'SAN SALVADOR', 1),
(339, '3017727', 'Alarmas de El Salvador Alarmas de El Salvador S.A. de C.V', '73 Av. Norte # 3 c-poniente #3839 7', 'SAN SALVADOR', 1),
(340, '3017728', 'Almacenes Siman Almacenes Siman S.A. de C.V.', 'Oficinas Corporativas: Centro Comer', 'SAN SALVADOR', 1),
(341, '3017729', 'Mexichem El Salvador, S.A. de C.V', 'Boulevard del Ejercito Nac.0 km 30', 'SAN SALVADOR', 1),
(342, '3017730', 'Asociación Panamericana Asociación Panamericana de Mercadeo', '1a. Calle Poniente No. 20050 Coloni', 'SAN SALVADOR', 1),
(343, '3017731', 'OFIXPRES, S.A. DE C.V. OFIXPRES, S.A. DE C.V.', 'CALLE SIEMENS, URBANIZACION INDUSTR', 'LA LIBERTAD', 1),
(344, '3017732', 'Autocentro S.A. de C.V. Autocentro S.A. de C.V.', '49 Avenida Sur Boulevard Venezuela', 'SAN SALVADOR', 1),
(345, '3017733', 'Autofacil S.A. de C.V. Autofacil S.A. de C.V.', 'CALLE CERRO VERDE Y AV. LOS ANDES,', 'SAN SALVADOR', 1),
(346, '3017734', 'Autokia S.A. DE C.V. Autokia S.A. DE C.V.', 'Prolongación0 Alameda Juan Pablo II', 'SAN SALVADOR', 1),
(347, '3017735', 'Autoleasing S.A. de C.V. Autoleasing S.A. de C.V.', 'Avenida los Andes y Calle Cerro Ver', 'SAN SALVADOR', 1),
(348, '3017736', 'Automax S.A. de C.V. Automax S.A. de C.V.', 'F. Boulevard los Proceres No.3 Urb.', 'LA LIBERTAD', 1),
(349, '3017737', 'Banco Azteca El Salvador Banco Azteca El Salvador S.A.', 'Final 75 Avenida Sur #2140 Colonia', 'SAN SALVADOR', 1),
(350, '3017738', 'Banco Davivienda Salvadoreño, S. A. Banco Davivienda Salvadoreño, S. A', 'Avenida Olimpica #3550 Centro Finan', 'SAN SALVADOR', 1),
(351, '3017739', 'Banco Promérica S.A. Banco Promérica S.A.', 'Entre Carretera Panamericana y Call', 'LA LIBERTAD', 1),
(352, '3017740', 'BDF El Salvador BDF El Salvador S.A. de C.V.', 'Edificio Bayer 1er. Nivel Calle El', 'SAN SALVADOR', 1),
(353, '3017741', 'CARVAJAL EDUCACION, S.A DE C.V', 'Elena, La Libertad', 'LA LIBERTAD', 1),
(354, '3017742', 'Bimbo de El Salvador Bimbo de El Salvador S.A. de C.V.', 'Boulevard Pynsa lote 6 y 7 Poligon', 'LA LIBERTAD', 1),
(355, '3017743', 'Blue Oil El Salvador Blue Oil El Salvador S.A. de C.V.', 'Final Calle la Mascota0 Colonia Maq', 'SAN SALVADOR', 1),
(356, '3017744', 'C. Imberton S.A. de CV. C. Imberton S.A. de CV.', 'Carretera a La Libertad km 11.', 'LA LIBERTAD', 1),
(357, '3017745', 'Cargo Expreso Cargo Expreso S.A. de C.V.', 'Boulevard Bayer No. 37-C Zona Indus', 'LA LIBERTAD', 1),
(358, '3017746', 'Holcim El Salvador S.A. de C.V.', 'Calle Holcim Av. El Esp, Madre Selv', 'ANTGUO CUSCATLAN', 1),
(359, '3017747', 'Centron de El Salvador Centron de El Salvador S.A. de', 'Boulevard del Ejercito Nacional0 Km', 'SAN SALVADOR', 1),
(360, '3017748', 'Comisión Ejecutiva Hidro Comisión Ejecutiva Hidroelétrica', '9ª. Calle Pte. No. 950 Centro de Go', 'SAN SALVADOR', 1),
(361, '3017749', 'Compañía Bristol Myers Compañía Bristol Myers Squibb', 'KPMG Loma Linda No.266 Colonia San', 'SAN SALVADOR', 1),
(362, '3017750', 'Compañia de Servicios Compañia de Servicios S.A. de C.V.', 'Urbanización Industrial Plan de la', 'LA LIBERTAD', 1),
(363, '3017751', 'CONDUCEN PHELPS DODGE CENTRO AMERIC CONDUCEN PHELPS DODGE CENTRO AMERI', 'Calle Circunvalación Pol. 1, Edif.', 'ANTGUO CUSCATLAN', 1),
(364, '3017752', 'Constructora Meco Caabsa Constructora Meco Caabsa S.A.', 'Avenida Masferrer0 Pje. San Carlos', 'SAN SALVADOR', 1),
(365, '3017753', 'Constructora Meco S.A. Constructora Meco S.A.', 'Blvd. Santa Elena y Calle Alegria C', 'LA LIBERTAD', 1),
(366, '3017754', 'Construmarket S.A. de C.V. Construmarket S.A. de C.V.', 'Av. Albert Einstein #17-c Col. Loma', 'LA LIBERTAD', 1),
(367, '3017755', 'Corporación Applica Corporación Applica de C.V. Ltda.', '3ra. Calle Pte. No. 3689 Col. Escal', 'SAN SALVADOR', 1),
(368, '3017756', 'Corporación Hotelera Corporación Hotelera Internacional', 'km 40 1/2 Autopista Aeropuerto Coma', 'SAN SALVADOR', 1),
(369, '3017757', 'FCC CONSTRUCCION DE CENTROAMERICA FCC CONSTRUCCION DE CENTROAMERICA', 'Avenida Masferrer0 Pje. San Carlos', 'SAN SALVADOR', 1),
(370, '3017758', 'Courier International Courier International, S.A. de C.V.', 'BLVD DE EJERCITO NACIONAL KM. 3 1/2', 'SOYAPANGO', 1),
(371, '3017759', 'Dequipos S.A. de C.V. Dequipos S.A. de C.V.', 'Km 9 1/2 Carretera Hacia El Puerto', 'SAN SALVADOR', 1),
(372, '3017760', 'Didea Industrial Didea Industrial S.A. de C.V.', '4 Calle Pte. Y 21 Av. Sur San Salva', 'SAN SALVADOR', 1),
(373, '3017761', 'Didea Usados Didea Usados S.A. de C.V.', 'Blvd. Los Heroes0 y Alameda Juan Pa', 'SAN SALVADOR', 1),
(374, '3017762', 'Didea S.A de C.V. Didea S.A de C.V. (Distribuidora', 'Blvd. Los Heroes0 y Alameda Juan Pa', 'SAN SALVADOR', 1),
(375, '3017763', 'DINANT El Salvador DINANT El Salvador S.A. de C.V.', 'Boulvard del Ejercito Nacional0 Km', 'SAN SALVADOR', 1),
(376, '3017764', 'Distribuidora Monolit Distribuidora Monolit S.A. de C.V.', 'Final Boulevard Bayer y Calle L-3 P', 'LA LIBERTAD', 1),
(377, '3017765', 'Distribuidora de Harinas Distribuidora de Harinas de', 'Urbanizacion Industrial Plan de la', 'LA LIBERTAD', 1),
(378, '3017766', 'Distribuidora de Insumos Distribuidora de Insumos del Pan', 'Contiguo a Jardin Botanico Plan de', 'LA LIBERTAD', 1),
(379, '3017767', 'Distribuidora de Insumos Distribuidora de Insumos Fabriles', 'Contiguo a Jardin Botanico Plan de', 'LA LIBERTAD', 1),
(380, '3017768', 'Distribuidora Interameri Distribuidora Interamericana', 'Pasaje Privado B-5 Urbanización Ind', 'LA LIBERTAD', 1),
(381, '3017769', 'Edificadora MSG Edificadora MSG', 'Avenida Masferrer0 Pje. San Carlos', 'SAN SALVADOR', 1),
(382, '3017770', 'Editorial Santillana, S.A de C.V.', '3 Calle Pte. 87 Av. Nte. Col. Escal', 'SAN SALVADOR', 1),
(383, '3017771', 'Electricidad de Centroame Electricidad de Centroamérica', 'Final 17 Avenida Norte y Calle Al V', 'LA LIBERTAD', 1),
(384, '3017772', 'Elevadores Otis Elevadores Otis, S de R.L. de C.V,', 'CALLE JUAN J. CAÑAS E/83 Y 85 AV. S', 'SAN SALVADOR', 1),
(385, '3017773', 'Embotelladora la Cascada Embotelladora la Cascada S.A.', '27 Calle Ote. #2290 San Salvador0 E', 'SAN SALVADOR', 1),
(386, '3017774', 'Era S.A. de C.V. Era S.A. de C.V.', 'Edificio Corp. Lote 21 Urbanización', 'LA LIBERTAD', 1),
(387, '3017775', 'Servicios de Seguridad para persona Alto Riesgo,  S.A. de C.V.', '73 Av. Norte # 3 c-poniente #3839 7', 'SAN SALVADOR', 1),
(388, '3017776', 'Etesal S.A. de C.V. Etesal S.A. de C.V.', 'Calle Primavera #11 Parque Residenc', 'LA LIBERTAD', 1),
(389, '3017777', 'Europa Motors Europa Motors S.A. de C.V.', 'Paseo General Escalon local 1 centr', 'SAN SALVADOR', 1),
(390, '3017778', 'Farina S.A. de C.V. Farina S.A. de C.V.', 'Urbanización Industrial Plan de la', 'LA LIBERTAD', 1),
(391, '3017779', 'Fundación Bancaja Fundación Bancaja', 'Fundación Bancaja P1. de Tetuán0 23', 'SAN SALVADOR', 1),
(392, '3017780', 'GRUPO EDITORIAL NORMA, S.A. DE C.V.', 'Boulevard Bayer0 Poligono C #3', 'SAN SALVADOR', 1),
(393, '3017781', 'Grupo Especializado de As Grupo Especializado de Asistencia', 'Colonia San Francisco Avenida Bugam', 'SAN SALVADOR', 1),
(394, '3017782', 'Harisa S.A. de C.V. Harisa S.A. de C.V.', 'Urbanización Industrial Plan de la', 'LA LIBERTAD', 1),
(395, '3017783', 'Importadora y Exportadora Importadora y Exportadora Elektra', 'Final 75 Avenida Sur #2140 Colonia', 'SAN SALVADOR', 1),
(396, '3017784', 'Inmobiliaria Zacersa Inmobiliaria Zacersa de El Salvador', '3ª Calle Poniente entre 73 y 75 Ave', 'SAN SALVADOR', 1),
(397, '3017785', 'Jumex de El Salvador Jumex de El Salvador S.A. de C.V.', 'Km 19.5 Carretera a Quezaltepeque0', 'SAN SALVADOR', 1),
(398, '3017786', 'Kimberly Clark Kimberly Clark de Centro América', 'Km. 32 1/2 Carretera San Juan Opico', 'LA LIBERTAD', 1),
(399, '3017787', 'Mondelez El Salvador Ltda. De C.V.', 'World Trade Center, Torre 1, Nivel', 'LA LIBERTAD', 1),
(400, '3017788', 'Leterago S.A. de C.V. Leterago S.A. de C.V.', 'Urbanización Santa Elena #900 Boule', 'LA LIBERTAD', 1),
(401, '3017789', 'Mabe de El Salvador Mabe de El Salvador S.A. de C.V.', 'Boulevard del Ejercito Nacional0 Km', 'SAN SALVADOR', 1),
(402, '3017790', 'Maquinaria y Materiales Maquinaria y Materiales de', 'Calle Gabriel Rosales No. 34 B Rpto', 'SAN SALVADOR', 1),
(403, '3017791', 'McCormick de Centro Amé McCormick de Centro América', 'Blvd. Deininger y Av. Las Parmeras.', 'LA LIBERTAD', 1),
(404, '3017792', 'Monolit de El Salvador Monolit de El Salvador S.A. de', 'Calle siemens, Urb Sta Elena #45', 'ANTGUO CUSCATLAN', 1),
(405, '3017793', 'Montagri S.A. de C.V. Montagri S.A. de C.V.', 'Urbanización Industrial Plan de la', 'LA LIBERTAD', 1),
(406, '3017794', 'Morán Méndez Morán Méndez & Asociados S.A. de', 'Avenida Sierra Nevada y Calle Atlit', 'SAN SALVADOR', 1),
(407, '3017795', 'GMG SERVICIOS EL SALVADOR, S.A DE C GMG SERVICIOS EL SALVADOR, S.A DE', 'BOULEVARD ORDEN DE MALTA, URBANIZAC', 'ANTGUO CUSCATLAN', 1),
(408, '3017796', 'Muehlstein Muehlstein de El Salvador S.A.', 'Calle la Mascota y 79 Avenida Sur #', 'SAN SALVADOR', 1),
(409, '3017797', 'Nature´s Sunshine Nature´s Sunshine Products de', '9a. Calle Poniente #3916 Colonia Es', 'SAN SALVADOR', 1),
(410, '3017798', 'Navega.com S.A. Navega.com S.A. Surcusal', '63 Avenida Sur y Alameda Roosevelt', 'SAN SALVADOR', 1),
(411, '3017799', 'Neo Seguridad Neo Seguridad S.A. de C.V.', 'Centro Comercial Masferrer. 2do. Ni', 'SAN SALVADOR', 1),
(412, '3017800', 'Nixtamasa de Centroame Nixtamasa de Centroamérica', 'Plan de la Laguna0 Urbanización Ind', 'LA LIBERTAD', 1),
(413, '3017801', 'OD El Salvador Limitada OD El Salvador Limitada de C.V.', '49 y 51 Avenida Norte y Alameda Jua', 'SAN SALVADOR', 1),
(414, '3017802', 'Organización Panamericana Organización Panamericana de', '85 Avenida Norte y 15 Calle Ponient', 'SAN SALVADOR', 1),
(415, '3017803', 'P.C. Servicios P.C. Servicios S. A. de C. V.', 'Km 6 1/2 Boulevard del Ejercito Nac', 'SAN SALVADOR', 1),
(416, '3017804', 'Pan American Life Pan American Life Insurance Company', 'Edificio Palic0 Alameda Dr. Manuel', 'SAN SALVADOR', 1),
(417, '3017805', 'Payless Shoe Source Payless Shoe Source of  El Salvador', '79 Avenida Sur #332 Col. Escalon,', 'SAN SALVADOR', 1),
(418, '3017806', 'Pintura y Enderezado Pintura y Enderezado S.A. de C.V.', '12 Calle Pte. Y 21 Av. Sur Pte. A V', 'SAN SALVADOR', 1),
(419, '3017807', 'Pollo Campero de El Salv Pollo Campero de El Salvador', 'Km 6 1/2 Boulevard del Ejercito Nac', 'SAN SALVADOR', 1),
(420, '3017808', 'Preformas y Envases Preformas y Envases S.A. de C.V.', 'Carretera a Santa Ana Km. 31 Parc.', 'LA LIBERTAD', 1),
(421, '3017809', 'Productos Roche Productos Roche S.A. de C.V.', 'Blvd. del Hipodromo San Benito.', 'SAN SALVADOR', 1),
(422, '3017810', 'Productos Alimenticios Ideal S.A. de C.V.', 'Plan de la Laguna.', 'LA LIBERTAD', 1),
(423, '3017811', 'Protección de Valores Protección de Valores S.A. de C.V.', 'Calle Padres Aguilar No. 9 Colonia', 'SAN SALVADOR', 1),
(424, '3017812', 'Representaciones Autom Representaciones Automotrices', 'Final 4a. Calle Poniente 26 Col. La', 'LA LIBERTAD', 1),
(425, '3017813', 'Repuestos Didea S.A. de C.V. Repuestos Didea S.A. de C.V.', 'Av. Luis Poma, Prolongación Alameda', 'SAN SALVADOR', 1),
(426, '3017814', 'Rialsa S.A. de C.V. Rialsa S.A. de C.V.', '27 Calle Poniente No. 12700 Colonia', 'SAN SALVADOR', 1),
(427, '3017815', 'Roemmers S.A. de C.V. Roemmers S.A. de C.V.', 'Urbanización Santa Elena #900 Boule', 'LA LIBERTAD', 1),
(428, '3017816', 'Roo Hsing Garment Co, El Salvador, Roo Hsing Garment Co, El Salvador,', 'Calle Chaparrstique 18 y 19 Poligon', 'SAN SALVADOR', 1),
(429, '3017817', 'Rowe S.A. de C.V. Rowe S.A. de C.V.', 'Urbanización Santa Elena #900 Boule', 'LA LIBERTAD', 1),
(430, '3017818', 'RR Donnelley de El Salvad RR Donnelley de El Salvador', 'Km7 1/2 Boulevard del Ejercito Naci', 'SAN SALVADOR', 1),
(431, '3017819', 'Servigen S.A. de C.V. Servigen S.A. de C.V.', 'Urbanización Industrial Plan de la', 'LA LIBERTAD', 1),
(432, '3017820', 'Sociedad de Servicios Sociedad de Servicios S.A. de C.V.', 'Urbanización Industrial Plan de la', 'LA LIBERTAD', 1),
(433, '3017821', 'Solaire S.A. de C.V. Solaire S.A. de C.V.', '4ª. Calle Poniente y  21ª Avenida S', 'SAN SALVADOR', 1),
(434, '3017822', 'Suministro de Restaurantes S. A. de Suministros de Restaurantes,', 'Km 6 1/2 Boulevard del Ejercito Nac', 'SAN SALVADOR', 1),
(435, '3017823', 'Sykes El Salvador Ltda. Sykes El Salvador Ltda.', 'BLVD. DE LOS HEROES, FRENTE A MUNDO', 'SAN SALVADOR', 1),
(436, '3017824', 'Taller Didea Taller Didea S.A. de C.V.', 'Entre 51 Avenida Norte Col. Miramon', 'SAN SALVADOR', 1),
(437, '3017825', 'Tecniser S.A. de C.V. Tecniser S.A. de C.V.', 'Urbanización Industrial Plan de la', 'LA LIBERTAD', 1),
(438, '3017826', 'Telefónica Móviles El Salvador Telefónica Móviles El Salvador', '63 Avenida Sur y Alameda Roosevelt', 'SAN SALVADOR', 1),
(439, '3017827', 'Belcorp El Salvador, S.A. de C.V. Belcorp El Salvador, S.A. de C.V.', 'Avenida Miramundo #27 Residencial B', 'LA LIBERTAD', 1),
(440, '3017828', 'Transportes Sebastián Transportes Sebastián S.A. de C.V.', 'Edificio Corp. Lote 21 Urbanización', 'LA LIBERTAD', 1),
(441, '3017829', 'Tricsa S.A. de C.V. Tricsa S.A. de C.V.', 'Urbanización Industrial Plan de la', 'LA LIBERTAD', 1),
(442, '3017830', 'Unifersa Disagro Unifersa Disagro S.A. de C.V.', 'Km 9 1/2 Carretera Hacia El Puerto', 'SAN SALVADOR', 1),
(443, '3017831', 'Unimetal de El Salvador Unimetal de El Salvador S.A. de', 'Kilometro 2/5 Canton Limon Carreter', 'SAN SALVADOR', 1),
(444, '3017832', 'UPS SCS EL SALVADOR  LTDA  DE C.V. UPS SCS EL SALVADOR  LTDA  DE C.V.', 'Prol. Alameda Juan Pablo II Urb.Y P', 'SAN SALVADOR', 1),
(445, '3017833', 'Whirlpool El Salvador Whirlpool El Salvador S.A. de C.V.', '89 Avenida Nte. Y Calle el Mirador', 'SAN SALVADOR', 1),
(446, '3017834', 'AES Distribuidores Salvad AES Distribuidores Salvadoreños', '63 Av Sur y Alameda Roo Nivel 5 Cen', 'SAN SALVADOR', 1),
(447, '3017835', 'AES Empr Electr de El Sal AES Empresa Electrica de El Salva', '63 Av Sur y Alameda Roo Nivel 5 Cen', 'SAN SALVADOR', 1),
(448, '3017836', 'Distribui Electr de Usulu Distribuidora Electrica de Usulutan', '63 Av Sur y Alameda Roo Nivel 5 Cen', 'SAN SALVADOR', 1),
(449, '3017837', 'Edificadora MSG S.A. Edificadora MSG S.A. de C.V.', 'Avenida Masferrer Pje. San Carlos N', 'SAN SALVADOR', 1),
(450, '3017838', 'Empresa Electr de Oriente Empresa Electrica de Oriente', '63 Av Sur y Alameda Roo Nivel 5 Cen', 'SAN SALVADOR', 1),
(451, '3017839', 'Esika Cosmetic S.A. Esika Cosmetic S.A. de C.V.', 'Urbaniz Santa Elena Calle Conchagua', 'LA LIBERTAD', 1),
(452, '3017840', 'Jumex Centroamericana Jumex Centroamericana S.A. de C.V.', 'Km 19.5 Carret a Quezalt cant Los C', 'SAN SALVADOR', 1),
(453, '3017841', 'Poma Hermanos S.A. Poma Hermanos S.A. de C.V.', 'Boulevard Constitucion y 1 a.c. Pte', 'SAN SALVADOR', 1);
INSERT INTO `clientes` (`codigoCliente`, `codigo`, `nombreCliente`, `calle`, `poblacion`, `idEliminado`) VALUES
(454, '3017842', 'Real Hotels & Reso Cotur Real Hotels & Resorts Inc. (Cotur)', 'Palm Chambe No. 3 P. O. Box 3152 Ro', 'SAN SALVADOR', 1),
(455, '3017843', 'Corporac Hotel Internac Corporación Hotelera Internacional', 'km 40 1/2 Autopista Aeropuerto Coma', 'SAN SALVADOR', 1),
(456, '3017844', 'Hoteles S.A. Hoteles S.A.', 'Boulevard de Los Heroes y Avenida S', 'SAN SALVADOR', 1),
(457, '3017845', 'Office Depot C. A. Office Depot Centra America S.A.', '49 y 51 Avenida Norte y Alam Juan P', 'SAN SALVADOR', 1),
(458, '3017846', 'Sherwin Williams de C.A. Sherwin Williams de Centroamerica', 'Km 11 1/2 Carretera Panamericana a', 'SAN SALVADOR', 1),
(459, '3017847', 'Transportes Servitrans Transportes Servitrans S.A. De C.V', 'Calle Siemen Lote 3 Urb. Industrial', 'LA LIBERTAD', 1),
(460, '3017848', 'AMC NEW YORK', 'NUEVA YORK', 'NEW YORK', 1),
(461, '3017849', 'Fabrica Molinera Salvadoreña S.A.', 'Urbanizacion Industrial Plan de la', 'LA LIBERTAD', 1),
(462, '3017850', 'Asesoria en Mercadeo y Comercializa Asesoria en Mercadeo y Comercializ', '4a Calle Int. I 15-14', 'Zona 14', 1),
(463, '3017851', 'Danone de Guatemala S.A.', '12 avenida 2do nivel 16-66', 'Zona 10', 1),
(464, '3018103', 'Avicola Salvadoreña, S.A. de C.V.', 'Km 7 1/2 Blvd. Ejército Nac Antiguo', 'SOYAPANGO', 1),
(465, '3018104', 'Agrinegocios S.A. de C.V. Puestos d Agrinegocios S.A. de C.V. Puestos', 'Pasaje B Contiguo a HARISA Antiguo', 'LA LIBERTAD', 1),
(466, '3018105', 'Agriza Agriza S.A. de C.V.', 'Urbanizacion  Industrial Plan De La', 'LA LIBERTAD', 1),
(467, '3018106', 'Alimentos de Animales Alimentos de Animales   S.A. de C.V', 'Pje. B Zona Industrial Plan de la L', 'LA LIBERTAD', 1),
(468, '3018107', 'Avinsa Avinsa   S.A. de C.V.', 'Blvd. Del Ejercito Nacional Km. 7 E', 'SOYAPANGO', 1),
(469, '3018108', 'Centro de Servicios Integrados Centro de Servicios Integrados', 'Pje.B zona Indust. Plan de la Lagun', 'LA LIBERTAD', 1),
(470, '3018109', 'ESSO STANDARD OIL, S.A LIMITED', 'Carretera al puerto de la Libertad', 'LA LIBERTAD', 1),
(471, '3018110', 'Forrajes Forrajes Salvadoreños   S.A. de C.V', 'Calle Principal El Porvenir, Santa', 'EL PORVENIR', 1),
(472, '3018111', 'Global Bussiness Global Bussiness Services de Costa', 'Calle Cerro Verde y Av. Los Andes C', 'SAN SALVADOR', 1),
(473, '3018112', 'Inter. Auto. Advisory Inter. Auto. Advisory Marketing Ser', 'Entre Carretera Panamericana y Call', 'SAN SALVADOR', 1),
(474, '3018113', 'La Sultana, S.A DE C.V,', 'Pje. B Urbanizacion Industrial La L', 'LA LIBERTAD', 1),
(475, '3018114', 'Los Cedros Los Cedros   S.A. de C.V.', 'Canton San El Rosario El Porvenir S', 'SAN SALVADOR', 1),
(476, '3018115', 'Procter & Gamble Procter & Gamble Interamericas de E', 'Boulevard Bayer No. 37  C Zona Indu', 'SAN SALVADOR', 1),
(477, '3018116', 'Programa Binacional Programa Binacional', 'Avinida El Espino y Boulevard Sur0', 'SAN SALVADOR', 1),
(478, '3018117', 'Proveedora de Granjas Proveedora de Granjas   S.A. de C.V', 'Pje. B, Zona Industrial Plan de la', 'LA LIBERTAD', 1),
(479, '3018118', 'Unilever de Centro America, S.A.', 'C. El Mirador 87 Av. Norte Col. Esc', 'SAN SALVADOR', 1),
(480, '3018192', 'Ricoh RICOH EL SALVADOR, S.A DE C.V.', '55 AV. Sur # 153', 'SAN SALVADOR', 1),
(481, '3018315', 'Cinemark Honduras, S. de R.L.', 'Centro Comercial Mall Multiplaza 3e', 'La Libertad - Francisco Morazán', 1),
(482, '3018317', 'Cinemark Guatemala, Ltda.', '6 salas en Eskala Roosevelt', 'Mixco', 1),
(483, '3018520', 'NEXSYS DE CENTROAMERICA, S.A. DE C.', '1 Calle Poniente 47Av. NTE Apto. 1', 'SAN SALVADOR', 1),
(484, '3018600', 'Seminarios y Conferencias DTT El Sa Seminarios y Conferencias DTT El S', 'Calle cortez Blanco Poniente y pasa', 'LA LIBERTAD', 1),
(485, '3018782', 'Distribuidora del Centro, S.A. de C', 'Final Av. Cerro Verde, Col. Sierra', 'SAN SALVADOR', 1),
(486, '3018783', 'Compañía Distribuidora de Oriente,', 'Av. Cacahuatique # 40, Col. Chaparr', 'SAN MIGUEL', 1),
(487, '3018784', 'Compañía Distribuidora de Occidente', 'Calle La Pedrera L1, Calle octubre', 'SANTA ANA', 1),
(488, '3018785', 'LABORATORIOS TERAPEUTICOS LABORATORIOS TERAPEUTICOS', 'Avendia latepec #6 y #7 y calle cha', 'LA LIBERTAD', 1),
(489, '3018786', 'DISTRIBUIDORA PRINCIPAL, S.A. de C.', '1ra calle Poniente y 91 Av. Norte 4', 'SAN SALVADOR', 1),
(490, '3018787', 'GALEMI, S.A. de C.V.', 'Col. Escalon 91 Av. Norte 1cal 4713', 'SAN SALVADOR', 1),
(491, '3018788', 'Global Motors, S.A. de C.V.', 'Av. Masferrer Norte y 7 Bif. Calle', 'SAN SALVADOR', 1),
(492, '3019099', 'Monsanto El Salvador, S.A. de C.V.', 'Calle la mascota Col. San Benito, c', 'SAN SALVADOR', 1),
(493, '3019100', 'Semillas, S.A. de C.V.', 'Carretera Panamericana Oriente, Km.', 'ILOPANGO', 1),
(494, '3019101', 'Cofiño Stahl, S.A. de C.V.', 'BLVD ORDEN DE MALTA # 6 SANTA ELENA', 'ANTGUO CUSCATLAN', 1),
(495, '3019102', 'Eskimo El Salvador, S.A. de C.V.', 'Calle principal y Blvd. del Ejercit', 'SAN SALVADOR', 1),
(496, '3019114', 'Deloitte Tax LLP', 'Suite 400 333 SE 2nd Ave Ste 3600', 'Miami', 1),
(497, '3019322', 'Inmobiliaria Pricesmart El Salvador Inmobiliaria Pricesmart El Salvado', 'Calle Cortez Blanco y Avenida El Pe', 'SAN SALVADOR', 1),
(498, '3019439', 'Tribu Nazca, S.A.', 'Radial Santa Ana Belen, 2 Km. al no', 'SANTA ANA- SANTA ANA', 1),
(499, '3019641', 'Arnecom de El Salvador, S.A. DE C.V', 'Km. 71 1/2 Carretera de Sta. Ana a', 'SANTA ANA', 1),
(500, '3019761', 'MICROSOFT EL SALVADOR, S.A. DE C.V. MICROSOFT EL SALVADOR, S.A. DE C.V', '89Ave. Norte y Calle el mirador  Ed', 'SAN SALVADOR', 1),
(501, '3020150', 'EOPC EL SALVADOR, S.A. DE C.V. EOPC EL SALVADOR, S.A. DE C.V.', 'Boulevard del Ejercito Nacional Km.', 'SOYAPANGO', 1),
(502, '3020167', 'Procaps S.A.', 'Calle 80 No.78B-201', 'BARRANQUILLA', 1),
(503, '3020262', 'CORPORACION SALVADOREÑA DOS PINOS CORPORACION SALVADOREÑA DOS PINOS', '67 AVE. SUR PASAJE 2, No. 28 COL. E', 'SAN SALVADOR', 1),
(504, '3020263', 'ORAZUL ENERGY EL SALVADOR SOCIEDAD ORAZUL ENERGY EL SALVADOR SOCIEDAD', 'AV. EL ESPINO Y BOULEVARD SUR, EDIF', 'ANTGUO CUSCATLAN', 1),
(505, '3020264', 'CANAL DOCE DE TELEVISION, S.A. DE C CANAL DOCE DE TELEVISION, S.A. DE', 'BOULEVAR Y URBANIZACION SANTA ELENA', 'LA LIBERTAD', 1),
(506, '3020265', 'NESTLE EL SALVADOR, S.A. DE C.V. NESTLE EL SALVADOR, S.A. DE C.V.', 'Ed. Centro Corporativo Madre Selva', 'LA LIBERTAD', 1),
(507, '3020292', 'FEDERAL EXPRESS FEDERAL EXPRESS', 'MIAMI, USA', 'FLORIDA', 1),
(508, '3020293', 'BROWN FORMAN CORPORATION BROWN FORMAN CORPORATION', '850 DIXIE HIGHWAY, LOUISVILE, KENTU', 'KENTUCKY', 1),
(509, '3020294', 'TOTAL EL SALVADOR, S.A.DE C.V. TOTAL EL SALVADOR, S.A.DE C.V.', 'Carretera a Quezaltepeque Km. 24 La', 'QUEZALTEPEQUE', 1),
(510, '3020295', 'CADBURY ADAMS EL SALVADOR, S.A. DE CADBURY ADAMS EL SALVADOR, S.A. DE', 'Calle Chaparrastique y principal No', 'ANTGUO CUSCATLAN', 1),
(511, '3020329', 'YAZAKI MEXICO, S.A. DE C.V.', 'AVENIDA ROMULO GARZA 300 TACUBA NUE', 'NUEVO LEON', 1),
(512, '3020330', 'AVERY DENNISON RETAIL INFORMATION AVERY DENNISON RETAIL INFORMATION', 'Km. 28 1/2 Carretera a Comalapa, Lo', 'OLOCUILTA', 1),
(513, '3020363', 'COINCA, S.A. DE C.V.', 'CALLE LOMA LINDA #246 COL. SAN BENI', 'SAN SALVADOR', 1),
(514, '3020452', 'AGDO, S.A. AGDO, S.A.', 'Calle L-1 44C Ciudad Merliot, Boule', 'ANTGUO CUSCATLAN', 1),
(515, '3020560', 'FINANPESA, S.A DE C.V. FINANPESA, S.A DE C.V.', 'Calle Nueva No.1 Ed. Palic Torre No', 'SAN SALVADOR', 1),
(516, '3020572', 'OPERADORES LOGISTICOS RANSA, S.A.', 'Lote 17 y 18 Fracción 1 Col. Granja', 'Zona 4', 1),
(517, '3020650', 'FINANPESA, S.A. DE C.V. FINANPESA, S.A. DE C.V.', 'Calle Nueva No. 1 Edificio Palic To', 'SAN SALVADOR', 1),
(518, '3020739', 'UNO GUATEMALA, SOCIEDAD ANONIMA', '2A CALLE 8-01 EDIFICIO LAS CONCHAS', 'Zona 14', 1),
(519, '3020759', 'INMOBILIARIA ANGOLO, S.A. DE C.V. INMOBILIARIA ANGOLO, S.A. DE C.V.', 'Calle L 1. #44-C Ciudad Merliot Bou', 'LA LIBERTAD', 1),
(520, '3020760', 'OPERADORES LOGISTICOS RANSA, S.A. D OPERADORES LOGISTICOS RANSA, S.A.', 'Calle L.1 # 44-C Ciudad Merliot Bou', 'LA LIBERTAD', 1),
(521, '3020761', 'CUTUCO ENERGY CENTRAL AMERICA, S.A. CUTUCO ENERGY CENTRAL AMERICA, S.A', 'C. La Mascota Local No 2 Edif Arias', 'LA LIBERTAD', 1),
(522, '3020763', 'COMPAÑIA GENERAL DE EQUIPOS, S.A. D COMPAÑIA GENERAL DE EQUIPOS, S.A.', 'AV. LAS MERCEDES No. 401 COLONIA LA', 'SAN SALVADOR', 1),
(523, '3020764', 'EDITORIAL ALTAMIRANDO MADRIZ, S.A. EDITORIAL ALTAMIRANDO MADRIZ, S.A.', '11 C. Ote 271 Ave. Cuscatancingo', 'SAN SALVADOR', 1),
(524, '3020765', 'SYKES CENTRAL AMERICA, LTDA.', 'Boulevard de los Heroes entre Aveni', 'SAN SALVADOR', 1),
(525, '3020766', 'INVERSIONES FINANCIERAS PROMERICA, INVERSIONES FINANCIERAS PROMERICA,', 'Entre Carretera Panamericana y CL.', 'SAN SALVADOR', 1),
(526, '3020776', 'URBANO EXPRESS, S.A. DE C.V. URBANO EXPRESS, S.A. DE C.V.', '43 Avenida Norte , No. 228 Colonia', 'SAN SALVADOR', 1),
(527, '3020778', 'VAPE, S.A. DE C.V. VAPE, S.A. DE C.V.', 'Boulevard Sur, Ed. Eben Ezer Col. S', 'ANTGUO CUSCATLAN', 1),
(528, '3020779', 'REXIM, S.A. DE C.V. REXIM, S.A. DE C.V.', 'Boulevard Sur, Ed. Eben Ezer, Col.', 'ANTGUO CUSCATLAN', 1),
(529, '3020780', 'HEALTHCO PRODUCTS, S.A. DE C.V. HEALTHCO PRODUCTS, S.A. DE C.V.', 'Boulevard Sur, Urbanizacion Santa E', 'ANTGUO CUSCATLAN', 1),
(530, '3020781', 'IMPROSA SERVICIOS INTERNACIONALES, IMPROSA SERVICIOS INTERNACIONALES,', '63 Avenida Sur  y Alameda Roosevelt', 'SAN SALVADOR', 1),
(531, '3020782', 'INDUSTRIAS ALIMENTICIAS KERN´S INDUSTRIAS ALIMENTICIAS KERN´S', 'C. ppal y calle Chaparrastique Urb.', 'ANTGUO CUSCATLAN', 1),
(532, '3020947', 'COMPAÑIA DE JARABES Y BEBIDAS GASEO COMPAÑIA DE JARABES Y BEBIDAS GASE', '43 Calle 1-10 Zona 12 Monte Maria I', 'Villa Nueva', 1),
(533, '3021012', 'PHILIP MORRIS LATIN PHILIP MORRIS LATIN', 'SARGENTO CABRAL 6732 TORRE 2', 'VICENTE LOPEZ', 1),
(534, '3021018', 'SERVICIOS MERCANTILES Y TECNICOS, S SERVICIOS MERCANTILES Y TECNICOS,', 'Final 67 Avenida Sur y Pasaje Carbo', 'SAN SALVADOR', 1),
(535, '3021020', 'COLITE EL SALVADOR, S.A. DE C.V. COLITE EL SALVADOR, S.A. DE C.V.', 'Boulevard del Hipodromo Centro Come', 'SAN SALVADOR', 1),
(536, '3021083', 'L TRES COMUNICACIONES COSTA RICA SO L TRES COMUNICACIONES COSTA RICA', 'Zona Franca Ultrapark, Edificio 2 B', 'HEREDIA- HEREDIA', 1),
(537, '3021085', 'Orazul Energy El Salvador Investmen Orazul Energy El Salvador Investme', 'Av. El Espino, Blvd. Orden de Malta', 'SAN SALVADOR', 1),
(538, '3021086', 'Orazul Energy Comercializadora Orazul Energy Comercializadora', 'Ave. El Espino, Boulevard Orden de', 'SAN SALVADOR', 1),
(539, '3021087', 'MAERSK EL SALVADOR, S.A. DE C.V.', 'Colonia Escalon Calle La Loma y 7a.', 'SAN SALVADOR', 1),
(540, '3021143', 'Coca Cola Femsa S.A.B. DE C.V.', 'Guillermo Gonzalez Camarena No. 600', 'Mexico DF 01210', 1),
(541, '3021154', 'Ministerio de Economía', '8a. Avenida 10-43', 'Zona 1', 1),
(542, '3021203', 'PLYCEM CONSTRUSISTEMAS EL SALVADOR PLYCEM CONSTRUSISTEMAS EL SALVADOR', 'Carretera Panamericana Km. 12 1/2 F', 'ILOPANGO', 1),
(543, '3021258', 'TROPIGAS DE EL SALVADOR, S.A. TROPIGAS DE EL SALVADOR, S.A.', 'BLVD. DEL EJERCITO NACIONAL COL. MO', 'SOYAPANGO', 1),
(544, '3021259', 'TERMINALES DE GAS DEL PACIFICO, S.A TERMINALES DE GAS DEL PACIFICO, S.', 'CARRETERA A PLAYITAS KM. 25 PUENTE', 'LA UNION', 1),
(545, '3021260', 'METROGAS, S.A. DE C.V. METROGAS, S.A. DE C.V.', 'KM. 31 1/2 CARRETERA A SAN JUAN OPI', 'SAN JUAN OPICO', 1),
(546, '3021261', 'TRANSPORTES DEL ISTMO S.A. DE C.V. TRANSPORTES DEL ISTMO S.A. DE C.V.', 'KM. 31 1/2 CANTON SITIO DEL NIÑO CA', 'SAN JUAN OPICO', 1),
(547, '3021262', 'OFIXPRES, S.A. DE C.V. OFIXPRES, S.A. DE C.V.', 'CALLE SIEMENS URB, INDUSTRIAL SANTA', 'ANTGUO CUSCATLAN', 1),
(548, '3021263', 'BANCO AGRICOLA, S.A. BANCO AGRICOLA, S.A.', '1A. CALLE PONIENTE Y 67 AVENIDA No.', 'SAN SALVADOR', 1),
(549, '3021297', 'TERNIUM INTERNACIONAL EL SALVADOR, TERNIUM INTERNACIONAL EL SALVADOR,', 'Novena calle Oriente y 48 Avenida N', 'SAN SALVADOR', 1),
(550, '3021366', 'MENFAR, S.A. DE C.V. MENFAR, S.A. DE C.V.', 'CALLE EL PROGRESO No. 2711 COL. FLO', 'SAN SALVADOR', 1),
(551, '3021460', 'AMERICA GLOBAL LOGISTICS, S.A. DE C AMERICA GLOBAL LOGISTICS, S.A. DE', '79 Avenida Sur y Avenida Cuscatlan', 'SAN SALVADOR', 1),
(552, '3021471', 'Duke Energy International Operacion Duke Energy International Operacio', '5 Av. 5-55 Torre 3 Nivel 12 Edif. E', 'Zona 14', 1),
(553, '3021569', 'Pricesmart Honduras S.A.de C. V. Pricesmart Honduras S.A.de C. V.', 'Urbanizacion sector El Playon, 1', 'San Pedro Sula', 1),
(554, '3021706', 'GBM de Panamá, S.A.', 'Ave Principal y Ave La Rotonda,', 'Panamá, República de Panamá', 1),
(555, '3021782', 'BRITISH AMERICAN TOBACCO CENTRAL AM', 'ALAMEDA ROOSVELT 2115', 'SAN SALVADOR', 1),
(556, '3021835', 'CSI LEASING DE CENTROAMERICA CSI LEASING DE CENTROAMERICA', 'Centro Financiero SISA, Carretera a', 'SANTA TECLA', 1),
(557, '3021836', 'TELEFONICA MULTISERVICIOS, S.A. TELEFONICA MULTISERVICIOS, S.A.', 'NIVEL 10 TORRE B COLONIA ESCALON', 'SAN SALVADOR', 1),
(558, '3021946', 'Gas Salvadoreño, S.A. de C.V.', 'Blvd. Ejercito Nacional, Contiguo a', 'SAN SALVADOR', 1),
(559, '3021947', 'Certificaciones Industriales, S.A.', 'Calle a Colonia Monte Carmelo, Cont', 'SAN SALVADOR', 1),
(560, '3021948', 'EOPC El Salvador, S.A. de C.V.', 'Blvd. Ejercito Nacional, Km 6.5', 'SAN SALVADOR', 1),
(561, '3022019', 'Pochteca de El Salvador, S.A. de C.', 'Calle Circunvalación. Col. Santa Lu', 'SAN SALVADOR', 1),
(562, '3022020', 'Editorial Océano de El Salvador', 'Calle Circunvalación,Colonia San Be', 'SAN SALVADOR', 1),
(563, '3022038', 'Nestlé Centroamerica, S.A.', 'Urb. La Loma Calle 690 N°74 D', 'Panamá, R. de P.', 1),
(564, '3022158', 'Premium  Food Services, S.A.', 'Panamá', 'Panamá', 1),
(565, '3022166', 'Chep El Salvador, S.A. de C.V.', 'Boulevard del Hipódromo,Ed 237 3° P', 'SAN SALVADOR', 1),
(566, '3022222', 'AYESA ADVANCED TECHNOLOGIES, S.A.', 'Estadio Olímpico de Sevilla s/n Tor', 'Santiponce, Sevilla (España)', 1),
(567, '3022282', 'CHEP EL SALVADOR, S.A. DE C.V.', 'BOULEVARD DEL HIPODROMO COLONIA SAN', 'SAN SALVADOR', 1),
(568, '3022283', 'Operadora del Sur S.A de C.V', '65 AV SUR CENTRO FINANCIERO GIGANTE', 'SAN SALVADOR', 1),
(569, '3022302', 'ERICSSON EL SALVADOR, S.A. DE C.V.', '89 AVENIDA NORTE', 'SAN SALVADOR', 1),
(570, '3022329', 'FÁBRICA DE PRODUCTOS LÁCTEOS PARMA, FÁBRICA DE PRODUCTOS LÁCTEOS PARMA', '19 CALLE 10-54 ZONA 10, CIUDAD DE G', 'Zona 10', 1),
(571, '3022375', 'Asociación Bancaria Salvadoreña (AB ABANSA', 'Pasaje Senda Florida, No. 140, Colo', 'SAN SALVADOR', 1),
(572, '3022572', 'OPERADORES LOGISTICOS RANSA, S.A DE', 'Prolongación 27Calle, S.E. A 600 me', 'San Pedro Sula', 1),
(573, '3022602', 'Banco G&T Continental El Salvador,', 'Calle La Reforma Col. San Benito Ca', 'SAN SALVADOR', 1),
(574, '3022658', 'Constructora Santa Fe, limitada. Constructora Santa Fe, limitada.', 'Edif World Trade Center Torre I Loc', 'SAN SALVADOR', 1),
(575, '3022785', 'SERVICIOS FINANCIEROS, S.A. DE C.V.', 'BOULEVARD DEL HIPODROMO No. 576, CO', 'SAN SALVADOR', 1),
(576, '3022801', 'TRICSA, S.A. DE C.V.', 'Contiguo a Jardín Botánico', 'SAN SALVADOR', 1),
(577, '3022802', 'TECNISER, S.A. DE C.V.', 'Contiguo a Jadrín Botánico La Lagun', 'SAN SALVADOR', 1),
(578, '3022819', 'Zed El Salvador, S.A. de C.V.', 'Calle el mirador, Torre 2, Edif. Wo', 'SAN SALVADOR', 1),
(579, '3022901', 'MAXIPRENDA EL SALVADOR, S.A. DE C.V', '63 AVENIDA SUR Y ALAMEDA ROOSVELT C', 'SAN SALVADOR', 1),
(580, '3023031', 'FERRETERIA EPA, S.A. DE C.V', '29 CALLE ORIENTE ENTRE 10 Y 12 AV N', 'SAN SALVADOR', 1),
(581, '3023037', 'Deloitte Tax LLP', 'Miami 333.S.E. 2nd Avenue,Suite 360', 'Miami', 1),
(582, '3023105', 'CORPAN, S.A. DE C.V.', 'C. Chiltiupan A-1 Centro', 'SAN SALVADOR', 1),
(583, '3023118', 'DESCA EL SALVADOR, S.A. DE C.V.', 'FINAL CALLE FRANCISCO GAVIDIA No. 4', 'SAN SALVADOR', 1),
(584, '3023188', 'United Parcel Service Co. Sucursal United Parcel Service Co. Sucursal', 'Prolongacion Juan Pablo II, Urbaniz', 'SAN SALVADOR', 1),
(585, '3023189', 'Enterprise Solutions America, S.A.', 'Calle circunvalacion, colonia San B', 'SAN SALVADOR', 1),
(586, '3023236', 'SOLUCIONES DECORATIVAS, S.A. DE C.V', 'CALLE LA REFORMA No. 227, COLONIA S', 'SAN SALVADOR', 1),
(587, '3023334', 'Distribuidora del centro, S.A. de C', 'Final Av. Cerro Verde, Urbanización', 'SAN SALVADOR', 1),
(588, '3023336', 'Compañía Distribuidora de Oriente,', 'Avenida Cacahuatique No.40 Col. Cha', 'SAN SALVADOR', 1),
(589, '3023337', 'Compañía Distribuidora de Occidente', 'Calle La Padrera L-1, Colon e Octub', 'SAN SALVADOR', 1),
(590, '3023398', 'Empresas ADOC, S.A. de C.V.', 'Calle Montecarmelo No 800. Soyapang', 'SOYAPANGO', 1),
(591, '3023401', 'Duramas S.A de C.V. Duramas S.A de C.V.', 'Calle Rpto El Matazano No.1', 'SOYAPANGO', 1),
(592, '3023413', 'DACF Ltd', '30 Rockefeller , 42 Floor , New Yor', 'New York', 1),
(593, '3023506', 'S.I.T.A.', 'Blvd.Los Heroes Edif. Torre Roble,C', 'SAN SALVADOR', 1),
(594, '3023510', 'Carvajal Empaques S.A. de C.V.', 'KM 10 1/2 CARRETERA AL PUER LA LIBE', 'SAN SALVADOR', 1),
(595, '3023511', 'G&T Continental, S.A. de C.V.', 'Calle La Reforma, Col san Benito #2', 'SAN SALVADOR', 1),
(596, '3023581', 'New World Networks Ltd', '15950 W. Dixie Highway North Miami', 'Florida', 1),
(597, '3023645', 'Grupo Q El Salvador, S.A de C.V', 'Av. Las Amapolas, Edif. Grupo Q, Co', 'SAN SALVADOR', 1),
(598, '3023646', 'Empresa Propietaria de la Red, S.A. Sucursal El Salvador', 'Blvd. Merliot, Complejo Ofi, Bodega', 'SAN SALVADOR', 1),
(599, '3023685', 'APPLICA AMERICAS, INC. APPLICA AMERICAS, INC.', 'Dirección 601 Rayovac Drive Madison', 'Madison', 1),
(600, '3023820', 'Grupo Pacífico, S.A', 'Calle 50, Edificio Plaza 50 piso 2', 'Ciudad de Panamá', 1),
(601, '3023877', 'PriceSmart Inc', '9740 Scraton Road, Suite 125', 'San Diego, California', 1),
(602, '3024064', 'Administradora de Restaurantes de E Administradora de Restaurantes de', 'Blvd. del Ejercito Nacional Km 1/2', 'SOYAPANGO', 1),
(603, '3024070', 'DIGICEL, S.A. DE C.V.', 'Alameda Dr. manuel Enrique Araujo E', 'SAN SALVADOR', 1),
(604, '3024142', 'NACEL DE EL SALVADOR, S.A. DE C.V.', 'PaCalle Chaparrastique, No.30', 'ANTGUO CUSCATLAN', 1),
(605, '3024181', 'LA CONSTANCIA LIMITADA LA CONSTANCIA LIMITADA', 'Av. Independencia, #526', 'SAN SALVADOR', 1),
(606, '3024185', 'GMB El Salvador, S.A de C.V', 'Calle Loma Linda #246, Col. San Ben', 'SAN SALVADOR', 1),
(607, '3024232', 'SAN CRESPIN, S.A DE C.V', 'Calle Montecarmelo N.800, Predios d', 'SAN SALVADOR', 1),
(608, '3024233', 'PAR-2, S.A DE C.V', 'Calle Montecarmelo N.800, Predios d', 'SAN SALVADOR', 1),
(609, '3024234', 'ALMACENES ADOC, S.A', 'Calle Montecarmelo N.800, Predio', 'SAN SALVADOR', 1),
(610, '3024240', 'LOPAL, S.A DE C.V', 'Calle Montecarmelo N.800, Predios d', 'SAN SALVADOR', 1),
(611, '3024242', 'ALMACENES ESPECIALES, S.A DE C.V', 'Calle Montecarmelo N.800, Predios d', 'SOYAPANGO', 1),
(612, '3024250', 'SPECIALTY  RETAIL STORES, S.A DE C.', '7ma Calle Pte. y Calle La Ceiba No.', 'SAN SALVADOR', 1),
(613, '3024276', 'CALLE AZUL, S.A. DE C.V.', '29 CALLE ORIENTE LOCAL 1 Y 2, CENTR', 'SAN SALVADOR', 1),
(614, '3024298', 'SERVICIOS SANTA ELENA, S.A. DE C.V.', 'Km 9 1/2 Carretera al Puerto de la', 'SANTA TECLA', 1),
(615, '3024309', 'CALLE AZUL, S.A. DE C.V.', 'CENTRO COMERCIAL LAS TERRAZAS', 'SAN SALVADOR', 1),
(616, '3024312', 'GRUPO INDUSTRIAL DIVERSIFICADO GRUPO INDUSTRIAL DIVERSIFICADO', 'Km. 10 1/2 Carretera al Puerto de L', 'SANTA TECLA', 1),
(617, '3024343', 'EMPRESA PALOMO, S.A DE C.V', 'Calle Montecarmelo N.800, Predios d', 'SOYAPANGO', 1),
(618, '3024479', 'Panalpina, S.A. de C.V.', 'Calle Padres Aguilar No. 326 e 81 y', 'SAN SALVADOR', 1),
(619, '3024506', 'GRUPO Q CORPORATIVO, S.A DE C.V', 'Av. Las Amapolas, Edif. Grupo Q, Co', 'SAN SALVADOR', 1),
(620, '3024507', 'GRUPO Q PRODUCTOS AUTOMOTRICES, S.A', 'Av. Las Amapolas, Edif. Grupo Q, Co', 'SAN SALVADOR', 1),
(621, '3024508', 'SERVICIAL, S.A DE C.V', 'Autopista Sur, Col. San Mateo Edif.', 'SAN SALVADOR', 1),
(622, '3024509', 'Q MOTORS EL SALVADOR, S.A DE C.V', 'Av. Las Amapolas, Edif. Grupo Q, Co', 'SAN SALVADOR', 1),
(623, '3024510', 'GENERAL DE VEHICULOS, S.A DE C.V', 'Av. Las Amapolas, Edif. Grupo Q, Co', 'SAN SALVADOR', 1),
(624, '3024511', 'TURIN MOTORS, S.A DE C.V', 'Calle Marginal Block A, Casa # 1 Co', 'SAN SALVADOR', 1),
(625, '3024512', 'GRUPO GEVESA, S.A DE C.V', 'Blvd. Los Próceres y Av.# 1, Lomas', 'SAN SALVADOR', 1),
(626, '3024513', 'INVERSIONES GEVESA, S.A DE C.V', 'Calle # 1, Blvd. Los Proceres Lomas', 'SAN SALVADOR', 1),
(627, '3024515', 'INVERSIONES DOMINICANAS, S.A DE C.V', 'Km. 11, Carretera a Tecla SISA Edif', 'SAN SALVADOR', 1),
(628, '3024565', 'SITA INFORMATION NETWORKING SITA INFORMATION NETWORKING', 'Blvd.Los Heroes Edif. Torre Roble,', 'SAN SALVADOR', 1),
(629, '3024660', 'MANPOWER EL SALVADOR, S.A DE C.V', 'Av. bella vista, calle el almendro', 'ANTGUO CUSCATLAN', 1),
(630, '3024712', 'ADOC DE COSTA RICA SOCIEDAD ANONIMA', 'Pavas, de la Sylvania 150 metros oe', 'SAN JOSÉ- PAVAS', 1),
(631, '3024843', 'Procter & Gamble International Oper Procter & Gamble International Ope', 'Parque Empresarial Fórum 1 Pozos de', 'SAN JOSÉ- CARMEN', 1),
(632, '3024844', 'Operadores Logisticos de Centroamer Operadores Logisticos de Centroame', 'Calle L-I No. 44-C Blvd. Vijosa, Ci', 'La Libertad', 1),
(633, '3024896', 'ADOC DE NICARAGUA SOCIEDAD ANONIMA', 'Centro Comercial Managua Seccion C', 'Managua', 1),
(634, '3024947', 'Grupo Los Tres El Salvador, Grupo Los Tres El Salvador,', 'Calle La Reforma #113 Frente a Plaz', 'SAN SALVADOR', 1),
(635, '3024948', 'Los Seis de El Salvador, Los Seis de El Salvador,', 'Calle La Reforma #113 Frente a Plaz', 'SAN SALVADOR', 1),
(636, '3025023', 'TRANSACTEL EL SALVADOR, S.A DE C.V', '17 Av. Norte, Calle Chiltiupan, Cen', 'SAN SALVADOR', 1),
(637, '3025045', 'Arvato Digital Services GmbH', 'Carl Bertelsmann Strasse 161F', 'Carl Bertelsmann Strasse 161F', 1),
(638, '3025240', 'HENCORP, SOCIEDAD ANONIMA HENCORP, S.A. DE C.V.,', 'Madre Selva 3 Ed.AvanteNv 5 #5-06 A', 'LA LIBERTAD', 1),
(639, '3025311', 'DON POLLO, S.A. DE C.V.', 'BOULEVARD DEL EJERCITO NACI KM. 6.5', 'SAN SALVADOR', 1),
(640, '3025351', 'BANCO GENERAL, S.A.', 'Avenida Aquilino de la Guardia Marb', 'Panama', 1),
(641, '3025425', 'BT Guatemala, S.A.', '3 Avenida 13-78 Torre Citibank  Zon', 'Zona 10', 1),
(642, '3025442', 'Amazon.com, Inc.', '205210_Advertising_and_Marketing', 'Washington', 1),
(643, '3025512', 'Instituto Interamericano de Coopera', '600 metros  Norte del Cruce Ipís- C', 'VÁZQUEZ DE CORONADO- SAN ISIDRO', 1),
(644, '3025517', 'MOTOROLA SOLUTIONS EL SALVADOR, S.A', '71 Av. Norte Col. Escalón casa 346,', 'SAN SALVADOR', 1),
(645, '3025553', 'CORPORACION APPLICA DE CENTROAMERIC CORPORACION APPLICA DE CENTROAMERI', 'San José', 'SAN JOSÉ- HOSPITAL', 1),
(646, '3025720', 'Compartamos, S.A.', 'Diagonal 6 10-50 Edificio Interamer', 'Zona 10', 1),
(647, '3025791', 'OXFAM- SOLIDARIDAD', 'Residencial Decapolis pasaje los án', 'SAN SALVADOR', 1),
(648, '3025792', 'AGENCIA DE COOPERACION INTERNACIONA AGENCIA DE COOPERACION INTERNACION', 'TORRE FUTURA NIVEL 8 LOCAL 803,', 'SAN SALVADOR', 1),
(649, '3025793', 'SEGALE, S.A. DE C.V.', 'CALLE MONTE CARMELO NO. 800', 'SOYAPANGO', 1),
(650, '3025840', 'Exmar Shipmanagement N.V. Exmar Shipmanagement N.V.', 'De Gerlachekaai 20', 'Antwerpen', 1),
(651, '3025874', 'NATURACEITES, S.A. DE C.V.', 'BLVD. ACERO POL. C, LOTE 4, ZONA IN', 'ANTGUO CUSCATLAN', 1),
(652, '3025913', 'CEMEX EL SALVADOR, S.A DE C.V', 'De San Francisco Edif. Construmarke', 'ANTGUO CUSCATLAN', 1),
(653, '3026011', 'ASEGURADORA SUIZA SALVADOREÑA, S.A', 'San Benito C. La Reforma', 'SAN SALVADOR', 1),
(654, '3026019', 'ASESUISA VIDA, S.A. SEGURO DE PERSO', 'Plaza Suiza, Col. San Benito, San S', 'SAN SALVADOR', 1),
(655, '3026131', 'CIA. DE ALUMBRADO ELECTRICO DE CIA. DE ALUMBRADO ELECTRICO DE', 'Calle El Bambú, Colonia San Antonio', 'AYUTUXTEPEQUE', 1),
(656, '3026132', 'AES CLESSA Y COMPAÑIA, S. EN C. DE', '23. Av. Sur y 5a Calle Poniente, Ba', 'SANTA ANA', 1),
(657, '3026217', 'CINEPOLIS EL SALVADOR, S.A DE C.V', 'Centro Comercial Galerías, San Salv', 'SAN SALVADOR', 1),
(658, '3026287', 'Itochu Panama, S.A.', 'PH Plaza Canaima, piso 7, Edf. HSBC', 'Panamá, Rep. de Panamá', 1),
(659, '3026423', 'APPLICA CONSUMER PRODUCTS, INC.', '601 Rayovac', 'Madison', 1),
(660, '3026500', 'MEJALLOCE, S.A. DE C.V.', 'CALLE MONTECARMELO No. 800 PREDIOS', 'SOYAPANGO', 1),
(661, '3026501', 'SPENCER RUBBER, S.A. DE C.V.', 'CALLE MONTECARLO No.800 PREDIOS DE', 'SOYAPANGO', 1),
(662, '3026503', 'TENERIA ATEOS, S.A. DE C.V.', 'CALLE MONTECARLO No. 800 PREDIOS DE', 'SOYAPANGO', 1),
(663, '3026504', 'SISTEMAS DE CATALOGO, S.A. DE C.V.', 'CALLE MONTECARLO No. 800 PREDIOS DE', 'SOYAPANGO', 1),
(664, '3026505', 'SYVA, SOCIEDAD ANONIMA', 'CALLE MONTECARLO No. 800 PREDIOS DE', 'SOYAPANGO', 1),
(665, '3026506', 'VALERIA, S.A. DE C.V.', 'CALLE MONTECARLO No. 800 PREDIOS DE', 'SOYAPANGO', 1),
(666, '3026530', 'EL SALVADOR YOGA CENTER, S.A. DE C.', '7a. CALLE PONIENTE Y CALLE LA CEIBA', 'SAN SALVADOR', 1),
(667, '3026531', 'MEGA EL SALVADOR, S.A. DE C.V.', 'BLVDLUIS POMA, LOCAL 6 URBANIZACION', 'ANTGUO CUSCATLAN', 1),
(668, '3026532', 'DISPENCER, S.A. DE C.V', 'CALLE MONTECARLO No.800 PREDIOS DE', 'SOYAPANGO', 1),
(669, '3026533', 'FUNDACIO ADOC', 'CALLE MONTECARLO No.800 PREDIOS DE', 'SOYAPANGO', 1),
(670, '3026537', 'MEJALLOCE, S.A. DE C.V.', 'CALLE MONTECARLO nO.800 PREDIOS DE', 'SOYAPANGO', 1),
(671, '3026538', 'TENERIA ATEOS, S.A. DE C.V.', 'CALLE MONTECARLO NO.800 PREDIOS DE', 'SOYAPANGO', 1),
(672, '3026621', 'SIEMENS, S.A.', 'Calle Siemens,Urb. Sta Elena,Parque', 'ANTGUO CUSCATLAN', 1),
(673, '3026698', 'ITOCHU Latín América, S.A.', 'Av.Samuel Lewis,Plaza Canalma,Edif.', 'Panama', 1),
(674, '3026699', 'GRUPO Q INMOBILIARIA, S.A. DE C.V.', 'Av.Las Amapolas Edif.Q.Col.San Mate', 'SAN SALVADOR', 1),
(675, '3026747', 'AES Nejapa Services, Limitada de C.', '63 Av.Sur,Centro Financiero Gigante', 'SAN SALVADOR', 1),
(676, '3026748', 'AES Nejapa Gas, Limitada de C.V', '63 Av.Sur,Centro Financiero Torre 8', 'SAN SALVADOR', 1),
(677, '3026810', 'Telemovil, S.A. de C.V.', 'Carril al Puerto de la Libertad Km', 'SAN SALVADOR', 1),
(678, '3026962', 'DON POLLO, S.A. DE C.V. DON POLLO, S.A. DE C.V.', 'BOULEVARD DEL EJERCITO NACIONAL KM', 'SAN SALVADOR', 1),
(679, '3026963', 'EXCELENCIA GROUP, INC.', '7ma calle poniente la ce colonia es', 'SAN SALVADOR', 1),
(680, '3026964', 'NINE WEST PANAMA, S.A.', 'C.C. Multiplaza Pacific, Punta Paci', 'Panama', 1),
(681, '3026965', 'STEVE MADDEN PANAMA, S.A.', 'C.C. Multiplaza Pacific, Punta Paci', 'Panama', 1),
(682, '3026979', 'GRAFICOS Y TEXTOS, S.A DE C.V', 'entre calle conchagua izalco', 'LA LIBERTAD', 1),
(683, '3026980', 'DUTRIZ HERMANOS, S.A. DE C.V.', 'cal. conchagua y call. iz Cuscatlan', 'LA LIBERTAD', 1),
(684, '3026981', 'EMI EL SALVADOR, S.A DE C.V.', '105 AV NORTE 110 B ESCALON', 'SAN SALVADOR', 1),
(685, '3027026', 'GENERAL ELECTRIC INTERNATIONAL, INC GENERAL ELECTRIC INTERNATIONAL, IN', '79 Y 81 AV SUR #218 ESCALON', 'SAN SALVADOR', 1),
(686, '3027027', 'ALAS DORADAS, S.A. DE C.V. ALAS DORADAS, S.A. DE C.V.', 'KM 27 1/2 CARR. A SANTA JUAN OPICO', 'LA LIBERTAD', 1),
(687, '3027064', 'DELL EL SALVADOR, LIMITADA DELL EL SALVADOR, LIMITADA', '#533 calle la mascota san b COLONIA', 'SAN SALVADOR', 1),
(688, '3027093', 'RADA S.A.', 'Oficentro La Virgen, Edificio 2 pis', 'SAN JOSÉ- PAVAS', 1),
(689, '3027094', 'Asoc.Bancaria Salvadoreña ABANSA', 'Pasaje Senda Florida Norte #140 col', 'SAN SALVADOR', 1),
(690, '3027099', 'DAR KOLOR, S.A. DE C.V', 'KM.28 1/2 Car. Sta Ana, Par Indu El', 'LA LIBERTAD', 1),
(691, '3027333', 'ALKIMIA, S.A. DE C.V.', 'Paseo General Escalon 143, Col Esca', 'SAN SALVADOR', 1),
(692, '3027363', 'DIAMOND GROUP, SOCIEDAD ANONIMA DIAMOND GROUP, SOCIEDAD ANONIMA', 'Local 220, C.C. Galerías #3700', 'SAN SALVADOR', 1),
(693, '3027364', 'MP4 SOCIEDAD ANONIMA DE CAPITAL VAR', 'Edificio Alas Doradas Km 27 1/2 Car', 'SAN JUAN OPICO', 1),
(694, '3027365', 'FIBRAS Y CELULOSAS, S.A. DE C.V.', 'Km 27 1/2 Carretera a Santa Ana, CT', 'SAN JUAN OPICO', 1),
(695, '3027366', 'MAQUINARIA Y SUMINISTROS PAPELEROS, MAQUINARIA Y SUMINISTROS PAPELEROS', 'Km 27 1/2 Carretera a Santa Ana CTG', 'SAN JUAN OPICO', 1),
(696, '3027367', 'INDUSTRIALES ASOCIADOS, S.A. DE C.V', 'Km 27 1/2 Carretera a Santa Ana, CT', 'SAN JUAN OPICO', 1),
(697, '3027484', 'BROWN-FORMAN WORLDWIDE, L.L.C. BROWN-FORMAN WORLDWIDE, L.L.C.', 'Av. Buganvillas #23, Colonia San Fr', 'SAN SALVADOR', 1),
(698, '3027498', 'Siemens S.A. de C.V.', 'Polanco V, Seccion Miguel Hidalgo 1', 'Distrito Federal, México D.F.', 1),
(699, '3027550', 'ASOCIACIÓN DE FOMENTO INTEGRAL ASOCIACIÓN DE FOMENTO INTEGRAL', 'Alameda Roosevelth #1807 Frente a E', 'SAN SALVADOR', 1),
(700, '3027561', 'FINCA MICROFINANZAS, SOCIEDAD ANONI FINCA MICROFINANZAS, SOCIEDAD ANON', '1A calle Poniente, colonia Escalon', 'SAN SALVADOR', 1),
(701, '3027688', 'SISAL ES, S.A DE C.V', 'Entre Av.Jerusalen y Av.El Pedregal', 'ANTGUO CUSCATLAN', 1),
(702, '3027706', 'PROMOTORA MUSICAL, S.A. DE C.V.', 'Carretera Panamericana 43 a 47 Cent', 'ANTGUO CUSCATLAN', 1),
(703, '3027707', 'CORPORACIÓN DE TIENDAS INTERNACIONA CORPORACIÓN DE TIENDAS INTERNACION', 'Carretera Panamericana 1, C.C. Mult', 'ANTGUO CUSCATLAN', 1),
(704, '3027746', 'Livisto, S.A. de C.V. Livisto, S.A. de C.V.', 'Carretera al Puerto de La Libertad,', 'LA LIBERTAD', 1),
(705, '3027862', 'ASOCIACION DE EMPLEADOS EMPRESAS ASOCIACION DE EMPLEADOS EMPRESAS', 'Calle Montecarmelo, Col. Montecarme', 'SOYAPANGO', 1),
(706, '3027863', 'YKK EL SALVADOR, S.A. DE C.V.', 'Km 31 1/2 Carretera a Santa Ana', 'SAN JUAN OPICO', 1),
(707, '3028062', 'GRUPO PRIDES DE EL SALVADOR, GRUPO PRIDES DE EL SALVADOR,', '89 Av. Nte C/ El Mirador Edif. WTC', 'SAN SALVADOR', 1),
(708, '3028145', 'AUSTRALIAN DAIRY GOODS EL SALVADOR, AUSTRALIAN DAIRY GOODS EL SALVADOR', 'CalleCircunvalación Block a Urb. In', 'ANTGUO CUSCATLAN', 1),
(709, '3028146', 'DIZAC, S.A. DE C.V.', 'Urbanizacion Industrial Plan de la', 'ANTGUO CUSCATLAN', 1),
(710, '3028161', 'DISTRIBUIDORES Y PRODUCTORES, S.A. DISTRIBUIDORES Y PRODUCTORES, S.A.', 'Plan de la LAguna, Block B#15,', 'ANTGUO CUSCATLAN', 1),
(711, '3028247', 'PROCTER & GAMBLE INTERNATIONAL PROCTER & GAMBLE INTERNATIONAL', 'Centro Empresarial Forum.  Edificio', 'SANTA ANA- SANTA ANA', 1),
(712, '3028342', 'The Church of Jesus Christ of Latte The Church of Jesus Christ of Latt', 'Los Angeles', 'Los Angeles', 1),
(713, '3028349', 'INDUSTRIAL VETERINARIA, S.A.', 'Km.20 Carretera al Puerto de la Lib', 'ZARAGOZA', 1),
(714, '3028692', 'PROYECTO BODEGAS DE EL SALVADOR PROYECTO BODEGAS DE EL SALVADOR', '89 AV NORTE COLONIA ESCALON # 673', 'SAN SALVADOR', 1),
(715, '3028758', 'Sistemas de Transportes y Bodegas d Sistemas de Transportes y Bodegas', 'Bvld. Pynsa calle L-2 atrás de Baye', 'ANTGUO CUSCATLAN', 1),
(716, '3028759', 'Intereses Agiles, S.A. DE C.V.', 'Bvld. Pynsa Zona Industrial Ciudad', 'ANTGUO CUSCATLAN', 1),
(717, '3028760', 'Viva Outdoor, S.A. de C.V.', 'Calle L-3 BLVD. SI-HAM, Z. Industri', 'ANTGUO CUSCATLAN', 1),
(718, '3028839', 'PACIFIC CREDIT RATING, S.A. DE C.V.', 'Av Capilla, Psj 8, Cond La Capilla', 'SAN SALVADOR', 1),
(719, '3028891', 'BANCO DE AMERICA CENTRAL, S.A.', '55AV. SUR ENTRE ALAMEDA ROOSVEL Y A', 'SAN SALVADOR', 1),
(720, '3028906', 'Huawei Telecommunications El Salva  Huawei Telecommunications El Salv', 'C. llama del bosque poniente SDA S,', 'ANTGUO CUSCATLAN', 1),
(721, '3028921', 'Organismo Internacional regional de Sanidad Agropecuaria', 'Ramón Belloso, final pasaje Isoide', 'SAN SALVADOR', 1),
(722, '3028926', 'Banco de Desarrollo de El Salvador', 'World Trade Center, en la colonia E', 'SAN SALVADOR', 1),
(723, '3028964', 'EXPORT IMPORT INTERNATIONAL, SOCIED EXPORT IMPORT INTERNATIONAL, SOCIE', 'CALLE LA MASCOTA, COLONIA SAN BENIT', 'SAN SALVADOR', 1),
(724, '3028965', 'Samsung Electronics LATAM (Zona Lib Samsung Electronics LATAM (Zona Li', 'Calle Llama del Bosque, Local 3-12,', 'SAN SALVADOR', 1),
(725, '3029020', 'UNIFI CENTRAL AMERICA, LIMITADA DE UNIFI CENTRAL AMERICA, LIMITADA DE', 'C Panamericana Km 36 Block F Z Amer', 'LA LIBERTAD', 1),
(726, '3029021', 'CONTRATACIONES INTERAMERICANAS, S.A CONTRATACIONES INTERAMERICANAS, S.', 'AV. 77 AV. NORTE PSJ. ITSMANIA, LOC', 'SAN SALVADOR', 1),
(727, '3029022', 'COMERCIALIZADORA LEO, S.A. DE C.V.', 'Calle Circunvalacion, Plan de la La', 'ANTGUO CUSCATLAN', 1),
(728, '3029023', 'COMERCIALIZADORA INTERAMERICANA, S. COMERCIALIZADORA INTERAMERICANA, S', 'AV. 77 AV. NORTE PSJ. ITSMANIA, LOC', 'SAN SALVADOR', 1),
(729, '3029024', 'MARIPOSA EL SALVADOR, S.A. DE C.V.', 'AV. 77 AV. NORTE PSJ. ITSMANIA, LOC', 'SAN SALVADOR', 1),
(730, '3029026', 'CORPORACION AGROENERGETICA, S.A. DE', 'Calle La Mascota PSJ 4. Col. La Mas', 'SAN SALVADOR', 1),
(731, '3029122', 'CAFETALERA DEL PACIFICO, SOCIEDAD CAFETALERA DEL PACIFICO, SOCIEDAD', 'Carretera a Sta Tecla local 8 Edif', 'LA LIBERTAD', 1),
(732, '3029133', 'BIOAGRO DE ORIENTE, S.A. DE C.V.', 'Calle la Mascota PSJ 4. Col. La Mas', 'SAN SALVADOR', 1),
(733, '3029134', 'DESARROLLOS AGRO, S.A. DE C.V.', 'Calle La Mascota PSJ4. Col. La Masc', 'SAN SALVADOR', 1),
(734, '3029135', 'RENOVABLES DE EL SALVADOR, S.A. DE', 'Calle La Mascota PSJ 4 Col. La Masc', 'SAN SALVADOR', 1),
(735, '3029136', 'BIODESARROLLADORA AGRICOLA, S.A. DE', 'Calle La Mascota PSJ 4 Col. La Masc', 'SAN SALVADOR', 1),
(736, '3029137', 'AGROBIO, S.A. DE C.V.', 'Calle La Mascota PSJ 4 Col. La Masc', 'SAN SALVADOR', 1),
(737, '3029138', 'DESARROLLADORA ENERGETICA, S.A. DE', 'Calle La Mascota PSJ 4 Col. La Masc', 'SAN SALVADOR', 1),
(738, '3029139', 'BIOENERTEXT, S.A. DE C.V.', 'Calle La Mascota 4 PSJ Col. La Masc', 'SAN SALVADOR', 1),
(739, '3029140', 'AGROMEGA, S.A. DE C.V.', 'Calle La Mascota 4 PSJ Co. La Masco', 'SAN SALVADOR', 1),
(740, '3029141', 'BIOENERGIA DE EL SALVADOR, S.A. DE', 'Calle La Mascota 4 PSJ Col. La Masc', 'SAN SALVADOR', 1),
(741, '3029142', 'AGROINDUSTRIAS BIO, S.A. DE C.V.', 'Calle La Mascota 4 PSJ Col. La Masc', 'SAN SALVADOR', 1),
(742, '3029172', 'RICORP, S.A. DE C.V.', 'Edificio BVES Jardines de la Hacien', 'ANTGUO CUSCATLAN', 1),
(743, '3029176', 'Banco Cuscatlán de El Salvador, S.A', 'Pirámide Citi Carretera a Santa Tec', 'SAN SALVADOR', 1),
(744, '3029192', 'LAFISE AGROBOLSA DE EL SALVADOR, S.', 'Edif WTC T.2 Local 305 89 Av Norte', 'SAN SALVADOR', 1),
(745, '3029202', 'OUTSOURCING SERVICES INTERNATIONAL S.A. DE C.V.', 'Edificio Avante 4-02 Urb Madreselva', 'ANTGUO CUSCATLAN', 1),
(746, '3029228', 'SEGACORP, S.A. DE C.V.', 'Paseo General Escalón, No. 5432 Col', 'SAN SALVADOR', 1),
(747, '3029253', 'DACF Ltd', '1633 Broadway New York, NY 10019, U', 'New York, NY 10019', 1),
(748, '3029291', 'VOLUNTARIOS CONSTRUYENDO EL SALVADO', 'Calle los Claveles Col. La Sultana', 'ANTGUO CUSCATLAN', 1),
(749, '3029292', 'LAS BRUMAS, S.A. DE C.V.', '17 av. Sur 14 CL. Ote', 'SANTA TECLA', 1),
(750, '3029364', 'ESCUELA ESPECIALIZADA EN INGENIERIA ITCA-FEPADE', 'Carrt a Sta Tecla Km 11 1/2', 'SANTA TECLA', 1),
(751, '3029366', 'CUPON CLUB, S.A. DE C.V.', '9a Calle Pte, Col. Escalon #3815', 'SAN SALVADOR', 1),
(752, '3029377', 'CELPAC, S.A. DE C.V.', 'Boulevard del Ejército Nacional, Km', 'ILOPANGO', 1),
(753, '3029378', 'CAJAS Y BOLSAS, S.A.', 'Boulevard del Ejército Nacional, Km', 'SOYAPANGO', 1),
(754, '3029380', 'CAJAS PLEGADIZAS, S.A. DE C.V.', 'Boulevard del Ejército Nacional, Km', 'SOYAPANGO', 1),
(755, '3029395', 'FONDO DE INVERSION SOCIAL PARA EL DESARROLLO LOCAL DE EL SALVADOR', 'Boulevard Orden de Malta, #470 Urba', 'ANTGUO CUSCATLAN', 1),
(756, '3029396', 'PRODUCTOS ALIMENTICIOS DIANA, S.A. PRODUCTOS ALIMENTICIOS DIANA, S.A.', '12 Av. Sur #111, Contiguo a Fabrica', 'SOYAPANGO', 1),
(757, '3029418', 'PHILIPS LIGHTING CENTRAL AMERICA, S DE C.V.', 'Carr. Comalapa Km 28 1/2, L 9 Edif', 'OLOCUILTA', 1),
(758, '3029422', 'BAYER, S.A.', 'LOCAL 2 CTRO. COM. LA GRAN VIA EDIF', 'ANTGUO CUSCATLAN', 1),
(759, '3029453', 'SAN MIGUEL PET EL SALVADOR, S.A. DE', '27 Calle Ote. 2 Av. Norte # 1523', 'SAN SALVADOR', 1),
(760, '3029488', 'BANCO DE FOMENTO AGROPECUARIO', 'Carr. al Puerto de La Libertad Km.', 'LA LIBERTAD', 1),
(761, '3029501', 'PROCALIDAD DE EL SALVADOR, S.A. DE', 'Carr. a Quetzaltepeque Km 17 Flexi', 'APOPA', 1),
(762, '3029532', 'CORPORACION BONIMA, S.A. DE C.V.', 'Km 11 1/2 Carretera Panamericana, p', 'ILOPANGO', 1),
(763, '3029562', 'ASAMBLEA LEGISLATIVA', '9 Calle Pniente y 15 Av. Norte, Cen', 'SAN SALVADOR', 1),
(764, '3029601', 'SCHLUMBERGER SURENCO, S.A. SUCURSAL EL SALVADOR', 'Alam Manuel Enri Araujo C. La Masco', 'SAN SALVADOR', 1),
(765, '3029602', 'TET EL SALVADOR, S.A. DE C.V.', 'CARR. CA-1 KM 17.5, #8 Y 9, PARQUE', 'APOPA', 1),
(766, '3029606', 'UNICOSERVI, S.A. DE C.V.', 'Final Calle la Mascota, Col. Maquil', 'SAN SALVADOR', 1),
(767, '3029643', 'DISMOSAL, S.A. DE C.V.', 'Alameda Roosevelt No. 2922 Contiguo', 'SAN SALVADOR', 1),
(768, '3029653', 'INDUSTRIAS MAGAÑA L., S.A. DE C.V.', 'Carretera a Metapan, Km 69 1/2', 'SANTA ANA', 1),
(769, '3029706', 'MAPFRE LA CENTRO AMERICANA, S.A. MAPFRE LA CENTRO AMERICANA, S.A.', 'Alameda Roosevelt, Edificio La Cent', 'SAN SALVADOR', 1),
(770, '3029727', 'Agencia de Promoción de Exportacion Agencia de Promoción de Exportacio', 'Boulevard Orden de Malta, Edificio', 'ANTGUO CUSCATLAN', 1),
(771, '3029759', 'EL SALVADOR YOGA CENTER, S.A. DE C.', '7a. Calle Pte y Calle la Ceiba #492', 'SAN SALVADOR', 1),
(772, '3029804', 'SERVICIOS SHASA, S DE RL DE CV', 'Aeropuerto Miguel Aleman 154 11 Ran', 'Lerma de Villada', 1),
(773, '3029808', 'KAESER COMPRESORES DE EL SALVADOR, LTDA. DE C.V.', '61 Av. Nte. y 1a. C. Pte. No. 3150', 'SAN SALVADOR', 1),
(774, '3029811', 'TARJETAS DE ORO, S.A. DE C.V.', 'Bvld. Los Próceres, Edif. Torre Cus', 'ANTGUO CUSCATLAN', 1),
(775, '3029812', 'SERVICIOS INTEGRALES SIC, S.A. DE C', 'KM. 7 1/2, LOTE 5-D-A, AUTOPISTA A', 'SAN MARCOS', 1),
(776, '3029813', 'REMESAS FAMILIARES CUSCATLÁN, REMESAS FAMILIARES CUSCATLÁN,', 'Av. Albert Einsten y Blvd. Los Próc', 'ANTGUO CUSCATLAN', 1),
(777, '3029814', 'SEGUROS E INVERSIONES, S.A.', 'Carretera Panamericana, KM 10 1/2', 'SANTA TECLA', 1),
(778, '3029815', 'SISA, VIDA, S.A. SEGUROS DE PERSONA', 'KM 10 1/2 Carretera Panamericana', 'SANTA TECLA', 1),
(779, '3029816', 'ADMINISTRADORA DE FONDOS DE PENSION ADMINISTRADORA DE FONDOS DE PENSIO', 'Alam. Dr. Manuel Enrique Araujo, Co', 'SAN SALVADOR', 1),
(780, '3029817', 'Tarjetas Cuscatlán de El Salvador, Tarjetas Cuscatlán de El Salvador,', 'Km. 7 1/2 Edif. Citi, Autopista a C', 'SAN MARCOS', 1),
(781, '3029825', 'CITIBANK, N.A. SUCURSAL EL SALVADOR', 'Alam Dr Manuel E. Araujo Edi Palic', 'SAN SALVADOR', 1),
(782, '3029827', 'INFO CENTROAMERICA, S.A. DE C.V. INFO CENTROAMERICA, S.A. DE C.V.', 'C. La Mascota, Col. San Benito #533', 'SAN SALVADOR', 1),
(783, '3029848', 'ECOFIBRAS, S.A. DE C.V.', 'Calle a Valle Nuevo, Lote C Costado', 'ILOPANGO', 1),
(784, '3029874', 'SABRITAS Y CÍA. S. EN C. DE C.V.', 'CALLE EL PROGRESO, LOTE 13,14,15, F', 'ANTGUO CUSCATLAN', 1),
(785, '3030022', 'EMPACADORA TOLEDO DE EL SALVADOR, EMPACADORA TOLEDO DE EL SALVADOR,', 'Blvrd. del ejercito Nac. Km 7 1/2 E', 'SOYAPANGO', 1),
(786, '3030199', 'ATENTO EL SALVADOR, S.A. DE C.V.', '63Av Sur y Alam Roosevelt Cent Fina', 'SAN SALVADOR', 1),
(787, '3030335', 'JOVENMODA, S.A. DE C.V.', 'C. Paseo General Escalon Col. Escal', 'SAN SALVADOR', 1),
(788, '3030338', 'PROMODA, S.A. DE C.V.', 'Col Escalon Ctro Com Galerias Casa', 'SAN SALVADOR', 1),
(789, '3030370', 'INNOVA TECNOLOGIA Y NEGOCIOS, S.A. INNOVA TECNOLOGIA Y NEGOCIOS, S.A.', '17 Av. Norte Carr. Al Boueron Km 12', 'SANTA TECLA', 1),
(790, '3030371', 'CREDISIMAN, S.A. DE C.V.', 'Paseo General Escalón, Col. Escalón', 'SAN SALVADOR', 1),
(791, '3030372', 'FABRICA DE CONFECCION SIMAN, S.A. FABRICA DE CONFECCION SIMAN, S.A.', 'Col. Escalón Casa 3100 C.C Galerias', 'SAN SALVADOR', 1),
(792, '3030373', 'QUANTUM ENERGY, S.A. DE C.V.', 'Blvd. El Hipódromo Col. San Benito', 'SAN SALVADOR', 1),
(793, '3030374', 'GRUPO EMPRESARIAL CYBSA, S.A. DE C.', 'Blvd. del Ejército Nac Km 7 1/2 Caj', 'SOYAPANGO', 1),
(794, '3030376', 'PROYECTOS ROMA, S.A. DE C.V.', 'Blvd. del Ejército Nac Km 8 dentro', 'ILOPANGO', 1),
(795, '3030377', 'SERVICIOS MERCANTILES, S.A. DE C.V.', 'Blvd. del Ejército Nac KM 8 dentro', 'ILOPANGO', 1),
(796, '3030383', 'DHL ZONA FRANCA (EL SALVADOR), S.A. DHL ZONA FRANCA (EL SALVADOR), S.A', '47a Av. NTE #104 Col. Las Terrazas', 'SAN SALVADOR', 1),
(797, '3030384', 'DHL GLOBAL FORWARDING (EL SALVADOR) DHL GLOBAL FORWARDING (EL SALVADOR', 'Km 18.5 Edif DHL, Nueva Carretera a', 'APOPA', 1),
(798, '3030449', 'NEJAPA POWER COMPANY, L.L.C.', 'Blvd. Santa Elena Urb. Santa Elena', 'ANTGUO CUSCATLAN', 1),
(799, '3030499', 'BLACKHAWK SUPPORT SERVICES (EL SALV , LTDA. DE C.V.', 'Blvd. Luis Poma, Edi.f Avante, #5-0', 'ANTGUO CUSCATLAN', 1),
(800, '3030533', 'BEARCOM, S.A. DE C.V.', 'Avenida Olímpica No. 3428', 'SAN SALVADOR', 1),
(801, '3030534', 'INDUSTRIAS MERLET, S.A. DE C.V. INDUSTRIAS MERLET, S.A. DE C.V.', 'Calle Circunvalacion Poligono A3', 'ANTGUO CUSCATLAN', 1),
(802, '3030535', 'INDUSTRIAS ST.JACKS, S.A. DE C.V.', 'Calle Circunvalación Poligono B #11', 'SAN SALVADOR', 1),
(803, '3030536', 'INGENIO EL ANGEL, S.A. DE C.V.', 'Carretera a Quetzaltepeque Km. 14 1', 'APOPA', 1),
(804, '3030537', 'EUROMODA, S.A. DE C.V.', 'P. Gen. Escalon Col. Escalon N.3700', 'SAN SALVADOR', 1),
(805, '3030538', 'IBEROMODA, S.A. DE C.V.', 'P. Gral Escalon Col Escalon #3700 C', 'SAN SALVADOR', 1),
(806, '3030544', 'AFP CONFIA S.A.', 'Alameda Dr Manuel Enrique Araujo No', 'SAN SALVADOR', 1),
(807, '3030569', 'POLARIS CAPITAL, S.A. DE C.V.', 'Torre Futura 9-3, Calle El Mirador,', 'SAN SALVADOR', 1),
(808, '3030690', 'AENOR CENTROAMERICA, S.A. DE C.V.', 'Calle Conchagua Pte. No. 7 Urb. Mad', 'ANTGUO CUSCATLAN', 1),
(809, '3030742', 'MAILROOM, S.A. DE C.V.', '43 Av. Nte. No. 228 Col. Flor Blanc', 'SAN SALVADOR', 1),
(810, '3030743', 'DIVECO EL SALVADOR, S.A. DE C.V.', 'Calle el Progreso Av. El Rosal # C-', 'SAN SALVADOR', 1),
(811, '3030791', 'HIPOTECARIA SANTA ANA LIMITADA DE HIPOTECARIA SANTA ANA LIMITADA DE', '63av sur alam roosvelt ctro financi', 'SAN SALVADOR', 1),
(812, '3030792', 'HIPOTECARIA SAN MIGUEL LIMITADA DE HIPOTECARIA SAN MIGUEL LIMITADA DE', '63av sur alam roosvelt ctro financi', 'SAN SALVADOR', 1),
(813, '3030793', 'ENERGIA Y SERVICIOS DE EL SALVADOR, ENERGIA Y SERVICIOS DE EL SALVADOR', '3 calle pte 3689 col escalon', 'SAN SALVADOR', 1),
(814, '3030802', 'AES CLESA ELECTRICIDAD, S.A. DE C.V', '5 av nte barrio santa barbara, 8', 'SANTA ANA', 1),
(815, '3030803', 'AES DISTRIBUIDORES SALVADOREÑOS Y C AES DISTRIBUIDORES SALVADOREÑOS Y', '63av Sur Alam Roosvelt Ctro Financi', 'SAN SALVADOR', 1),
(816, '3030804', 'AES FONSECA ENERGIA LIMITADA DE CAP AES FONSECA ENERGIA LIMITADA DE CA', '63av Sur Alam Roosvelt Ctro Financi', 'SAN SALVADOR', 1),
(817, '3030805', 'AES SERVICIOS ELECTRICOS LIMITADA D', '63av Sur Alam Roosvelt Ctro Financi', 'SAN SALVADOR', 1),
(818, '3030806', 'AES SERVICIOS ELECTRICOS Y COMPAÑÍA AES SERVICIOS ELECTRICOS Y COMPAÑÍ', '63av Sur Alam Roosvelt Ctro Financi', 'SAN SALVADOR', 1),
(819, '3030807', 'AES TRANSMISORES SALVADOREÑOS LTDA. AES TRANSMISORES SALVADOREÑOS LTDA', '63av Sur Alam Roosvelt Ctro Financi', 'SAN SALVADOR', 1),
(820, '3030909', 'LIVSMART AMERICAS, S.A. DE C.V.', 'Carr. a Sonsonate Lourdes Colon KM', 'SONSONATE', 1),
(821, '3030968', 'IMCARD, S.A. DE C.V.', 'Blvd. Orden de Malta, Edificio No.', 'ANTGUO CUSCATLAN', 1),
(822, '3030991', 'CREDIQ, S.A. DE C.V.', 'Boulevard Los Proceres y Calle Los', 'SAN SALVADOR', 1),
(823, '3030992', 'ASEGURADORA AGRICOLA COMERCIAL, S.A', 'Alam. Roosevelt 1855, 3104 Edif. AC', 'SAN SALVADOR', 1),
(824, '3030999', 'COLUMBUS NETWORKS EL SALVADOR, S.A. COLUMBUS NETWORKS EL SALVADOR, S.A', 'Calle llama del Bosque pte Urb Madr', 'ANTGUO CUSCATLAN', 1),
(825, '3031044', 'GTM El Salvador, S.A. de C.V.', 'Ant Carr Panamericana Km 7 1/2', 'SOYAPANGO', 1),
(826, '3031084', 'HIDROTECNIA DE EL SALVADOR, S.A.', 'Carretera Panamericana, Local 2A, C', 'ANTGUO CUSCATLAN', 1),
(827, '3031149', 'COLOCATION TECHNOLOGIES, LIMITADA', '2 CALLE 7-93 ZONA 14 EDIFICIO LAS C', 'Zona 14', 1),
(828, '3031178', 'PHILIP MORRIS EL SALVADOR, S.A. DE', '87av.Nte & 11 calle pte Nivel 10 L.', 'SAN SALVADOR', 1),
(829, '3031179', 'CORPORACION MULTI INVERSIONES, S.A. CORPORACION MULTI INVERSIONES, S.A', 'Boulevard del ejercito nacional Km', 'SOYAPANGO', 1),
(830, '3031180', 'AFP CRECER, S.A.', 'Blvd De Los Heroes Metrocentro Edif', 'SAN SALVADOR', 1),
(831, '3031181', 'SHASA EL SALVADOR, LIMITADA DE CAPI SHASA EL SALVADOR, LIMITADA DE CAP', 'Calle Pedregal Carr Panamericana Lo', 'ANTGUO CUSCATLAN', 1),
(832, '3031249', 'PINTUCO EL SALVADOR, S.A. DE C.V.', 'C.Circunvilación#2 Compl Indust Las', 'ANTGUO CUSCATLAN', 1),
(833, '3031282', 'DISTRIBUIDORA TENNIS, S.A. DE C.V.', 'PSJ. Senda Florida Norte, Col. Colo', 'SAN SALVADOR', 1),
(834, '3031399', 'CONSEJO DE VIGILANCIA DE LA PROFESI CONSEJO DE VIGILANCIA DE LA PROFES', '71Av. Sur #239 Col Escalón', 'SAN SALVADOR', 1),
(835, '3031406', 'Brightstar Corporation', '1111 Bagby Street, Suite 4500, Hous', 'texas', 1),
(836, '3031499', 'DISTRIBUIDORA ZABLAH, S.A. DE C.V.', '17 Av Sur y 14 Calle Ote. Carretera', 'SANTA TECLA', 1),
(837, '3031503', 'DISTRIBUIDORA ADOC DE HONDURAS SA', 'Barrio Rio de Piedra 8 y 9 Calle 21', 'San Pedro Sula', 1),
(838, '3031543', 'ADOC INTERNATIONAL TRADING CORP. ADOC INTERNATIONAL TRADING CORP.', 'Calle Montecarmelo No. 800', 'SOYAPANGO', 1),
(839, '3031547', 'AMWAY EL SALVADOR, S.A. DE C.V.', 'Calle La Reforma frente a Pórtico,', 'SAN SALVADOR', 1),
(840, '3031617', 'Puratos Group NV', 'Berkenlaan 8A, B-1831 Diegem, Belgi', 'Berkenlaan', 1),
(841, '3031628', 'DISTRIBUIDORA CHAPARRASTIQUE, S.A. DISTRIBUIDORA CHAPARRASTIQUE, S.A.', 'BOULEVAR VENEZUELA Y 29 DE AGOSTO S', 'SAN SALVADOR', 1),
(842, '3031630', 'RARO, S.A. DE C.V.', 'C. L-2 BLVD. ACERO ZONA INDUSTRIAL', 'ANTGUO CUSCATLAN', 1),
(843, '3031653', 'QUALITAS COMPAÑÍA DE SEGUROS, S.A.', 'Blvd Orden De Malta Sur # 15 Bloque', 'ANTGUO CUSCATLAN', 1),
(844, '3031659', 'BRIGHSTAR, EL SALVADOR, S.A. DE C.V', 'Local A-29 Ctro Com Metro Sur Edif', 'SAN SALVADOR', 1),
(845, '3031660', 'BANCO INDUSTRIAL EL SALVADOR, S.A.', 'Av. Las Magnolias #144 Col. San Ben', 'SAN SALVADOR', 1),
(846, '3031673', 'AMWAY LATIN AMERICA S DE RL DE CV', 'Blvd Lic. Gustavo Diaz Ordaz 123 Ri', 'Monterrey', 1),
(847, '3031744', 'LA CENTRAL DE SEGUROS Y FINANZAS, S', 'Avenida Olimpica N. 3333', 'SAN SALVADOR', 1),
(848, '3031745', 'BANCO ATLANTIDA EL SALVADOR, S.A. BANCO ATLANTIDA EL SALVADOR, S.A.', 'Blvd. Constitucion y 1ra Calle Poni', 'SAN SALVADOR', 1),
(849, '3031808', 'AGROQUIMICA INTERNACIONAL, S.A. DE', 'KM. 31 CARRET. A SN JUAN OPICO, COL', 'SAN JUAN OPICO', 1),
(850, '3031809', 'DISTRIBUIDORA NACIONAL, S.A. DE C.V', '17 AV. SUR 4 CARR AL PUERTO DE LA L', 'SANTA TECLA', 1),
(851, '3031810', 'INVERMOBIL, S.A. DE C.V.', '17 AV SUR Y 14 CALLE OTE EDIF DISZA', 'SANTA TECLA', 1),
(852, '3031811', 'OPERADORA LOGISTICA SALVADOREÑA, S. OPERADORA LOGISTICA SALVADOREÑA, S', '17 AV. SUR 14 CALLE ORIENTE EDIF. D', 'SANTA TECLA', 1),
(853, '3031861', 'ADOC DE PANAMA, S.A.', 'Calle Montecarmelo No. 800', 'SOYAPANGO', 1),
(854, '3031862', 'Unilever Business and Marketing Sup Unilever Business and Marketing Su', 'Spitalstrasse 5, 8200 Schaffhausen', 'Schaffhausen', 1),
(855, '3031933', 'QUIROMAR, S.A.', 'Blvd.  de Los Proceres y Av. Las Am', 'SAN SALVADOR', 1),
(856, '3031945', 'SERVICIOS FINANCIEROS ENLACE, S.A. SERVICIOS FINANCIEROS ENLACE, S.A.', '6 Av. Norte Calle José Ciriaco Lópe', 'SANTA TECLA', 1),
(857, '3031948', 'FRITOLAY DE GUATEMALA Y COMPAÑIA FRITOLAY DE GUATEMALA Y COMPAÑIA', 'Calz. San Juan 34-01', 'Zona 7', 1),
(858, '3032145', 'IMPLEMENTOS AGRICOLAS CENTROAMERICA IMPLEMENTOS AGRICOLAS CENTROAMERIC', 'Final Calle Poniente, parque indust', 'SANTA ANA', 1),
(859, '3032146', 'ASOCIACION LICEO FRANCES', 'Km 10.5 Carretera a Sta. Tecla Cont', 'LA LIBERTAD', 1),
(860, '3032147', 'HECTOR ERNESTO MATA AVILES', 'CALLE Y COL. LA MASCOTA #458', 'SAN SALVADOR', 1),
(861, '3032148', 'SOCIEDAD DE AHORRO Y CREDITO MULTIV SOCIEDAD DE AHORRO Y CREDITO MULTI', 'URB. EL MAQUILISHUAT Y CALLE LA MAS', 'SAN SALVADOR', 1),
(862, '3032203', 'INTI INVERSIONES INTERAMERICANAS CO', 'Ed. P.H. 909 Piso 15 y 16 Calle 50', 'San Francisco', 1),
(863, '3032214', 'UNIVERSIDAD DR. JOSÉ MATÍAS DELGADO', 'Km. 8 1/2 carretera a Sta. Tecla', 'SANTA TECLA', 1),
(864, '3032303', 'DISTRIBUIDORA SALVADOREÑA DE DISTRIBUIDORA SALVADOREÑA DE', 'Blvd. SI-Ham #15 Zona Industrial Me', 'ANTGUO CUSCATLAN', 1),
(865, '3032304', 'LABORATORIOS LOPEZ, S.A. DE C.V.', 'Blvd del Ejército Nacional, Km 5 1/', 'SAN SALVADOR', 1),
(866, '3032424', 'International Finance Corporation', '2121 Pennsylvania Avenue, NW', 'Washington', 1),
(867, '3032431', 'INTERNATIONAL FINANCE CORPORATION', '13 calle 3-40 Edificio Atlantis Niv', 'Zona 10', 1),
(868, '3032517', 'World Bank', '1818 h street, n.w.Washington 20433', 'Washington', 1),
(869, '3032521', 'Siemens AG', 'Wittelsbacherplatz 2 80333', 'MUNICH', 1),
(870, '3032524', 'CONTINENTAL TOWERS EL SALVADOR, LTD CONTINENTAL TOWERS EL SALVADOR, LT', 'Av. La Capilla 359-C pje 8 Col. San', 'SAN SALVADOR', 1),
(871, '3032526', 'UNFPA FINANCE BRANCH', '605 Third avenue, 5th Floor United', 'New York', 1),
(872, '3032527', 'BRENNTAG EL SALVADOR, S.A. DE C.V.', 'Km. 7 1/2 Blvd del Ejercito Naciona', 'SOYAPANGO', 1),
(873, '3032528', 'Suramericana S.A.', 'Calle 49B No. 63 - 21 Piso 1', 'MEDELLIN', 1),
(874, '3032611', 'CATCO, CORP.', 'Av. Samuel Lewis y Calle 54 Edif. A', 'Pamaná', 1),
(875, '3032612', 'CENTRAL AMERICA TRADE (CATCO) CORP.', '9500 NW 108th Av. MIAMI FL, 33178', 'Miami', 1),
(876, '3032614', 'TARSCO CORPORATION', '1200 Valley West Drive, Suite 30, M', 'Iowa', 1),
(877, '3032823', 'U.S. PHARMACY SYSTEMS, INC.', 'Parque Lefevre, Urb. Costa del Este', 'Casa Local No. 31', 1),
(878, '3032866', 'COMERCIALIZADORA SAN DIEGO, S.A. DE', 'C. Llama del Bosque local 9-9 Urb.', 'ANTGUO CUSCATLAN', 1),
(879, '3032884', 'AMERICARES FUNDACION INC.', 'Final pasaje Herrera, Bo. San Anton', 'STGO DE MARIA', 1),
(880, '3032967', 'COLLOCATION TECHNOLOGIES EL SALVADO COLLOCATION TECHNOLOGIES EL SALVAD', 'Av. La Capilla 359-C Pje B Colonia', 'SAN SALVADOR', 1),
(881, '3032968', 'MINISTERIO DE LA DEFENSA NACIONAL', 'KM 5 1/2 CARRETERA A SANTA TECLA', 'SAN SALVADOR', 1),
(882, '3032986', 'ABB, S.A.', 'Av. Las Americas 18-81 Edif. Colomb', 'Zona 14', 1),
(883, '3032995', 'GETCOM, S.A. DE C.V.', 'Col. Escalon 71 Av norte y 3a Calle', 'SAN SALVADOR', 1);
INSERT INTO `clientes` (`codigoCliente`, `codigo`, `nombreCliente`, `calle`, `poblacion`, `idEliminado`) VALUES
(884, '3033107', 'ENERGIA Y SERVICIOS DEL ISTMO ENERGIA Y SERVICIOS DEL ISTMO', 'Av. 1 Col Brisas de San Fco. #6', 'SAN SALVADOR', 1),
(885, '3033119', 'DISMATEL, S.A. DE C.V.', 'Blvd. constitucion #8 col. Miralval', 'SAN SALVADOR', 1),
(886, '3033155', 'CDI, S.A.', '19 Av. 15-62 apartamento A', 'Zona 10', 1),
(887, '3033168', 'UCP WHEELS FOR HUMANITY', '', 'SAN SALVADOR', 1),
(888, '3033170', 'Cinven Capital Management', '', 'Londres', 1),
(889, '3033209', 'INVERSIONES ZACBE, S.A. DE C.V.', 'Urb. Plan de la Laguna, Block B 1', 'ANTGUO CUSCATLAN', 1),
(890, '3033210', 'CENTRO INDUSTRIAL, S.A. DE C.V.', 'Urb. Plan de la Laguna Block B 15', 'ANTGUO CUSCATLAN', 1),
(891, '3033218', 'PURATOS DE EL SALVADOR, S.A. DE C.V', 'Blvd Acero Calle L-2 No. 1073 Z. In', 'ANTGUO CUSCATLAN', 1),
(892, '3033235', 'BASF DE EL SALVADOR, S.A. DE C.V.', '89 Av. Nte, Local 207 Col. Escalon', 'SAN SALVADOR', 1),
(893, '3033289', 'RULESWARE DE RESPONSABILIDAD LIMITA RULESWARE DE RESPONSABILIDAD LIMIT', 'Edificio y Torre Avante, 8vo Nivel,', 'ANTGUO CUSCATLAN', 1),
(894, '3033479', 'COMERCIALIZADORA Y PRODUCTORA DE BE COMERCIALIZADORA Y PRODUCTORA DE B', 'Av. Reforma 9-55, Edificio Reforma', 'Zona 10', 1),
(895, '3033502', 'TERMOENCOGIBLES, S.A. DE C.V.', 'Calle L-3 Polígono D, Lotes 1 y 2,', 'LA LIBERTAD', 1),
(896, '3033526', 'INTEK EL SALVADOR, S.A. DE C.V.', 'Calle Gabriela Mistral No. 373', 'SAN SALVADOR', 1),
(897, '3033527', 'AIRLINE SUPPORT SERVICES OF EL SALV AIRLINE SUPPORT SERVICES OF EL SAL', 'Residencial Madre Selva III, Calle', 'ANTGUO CUSCATLAN', 1),
(898, '3033531', 'BANCO HIPOTECARIO', 'Pasaje Senda Florida Sur Colonia Es', 'SAN SALVADOR', 1),
(899, '3033657', 'CARIBE HOSPITALITY EL SALVADOR, S.A CARIBE HOSPITALITY EL SALVADOR, S.', 'Esquina Calle 2 y C. 3, Centro de E', 'ANTGUO CUSCATLAN', 1),
(900, '3033730', 'Grupo Industrial Alimenticio , S.A.', 'Km. 26.5, Carretera Al Pacifico,', 'Amatitlán', 1),
(901, '3033784', 'PROFILAXIS, S.A. DE C.V.', 'Km. 27 Carretera a Sonsonate, desvi', 'LA LIBERTAD', 1),
(902, '3033785', 'LA FABRIL DE ACEITES, S.A. DE C.V.', 'Blvd. Del Ejercito Km 5 1/2 No 5500', 'SOYAPANGO', 1),
(903, '3033811', 'SOCIEDAD DE AHORRO Y CRÉDITO APOYO SOCIEDAD DE AHORRO Y CRÉDITO APOYO', 'Alameda Roosevelt y 47 Av. Sur, Col', 'SAN SALVADOR', 1),
(904, '3033865', 'DESCORTEZADO, S.A. DE C.V.', 'Calle L-1 #23 Urb. Industrial', 'SOYAPANGO', 1),
(905, '3033908', 'FONDO DE CONSERVACION VIAL', 'Km. 10 1/2 carretera al Puerto de l', 'ANTGUO CUSCATLAN', 1),
(906, '3033912', 'AEROMANTENIMIENTO, S.A.', 'San Luis Talpa Acceso 6', 'SAN LUIS TALPA', 1),
(907, '3033994', 'FONDO SOLIDARIO PARA LA SALUD', 'Calle Arce No. 267', 'SAN SALVADOR', 1),
(908, '3034094', 'FÁBRICA DE CALZADO SAN BOSCO, S.A.', 'Calle y avenida: Ruta 104 Av. 15', 'SAN JOSÉ- CARMEN', 1),
(909, '3034119', 'DELOITTE & TOUCHE LTDA.', 'Calle 16 Sur No. 43 A - 49 Piso 9', 'MEDELLIN', 1),
(910, '3034156', 'IMFICA, S.A. DE C.V.', 'Km 22 1/2 Carr Troncal del Nte., Ca', 'ANTGUO CUSCATLAN', 1),
(911, '3034157', 'CENTRO NACIONAL DE REGISTROS', '1a Calle Poniente y 43 Av. norte #2', 'SAN SALVADOR', 1),
(912, '3034227', '3M EL SALVADOR, S.A. DE C.V.', 'Urb. Industrial Santa Elena Calle C', 'ANTGUO CUSCATLAN', 1),
(913, '3034228', 'GEORGE C. MOORE - EL SALVADOR, LTDA GEORGE C. MOORE - EL SALVADOR, LTD', 'Carretera a Santa Ana Km. 36 Zona F', 'CIUDAD ARCE', 1),
(914, '3034328', 'INTER-EQUIPOS, S.A. DE C.V.', 'Av. La Capilla pi. 6 #144', 'SAN SALVADOR', 1),
(915, '3034360', 'ASA POSTER, S.A. DE C.V.', 'Clle. L-3 Blvd Siham Zna Indus Merl', 'ANTGUO CUSCATLAN', 1),
(916, '3034463', 'MONTREAL, S.A. DE C.V.', 'Urb. San Frco. Clle, Los Abetos N-2', 'SAN SALVADOR', 1),
(917, '3034464', 'FONDO SOCIAL PARA LA VIVIENDA', 'Calle Ruben Dario No. 901', 'SAN SALVADOR', 1),
(918, '3034496', 'COMPAÑÍA DE ENERGÍA DE CENTROAMERIC COMPAÑÍA DE ENERGÍA DE CENTROAMERI', 'Edificio FUSADES, Urbanizacion Sant', 'ANTGUO CUSCATLAN', 1),
(919, '3034517', 'BT LATAM EL SALVADOR, S.A. DE C.V.', 'Blvd. Orden de Malta, Centro prof.', 'LA LIBERTAD', 1),
(920, '3034519', 'BT EL SALVADOR LIMITADA DE C.V.', 'Blvd. Orden de Malta, Centro prof.', 'LA LIBERTAD', 1),
(921, '3034520', 'ENERGIA DEL PACIFICO, Litda de C.V. ENERGIA DEL PACIFICO, Litda de C.V', 'C. llama del bosque pt L Edif Avant', 'LA LIBERTAD', 1),
(922, '3034566', 'FUNDACION AYUDA EN ACCION', 'Col. San Francisco Av. Las Camelias', 'SAN SALVADOR', 1),
(923, '3034581', 'FIDEICOMISO AVICOLA SALVADOREÑA II', 'Blvd. Consitucion #100 Edif. Sn. Jo', 'SAN SALVADOR', 1),
(924, '3034583', 'SHELL WESTERN SUPPLY & TRADING, LTD', 'Mahogany Court, Wildey Business Par', 'St. Michel, Barbados', 1),
(925, '3034617', 'SAN CRESPIN ALAJUELA, S.A.', 'Calle y avenida Ruta 104 Av 15', 'SAN JOSÉ- CARMEN', 1),
(926, '3034618', 'SAN CRESPIN ANTIGUOS, S.A.', 'Ruta 104 Av 15', 'SAN JOSÉ- CARMEN', 1),
(927, '3034619', 'SAN CRESPIN SCMI ALAJUELA, S.A.', 'Ruta 104 Av 15', 'SAN JOSÉ- CARMEN', 1),
(928, '3034620', 'SAN CRESPIN MULTIPLAZA, S.A.', 'Ruta 104 Av. 15', 'SAN JOSÉ- CARMEN', 1),
(929, '3034621', 'SAN CRESPIN GUACHIPELIN, S.A.', 'Ruta 104 Av. 15', 'SAN JOSÉ- CARMEN', 1),
(930, '3034622', 'SAN CRESPIN METROCENTRO, S.A.', 'Ruta 104 Av. 15', 'SAN JOSÉ- CARMEN', 1),
(931, '3034623', 'SAN CRESPIN CARTAGO, S.A.', 'Ruta 104 Av. 15', 'SAN JOSÉ- CARMEN', 1),
(932, '3034624', 'SAN CRESPIN MALL SAN PEDRO, S.A.', 'Ruta 104 Av. 15', 'SAN JOSÉ- CARMEN', 1),
(933, '3034633', 'BRIDGE INTERMODAL TRANSPORT EL SALV BRIDGE INTERMODAL TRANSPORT EL SAL', 'Calle a Mariona Km 11 1/2 Canton Gu', 'SAN SALVADOR', 1),
(934, '3034708', 'FECREDITO, C.V.', '23 cll Pte  Y 25 Av Nte, Edificio M', 'SAN SALVADOR', 1),
(935, '3034712', 'Providencia Solar S.A de C.V.', 'El Salvador', 'SAN SALVADOR', 1),
(936, '3034797', 'Multi Inv. Bco. Coop de los TBJRS S Multi Inv. Bco. Coop de los TBJRS', 'Boulevard Los Proceres n. 2', 'SAN SALVADOR', 1),
(937, '3034820', 'ACH DE EL SALVADOR, S.A. DE C.V.', 'Edif Corp Madreselva Nivel 4', 'ANTGUO CUSCATLAN', 1),
(938, '3034825', 'MINISTERIO DE HACIENDA', 'Blvd. de los Heroes No. 1231', 'SAN SALVADOR', 1),
(939, '3034829', 'Telecom Business Solution Ltda', 'Calle 100 No. 8A - 55 Torre C Of. 3', 'BOGOTA D.C.', 1),
(940, '3034870', 'INVESTIGACIONES Y SEGURIDAD S.A. DE', 'Av. Bungabillas N. 7 Colonia San Fc', 'SAN SALVADOR', 1),
(941, '3035001', 'COLGATE PALMOLIVE CENTRAL AMERICA I', 'Boulevard Pinza Calle L2 y L3 #11 C', 'LA LIBERTAD', 1),
(942, '3035107', 'PINSAL, S.A. DE C.V.', 'Calle al Matazano', 'SOYAPANGO', 1),
(943, '3035302', 'CHIQUITA LOGISTIC SERVICES EL SALVA CHIQUITA LOGISTIC SERVICES EL SALV', '', 'SAN SALVADOR', 1),
(944, '3035303', 'GETCOM INTERNACIONAL S.A. DE C.V.', 'Col Escalón 71 Av. Norte y 3a Calle', 'SAN SALVADOR', 1),
(945, '3035304', 'AOL PRODUCTOS EL  SALVADOR S.A DE C', 'CALLE EL MIRADOR, 93 AV. NORTE, COL', 'SAN SALVADOR', 1),
(946, '3035331', 'MERCADOS ELECTRICOS DE CENTROAMERIC MERCADOS ELECTRICOS DE CENTROAMERI', 'Local 10-2 Co. Layco Edif. Tequenda', 'SAN SALVADOR', 1),
(947, '3035332', 'INVERSIONES MERELEC, S.A. DE C.V.', 'Local 10-2 Co. Layco Edif. Tequenda', 'SAN SALVADOR', 1),
(948, '3035377', 'AGRICOLA INDUSTRIAL SALVADOREÑA, S.', 'Torre futura nivel 20 Col. Escalon', 'SAN SALVADOR', 1),
(949, '3035466', 'FUNDACION EDUCANDO A UN SALVADOREÑO', 'Ala Manuel Araujo C.C. Loma Linda L', 'SAN SALVADOR', 1),
(950, '3035488', 'FUNDACION SALVADOREÑA PARA EL DESAR ECONOMICO', 'Edificio FUSADES Boulevard y Urb. S', 'SAN SALVADOR', 1),
(951, '3035513', 'SUPER REPUESTOS EL SALVADOR S.A. DE', 'Blvd. Constitución #504 S.S.', 'SAN SALVADOR', 1),
(952, '3035580', 'TELECOM BUSINESS SOLUTION LTDA', 'Av. La Capilla, Pje. No. 8 #359 C', 'SAN SALVADOR', 1),
(953, '3035581', 'SOL MARIA GUZMAN DE FLINT', 'Colonia Escalón, Calle el Mirador #', 'SAN SALVADOR', 1),
(954, '3035713', 'JCDecaux El Salvador, S.A. de C.V.', '51 Av. Norte .*119 Col Flor Blanca', 'SAN SALVADOR', 1),
(955, '3035720', 'ALPHA SOLAR, S.A. DE C.V.', 'San Salvador', 'SAN SALVADOR', 1),
(956, '3035721', 'FUNDACION ESCOLAR BRITANICO SALVADO', 'Km. 10 1/2 Carretera a Santa Tecla,', 'SAN SALVADOR', 1),
(957, '3035742', 'ALBACROME, S.A. DE C.V.', 'San Salvador', 'SAN SALVADOR', 1),
(958, '3035743', 'ALBACROME, S.A. (PANAMÁ)', '', 'Panama', 1),
(959, '3035744', 'DISTRIBUIDORA EDITORIAL, S.A. DE C.', 'San Salvador', 'SAN SALVADOR', 1),
(960, '3035761', 'Nissan Mexicana S.A. DE C.V.', 'Aguascalientes', 'Aguascalientes', 1),
(961, '3035765', 'UNION COMERCIAL DE EL SALVADOR, S.A UNION COMERCIAL DE EL SALVADOR, S.', 'Final C. La Mascota, Urb. Maquilish', 'SAN SALVADOR', 1),
(962, '3035766', 'BANCO CENTRAL DE RESERVA BANCO CENTRAL DE RESERVA DE EL SALV', 'alameda Juan Pablo II 15 y 17 Av. N', 'SAN SALVADOR', 1),
(963, '3035777', 'INGENIO LA CABAÑA, S.A. DE C.V.', 'Km 39 1/2 Carretera Troncal del NTE', 'EL PAISNAL', 1),
(964, '3035821', 'AC NIELSEN EL SALVADOR, S.A. DE C.V', 'Calle Nueva 1 #3670 Colonia Escalon', 'SAN SALVADOR', 1),
(965, '3035822', 'AMERICA INTERACTIVA S.A. DE C.V.', '1 Calle Oriente y Avenida Cuscatanc', 'SAN SALVADOR', 1),
(966, '3035938', 'NEOEN El Salvador  S.A.DE.C.V.', '75 av. norte col. Escalon #536', 'SAN SALVADOR', 1),
(967, '3035939', 'UNIGAS DE EL SALVADOR S.A. DE.C.V.', 'Carrt. Ent Nejapa y Quezaltepeque K', 'SAN SALVADOR', 1),
(968, '3035946', 'INVERSIONES FINANCIERAS BANCO AGRIC INVERSIONES FINANCIERAS BANCO AGRI', '1a. C. Pte. y 67 Av. Nte No.100 Blv', 'SAN SALVADOR', 1),
(969, '3035947', 'ARRENDADORA FINANCIERA, S.A.', '1a c. Pte. y 67 Av. N100 Blvd Const', 'SAN SALVADOR', 1),
(970, '3035948', 'VALORES BANAGRICOLA, S.A. DE C.V. VALORES BANAGRICOLA, S.A. DE C.V.', 'Blvd. Constitución, Edif. San Jose', 'SAN SALVADOR', 1),
(971, '3035969', 'COMERCIAL POZUELO EL SALVADOR COMERCIAL POZUELO EL SALVADOR', 'Av. Albert Einstein Col. Lomas de S', 'ANTGUO CUSCATLAN', 1),
(972, '3035970', 'WHIRLPOOL CORPORATION', '2000 NORTH STATE ROUTE 63 BENTON HA', 'USA', 1),
(973, '3036002', 'INVERSIONES EL COPINOL, S.A. DE C.V', 'Calle el mirador y 95 Av. Nte. #490', 'SAN SALVADOR', 1),
(974, '3036003', 'MINISTERIO DE OBRAS PUBLICAS, TRANS MINISTERIO DE OBRAS PUBLICAS, TRAN', 'Km. 5.5, Alameda Manuel Enrique Ara', 'SAN SALVADOR', 1),
(975, '3036096', 'FONDO DE DESARROLLO ECONOMICO', 'Calle. El mirador 89 Av. Norte Loca', 'SAN SALVADOR', 1),
(976, '3036097', 'FONDO SALVADOREÑO DE GARANTIAS', 'Calle El mirador 89 Av. Nrte local', 'SAN SALVADOR', 1),
(977, '3036147', 'FITCH CENTROAMERICA, S.A.', 'San Salvador', 'SAN SALVADOR', 1),
(978, '3036148', 'PAPELERIA INTERNACIONAL EL SALVADOR PAPELERIA INTERNACIONAL EL SALVADO', 'Av. LAMATEPEC Y  CALLE CHAPARRASTIQ', 'SAN SALVADOR', 1),
(979, '3036187', 'ALCON CENTROAMERICA S A', 'Centro Corporativo Plaza Roble, edi', 'ESCAZÚ- ESCAZÚ', 1),
(980, '3036194', 'RENOVABLES EL SALVADOR UNO S.A. DE RENOVABLES EL SALVADOR UNO S.A. DE', 'San Salvador', 'SAN SALVADOR', 1),
(981, '3036195', 'PVGEN, S.A. de C.V.', '', 'SAN SALVADOR', 1),
(982, '3036196', 'PROYECTO LA TRINIDAD, S.A. DE C.V.', '', 'SAN SALVADOR', 1),
(983, '3036197', 'GRUPO ROCA, S.A. de C.V.', '', 'SAN SALVADOR', 1),
(984, '3036198', 'SUNO POWER, S.A. de C.V.', '', 'SAN SALVADOR', 1),
(985, '3036334', 'FRV SOLAR EL SALVADOR LTDA. DE C.V.', 'Calle La Mascota # 533 San Benito', 'SAN SALVADOR', 1),
(986, '3036335', 'DARLINGTON FABRICS EL SALVADOR LTDA', 'Carret. A Sta. Ana Km, Zona Franca', 'CIUDAD ARCE', 1),
(987, '3036461', 'AGROINDUSTRIAS GUMARSAL, S.A. DE C.', 'KM. 1/2 Carr. Sta. Ana Cton. Sitio', 'SAN SALVADOR', 1),
(988, '3036484', 'CORPORACION PIRAMIDE, S.A. DE C.V.', 'Clle. La Reforma Blvd. Del Hipodrom', 'SAN SALVADOR', 1),
(989, '3036495', 'NEC de Colombia S A', 'Cra 9 No 80 – 32 Bogotá', 'BOGOTA D.C.', 1),
(990, '3036497', 'POLIWATT, LIMITADA', '101 Av. Nte. Y calle José Martí #61', 'SAN SALVADOR', 1),
(991, '3036498', 'INTEL TECNOLOGIA EL SALVADOR,S.A.DE', '71 Av. Sur #185 Colonia Escalón', 'SAN SALVADOR', 1),
(992, '3036501', 'ENTE OPERADOR REGIONAL', 'Diagonal Universitaria entre 25 Cal', 'SAN SALVADOR', 1),
(993, '3036584', 'BANCO AZUL', 'Avenida Olimpica', 'SAN SALVADOR', 1),
(994, '3036599', 'FIDECOMISO FINANCIAMIENTO DE ACCION FIDECOMISO FINANCIAMIENTO DE ACCIO', 'Boulevard Constitucion #100 Edifici', 'SAN SALVADOR', 1),
(995, '3036600', 'FIDEICOMISO LUIS CASTRO LOPEZ', 'Boulevard Constitución #100 Edifici', 'SAN SALVADOR', 1),
(996, '3036601', 'FIDEICOMISO FIAES TROPICAL FOREST CONSERVATION', 'Boulevard Constitución #100 Edifici', 'SAN SALVADOR', 1),
(997, '3036602', 'FIDEICOMISO FIAES - PL-480 II', 'Boulevard Constitución #100 Edifici', 'SAN SALVADOR', 1),
(998, '3036603', 'FIDEICOMISO DE DESARROLLO COOPERATI', 'Boulevard Constitución #100 Edifici', 'SAN SALVADOR', 1),
(999, '3036604', 'FIDEICOMISO POLLO CAMPERO DE FIDEICOMISO POLLO CAMPERO DE', 'Boulevard Constitución #100 Edifici', 'SAN SALVADOR', 1),
(1000, '3036606', 'FIDEICOMISO COMITÉ DE PROYECCIÓN FIDEICOMISO COMITÉ DE PROYECCIÓN', 'Boulevard Constitución #100 Edifici', 'SAN SALVADOR', 1),
(1001, '3036618', 'FIDEICOMISO FIAES - AID II', 'Boulevard Constitución #100 Edifici', 'SAN SALVADOR', 1),
(1002, '3036769', 'EQUANT EL SAVADOR S.A. DE C.V.', 'Col. Miramonte 57 Av. Nte. No. 429', 'SAN SALVADOR', 1),
(1003, '3036770', 'MCCORMICK DE CENTROAMERICA S.A. DE', '', 'SAN SALVADOR', 1),
(1004, '3036771', 'EXCLUSIVE BRAND S.A. DE C.V.', '', 'SAN SALVADOR', 1),
(1005, '3036800', 'LEGALIZACION DE LIBROS DELOITTE', 'Edif. Avante Ofic. #10-1 y 10-3', 'LA LIBERTAD', 1),
(1006, '3036801', 'MINISTERIO DE ECONOMIA', 'Aldea Juan Pablo II Y Clle. Guadalu', 'SAN SALVADOR', 1),
(1007, '3036847', 'TECNISPICE S.A.DE.C.V.', 'Carr. Puerto de la Libertad KM 11 1', 'SAN SALVADOR', 1),
(1008, '3036891', 'CORPORACION DISTRIBUIDORA INTERNACI CORPORACION DISTRIBUIDORA INTERNAC', 'Blvrd. del Ejercito Nacional KM. 51', 'SOYAPANGO', 1),
(1009, '3037015', 'TRIBU EN EL SALVADOR S.A. DE C.V.', 'Boulevard del Hipódromo No. 519 Col', 'SAN SALVADOR', 1),
(1010, '3037016', 'INVENERGY SERVICES EL SALVADOR LTDA INVENERGY SERVICES EL SALVADOR LTD', 'Calle de la Mascotaa Col. San Benit', 'SAN SALVADOR', 1),
(1011, '3037017', 'GRANELES DE CENTRO AMERICA S.A. DE GRANELES DE CENTRO AMERICA S.A. DE', 'Calle. Los Galeones y Av. Las Carav', 'SAN SALVADOR', 1),
(1012, '3037018', 'TRANSPORTES DANY S.A. DE C.V.', 'KM. 30 1/2 Carr-Sta. Ana Cton Sitio', 'SAN SALVADOR', 1),
(1013, '3037047', 'NORVANDA HEALTHCARE, S.A. NORVANDA HEALTHCARE, S.A.', 'Calle Maramara No. 10, Col. Jardine', 'ANTGUO CUSCATLAN', 1),
(1014, '3037053', 'SOLUCIONES PARAISO S.A. DE C.V.', 'Urb. Sta. Elena, calle el Boqueron', 'ANTGUO CUSCATLAN', 1),
(1015, '3037074', 'OPTICAS DEVLYN DE EL SALVADOR S.A. OPTICAS DEVLYN DE EL SALVADOR S.A.', 'SAN SALVADOR', 'SAN SALVADOR', 1),
(1016, '3037104', 'CARMEN MARCELA GARCIA PRIETO DE SIM CARMEN MARCELA GARCIA PRIETO DE SI', 'Blvd. del Hipódromo, Col. San Benit', 'SAN SALVADOR', 1),
(1017, '3037105', 'UNIDAD DE TRANSACCIONES S.A. DE C.V', 'Carr. Pto La Libertad, KM. 12 1/2', 'SAN SALVADOR', 1),
(1018, '3037162', 'HAMBURG SUD EL SALVADOR SA DE CV', 'Edif. Avante nivel 9 local 06', 'ANTGUO CUSCATLAN', 1),
(1019, '3037163', 'KELLOGG EL SALVADOR LTDA DE C.V.', 'Cl. El Mirador y 89 Av. Nte. Edif.', 'SAN SALVADOR', 1),
(1020, '3037217', 'SIEMENS HEALTHCARE, S.A.', 'Calle Siemens #43, Parque Industria', 'ANTGUO CUSCATLAN', 1),
(1021, '3037269', 'PEGASUS S.A DE C.V.', 'Bvld. Pynsa Zona Industrial Ciudad', 'ANTGUO CUSCATLAN', 1),
(1022, '3037322', 'TRANSACCIONES TELEFONICAS EL SALVAD TRANSACCIONES TELEFONICAS EL SALVA', 'Calle Chilltiupan y 17 Av. Nte. C.C', 'ANTGUO CUSCATLAN', 1),
(1023, '3037323', 'TRANSACTEL EL SALVADOR S.A. DE C.V.', 'Calle Chiltiupan y 17 Av. Nte. C.C.', 'SANTA TECLA', 1),
(1024, '3037324', 'ASESORIA EN ALIMENTOS DE EL SALVADO  S.A. DE C.V.', 'Carr. Oeste Panamericana Km. 20 Ofi', 'NEJAPA', 1),
(1025, '3037362', 'CORPORACION FAMILY HEALTH INTERNATI', 'Calle Circunvalación # 44, Col. San', 'SAN SALVADOR', 1),
(1026, '3037363', 'MOBILE MONEY CENTROAMERICA S.A. DE MOBILE MONEY CENTROAMERICA S.A. DE', 'Final 63 av. Sur y Av. Olimpica pje', 'SAN SALVADOR', 1),
(1027, '3037365', 'CORPORACION APOLO S.A. DE C.V.', 'Alameda Roosevelt No. 3104', 'SAN SALVADOR', 1),
(1028, '3037385', 'Telefónica, S.A. Telefónica, S.A.', '', 'Gran Vía, Madrid, España', 1),
(1029, '3037412', 'TARSCO EL SALVADOR LTDA DE C.V.', 'Urb. Madre Selva III, Calle Lima de', 'LA LIBERTAD', 1),
(1030, '3037446', 'ADEBIEN, S.A. DE C.V.', 'Boulevard Merliot #5,', 'ANTGUO CUSCATLAN', 1),
(1031, '3037542', 'UFINET', 'c/ Manuel Silvela, 13. 28010 Madrid', 'Madrid', 1),
(1032, '3037552', 'FITCH CENTROAMERICANA, S.A.', '3av. nivel 17 Inter. plaza torre ci', 'Zona 10', 1),
(1033, '3037553', 'FITCH CENTROAMERICANA, S.A.', 'Los Andes calle 15 av.4 clle N casa', 'Tegucigalpa', 1),
(1034, '3037556', 'FITCH CENTROAMERICANA, S.A.', 'Panamá', 'Panamá', 1),
(1035, '3037595', 'Continental Motores, S.A de C.V.', 'Blvr. Santa Elena y Calle Oromontiq', 'ANTGUO CUSCATLAN', 1),
(1036, '3037638', 'DIGITEX, EL SALVADOR, S.A. DE C.V.', 'Urb. Jard. de la Hda Z Comercial 22', 'ANTGUO CUSCATLAN', 1),
(1037, '3037639', 'INWK El Salvador, Ltda. De C.V.', '1Calle PTE 47Av Norte, Col flor Bla', 'SAN SALVADOR', 1),
(1038, '3037640', 'GlaxoSmithKline El Salvador,S.A. DE', 'Avenida El Boquerón Calle Izalco #7', 'ANTGUO CUSCATLAN', 1),
(1039, '3037671', 'Celeo Arias Retes', 'Distrito El Espino,Puerta La Palma,', 'SAN SALVADOR', 1),
(1040, '3037680', 'INVEMESAL S.A DE C.V.', 'Calle la mascota, col. San Benito #', 'SAN SALVADOR', 1),
(1041, '3037681', 'AS HOLDING, S.A. DE C.V.', 'Carret. Panamericana, #12 Urb. Indu', 'ANTGUO CUSCATLAN', 1),
(1042, '3037843', 'QUALA EL SALVADOR, S.A. DE C.V.', 'Calle el progreso, # 8, 9 y 10, Zon', 'SAN SALVADOR', 1),
(1043, '3037844', 'Deloitte Canada', '255 Queens Ave. Suite 700 london, O', 'Ontario', 1),
(1044, '3037900', 'SERVICIOS TÉCNICOS EN SEGUROS, S.A. SERVICIOS TÉCNICOS EN SEGUROS, S.A', '85 Av Nrte entre 13 y 15 calle poni', 'SAN SALVADOR', 1),
(1045, '3037988', 'Antena Azteca, S. A de C. V.', 'Avenida Júarez 1509, Colonia La Paz', 'Puebla', 1),
(1046, '3038025', 'BANCO DE DESARROLLO RURAL, S.A.', 'AVENIDA REFORMA 9-30 ZONA 9 EDIFICI', 'Zona 9', 1),
(1047, '3038118', 'UNILEVER EL SALVADOR SCC, S.A DE C.', 'Col. ESLAVON 87 Av. NORTE C. EL MIR', 'SAN SALVADOR', 1),
(1048, '3038273', 'UNION DISTRIBUIDORA INTERNACIONAL, UNION DISTRIBUIDORA INTERNACIONAL,', '17 Av. Sur Carr. Puerta de la Liber', 'SAN SALVADOR', 1),
(1049, '3038275', 'Biokemical, S.A de C.V', 'Calle Alberto Masferrer, Bo Las Mer', 'SANTO TOMAS', 1),
(1050, '3038277', 'IBERO EL SALVADOR, S.A. DE C.V.', 'Colonia Jardines De Merliot, calle', 'SAN SALVADOR', 1),
(1051, '3038316', 'Tronix, S.A de C.V.', 'URB. PLAN DE LA LAGUNA #05, PJE PRI', 'ANTGUO CUSCATLAN', 1),
(1052, '3038318', 'CORPORACION DE INVERSIONES ATLANTID CORPORACION DE INVERSIONES ATLANTI', '5A CALLE PONIENTE, PASAJE CAMILO CA', 'SAN SALVADOR', 1),
(1053, '3038369', 'ASOCIACION DE TRABAJADORES DE POLLO CAMPERO DE EL SALVADOR, SA DE CV Y', 'KILOMETRO 6 1/2 BOULEVARD DEL EJERC', 'SAN SALVADOR', 1),
(1054, '3038536', 'DESARROLLOS CULTURALES SALVADOREÑOS DESARROLLOS CULTURALES SALVADOREÑO', '57 Avenida norte, local 2B, Colonia', 'SAN SALVADOR', 1),
(1055, '3038605', 'IMPULSO, S.A. DE C.V.', 'CALLE SIEMENS #54, URBANIZACION IND', 'LA LIBERTAD', 1),
(1056, '3038606', 'RAYOVAC EL SALVADOR, S.A. DE C.V.', 'EDIF. RAYOVAC #2079, BOULEVARD MERL', 'LA LIBERTAD', 1),
(1057, '3038684', 'Crowley TRansportes El Salvador, S. Crowley TRansportes El Salvador, S', 'Avenida Olimipica, Col. Escalon, Ce', 'SAN SALVADOR', 1),
(1058, '3038685', 'Crowley Logistic El Salvador, S.A. Crowley Logistic El Salvador, S.A.', 'Carr. A SANTA ANA KM 24, EDIF. #10,', 'LA LIBERTAD', 1),
(1059, '3038686', 'Crowley Shared Services, S.A. de C.', 'Av. Olimpica, Col. Escalon, Centro', 'SAN SALVADOR', 1),
(1060, '3038702', 'CLUB CAMPESTRE CUSCATLAN', 'PASEO GENERAL ESCALON, NO. 5423, CO', 'SAN SALVADOR', 1),
(1061, '3038854', 'FEDEX CORPORATION FEDEX CORPORATION', '942 S SHADY GROVE RD', 'MEMPHIS', 1),
(1062, '3038889', 'FOMILENIO II', 'BO. ORDEN DE MALTA EDIF. ZAFIRO #4', 'ANTGUO CUSCATLAN', 1),
(1063, '3038917', 'TRANSPORTES PESADOS, S.A. DE C.V.', 'CALLE A ALDEA SAN ANTONIO #20, BARR', 'LA LIBERTAD', 1),
(1064, '3038967', 'BENJAMIN VALDEZ & ASOCIADOS, LTDA D BENJAMIN VALDEZ & ASOCIADOS, LTDA', 'CALLE LLAMA DEL BOSQUE PTE. PJE. S,', 'LA LIBERTAD', 1),
(1065, '3039010', 'FUNDACIÓN BENJAMIN BLOOM', 'RESIDENCIAL FONTAINBLUE, BLOCK D-1,', 'SAN SALVADOR', 1),
(1066, '3039030', 'PRODUCTOS CÁRNICOS S.A. DE C.V.', 'CALLE EL PROGRESO #3320, COLONIA RO', 'SAN SALVADOR', 1),
(1067, '3039031', 'SEGURIDAD Y PROTECCION DE CENTROAME SEGURIDAD Y PROTECCION DE CENTROAM', 'CALLE LE MIRADOR 93 AV. NORTE, COL.', 'SAN SALVADOR', 1),
(1068, '3039038', 'ALCON CENTROAMERICA S.A.', 'Vía España, Centro Comercial Plaza', 'Panamá, Republica de Panamá', 1),
(1069, '3039046', 'DELTA AIRLINES INC', 'Calle El Mirador 89 Avenida Norte L', 'SAN SALVADOR', 1),
(1070, '3039047', 'CAPELLA SOLAR, S.A. DE C.V.', 'CALLE PADRES AGUILAR, COL. ESCALON', 'SAN SALVADOR', 1),
(1071, '3039099', 'BANAGRICOLA, S.A.', 'BOULEVAR CONSTITUCION, EDIFICIO SAN', 'SAN SALVADOR', 1),
(1072, '3039109', 'CREDIBAC, S.A. DE C.V.', 'BOULEVARD CONSTITUCION, EDIFICIO SA', 'SAN SALVADOR', 1),
(1073, '3039110', 'MUVIX EL SALVADOR, S.A. DE C.V.', 'BOULEVARD LLAMA DEL BOSQUE, EDIFICI', 'SAN SALVADOR', 1),
(1074, '3039213', 'COMPANÍA SALVADOREÑA DE TELESERVICE COMPANÍA SALVADOREÑA DE TELESERVIC', 'AVENIDA OLIMPICA Y PASAJE 3, EDIFIC', 'SAN SALVADOR', 1),
(1075, '3039249', 'C.O.M.E.D.I.C.A., DE R.L.', 'ESQUINA SUR PTE. ENTRE BOULEVARD CO', 'SAN SALVADOR', 1),
(1076, '3039251', 'CAMARA ALEMANA SALVADOREÑA DE CAMARA ALEMANA SALVADOREÑA DE', 'BOULEVARD LA SULTANA # 245 COL. LA', 'LA LIBERTAD', 1),
(1077, '3039253', 'Soluciones BK, S.A. Suc El Salvador', 'Blvd. Luis Poma, Loc 5-01, Edif Ava', 'ANTGUO CUSCATLAN', 1),
(1078, '3039358', 'VIVA GRAFICA, S.A. DE C.V.', '.', 'SAN SALVADOR', 1),
(1079, '3039378', 'OTTO ERICH WAHN MEJIA', 'USLA. CUMBRES DE CUSCATLAN COL XACH', 'LA LIBERTAD', 1),
(1080, '3039379', 'COMERCIALIZADORA ELECTRONOVA S,A  D', 'WORLD TRADA CENTER TORRE 1 NIVEL 2', 'LA LIBERTAD', 1),
(1081, '3039380', 'LATIN ADVISORY SERVICES, S.A.', 'PASEO GENERAL ESCALON # 3737 COL. E', 'SAN SALVADOR', 1),
(1082, '3039409', 'DEVEL SECURITY, S.A.', '10 AVENIDA 14-92', 'Zona 10', 1),
(1083, '3039440', 'PANASONIC CENTROAMERICANA, S.A. PANASONIC CENTROAMERICANA, S.A.', 'CALLE IZALCO, AV. EL BOQUERON, USR.', 'LA LIBERTAD', 1),
(1084, '3039485', 'NICEA, S.A. DE C.V.', 'BLVD. MERLITO, CIUDAD MERLITO, 5, E', 'LA LIBERTAD', 1),
(1085, '3039486', 'FUNDACION DE DESARROLLO SOCIAL', 'CALLE AL PLAN DE LA LAGUNA, LOCAL C', 'LA LIBERTAD', 1),
(1086, '3039487', 'FUNDACION PROBESA', 'CALLE AL PLAN DE LA LAGUNA, LOCAL C', 'LA LIBERTAD', 1),
(1087, '3039489', 'ASOCIACION JARDIN BOTANICO LA LAGUN', 'URBANIZACION INDUSTRIAL PLAN DE LA', 'LA LIBERTAD', 1),
(1088, '3039536', 'SERALPRO, S.A. DE C.V.', 'BLVD. MELIOT. CIUDAD MERLITO, 5. ED', 'ANTGUO CUSCATLAN', 1),
(1089, '3039537', 'LISALVA, S.A. DE D.V.', 'BLVD. MERLIOT, CIUDAD MERLIOT, 5, E', 'ANTGUO CUSCATLAN', 1),
(1090, '3039538', 'UNIÓN COMERCIAL CORPORATIVO, S.A. D', 'EDIFICIO LA CURACAO - UNICOMER, ALA', 'LA LIBERTAD', 1),
(1091, '3039554', 'VACUNA, S.A. DE C.V.', '89 AV. NORTE, COL. ESCALÓN, #525,', 'SAN SALVADOR', 1),
(1092, '3039555', 'SOCIEDAD COOPERATIVA DE AHORRO Y CR', '17 CALLE PONIENTE, COL. HIRLEMNA, #', 'SAN MIGUEL', 1),
(1093, '3039934', 'VALORES AGROINDUSTRIALES, S.A. DE C', 'Calle el Mirador 87 AV. Norte, loca', 'SAN SALVADOR', 1),
(1094, '3040031', 'ILG Logistic de El Salvador, S.A. d', 'Colonia San Benito, Edificio Gran P', 'SAN SALVADOR', 1),
(1095, '3040032', 'TGD El Salvador, S.A. de C.V.', 'Colonia San Benito, Edificio Gran P', 'SAN SALVADOR', 1),
(1096, '3040108', 'Gestora de Fondos de Inversión Gestora de Fondos de Inversión', '1RA CALLE PONIENTE Y 67 AVENIDA NOR', 'SAN SALVADOR', 1),
(1097, '3040121', 'CUESTAMORAS COMERCIALIZADORA ELÉCTR CUESTAMORAS COMERCIALIZADORA ELÉCT', 'Calle La Mascota, Col. San Benito #', 'SAN SALVADOR', 1),
(1098, '3040162', 'CAEX LOGISTICS, S.A. DE C.V.', 'BLVD. DEL EJERCITO NACIONAL KM 3 1/', 'SOYAPANGO', 1),
(1099, '3040197', 'Telefónica Centroamérica, S.A.', 'Business Park, Edificio Este, Ave L', 'Ciudad Panamá', 1),
(1100, '3040387', 'BT Group Plc.', 'BT Centre, 81 Newgate Street, Londo', 'London', 1),
(1101, '3040435', 'Nippon Koei Latin America – Caribea Nippon Koei Latin America – Caribe', '87 Av. Norte, Col. Escalón, Edif. T', 'SAN SALVADOR', 1),
(1102, '3040548', 'Sistemas y Proyectos, S.A. de C.V.', 'Calle y col. La mascota nº215', 'SAN SALVADOR', 1),
(1103, '3040570', 'SERVICIOS LABORALES, S.A. DE C.V.', 'Final Calle el Progreso, Sdo Nivel,', 'SAN SALVADOR', 1),
(1104, '3040587', 'CTE TELECOM PERSONAL, S.A. DE C.V.', 'Final Calle el Progreso, Sdo Nivel,', 'SAN SALVADOR', 1),
(1105, '3040588', 'TELECOMODA , S.A. DE C.V.', 'Final Calle el Progreso, Sdo Nivel,', 'SAN SALVADOR', 1),
(1106, '3040595', 'Publitel, S.A. de C.V.', 'Final Calle el Progreso, Sdo Nivel,', 'SAN SALVADOR', 1),
(1107, '3040596', 'ARRENTEL, S.A. de C.V.', 'Final Calle el Progreso, Sdo Nivel,', 'SAN SALVADOR', 1),
(1108, '3040628', 'Inversiones Integrales IFC, Inversiones Integrales IFC,', 'Alameda DR. Manuel Enrique Araujo E', 'SAN SALVADOR', 1),
(1109, '3040629', 'Citi Inversiones, S.A. de C.V.', 'Edif. Palic, Alam. Manuel Enrique A', 'SAN SALVADOR', 1),
(1110, '3040634', 'Inversiones SIMCO S.A. de C.V.', 'Paseo general escalón, N° 3700 San', 'SAN SALVADOR', 1),
(1111, '3040636', 'FIDEICOMISO MARTA HUEZO DE SANDOVAL', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1112, '3040637', 'FIDEICOMISO RHINA STELLA AMAYA', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1113, '3040638', 'FIDEICOMISO SALVADOR SANCHEZ CERNA', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1114, '3040639', 'FIDEICOMISO PARA EL DESARROLLO DE L FIDEICOMISO PARA EL DESARROLLO DE', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1115, '3040640', 'FIDEICOMISO ILC JUBILACION II', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1116, '3040641', 'FIDEICOMISO PARA LA FORMACION DE FIDEICOMISO PARA LA FORMACION DE', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1117, '3040642', 'FIDEICOMISO GLORIA DEL CARMEN MORAL FIDEICOMISO GLORIA DEL CARMEN MORA', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1118, '3040643', 'Droguería Santa Lucia, S.A. de C.V', 'Calle y Colonia Roma No. 238', 'SAN SALVADOR', 1),
(1119, '3040652', 'FIDEICOMISO NORMAN NIELSEN RIVERA M', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1120, '3040654', 'FIDEICOMISO NELSON ALBERTO RIVERA M', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1121, '3040655', 'FIDEICOMISO JOSE ROBERTO ORELLANA W', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1122, '3040656', 'FIDEICOMISO BETTINA', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1123, '3040657', 'FIDEICOMISO PNC', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1124, '3040658', 'FIDEICOMISO FONDO DE BECAS DE FUNDA FIDEICOMISO FONDO DE BECAS DE FUND', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1125, '3040659', 'FIDEICOMISO PROYECTO AZUL Y BLANCO FIDEICOMISO PROYECTO AZUL Y BLANCO', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1126, '3040660', 'Weeks Marine, Inc.', '4 Commerce Drive, Cranford, NJ 0701', 'New Jersey', 1),
(1127, '3040688', 'Optima Servicios Financieros, S.A. Optima Servicios Financieros, S.A.', '75 Avenida Nte. Y 9a Calle Pte. Col', 'SAN SALVADOR', 1),
(1128, '3040740', 'METALCO DE EL SALVADOR S.A DE C.V', 'Km 11 1/2 Carretera Al Puerto de la', 'LA LIBERTAD', 1),
(1129, '3040742', 'FIDEICOMISO DE ADMON. DE ACC. PARA FIDEICOMISO DE ADMON. DE ACC. PARA', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1130, '3040743', 'FIDEICOMISO DE ADMON. DE BENEF. PAR FIDEICOMISO DE ADMON. DE BENEF. PA', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1131, '3040744', 'FIDEICOMISO LA SULTANA S.A.DE C.V.', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1132, '3040745', 'FIDEICOMISO  UNIVERSIDAD DR. JOSE M FIDEICOMISO  UNIVERSIDAD DR. JOSE', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1133, '3040758', 'FIDEICOMISO CESSA', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1134, '3040759', 'FIDEICOMISO FONDO DE RETIRO DE EMPL FIDEICOMISO FONDO DE RETIRO DE EMP', 'Paseo General Escalón, No. 3635, Co', 'SAN SALVADOR', 1),
(1135, '3040760', 'FIDEICOMISO FUNDACION PROMOTORA DE FIDEICOMISO FUNDACION PROMOTORA DE', 'Paseo General Escalón, No. 3635, Co', 'SAN SALVADOR', 1),
(1136, '3040762', 'FIDEICOMISO FUNDACION HERMANO PEDRO', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1137, '3040764', 'ZONIFICADORA NOTARIAL EL SALVADOR, ZONIFICADORA NOTARIAL EL SALVADOR,', 'CALLE REPUBLICA FEDERAL DE ALEMANIA', 'SAN SALVADOR', 1),
(1138, '3040766', 'FIDEICOMISO ALCATEL- LUCENT EL SALV FIDEICOMISO ALCATEL- LUCENT EL SAL', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1139, '3040767', 'FIDEICOMISO ORLANDO FLORES', 'BLVD. CONSTITUCIÓN, EDIF. SAN JOSÉ', 'SAN SALVADOR', 1),
(1140, '3040768', 'FIDEICOMISO PROGRAMA REGALO DE VIDA FIDEICOMISO PROGRAMA REGALO DE VID', 'Paseo General Escalón, No. 3635, Co', 'SAN SALVADOR', 1),
(1141, '3040791', 'Digitex Informática, S.L.U.', 'Teniente Coronel Noreña, 3028045, M', 'MADRID', 1),
(1142, '3040837', 'Scotiabank El Salvador, S.A.', '25 av. Norte y 23 calle poniente, C', 'SAN SALVADOR', 1),
(1143, '3040840', 'Scotia Leasing, S.A. de C.V.', '25 av. Norte y 23 calle poniente, C', 'SAN SALVADOR', 1),
(1144, '3040841', 'Scotia Seguros, S.A.', 'Calle Loma Linda #223, San Benito', 'SAN SALVADOR', 1),
(1145, '3040851', 'Gonzalo Galvez Freund', 'Av. Masferrer Norte, Col. Escalon', 'SAN SALVADOR', 1),
(1146, '3040967', 'Devel Security, Sociedad Anonima de Devel Security, Sociedad Anonima d', 'Colonia Escalón, WTC, Torre Uno, Pi', 'SAN SALVADOR', 1),
(1147, '3041015', 'Inversiones Pelicano, S.A. de C.V.', 'Lote A-2, Finca Las Piletas, Hijuel', 'LA LIBERTAD', 1),
(1148, '3041287', 'Drifam, S.A. de C.V.', 'Carr. a Santa Ana Km. 24, Local 19-', 'LA LIBERTAD', 1),
(1149, '3041322', 'Innerlex Grupo Financiero, S.L.', 'Beethoven 16, Barcelona', 'Barcelona', 1),
(1150, '3041396', 'Cummins de Centroamérica El Salvado Cummins de Centroamérica El Salvad', 'KM 11 1/2, sobre la carretera al pu', 'LA LIBERTAD', 1),
(1151, '3041423', 'New Com Live El Salvador, S.A. de C', 'Calle Nueva #1, Col. Escalon Alamed', 'SAN SALVADOR', 1),
(1152, '3041468', 'INFORMÁTICA & TECNOLOGÍA STEFANINI, INFORMÁTICA & TECNOLOGÍA STEFANINI', 'Col. Escalon edificio Vittoria, #48', 'SAN SALVADOR', 1),
(1153, '3041476', 'Corporación industrial Centroameric Corporación industrial Centroameri', 'Entrada a Quezaltepeque', 'QUEZALTEPEQUE', 1),
(1154, '3041529', 'Pintuco Guatemala S.A.', '18 Calle 22-73 zona 10', 'Zona 10', 1),
(1155, '3041553', 'INTCOMEX, S.A. DE C.V.', 'CALLE Y COLONIA LA MASCOTA No.517-5', 'SAN SALVADOR', 1),
(1156, '3041622', 'NEON NIETO COMERCIAL, S.A. DE C.V.', 'KM 20 CARRETERA A QUEZALTEPEQUE OFI', 'SAN SALVADOR', 1),
(1157, '3041676', 'INVERSIONES DE GUATEMALA SOCIEDAD INVERSIONES DE GUATEMALA SOCIEDAD', 'Km 16.5 Calzada Roosevelt 4-81 zona', 'Mixco', 1),
(1158, '3041703', 'Intermundial S.A. de C.V.', 'Plan de La Laguna, Calle Circunvala', 'ANTGUO CUSCATLAN', 1),
(1159, '3041892', 'SBA TORRES EL SALVADOR, S.A. DE C.V', 'Novena calle poniente No 4115 col.', 'SAN SALVADOR', 1),
(1160, '3041925', 'Unilever PLC', 'Unilever House Springfield Dr, Leat', 'Leatherhead', 1),
(1161, '3041963', 'TREBALLEM, SOCIEDAD ANÓNIMA', 'Avenida Reforma 6-39, Centro Corpor', 'Zona 10', 1),
(1162, '3042044', 'EDT El Salvador, S.A de C.V', 'Km 19 1/2 Carretera al puerto de La', 'LA LIBERTAD', 1),
(1163, '3042045', 'Compañía Azucarera Salvadoreña, S.A Compañía Azucarera Salvadoreña, S.', 'Km 62 1/2, Carretera a Sonsonate, C', 'IZALCO', 1),
(1164, '3042046', 'Stereo Noventa y Cuatro Punto Uno F Stereo Noventa y Cuatro Punto Uno', 'Avenida Maracaibo #703, Colonia Mir', 'SAN SALVADOR', 1),
(1165, '3042047', 'PIEL Y CALZADO, S.A DE C.V', 'Col. Flor Blanca, Alameda Roosvelt,', 'SAN SALVADOR', 1),
(1166, '3042048', 'FEDECREDITO VIDA, S.A, SEGUROS DE FEDECREDITO VIDA, S.A, SEGUROS DE', '67 Avenida sur y Avenida Olímpica,', 'SAN SALVADOR', 1),
(1167, '3042082', 'MENDEZ ENGLAND & ASSOCIATES INC. MENDEZ ENGLAND & ASSOCIATES INC.', 'CALLE CIRCUNVALACIÓN #261 COL. SAN', 'SAN SALVADOR', 1),
(1168, '3042084', 'UNIVERSIDAD EVANGELICA DE EL SALVAD', 'Prolongacion Alameda Juan Pablo II', 'SAN SALVADOR', 1),
(1169, '3042086', 'CLUB DE PLAYAS SALINITAS, S.A. DE C', 'PASEO GENERAL ESCALÓN No. 4711', 'SAN SALVADOR', 1),
(1170, '3042122', 'Deloitte Belastingadviseurs B.V.', '1040 HC Amsterdam', 'Amsterdam', 1),
(1171, '3042146', 'Whitney International Holdings, Ltd', 'Bermuda', 'Bermuda', 1),
(1172, '3042150', 'DAR HOLDINGS', 'CHICAGO', 'CHICAGO', 1),
(1173, '3042160', 'Milvik El Salvador S.A. de C.V.', '87 Av. Norte y Paseo General Escalo', 'SAN SALVADOR', 1),
(1174, '3042164', 'Sonosite, INC', '21919 30th Drive SE, Bothell, WA 98', 'Bothell', 1),
(1175, '3042166', 'GNFT España', 'Plaza Pablo Ruiz Picasso, 1, Torre', 'Madrid', 1),
(1176, '3042196', 'Remesas  y Pago Cuscatlan Limitada Remesas  y Pago Cuscatlan Limitada', 'Complejo Financiero SISA, Edificio', 'SANTA TECLA', 1),
(1177, '3042197', 'KL CONTACTO DE EL SALVADOR, S.A. DE', 'Urbanización Cumbres de La Escalón,', 'SAN SALVADOR', 1),
(1178, '3042230', 'Cuestamoras Comercializadora Eléctr Cuestamoras Comercializadora Eléct', ', LOCAL. 2 , CTRO. COM. LA GRAN VIA', 'ANTGUO CUSCATLAN', 1),
(1179, '3042244', 'CHINA HARBOUR ENGINEERING COMPANY D CHINA HARBOUR ENGINEERING COMPANY', 'Piso 4 edificio 7 oficentro de la s', 'SAN JOSÉ- MATA REDONDA', 1),
(1180, '3042256', 'BAKER HUGHES DE MEXICO, S DE RL DE', 'Blvd Manuel Ávila Camacho No. 138 P', 'Distrito Federal', 1),
(1181, '3042278', 'DURECO DE EL SALVADOR, S.A. DE C.V.', 'CALLE CONCHAGUA PONIENTE Y CALLE CE', 'LA LIBERTAD', 1),
(1182, '3042328', 'EMOTION INTERNATIONAL S.A. DE C.V.', 'COL. ESCALON 5262 PASEO GENERAL ESC', 'SAN SALVADOR', 1),
(1183, '3042346', 'British American Tobacco Central British American Tobacco Central', 'Torre Banco Panamá, Boulevard Costa', 'Ciudad Panamá', 1),
(1184, '3042352', 'Carga Urgente de El Salvador, Carga Urgente de El Salvador,', 'Calle Los Abetos, Col. San Fransico', 'SAN SALVADOR', 1),
(1185, '3042354', 'CORPORACION SIETE, S.A. DE C.V.', 'Carretera Troncal del Norte Kilomet', 'SAN SALVADOR', 1),
(1186, '3042383', 'Fisherman Wealth Management, S.A. d', 'Calle Cuscatlán #21  Col Escalón', 'SAN SALVADOR', 1),
(1187, '3042434', 'InterEnergy Holdings', 'Cayman Islands', 'Cayman Islands', 1),
(1188, '3042444', 'Ricardo Udolfo Castro', 'San Andrés, Frente Iglesia Católica', 'LA LIBERTAD', 1),
(1189, '3042516', 'Syngenta International AG', 'Basel', 'Basel', 1),
(1190, '3042540', 'ACEROS DE GUATEMALA, SOCIEDAD ANÓNI', 'Avenida Las Américas  18-81 Columbu', 'Zona 14', 1),
(1191, '3042586', 'Intel Corporation', '2200 Mission College Boulevard', 'SANTA CLARA', 1),
(1192, '3042587', 'Trident Seafoods Corporation', '5303 Shilshole Ave Nw', 'SEATTLE', 1),
(1193, '3042596', 'BANCO INTERAMERICANO DE DESARROLLO', '89 Ave. Norte y Calle El Mirador, E', 'SAN SALVADOR', 1),
(1194, '3042608', 'Aliaxis Group, S.A.', 'Brusselas', 'Bruselas', 1),
(1195, '3042633', 'TINACOS Y TANQUES DE CENTRO AMERICA TINACOS Y TANQUES DE CENTRO AMERIC', 'KM 27 Carret. a Santa Ana, Colon', 'SANTA ANA', 1),
(1196, '3042738', 'INVERSIONES FINANCIERAS SCOTIABANK INVERSIONES FINANCIERAS SCOTIABANK', '25 AV. NORTE Y 23 CALLE PONIENTE S.', 'SAN SALVADOR', 1),
(1197, '3042756', 'OLX COLOMBIA S.A.S', 'Calle 95 No. 14 -45 Oficina 504', 'BOGOTA D.C.', 1),
(1198, '3042879', 'DATUM S.A. DE C.V.', '89 AV NORTE, C EL MIRADOR, EDIFICIO', 'SAN SALVADOR', 1),
(1199, '3042880', 'MILLICOM SSC, S.A. DE C.V.', 'CALLE EL MIRADOR Y 87 AV NTE COL ES', 'SAN SALVADOR', 1),
(1200, '3042881', 'CLIO COSMETICS, S.A. DE C.V.', '12 CALLE PONIENTE, COLONIA', 'SAN SALVADOR', 1),
(1201, '3042904', 'IMPERIA INTERCONTINENTAL INC.', 'RESIDENCIAL LA CUMBRE 1ERA AVENIDA', 'Tegucigalpa', 1),
(1202, '3042922', 'VIAJES DESPEGAR.COM O.N.L.I.N.E. VIAJES DESPEGAR.COM O.N.L.I.N.E.', 'MULTICENTRO LA SABANA OFICINA. #12', 'SAN JOSÉ- MATA REDONDA', 1),
(1203, '3042938', 'EXA S.A de C.V.', 'Bo. El Benque, 9 Ave. 2 y 3 calle P', 'Tegucigalpa', 1),
(1204, '3042986', 'Geocycle El Salvador, S.A. de C.V.', 'CARR. A SANTA ANA KM. 25,,', 'COLON', 1),
(1205, '3042987', 'SLVRETAIL, S.A. DE C.V. SLVRETAIL, S.A. DE C.V.', 'AV. EL ESPINO Y BLVD. SUR,', 'LA LIBERTAD', 1),
(1206, '3042995', 'Franchise World Headquarters LLC', '325 Sub Way Milford', 'Connecticut', 1),
(1207, '3043004', 'HOLCIM CONCRETOS, S.A. DE C.V.', 'CARR. A SANTA ANA KM. 25,,', 'COLON', 1),
(1208, '3043005', 'BOLSAS DE CENTROAMERICA, S.A. DE C.', 'AV. EL ESPINO Y BLVD. SUR , URBANIZ', 'LA LIBERTAD', 1),
(1209, '3043007', 'AGRESAL S.A. DE C.V.', 'CARR. A SANTA ANA, KM 25, COLON', 'LA LIBERTAD', 1),
(1210, '3043008', 'CONCRETERA MIXTO LISTO, S.A. DE C.V', 'CARR. A SANTA ANA KM 25, COLON', 'LA LIBERTAD', 1),
(1211, '3043009', 'CONCRETERA SALVADOREÑA, S.A. D C.V.', 'CARR. A SANTA ANA, KM 25, COLON', 'LA LIBERTAD', 1),
(1212, '3043010', 'PEDRERA DE EL SALVADOR, S.A. DE C.V', 'AV EL ESPINO Y BLVD. SUR, URBANIZAC', 'LA LIBERTAD', 1),
(1213, '3043011', 'PAVIMENTOS DE CONCRETO, S.A. DE C.V', 'AV. EL ESPINO URBANIZACION MADRESEL', 'LA LIBERTAD', 1),
(1214, '3043012', 'EL RONCO, S.A. DE C.V.', 'AV. EL ESPINO URBANIZACION MADRESEL', 'LA LIBERTAD', 1),
(1215, '3043013', 'INVERSIONES GUIJA, S.A. DE C.V.', 'AV. ESPINO Y BLVD. SUR,', 'LA LIBERTAD', 1),
(1216, '3043014', 'INDUSTRIAS SANTA CRUZ, S.A. DE C.V.', 'AV. EL ESPINO Y BLVD. SUR,', 'LA LIBERTAD', 1),
(1217, '3043015', 'INDUSTRIAS MONTECRISTO, S.A. DE C.V', 'AV. EL ESPINO Y BLVD. SUR,', 'LA LIBERTAD', 1),
(1218, '3043016', 'INDUSTRIAL METAPANECA, S.A. DE C.V.', 'AV. EL ESPINO URBANIZACION MADRESEL', 'LA LIBERTAD', 1),
(1219, '3043017', 'TECOMAPA, S.A. DE C.V.', 'AV. EL ESPINO URBANIZACION MADRESEL', 'LA LIBERTAD', 1),
(1220, '3043018', 'TEMPISCON, S.A. DE C.V.', 'AV. EL ESPINO Y BLVD. SUR,', 'LA LIBERTAD', 1),
(1221, '3043019', 'ORLONA, S.A. DE C.V.', 'AV. EL ESPINO Y BLVD. SUR,', 'LA LIBERTAD', 1),
(1222, '3043020', 'CHUCUMBA, S.A. DE C.V.', 'AV. EL ESPINO Y BLVD. SUR,', 'LA LIBERTAD', 1),
(1223, '3043021', 'CALICHAL, S.A. DE C.V.', 'AV. EL ESPINO Y BLVD. SUR,', 'LA LIBERTAD', 1),
(1224, '3043022', 'CECORTA, S.A. DE C.V.', 'AV. EL ESPINO Y BLVD. SUR,', 'LA LIBERTAD', 1),
(1225, '3043023', 'SUPERCEMENTO, S.A. DE C.V.', 'AV. EL ESPINO Y BLVD. SUR,', 'LA LIBERTAD', 1),
(1226, '3043030', 'Ingenio La Cabaña, S.A. de C.V.', 'Carretera Troncal del Norte, Km 39', 'SAN SALVADOR', 1),
(1227, '3043060', 'NEC de Colombia, S.A. Suc. El Salva', 'Edificio World Trade Cent Local 206', 'SAN SALVADOR', 1),
(1228, '3043120', 'ACCORHOTELS PERU S.A.', 'Victor Andres Belaúnde 181 Int 801', 'LIMA', 1),
(1229, '3043125', 'Terex Germany GmbH & Co, KG', 'Dusseldorf, 40597', 'Dusseldorf', 1),
(1230, '3043129', 'Spectrum Brands', '3001 Deming Way', 'Middleton', 1),
(1231, '3043138', 'Keraben Grupo, S.A.', 'Carr. Valencia-Barcelona Castellon', '.', 1),
(1232, '3043159', 'Invenergy LLC Invenergy LLC', 'CHICAGO', 'CHICAGO', 1),
(1233, '3043224', 'Operadores Logisticos Ransa, S.A. d', 'Parque Industrial Amarateca KM 19 C', 'Tegucigalpa', 1),
(1234, '3043225', 'ALMACENADORA HONDUREÑA, S.A.', '33 calle Sector Polvorin frente a M', 'San Pedro Sula', 1),
(1235, '3043249', 'Ventus S.A. de C.V.', 'Paseo General Escalon No. 5454,', 'SAN SALVADOR', 1),
(1236, '3043250', 'Aseguradora Vivir, S.A.', '81 Av. Sur y Paseo General Escalon', 'SAN SALVADOR', 1),
(1237, '3043319', 'Fundacion Aladina Fundacion Aladina', 'Calle Tomas Breton 50-52, 3 5, 2804', 'MADRID', 1),
(1238, '3043382', 'The Nordam Group Inc.', 'Tulsa, Oklahoma', 'Tulsa', 1),
(1239, '3043383', 'AM DL MRO JV SAPI DE CV', 'No. 22500 Int. A, Carr Queretaro-Te', 'Queretaro', 1),
(1240, '3043428', 'GREAT PLACE TO WORK INSTITUTE OF EL SALVADOR, S.A. DE C.V.', 'Edificio Valencia 5to Nivel, local', 'SAN SALVADOR', 1),
(1241, '3043429', 'American International Group (AIG)', '175 Water ST Rm 1800,', 'New York', 1),
(1242, '3043514', 'Spectrum, S.A. Spectrum, S.A.', 'Diagonal 6 10-01, Centro Gerencial', 'Zona 10', 1),
(1243, '3043594', 'San Crespin, S.A. San Crespin, S.A.', 'Nicaragua', 'Managua', 1),
(1244, '3043623', 'Eagle Motors, S.A. de C.V. Eagle Motors, S.A. de C.V.', 'Boulevard del Hipodromo No. 441', 'SAN SALVADOR', 1),
(1245, '3043624', 'Power Motors, S.A. de C.V.', 'BOULEVARD SI-HAM, CALLE L-3', 'ANTGUO CUSCATLAN', 1),
(1246, '3043650', 'Ministerio de Justicia y Seguridad Ministerio de Justicia y', 'Alameda Juan Pablo II y 17 Av. Nort', 'SAN SALVADOR', 1),
(1247, '3043652', 'Ministerio de Obras Publicas Ministerio de Obras Publicas,', 'Plantel La Lechuza, Carretera a San', 'SAN SALVADOR', 1),
(1248, '3043691', 'PERTENTO SARL', 'PLAZA PABLO, MADRIZ, ESPAÑA.', 'MADRID', 1),
(1249, '3043740', 'Autozama, S.A. de C.V. Autozama, S.A. de C.V.', 'Carretera a Santa Tecla Km. 22, Col', 'LA LIBERTAD', 1),
(1250, '3043741', 'ProCredit Holding AG & Co. KGaA ProCredit Holding AG & Co. KGaA', 'Rohmerplatz 33-37, 60486 Frankfurt', 'Main', 1),
(1251, '3043855', 'KUEHNE + NAGEL, S.A. DE C.V. KUEHNE + NAGEL, S.A. DE C.V.', '103 AVENIDA NORTE, NO 124, COLONIA', 'SAN SALVADOR', 1),
(1252, '3043932', 'Industrial Veterinaria, S.A. Industrial Veterinaria, S.A.', 'Carrer Esmeragda, 19 08950 Esplugue', 'Barcelona', 1),
(1253, '3043944', 'Servilaborales, S.A. de C.V. Servilaborales, S.A. de C.V.', 'Paseo General Escalon, Colonia Esca', 'SAN SALVADOR', 1),
(1254, '3043945', 'Svitzer Caribbean Ltd Svitzer Caribbean Ltd', 'Miramar Huntington Centre II, 2801', 'Florida', 1),
(1255, '3043981', 'Coinsal Instalaciones y Servicios, Coinsal Instalaciones y Servicios,', 'Calle Ayagualo Polig. M, Col. Jardi', 'SANTA TECLA', 1),
(1256, '3043982', 'International Justice Mission International Justice Mission', 'World Trade Center Torre 1, 2do Niv', 'SAN SALVADOR', 1),
(1257, '3044006', 'ABB, S.A. SUCURSAL EL SALVADOR ABB, S.A. SUCURSAL EL SALVADOR', 'Calle El Mirador 89 AV. Norte, Loca', 'SAN SALVADOR', 1),
(1258, '3044029', 'Crowley Maritime Corporation Crowley Maritime Corporation', 'Jacksonville', 'Florida', 1),
(1259, '3044065', 'Emergent Technology Services LLC Emergent Technology Services LLC', '7500 Rialto Boulevard, Building. 2,', 'Texas', 1),
(1260, '3044122', 'Inmobiliaria San Jose S.A. de C.V. Inmobiliaria San Jose S.A. de C.V.', 'Paseo General Escalon, No. 3700', 'SAN SALVADOR', 1),
(1261, '3044213', 'Exportadora de Centroamerica, S.A. Exportadora de Centroamerica,', 'BLVD. Del Ejercito Nacional, KM 7 1', 'SAN SALVADOR', 1),
(1262, '3044239', 'Ministerio de Obras Publicas Ministerio de Obras Publicas,', 'Plantel La Lechuza, Carretera a San', 'SAN SALVADOR', 1),
(1263, '3044240', 'Ministerio de Justicia y Seguridad Ministerio de Justicia y', 'Alameda Juan Pablo II y 17 Av. Nort', 'SAN SALVADOR', 1),
(1264, '3044277', 'IBT, LLC, SUCURSAL EL SALVADOR IBT, LLC SUCURSAL EL SALVADOR', 'Calle El Mirador, Col. Escalon, Edi', 'SAN SALVADOR', 1),
(1265, '3044278', 'Amaya & Guevara Auditores, S.A. de Amaya & Guevara Auditores, S.A. de', 'Ave. Sierra Nevada, Edificio CC,', 'SAN SALVADOR', 1),
(1266, '3044282', 'BELLMART, S.A. DE C.V. BELLMART, S.A. DE C.V.', 'AV. VICTOR MANUEL MEJIA LARA, C #20', 'SAN SALVADOR', 1),
(1267, '3044283', 'SANDRA GUZMAN BELTRAN SANDRA GUZMAN BELTRAN', 'Residencial Marcela, Apto. 21, Call', 'SAN SALVADOR', 1),
(1268, '3044285', 'DEXTRA EMPRESARIAL, S.A. DE C.V. DEXTRA EMPRESARIAL, S.A. DE C.V.', 'AV. PINARES, POLIG 13, #9, RESID. P', 'SANTA TECLA', 1),
(1269, '3044286', 'Inversiones Financieras Atlantida, Inversiones Financieras Atlantida,', 'CALLE CUSCATLAN, COL. ESCALON, #133', 'SAN SALVADOR', 1),
(1270, '3044287', 'Transportes Calpi, S.A. de C.V. Transportes Calpi, S.A. de C.V.', '8a Porcion, hacienda el angel Apopa', 'SAN SALVADOR', 1),
(1271, '3044306', 'SUEZ INTERNATIONAL SAS', 'AVENIDA CENTENARIO, COSTA DEL ESTE,', 'PANAMA', 1),
(1272, '3044426', 'SWAT CONSULTING SERVICES EL SALVADO SWAT CONSULTING SERVICIES EL SALVA', 'CALLE EL MIRADOR 89 AV. NORTE, LOCA', 'SAN SALVADOR', 1),
(1273, '3044427', 'PANALPINA SEM, S.A. PANALPINA SEM, S.A.', 'Los Andres No 2, Centro Industrial', 'Ojo de Agua', 1),
(1274, '3044470', 'Servicios Bursatiles Salvadoreños, Servicios Bursatiles Salvadoreños,', 'Bulevar Luis Poma Edificio Avante S', 'ANTGUO CUSCATLAN', 1),
(1275, '3044507', 'FRUTERIA VIDAURRI, S.A. DE C.V. FRUTERIA VIDAURRI, S.A. DE C.V.', 'POIGONO 2, CANTO JOYA A GALANA, LOT', 'APOPA', 1),
(1276, '3044508', 'International Committee of the Red International Committee of the Red', '19 Avenue de la paix', ' 1202', 1),
(1277, '3044531', 'FOSAFFI Fondo de Saneamiento y', '1a Calle Poniente y 7a Av. Norte, E', 'SAN SALVADOR', 1),
(1278, '3044574', 'CH Operacion de Inversiones Hoteler CH Operacion de Inversiones', 'Avenida Escazu, edificio 102, piso', 'ESCAZÚ- ESCAZÚ', 1),
(1279, '3044634', 'Fundacion Campo Fundacion Campo', '14 Calle poniente, Colonia Hirleman', 'SAN SALVADOR', 1),
(1280, '3044721', 'Innovaciones Medicas, S.A. de C.V. Innovaciones Medicas, S.A. de C.V.', 'Entre Calle Gabriela Mistral y 21 C', 'SAN SALVADOR', 1),
(1281, '3044722', 'FEPADE Fundacion Empresarial para el', 'Calle Pedregal y Calle de acceso a', 'ANTGUO CUSCATLAN', 1),
(1282, '3044723', 'Statetrust Seguros Aseguradora Statetrust El Salvador,', 'Calle El Mirador 89 Av. Norte, Col.', 'SAN SALVADOR', 1),
(1283, '3044770', 'Millicom International Cellular, S. Millicom International Cellular, S', '2 rue du firt Bourbon, L-1249', 'Luxembourg', 1),
(1284, '3044771', 'Siemens Healthcare GmbH Siemens Healthcare GmbH', '', 'New York', 1),
(1285, '3044772', 'WALMART MEXICO & CENTRAL AMERICA WALMART MEXICO & CENTRAL AMERICA', '', 'Mexico', 1),
(1286, '3044810', 'Cooperativa Ganadera de Sonsonate d Cooperativa Ganadera', 'Boulevard Oscar Osorio, Barrio El A', 'SONSONATE', 1),
(1287, '3044865', 'CARIBE TERRANUM EL SALVADOR CARIBE TERRANUM EL SALVADOR, S.A. D', 'CALLE 2 CENTRO DE ESTILO DE VIDA LA', 'LA LIBERTAD', 1),
(1288, '3044903', 'HOTELES E INVERSIONES, S.A. DE C.V. HOTELES E INVERSIONES, S.A. DE C.V', 'BLV. DEL HIPODROMO Y AV. LAS MAGNOL', 'SAN SALVADOR', 1),
(1289, '3044904', 'Unipharm de El Salvador, S.A. de C. Unipharm de El Salvador, S.A. de C', 'Calle L-3 Blvd. Vijosa Polig. C, #3', 'SANTA TECLA', 1),
(1290, '3044905', 'Barcelo Corporacion Empresarial, S. Barcelo Corporacion Empresarial, S', 'Calle Josep Rover Motta 27 Palma', 'Beleares', 1),
(1291, '3045023', 'SERVICIOS OPTIMOS, S.A. DE C.V. SERVICIOS OPTIMOS, S.A. DE C.V.', 'Carretera Troncal del Norte, Km 39.', 'SAN SALVADOR', 1),
(1292, '3045027', 'GARAN DE EL SALVADOR, S.A. DE C.V. GARAN DE EL SALVADOR, S.A. DE C.V.', 'KM. 24-5 CARRETERA A SANTA ANA, ZON', 'LA LIBERTAD', 1),
(1293, '3045085', 'Enertiva de El Salvador, S.A. de C.', 'Calle Cuscatlan Local No. 104', 'SAN SALVADOR', 1),
(1294, '3045134', 'Coqueterias El Salvador, S.A. de C. Coqueterias El Salvador, S.A. de C', 'Calle Alegria Blvd. Sta Elena, Col.', 'ANTGUO CUSCATLAN', 1),
(1295, '3045135', 'Youngone El Salvador, S.A. de C.V. Youngone El Salvador, S.A. de C.V.', 'Km 28 1/2 Carretera a Comalapa,', 'OLOCUILTA', 1),
(1296, '3045242', 'Alcatel-Lucent El Salvador, S.A. de Alcatel-Lucent El Salvador, S.A. d', 'India', 'India', 1),
(1297, '3045243', 'INVERSIONES TEOPAN, S.A. DE C.V. INVERSIONES TEOPAN, S.A. DE C.V.', '4a CALLE ORIENTE No. 5-8', 'SANTA TECLA', 1),
(1298, '3045244', 'Crediplata, S.A. Crediplata, S.A.', 'Novena calle Poniente 4/6 av Sur #2', 'SANTA ANA', 1),
(1299, '3045266', 'IDC Asesores Financieros, S.A. de C IDC Asesores Financieros, S.A. de', 'Edificio Avante, Piso 7 Local 7-03,', 'ANTGUO CUSCATLAN', 1),
(1300, '3045267', 'Portafolio de Negocios, S.A. de C.V Portafolio de Negocios, S.A. de C.', 'Edificio Avante, Piso 7 Local 7-03,', 'ANTGUO CUSCATLAN', 1),
(1301, '3045299', 'Thales Avionics, Inc. Thales Avionics, Inc.', '140 Centennial Avenue', 'Piscataway', 1),
(1302, '3045306', 'Desarrollos Terrestres, Ltda de C.V Desarrollos Terrestres, Ltda de C.', 'Colonia San Benito Avenida la Capil', 'SAN SALVADOR', 1),
(1303, '3045367', 'Roberto Dueñas Limitada Roberto Dueñas Limitada', 'Carretera Panamericana y Calle Chil', 'ANTGUO CUSCATLAN', 1),
(1304, '3045368', 'AVX INDUSTRIES PTE LTD AVX INDUSTRIES PTE LTD', 'ZONA FRANCA SAN BARTOLO 4-4', 'ILOPANGO', 1),
(1305, '3045369', 'FUNDACION CESSA FUNDACION CESSA', '', 'SAN SALVADOR', 1),
(1306, '3045377', 'Zafra, S.A. de C.V. Zafra, S.A. de C.V.', 'Carretera Troncal del Norte, Km 39', 'EL PAISNAL', 1),
(1307, '3045381', 'Latam Airlines Group, S.A', 'Santiago de Chile', 'Santiago', 1),
(1308, '3045426', 'Servicios Efectivos, S.A. de C.V. Servicios Efectivos, S.A. de C.V.', 'Carretera Troncal del Norte, Km 39', 'EL PAISNAL', 1),
(1309, '3045427', 'Sika Guatemala S.A. Sucursal El Sal Sika Guatemala, S.A.', 'Calle Circunvalacion, bodegas 15 y', 'ANTGUO CUSCATLAN', 1),
(1310, '3045435', 'Energizer Holdings, Inc Energizer Holdings, Inc.', '', 'Estados Unidos', 1),
(1311, '3045526', 'Telemovil El Salvador Telemovil El Salvador, S.A. de C.V.', 'Carril al Puerto de la Liber m 16.5', 'SAN SALVADOR', 1),
(1312, '3045527', 'Carlos Ernesto Reyes Vasquez Carlos Ernesto Reyes Vasquez', 'Col. San Luis, C. Planes de Rendero', 'SAN SALVADOR', 1),
(1313, '3045622', 'LIVISTO EXPORT, S.A. DE C.V. LIVISTO EXPORT, S.A. DE C.V.', 'CARR. AL PUERTO DE LA LIBERTAD KM 1', 'SANTA TECLA', 1),
(1314, '3045623', 'BLUE JAY DE EL SALVADOR, S.A. DE C. BLUE JAY DE EL SALVADOR, S.A. DE C', 'CENTRO COMERCIAL GALERIAS, COLONIA', 'SAN SALVADOR', 1),
(1315, '3045624', 'RED FOX LAS MERCEDES, S.A. DE C.V. RED FOX LAS MERCEDES, S.A. DE C.V.', 'Carretera de Sana Ana a Sonsonate K', 'SANTA ANA', 1),
(1316, '3045625', 'Parque Industrial Santa Ana, S.A. d Parque Industrial Santa Ana, S.A.', 'Carretera de Santa Ana a Sonsonate', 'SANTA ANA', 1),
(1317, '3045667', 'Soluciones y Herramientas, S.A. de Soluciones y Herramientas, S.A. de', 'Carretera CA-1 KM 17.5, Num 8-9', 'APOPA', 1),
(1318, '3045668', 'FONDO DE INVERSION ABIERTO FONDO DE INVERSION ABIERTO', '1era Calle Pte. y 67 Av. Norte No.', 'SAN SALVADOR', 1),
(1319, '3045669', 'CDI, Sociedad Anonima', 'Km. 10 1/2 Carretera Sur, Costado S', 'Managua', 1),
(1320, '3045672', 'Citi Group', 'Estados Unidos', 'Estados Unidos', 1);
INSERT INTO `clientes` (`codigoCliente`, `codigo`, `nombreCliente`, `calle`, `poblacion`, `idEliminado`) VALUES
(1321, '3045694', 'Corporacion Ferretera, S.A. de C.V. Corporacion Ferretera, S.A. de C.V', 'Urb. Madreselva Pte. Edificio Avant', 'ANTGUO CUSCATLAN', 1),
(1322, '3045720', 'British Telecommunications PLC', 'BT Centre, 81 Newgate Street London', 'londres', 1),
(1323, '3045728', 'GRANJA INDUSTRIAL BONANZA, S.A. DE GRANJA INDUSTRIAL BONANZA, S.A. DE', 'KM. 32 1/2, CARRETERA A SANTA ANA C', 'LA LIBERTAD', 1),
(1324, '3045831', 'Sony Mobile Communications Inc.', 'Tokio', 'tokio', 1),
(1325, '3045846', 'Grupo Mantech, S.A. de C.V.', 'Cumbres de la Escalon, calle el Boq', 'SAN SALVADOR', 1),
(1326, '3045869', 'Hoteles Decameron El Salvador, Hoteles Decameron El Salvador,', 'Paseo General Escalon No. 4711', 'SAN SALVADOR', 1),
(1327, '3045875', 'BASF SE', 'Zurich, Switzerland', 'Zurich', 1),
(1328, '3045943', 'Batcca Servicios, S.A.', '325 Metros este de la Firestone, Sa', 'FLORES- SAN JOAQUÍN', 1),
(1329, '3045944', 'MOTOROLA SOLUTIONS DE MEXICO', 'Bosques de Alisos 125, Bosques de l', 'Ciudad de Mexico', 1),
(1330, '3045945', 'LICORERA CIHUATAN, S.A. DE C.V.', 'CARRETERA TRONCAL DEL NORTE KM 39 1', 'EL PAISNAL', 1),
(1331, '3045946', 'SERVICIOS AGROINDUSTRIALES, S.A. DE', 'KM 39 1/2 CARRET. TRONCAL DEL NTE.', 'EL PAISNAL', 1),
(1332, '3045974', 'TRANSUNION EL SALVADOR, S.A. DE C.V', 'CALLE EL MIRADOR 87 AVE. NORTE, LOC', 'SAN SALVADOR', 1),
(1333, '3045975', 'Bolt Marketing, S.A. de C.V.', 'Calle L3, Blv, Si-Ham, Zona Industr', 'ANTGUO CUSCATLAN', 1),
(1334, '3045976', 'Espatiendas de El Salvador, S.A. de', 'Col. Escalon Ctro. Com. Galerias #3', 'SAN SALVADOR', 1),
(1335, '3046027', 'Suez International, S.A.S Suez International, S.A.S', 'Local9-10, URB, Madre Selva Edifici', 'ANTGUO CUSCATLAN', 1),
(1336, '3046042', 'THE OFFICE GURUS LTDA DE CV', 'Zona 02, Zona Industrial Carretera', 'ANTGUO CUSCATLAN', 1),
(1337, '3046043', 'GMG COMERCIAL EL SALVADOR, S.A. DE', 'Boulevard Orden de Malta #700, Urba', 'ANTGUO CUSCATLAN', 1),
(1338, '3046156', 'Tetunte, S.A. de C.V.', 'Carr. Tcal del Norte Km 39 y medio', 'EL PAISNAL', 1),
(1339, '3046157', 'Tanate, S.A. de C.V.', 'Carr. Tcal del Norte Km 39 y medio', 'EL PAISNAL', 1),
(1340, '3046158', 'Productora Belen, S.A. de C.V.', 'Carr. Tcal del Norte Km 39 y  medio', 'EL PAISNAL', 1),
(1341, '3046159', 'Tecomate, S.A. de C.V.', 'Carr. Tcal del Norte Km 39 y medio', 'EL PAISNAL', 1),
(1342, '3046160', 'International Pharmaceutical International Pharmaceutical', 'Paseo General Escalon y Calle Artur', 'SAN SALVADOR', 1),
(1343, '3046162', 'Servicios de Documentos, S.A. de C.', '23 Ave. Sur y Calle Primavera, Parq', 'SANTA TECLA', 1),
(1344, '3046164', 'SPECTRUM BRANDS EL SALVADOR, LTDA D', 'BLVD. MERLIOT EDIFICIO RAYOVAC', 'SANTA TECLA', 1),
(1345, '3046272', 'Turboden S.P.A', 'Berscia Via Cernaia 10 Cap 25124', 'Italia', 1),
(1346, '3046273', 'Onelink Holdings, S.A.', 'Plaza Credicorp Bank, Piso 26 Aveni', 'Panama', 1),
(1347, '3046274', 'Distribuidora de Alimentos Distribuidora de Alimentos', 'KM 4.5 Carr. Antigua San Marco, Col', 'SAN MARCOS', 1),
(1348, '3046333', 'Termoexport, S.A. de C.V.', 'Calle L-2, Local 19 y 20, Ciudad Me', 'ANTGUO CUSCATLAN', 1),
(1349, '3046439', 'HIDALGO E HIDALGO, S.A HIDALGO E HIDALGO, S.A', 'Calle Llama del Bosque poniente pje', 'ANTGUO CUSCATLAN', 1),
(1350, '3046440', 'Progreso e Inversiones, S.A. de C.V', 'Calle L-3 Poligono D, Lote 1 Y 2, Z', 'ANTGUO CUSCATLAN', 1),
(1351, '3046518', 'AES Union de Negocios, S.A. de C.V.', 'Calle Circunvalacion, Polig J, Col.', 'SAN SALVADOR', 1),
(1352, '3046519', 'AES Next Limitada de Capital Variab', 'Calle Circunvalacion, Polig J, Col.', 'SAN SALVADOR', 1),
(1353, '3046520', 'Allegiant Travel Company', 'Las Vegas', 'Las Vegas', 1),
(1354, '3046521', 'Recicladora de Metales de Centroame Recicladora de Metales', 'Calle Llama de Bosque PTE., Local 6', 'LA LIBERTAD', 1),
(1355, '3046524', 'Arabela El Salvador, S.A. de C.V.', 'Calle Los Bambues, Res. Las Bunganv', 'SAN SALVADOR', 1),
(1356, '3046525', 'Arabela Logistics, S.A. de C.V.', 'Carretera Santa Ana Km. 36, Local 1', 'LA LIBERTAD', 1),
(1357, '3046633', 'CALIDAD INTEGRAL, S.A. DE C.V.', 'Final 21 Av. Nte y Autopista Nte. E', 'SAN SALVADOR', 1),
(1358, '3046676', 'INGENIERIA CONSULTORIA Y INGENIERIA CONSULTORIA Y', 'Fincal 21 Av. Nte y Autopista Nte.', 'LA LIBERTAD', 1),
(1359, '3046686', 'BIO TEST, S.A. DE C.V.', 'Colonia Jardines de Guadalupe, Av.', 'LA LIBERTAD', 1),
(1360, '3046705', 'El Salvador Asistencia, S.A. de C.V', 'Alameda Roosevelt, Edificio La Cent', 'SAN SALVADOR', 1),
(1361, '3046781', 'Jiboa Solar, S.A. de C.V.', '89 Av. Norte, Local 205, Col. Escal', 'SAN SALVADOR', 1),
(1362, '3046833', 'Vuela El Salvador, S.A. de C.V.', 'Calle Llama de Bosque PTE, Local 3-', 'LA LIBERTAD', 1),
(1363, '3046888', 'Plasticos El Panda, S.A. de C.V.', 'Calle Circunvalacion, Polig A, Urb.', 'ANTGUO CUSCATLAN', 1),
(1364, '3046893', 'Distribuidora Morazan, S.A. de C.V.', 'Carretera Troncal del Norte KM 11.5', 'APOPA', 1),
(1365, '3046894', 'TOMSAL, S.A. DE C.V.', 'CALLE SIEMENS, URB. INDUSTRIAL. SAN', 'ANTGUO CUSCATLAN', 1),
(1366, '3046895', 'Calleja, S.A. de C.V.', 'Prolongacion 59 av. Sur, Col. Escal', 'SAN SALVADOR', 1),
(1367, '3047037', 'ATLANTIDA SECURITIES, S.A. DE C.V. ATLANTIDA SECURITIES, S.A. DE C.V.', 'BOULEVARD CONSTITUCION Y 1RA CALLE', 'SAN SALVADOR', 1),
(1368, '3047038', 'ATLANTIDA CAPITAL, S.A. GESTORA ATLANTIDA CAPITAL, S.A. GESTORA', 'Calle Cuscatlan N. 133, Entre 81 y', 'SAN SALVADOR', 1),
(1369, '3047043', 'Arrocera San Francisco S.A. de C.V.', 'Km. 9-5 Carretera a Comalapa,', 'SAN MARCOS', 1),
(1370, '3047044', 'Scotia Inversiones S.A. de C.V. Scotia Inversiones S.A. de C.V.', '25 Avenida Norte, 21 y 23 Calle Pon', 'SAN SALVADOR', 1),
(1371, '3047049', 'Scotia Soluciones Financieras, S.A.', '25 Avenida Norte, entre 21 y 23 Cal', 'SAN SALVADOR', 1),
(1372, '3047050', 'Scotia Servicredit, S.A. de C.V.', '25 Avenida Norte t 23 Calle Ponient', 'SAN SALVADOR', 1),
(1373, '3047052', 'Statkraft AS', '', 'Oslo', 1),
(1374, '3047076', 'Helados Rio Soto, S.A. de C.V.', '1A CALLE OTE#1008, BARRIO CONCEPCIO', 'SAN SALVADOR', 1),
(1375, '3047078', 'DACSA DE EL SALVADOR, S.A. DE C.V.', 'FINAL 79 AVENIDA SUR, PASAJE C, CAS', 'SAN SALVADOR', 1),
(1376, '3047098', 'Mark Gitomer', '431 Maple Ave,', 'Pittsburgh', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalleenvio`
--

CREATE TABLE `detalleenvio` (
  `codigoDetalleEnvio` int(11) NOT NULL,
  `correlativoDetalle` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `codigoEnvio` int(11) DEFAULT NULL,
  `codigoTipoTramite` int(11) DEFAULT NULL,
  `codigoCliente` int(11) DEFAULT NULL,
  `codigoTipoDocumento` int(11) DEFAULT NULL,
  `codigoArea` int(11) DEFAULT NULL,
  `codigoStatus` int(11) DEFAULT NULL,
  `numDoc` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `monto` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacion` text COLLATE utf8mb4_unicode_ci,
  `fechaRegistro` date DEFAULT NULL,
  `fechaRevision` date DEFAULT NULL,
  `horaRevision` time DEFAULT NULL,
  `fechaEnviado` date DEFAULT NULL,
  `codigoMensajero` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `detalleenvio`
--

INSERT INTO `detalleenvio` (`codigoDetalleEnvio`, `correlativoDetalle`, `codigoEnvio`, `codigoTipoTramite`, `codigoCliente`, `codigoTipoDocumento`, `codigoArea`, `codigoStatus`, `numDoc`, `monto`, `observacion`, `fechaRegistro`, `fechaRevision`, `horaRevision`, `fechaEnviado`, `codigoMensajero`) VALUES
(1, 'DD1', 1, 1, 1, 1, 1, 3, '123', '$0.00', '123', '2019-02-01', '2019-02-01', '15:23:53', '2019-02-01', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `envio`
--

CREATE TABLE `envio` (
  `codigoEnvio` int(11) NOT NULL,
  `correlativoEnvio` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `codigoUsuario` int(11) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `hora` time DEFAULT NULL,
  `estado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `envio`
--

INSERT INTO `envio` (`codigoEnvio`, `correlativoEnvio`, `codigoUsuario`, `fecha`, `hora`, `estado`) VALUES
(1, 'ED1', 1, '2019-02-01', '15:23:53', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mensajero`
--

CREATE TABLE `mensajero` (
  `codigoMensajero` int(11) NOT NULL,
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `idEliminado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `mensajero`
--

INSERT INTO `mensajero` (`codigoMensajero`, `nombre`, `idEliminado`) VALUES
(1, 'No Asignado', 1),
(2, 'Enrique Segoviano', 1),
(3, 'Ramon Valdéz', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `observaciones`
--

CREATE TABLE `observaciones` (
  `codigoObservaciones` int(11) NOT NULL,
  `observacion` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `codigoRol` int(11) NOT NULL,
  `descRol` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`codigoRol`, `descRol`) VALUES
(1, 'Administrador'),
(2, 'Solicitante');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `status`
--

CREATE TABLE `status` (
  `codigoStatus` int(11) NOT NULL,
  `descStatus` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `status`
--

INSERT INTO `status` (`codigoStatus`, `descStatus`) VALUES
(1, 'Pendiente de Revision'),
(2, 'Incompleto'),
(3, 'Recibido'),
(4, 'Pendiente'),
(5, 'Completo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipodocumento`
--

CREATE TABLE `tipodocumento` (
  `codigoTipoDocumento` int(11) NOT NULL,
  `descTipoDocumento` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `idEliminado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tipodocumento`
--

INSERT INTO `tipodocumento` (`codigoTipoDocumento`, `descTipoDocumento`, `idEliminado`) VALUES
(1, 'FE', 1),
(2, 'F', 1),
(3, 'CCF', 1),
(4, 'Q', 1),
(5, 'Propuestas', 1),
(6, 'Informes', 1),
(7, 'Otro', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipotramite`
--

CREATE TABLE `tipotramite` (
  `codigoTipoTramite` int(11) NOT NULL,
  `descTipoTramite` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tipotramite`
--

INSERT INTO `tipotramite` (`codigoTipoTramite`, `descTipoTramite`, `estado`) VALUES
(1, 'Entrega', 1),
(2, 'Cobro', 1),
(3, 'Transferencia', 1),
(4, 'Depósito', 1),
(5, 'Retiro de Cheques', 1),
(6, 'Retiro de Documentos', 1),
(7, 'Pago', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `codigoUsuario` int(11) NOT NULL,
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apellido` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nomUsuario` varchar(75) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pass` varchar(75) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `codigoAuth` int(11) DEFAULT NULL,
  `codigoRol` int(11) DEFAULT NULL,
  `codigoArea` int(11) DEFAULT NULL,
  `idEliminado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`codigoUsuario`, `nombre`, `apellido`, `nomUsuario`, `email`, `pass`, `codigoAuth`, `codigoRol`, `codigoArea`, `idEliminado`) VALUES
(1, 'Karla Guadalupe', 'Arevalo Vega', 'kgarevalo', 'kgarevalo@deloitte.com', '51ad76a46492b0a1442a0a626fb3fef885976cce', 1, 1, 1, 1);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `area`
--
ALTER TABLE `area`
  ADD PRIMARY KEY (`codigoArea`);

--
-- Indices de la tabla `authusuario`
--
ALTER TABLE `authusuario`
  ADD PRIMARY KEY (`codigoAuth`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`codigoCliente`);

--
-- Indices de la tabla `detalleenvio`
--
ALTER TABLE `detalleenvio`
  ADD PRIMARY KEY (`codigoDetalleEnvio`),
  ADD KEY `fk_detalleEnvio_envio` (`codigoEnvio`),
  ADD KEY `fk_detalleEnvio_tipoTramite` (`codigoTipoTramite`),
  ADD KEY `fk_detalleEnvio_tipoDocumento` (`codigoTipoDocumento`),
  ADD KEY `fk_detalleEnvio_area` (`codigoArea`),
  ADD KEY `fk_detalleEnvio_clientes` (`codigoCliente`),
  ADD KEY `fk_detalleEnvio_status` (`codigoStatus`),
  ADD KEY `fk_detalleEnvio_mensajero` (`codigoMensajero`);

--
-- Indices de la tabla `envio`
--
ALTER TABLE `envio`
  ADD PRIMARY KEY (`codigoEnvio`),
  ADD KEY `fk_envio_usuario` (`codigoUsuario`);

--
-- Indices de la tabla `mensajero`
--
ALTER TABLE `mensajero`
  ADD PRIMARY KEY (`codigoMensajero`);

--
-- Indices de la tabla `observaciones`
--
ALTER TABLE `observaciones`
  ADD PRIMARY KEY (`codigoObservaciones`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`codigoRol`);

--
-- Indices de la tabla `status`
--
ALTER TABLE `status`
  ADD PRIMARY KEY (`codigoStatus`);

--
-- Indices de la tabla `tipodocumento`
--
ALTER TABLE `tipodocumento`
  ADD PRIMARY KEY (`codigoTipoDocumento`);

--
-- Indices de la tabla `tipotramite`
--
ALTER TABLE `tipotramite`
  ADD PRIMARY KEY (`codigoTipoTramite`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`codigoUsuario`),
  ADD KEY `fk_usuario_rol` (`codigoRol`),
  ADD KEY `fk_usuario_auth` (`codigoAuth`),
  ADD KEY `fk_usuario_area` (`codigoArea`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `area`
--
ALTER TABLE `area`
  MODIFY `codigoArea` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `authusuario`
--
ALTER TABLE `authusuario`
  MODIFY `codigoAuth` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `codigoCliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1377;

--
-- AUTO_INCREMENT de la tabla `detalleenvio`
--
ALTER TABLE `detalleenvio`
  MODIFY `codigoDetalleEnvio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `envio`
--
ALTER TABLE `envio`
  MODIFY `codigoEnvio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `mensajero`
--
ALTER TABLE `mensajero`
  MODIFY `codigoMensajero` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `observaciones`
--
ALTER TABLE `observaciones`
  MODIFY `codigoObservaciones` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `codigoRol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `status`
--
ALTER TABLE `status`
  MODIFY `codigoStatus` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `tipodocumento`
--
ALTER TABLE `tipodocumento`
  MODIFY `codigoTipoDocumento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `tipotramite`
--
ALTER TABLE `tipotramite`
  MODIFY `codigoTipoTramite` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `codigoUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `detalleenvio`
--
ALTER TABLE `detalleenvio`
  ADD CONSTRAINT `fk_detalleEnvio_area` FOREIGN KEY (`codigoArea`) REFERENCES `area` (`codigoArea`),
  ADD CONSTRAINT `fk_detalleEnvio_clientes` FOREIGN KEY (`codigoCliente`) REFERENCES `clientes` (`codigoCliente`),
  ADD CONSTRAINT `fk_detalleEnvio_envio` FOREIGN KEY (`codigoEnvio`) REFERENCES `envio` (`codigoEnvio`),
  ADD CONSTRAINT `fk_detalleEnvio_mensajero` FOREIGN KEY (`codigoMensajero`) REFERENCES `mensajero` (`codigoMensajero`),
  ADD CONSTRAINT `fk_detalleEnvio_status` FOREIGN KEY (`codigoStatus`) REFERENCES `status` (`codigoStatus`),
  ADD CONSTRAINT `fk_detalleEnvio_tipoDocumento` FOREIGN KEY (`codigoTipoDocumento`) REFERENCES `tipodocumento` (`codigoTipoDocumento`),
  ADD CONSTRAINT `fk_detalleEnvio_tipoTramite` FOREIGN KEY (`codigoTipoTramite`) REFERENCES `tipotramite` (`codigoTipoTramite`);

--
-- Filtros para la tabla `envio`
--
ALTER TABLE `envio`
  ADD CONSTRAINT `fk_envio_usuario` FOREIGN KEY (`codigoUsuario`) REFERENCES `usuario` (`codigoUsuario`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `fk_usuario_area` FOREIGN KEY (`codigoArea`) REFERENCES `area` (`codigoArea`),
  ADD CONSTRAINT `fk_usuario_auth` FOREIGN KEY (`codigoAuth`) REFERENCES `authusuario` (`codigoAuth`),
  ADD CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`codigoRol`) REFERENCES `rol` (`codigoRol`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
