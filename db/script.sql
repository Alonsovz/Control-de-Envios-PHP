drop database if exists deloitte_mensajeria;
create database deloitte_mensajeria;
use deloitte_mensajeria;

ALTER DATABASE deloitte_mensajeria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ===========================================================================
-- TABLAS
-- ===========================================================================

create table usuario (
    codigoUsuario int primary key unique auto_increment,
    nombre varchar(50),
    apellido varchar(50),
    nomUsuario varchar(75),
    email varchar(100),
    pass varchar(75),
    codigoAuth int,
    codigoRol int,
    codigoArea int,
    idEliminado int
);

create table rol (
    codigoRol int primary key unique auto_increment,
    descRol varchar(25)
);

create table area (
	codigoArea int primary key unique auto_increment,
    descArea varchar(25),
    idEliminado int
);

create table authUsuario (
	codigoAuth int primary key unique auto_increment,
    descAuth varchar(25)
);

create table envio (
	codigoEnvio int primary key unique auto_increment,
    correlativoEnvio varchar(25),
    codigoUsuario int,
    fecha date,
    hora time,
	estado int
);

create table detalleEnvio (
	codigoDetalleEnvio int primary key unique auto_increment,
    correlativoDetalle varchar(25),
    codigoEnvio int,
    codigoTipoTramite int,
    codigoCliente int,
    codigoTipoDocumento int,
    codigoArea int,
    codigoStatus int,
    numDoc varchar(25),
    monto varchar(25),
    observacion text,
    fechaRegistro date,
    fechaRevision date,
    horaRevision time,
    fechaEnviado date,
    codigoMensajero int
);

create table mensajero(
	codigoMensajero int primary key unique auto_increment,
    nombre varchar(50),
    idEliminado int
);

create table tipoTramite(
	codigoTipoTramite int primary key unique auto_increment,
    descTipoTramite varchar(25),
    estado int
);

create table clientes (
	codigoCliente int primary key unique auto_increment,
	codigo varchar(25),
    nombreCliente varchar(128),
    calle varchar(256),
    poblacion varchar(75),
    idEliminado int
);

create table tipoDocumento (
    codigoTipoDocumento int primary key unique auto_increment,
    descTipoDocumento varchar(25),
    idEliminado int
);

create table observaciones (
    codigoObservaciones int primary key unique auto_increment,
    observacion text
);

create table status (
    codigoStatus int primary key unique auto_increment,
    descStatus varchar(25)
);

-- ===========================================================================
-- RELACIONES
-- ===========================================================================

alter table usuario add constraint fk_usuario_rol foreign key (codigoRol) references rol(codigoRol);
alter table usuario add constraint fk_usuario_auth foreign key (codigoAuth) references authUsuario(codigoAuth);
alter table usuario add constraint fk_usuario_area foreign key (codigoArea) references area(codigoArea);
alter table envio add constraint fk_envio_usuario foreign key (codigoUsuario) references usuario(codigoUsuario);
alter table detalleEnvio add constraint fk_detalleEnvio_envio foreign key (codigoEnvio) references envio(codigoEnvio);
alter table detalleEnvio add constraint fk_detalleEnvio_tipoTramite foreign key (codigoTipoTramite) references tipoTramite(codigoTipoTramite);
alter table detalleEnvio add constraint fk_detalleEnvio_tipoDocumento foreign key (codigoTipoDocumento) references tipoDocumento(codigoTipoDocumento);
alter table detalleEnvio add constraint fk_detalleEnvio_area foreign key (codigoArea) references area(codigoArea);
alter table detalleEnvio add constraint fk_detalleEnvio_clientes foreign key (codigoCliente) references clientes(codigoCliente);
-- alter table detalleEnvio add constraint fk_detalleEnvio_observaciones foreign key (codigoObservaciones) references observaciones(codigoObservaciones);
alter table detalleEnvio add constraint fk_detalleEnvio_status foreign key (codigoStatus) references status(codigoStatus);
alter table detalleEnvio add constraint fk_detalleEnvio_mensajero foreign key (codigoMensajero) references mensajero(codigoMensajero);


