use deloitte_mensajeria;

delimiter $$
create procedure eliminarDetalle(
	in detalle int
)
begin
	declare numDetalles int;
	declare envio int;
    
    set envio = (select (codigoEnvio) from detalleenvio where codigoDetalleEnvio = detalle);
    
	delete from detalleenvio where codigoDetalleEnvio = detalle;
    
    set numDetalles = (select count(1) from detalleenvio where codigoEnvio = envio and codigoStatus <> 6);
    
    if numDetalles = 0 then 
		update envio 
        set estado = 0
        where codigoEnvio = envio;
	end if;
end
$$