delimiter $$
create procedure registrarUsuario(
	in nom varchar(50),
    in ape varchar(50),
    in us varchar(50),
    in correo varchar(75),
    in contra varchar(75),
    in idArea int,
    in rol int,
    in idEli int
)
begin
	insert into usuario values (null, nom, ape, us, correo, contra, 2, rol, idArea,idEli);
end
$$

delimiter $$
create procedure login(
	in user varchar(50),
    in contra varchar(75)
)
begin
	select u.*, r.descRol, a.descAuth, ar.descArea
	from usuario u
	inner join rol r on r.codigoRol = u.codigoRol
	inner join authUsuario a on a.codigoAuth = u.codigoAuth
    inner join area ar on ar.codigoArea = u.codigoArea
    where u.nomUsuario = user and u.pass = contra;
end	
$$

delimiter $$
create procedure datosNomUsuario(
	in nom varchar(50)
)
begin
	select u.*, r.descRol
    from usuario u
    inner join rol r on r.codigoRol = u.codigoRol
    where u.nomUsuario = nom;
end
$$

delimiter $$
create procedure editarUsuario(
	in nom varchar(50),
    in ape varchar(50),
    in us varchar(50),
    in correo varchar(75),
    in rol int,
    in idArea int,
    in idUser int
)
begin
	update usuario
    set nombre = nom, apellido = ape, nomUsuario = us, email = correo, codigoRol = rol, codigoArea = idArea
    where codigoUsuario = idUser;
end
$$

delimiter $$
create procedure mostrarUsuarios()
begin
	select u.*, r.descRol, a.descAuth, ar.descArea
	from usuario u
	inner join rol r on r.codigoRol = u.codigoRol
	inner join authUsuario a on a.codigoAuth = u.codigoAuth
    inner join area ar on ar.codigoArea = u.codigoArea
    where u.idEliminado=1;
end
$$

delimiter $$
create procedure cuentasAdministrador() 
begin
	select u.*, r.descRol, a.descAuth, ar.descArea
	from usuario u
	inner join rol r on r.codigoRol = u.codigoRol
	inner join authUsuario a on a.codigoAuth = u.codigoAuth
    inner join area ar on ar.codigoArea = u.codigoArea
    where u.idEliminado=1 and r.descRol = 'Administrador';
end
$$

#Procedimientos de Clientes

delimiter $$
create procedure mostrarClientes()
begin
	select * from clientes where idEliminado=1
    order by nombreCliente;
end
$$


delimiter $$
create procedure registrarCliente(
	in codigo varchar(50),
    in nombre varchar(128),
    in ca varchar(256),
    in pob varchar(75)
)
begin
	insert into clientes values (null, codigo, nombre, ca, pob, 1);
end
$$

delimiter $$
create procedure editarCliente(
	in nom varchar(128),
    in cod varchar(50),
    in ca varchar(256),
    in pob varchar(75),
    in idCliente int
)
begin
	update clientes
    set nombreCliente = nom, calle = ca, poblacion = pob, codigo = cod
    where codigoCliente = idCliente;
end
$$
-- PROCEDIMIENTOS DOCUMENTO--
delimiter $$
create procedure mostrarDocumentos()
begin
	select * from tipoDocumento where idEliminado=1;
end
$$

delimiter $$
create procedure registrarDocumentos(
	in nom varchar(50),
    in idEli int
)
begin
	insert into tipoDocumento values (null, nom, idEli);
end
$$

delimiter $$
create procedure editarDocumento(
	in nom varchar(50),
    in idDocumento int
)
begin
	update tipoDocumento
    set descTipoDocumento = nom
    where codigoTipoDocumento = idDocumento;
end
$$

-- PROCEDIMIENTOS AREAS--
delimiter $$
create procedure mostrarArea()
begin
	select * from area where idEliminado=1;
end
$$


delimiter $$
create procedure registrarArea(
	in descArea varchar(50),
    in idEli int
)
begin
	insert into area values (null,descArea,idEli);
end
$$

delimiter $$
create procedure editarArea(
	in nom varchar(50),
    in idArea int
)
begin
	update area
    set descArea = nom
    where codigoArea = idArea;
end
$$


-- PROCEDIMIENTOS MENSAJEROS --
delimiter $$
create procedure mostrarMensajeros()
begin
	select * from mensajero where idEliminado=1;
end
$$

delimiter $$
create procedure registrarMensajero(
	in nombre varchar(50),
    in idEli int
)
begin
	insert into mensajero values (null,nombre, idEli);
end
$$

delimiter $$
create procedure editarMensajero(
	in nom varchar(50),
    in idMensajero int
)
begin
	update mensajero
    set nombre = nom
    where codigoMensajero = idMensajero;
end
$$

-- PROCEDIMIENTOS ENVIOS--	
delimiter $$
create procedure encabezadoEnvio(
	in usuario int
)
begin
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
end
$$
delimiter $$
create procedure registrarDetalleEnvio(
	in envio int,
    in tramite int,
    in cliente int,
    in documento int,
    in area int,
    in mon varchar(25),
    in obs text,
    in num varchar(25)
)
begin
	declare idAnterior int;
    set idAnterior = (select max(codigoDetalleEnvio) from detalleEnvio) + 1;
    insert into detalleEnvio values (null, concat('DD', idAnterior), envio, tramite, cliente, documento, area, 1, num, mon, obs, curdate(), '0000-00-00', '00:00:00', '0000-00-00', 1);

end
$$

delimiter $$
create procedure enviosPendientes()
begin
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
    
end
$$

delimiter $$
create procedure detallesEnvio(
	in idEnvio int
)
begin
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
end
$$

delimiter $$
create procedure detallesEnvioLabel
(
	in idEnvio int
)
begin
	select e.codigoEnvio, d.codigoDetalleEnvio,s.descStatus
	from detalleEnvio d
	inner join envio e on e.codigoEnvio = d.codigoEnvio
    inner join status s on s.codigoStatus = d.codigoStatus
    
    where e.codigoEnvio = idEnvio
    
    order by d.codigoDetalleEnvio desc;
end
$$


delimiter $$
create procedure getEncabezadoEnvio(
	in idEnvio int
)
begin
	select e.codigoEnvio, e.correlativoEnvio, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, u.nomUsuario, u.codigoUsuario, u.nombre, u.apellido, e.estado
    from envio e
    inner join usuario u on u.codigoUsuario = e.codigoUsuario
    where e.codigoEnvio = idEnvio;
end
$$

delimiter $$
create procedure mostrarPaquetes()
begin
	select Distinct(e.codigoEnvio), e.correlativoEnvio, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, u.nomUsuario, u.codigoUsuario, u.nombre, u.apellido from envio e
	inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join detalleEnvio d on e.codigoEnvio = d.codigoEnvio
	where e.estado = 1
    order by e.codigoEnvio desc;
end
$$


delimiter $$
create procedure mostrarPaquetesManana()
begin
	select Distinct(e.codigoEnvio), e.correlativoEnvio, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, u.nomUsuario, u.codigoUsuario, u.nombre, u.apellido from envio e
	inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join detalleEnvio d on e.codigoEnvio = d.codigoEnvio
	where e.estado = 2
    order by e.codigoEnvio desc;
end
$$

delimiter $$ 
create procedure historialEnvios()
begin
	select Distinct(e.codigoEnvio), e.correlativoEnvio, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, u.nomUsuario, u.nombre, u.apellido from envio e
	inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join detalleEnvio d on e.codigoEnvio = d.codigoEnvio;
end
$$

delimiter $$
create procedure detallesEnvioH(
	in idEnvio int
)
begin
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
end
$$

delimiter $$
create procedure actualizarDetalle(
	in idDetalle int,
    in idStatus int,
    in obs text,
    in idMensajero int
)
begin
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
	
end
$$

delimiter $$
create procedure misEnvios(
	in idUsuario int
)
begin
	select Distinct(e.codigoEnvio), e.correlativoEnvio, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora
    from envio e		
	inner join usuario u on u.codigoUsuario = e.codigoUsuario
	inner join detalleEnvio d on e.codigoEnvio = d.codigoEnvio
	where u.codigoUsuario = idUsuario
    order by e.codigoEnvio desc;
end 
$$

delimiter $$
create procedure misDocumentosPendientes(
	in idUsuario int 
)
begin
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
end
$$

delimiter $$
create procedure contarDocumentosPendientes(
	in idUsuario int 
)
begin
	select count(d.codigoDetalleEnvio) as numero
    from envio e, detalleEnvio d
    where (s.codigoStatus = 4 or s.codigoStatus = 2) and e.codigoUsuario = idUsuario;
end
$$


delimiter $$
create procedure paquetesDiaSiguiente()
begin

	declare numeroPaquetes int;
    set numeroPaquetes = (select count(codigoEnvio) from envio where estado = 2 and fecha < curdate());
    
    if numeroPaquetes >= 1 then 
		select codigoEnvio from envio where estado = 2 and fecha < curdate();
	else 
		select 2 as numero;
	end if;
        
end
$$

delimiter $$
create procedure numeroDocumentosPendientes(
	in idUsuario int
)
begin

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

end
$$

delimiter $$
create procedure actualizarFecha(
    in idEnvio int
)
begin

    update envio set estado = 1, fecha = curdate() where codigoEnvio = idEnvio;
    
    update detalleEnvio set fechaRegistro = curdate() where codigoEnvio = idEnvio;

end
$$

-- PROCEDIMIENTOS REPORTES--


delimiter $$
create procedure reporteDiario()
begin
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
end
$$

delimiter $$
create procedure reporteMensajeros()
begin
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
end
$$
select * from detalleEnvio

delimiter $$
create procedure reporteEstadoDocumento(
	in parametro int
)
begin
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
end
$$


delimiter $$
create procedure tiposTramiteUsuario(
in idUsuario int
)
begin
select count(tt.codigoTipoTramite) as Tramite, tt.descTipoTramite  from detalleEnvio d
inner join tipoTramite tt on tt.codigoTipoTramite = d.codigoTipoTramite
inner join envio e on e.codigoEnvio = d.codigoEnvio
where e.codigoUsuario=idUsuario and e.fecha between (SELECT date_add(CURDATE(), INTERVAL -31 DAY)) and CURDATE()
group by tt.descTipoTramite;
end
$$

delimiter $$
create procedure clientes_Usuario(
in idUsuario int
)
begin
select count(c.codigoCliente) as Cliente, c.nombreCliente  from detalleEnvio d
inner join clientes c on c.codigoCliente = d.codigoCliente
inner join envio e on e.codigoEnvio = d.codigoEnvio
where e.codigoUsuario=idUsuario and e.fecha between (SELECT date_add(CURDATE(), INTERVAL -31 DAY)) and CURDATE()
group by c.nombreCliente;
end
$$



delimiter $$
create procedure clientesConMasEnvios()
begin
select count(c.codigoCliente) as Cliente, c.nombreCliente  from detalleEnvio d
inner join clientes c on c.codigoCliente = d.codigoCliente
inner join envio e on e.codigoEnvio = d.codigoEnvio
 where e.fecha between (SELECT date_add(CURDATE(), INTERVAL -7 DAY)) and CURDATE() group by c.nombreCliente;
end
$$


delimiter $$
create procedure usuariosEnvios()
begin
select count(c.codigoUsuario) as Usuario, c.nomUsuario  from envio e
inner join usuario c on c.codigoUsuario = e.codigoUsuario
 where e.fecha between (SELECT date_add(CURDATE(), INTERVAL -7 DAY)) and CURDATE() group by c.nomUsuario;
end
$$


delimiter $$
create procedure reporteArea(
	in idArea int
)
begin
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
end $$


delimiter $$
create procedure reporteFechas(
	in fecha date,
    in fecha2 date
)
begin
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
end $$


delimiter $$
create procedure reporteAreaDiario(
	in idArea int
)
begin
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
end $$



delimiter $$
create procedure reporteAreaPorFechas(
	in idArea int,
    in fecha1 date,
    in fecha2 date
)
begin
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
end $$


delimiter $$
create procedure reporteUsuarioDiario(
	in idUsuario int
)
begin
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
end $$

delimiter $$
create procedure reporteUsuario(
	in idUsuario int
)
begin
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
end
$$

delimiter $$
create procedure reporteUsuarioPorFechas(
	in idUsuario int,
    in fecha1 date,
    in fecha2 date
)
begin
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
end $$

-- ===========================================================================
-- DATOS
-- ===========================================================================

# Rol
insert into rol values (null, 'Administrador');
insert into rol values (null, 'Solicitante');

# Auth (Autorización del Usuario)
insert into authUsuario values (null, 'Autorizado');
insert into authUsuario values (null, 'Esperando Autorizacion');
insert into authUsuario values (null, 'Restringido');
	
# Tipo de Tramite
insert into tipoTramite values(null, 'Entrega', 1);
insert into tipoTramite values(null, 'Cobro', 1);
insert into tipoTramite values(null, 'Transferencia', 1);
insert into tipoTramite values(null, 'Depósito', 1);
insert into tipoTramite values(null, 'Retiro de Cheques', 1);
insert into tipoTramite values(null, 'Retiro de Documentos', 1);
insert into tipoTramite values(null, 'Pago', 1);
#Area
-- insert into area values (null, 'Administraci&oacute;n');
insert into area values (null, 'ABAS',1);
insert into area values (null, 'Tax y Legal',1);
insert into area values (null, 'RRHH',1);
insert into area values (null, 'Finanzas',1);
insert into area values (null, 'Tecnología',1);

# Usuario
insert into usuario values (null, 'Karla Guadalupe', 'Arevalo Vega', 'kgarevalo', 'kgarevalo@deloitte.com', sha1('Deloitte123!'), 1, 1, 1,1);
/*insert into usuario values (null, 'Jorge Luis', 'Sidgo Pimentel', 'jlsidgo', 'jorge.sidgo@gmail.com', sha1('Deloitte123!'), 1, 1, 1,1);
insert into usuario values (null, 'Fabio Alonso', 'Mejia', 'famejia', 'masterjsidgop@gmail.com', sha1('Deloitte123!'), 1, 1, 1,1);
insert into usuario values (null, 'Carlos Eduardo', 'Campos', 'cecampos', 'jsidgopimentel21@outlook.com', sha1('Deloitte123!'), 1, 1, 1,1);
insert into usuario values (null, 'John', 'Doe', 'johndoe', 'johndoe@deloitte.com', sha1('123'), 1, 2, 4,1);*/

#Cliente
insert into clientes values
(null, '465000', 'Carlos Gustavo López Ayala', 'Residencial y Calle Primavera #11,', 'SANTA TECLA', 1),
(null, '465001', 'Sun Chemical de Centroamérica S.A. Sun Chemical de Centroamérica S.A.', 'Blvd. Del Ejercito Nacional Km 5 1/', 'SOYAPANGO', 1),
(null, '465002', 'Abruzzo S.A. de C.V.', 'Km 16 1/2 Carretera al Puerto de La', 'LA LIBERTAD', 1),
(null, '465003', 'Multiriesgos, S.A. de C.V.', 'Calle Palmeral No. 144 Col. Toluca', 'SAN SALVADOR', 1),
(null, '465004', 'Escuela Superior de Economía y Nego', 'Km 12  1/2 Carretera al Puerto de L', 'SANTA TECLA', 1),
(null, '465005', 'Productos Carnicos S.A. de C.V.', 'Calle El Progreso, Col. Roma No. 33', 'SAN SALVADOR', 1),
(null, '465006', 'Galvanizadora Industrial Salvadoreñ', 'Boulevard de Los Proceres, Edificio', 'SAN SALVADOR', 1);


#Tipo de Documento
insert into tipoDocumento values(null, 'FE',1);
insert into tipoDocumento values(null, 'F',1);
insert into tipoDocumento values(null, 'CCF',1);
insert into tipoDocumento values(null, 'Q',1);
insert into tipoDocumento values(null, 'Propuestas',1);
insert into tipoDocumento values(null, 'Informes',1);
insert into tipoDocumento values(null, 'Otro',1);

#Status 
insert into status values (null, 'Pendiente de Revision');
insert into status values (null, 'Incompleto');
insert into status values (null, 'Recibido');
insert into status values (null, 'Pendiente');
insert into status values (null, 'Completo');

insert into mensajero values(null, 'No Asignado',1);
insert into mensajero values(null, 'Enrique Segoviano',1);
insert into mensajero values(null, 'Ramon Valdéz',1);

insert into envio values(null, concat('ED', 1), 2, curdate(), DATE_FORMAT(NOW(), "%H:%i:%s" ), 1);
insert into detalleEnvio values (null, 'DD1', 1, 1, 1, 1, 1, 3, '123', '$0.00', '123', curdate(),curdate(),  DATE_FORMAT(NOW(), "%H:%i:%s" ), curdate(), 1);
/*


insert into detalleEnvio values (null, 'DD2', 1, 1, 2, 1, 1, 3, '123', '$1', 'nada', curdate(),'0000-00-00', '00:00:00', '0000-00-00', 1);
insert into detalleEnvio values (null, 'DD3', 1, 1, 3, 1, 1, 3, '123', '$1', 'nada', curdate(),'0000-00-00', '00:00:00', '0000-00-00', 1);
-- insert into detalleEnvio values (null, 'DD4', 1, 1, 1, 1, 1, 3, '123', '$1', 'nada', curdate(),'0000-00-00', '00:00:00', '0000-00-00', 1);
	
						
insert into envio values(null, concat('ED', 2), 4, '2018-12-16', '14:00:01', 2);   

insert into detalleEnvio values (null, 'DD5', 2, 1, 1, 1, 1, 2, '123', '$1', 'nada', '2018-12-16','0000-00-00', '13:00:00', '0000-00-00', 1);
insert into detalleEnvio values (null, 'DD6', 2, 1, 2, 1, 1, 3, '123', '$1', 'nada', '2018-12-16','0000-00-00', '13:00:00', '0000-00-00', 1);
insert into detalleEnvio values (null, 'DD7', 2, 1, 3, 1, 1, 1, '123', '$1', 'nada', '2018-12-16','0000-00-00', '13:00:00', '0000-00-00', 1);
insert into detalleEnvio values (null, 'DD8', 2, 1, 1, 1, 1, 4, '123', '$1', 'nada', '2018-12-16','0000-00-00', '13:00:00', '0000-00-00', 1);

insert into envio values(null, concat('ED', 3), 4, '2018-12-16', '16:00:01', 2);   

insert into detalleEnvio values (null, 'DD9', 3, 1, 1, 1, 1, 3, '123', '$1', 'nada', '2018-12-16','0000-00-00', '14:00:00', '0000-00-00', 1);
insert into detalleEnvio values (null, 'DD10', 3, 1, 2, 1, 1, 3, '123', '$1', 'nada','2018-12-16', '0000-00-00', '14:00:00', '0000-00-00', 1);
insert into detalleEnvio values (null, 'DD11', 3, 1, 3, 1, 1, 3, '123', '$1', 'nada','2018-12-16', '0000-00-00', '14:00:00', '0000-00-00', 1);
insert into detalleEnvio values (null, 'DD12', 3, 1, 1, 1, 1, 3, '123', '$1', 'nada','2018-12-16', '0000-00-00', '14:00:00', '0000-00-00', 1);

*/
-- select * from detalleEnvio;


-- select * from usuario