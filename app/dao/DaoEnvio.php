<?php

class DaoEnvio extends DaoBase {

    public function __construct() {
        parent::__construct();
        $this->objeto = new Envio();
    }

    public function encabezadoEnvio() {
        $_query = "call encabezadoEnvio
        ({$this->objeto->getCodigoUsuario()})";

        $resultado = $this->con->ejecutar($_query);

        $resultado = $resultado->fetch_assoc();

        $codigoEnvio = $resultado["codigoEnvio"];

        return $codigoEnvio;
    }

    public function numeroDocumentosPendientes()
    {
        if(session_status() != 2) {
            session_start();
        }

        $idUsuario = $_SESSION["codigoUsuario"];

        $_query = "call numeroDocumentosPendientes({$idUsuario})";

        $resultado = $this->con->ejecutar($_query);

        $resultado = $resultado->fetch_assoc();

        return $resultado["numero"];
    }

    // Eliminado de envíos
    public function eliminarPaquete() {
        $_query = "call eliminarPaquete({$this->objeto->getCodigoEnvio()})";

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function eliminarDetalle() {
        $_query = "call eliminarDetalle({$this->objeto->getCodigoDetalleEnvio()})";

        $resultado = $this->con->ejecutar($_query);
		
        if($resultado) {
            return 11;
        } else {
            return 0;
        }
    }

    public function actualizarDetalle() {
        $_query = "call actualizarDetalle({$this->objeto->getCodigoDetalleEnvio()}, {$this->objeto->getCodigoStatus()}, '{$this->objeto->getObservacion()}', {$this->objeto->getCodigoMensajero()})";

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function registrarDetalleEnvio() {

        $query = "call registrarDetalleEnvio(".$this->objeto->getCodigoEnvio().", ".$this->objeto->getCodigoTipoTramite().", ".$this->objeto->getCodigoCliente().", ".$this->objeto->getCodigoTipoDocumento().", ".$this->objeto->getCodigoArea().", '".$this->objeto->getMonto()."', '".$this->objeto->getObservacion()."', '".$this->objeto->getNumDoc()."');";

        $resultado = $this->con->ejecutar($query);

        return $resultado;
    }

    public function getEncabezadoEnvio() {
        $_query = "call getEncabezadoEnvio({$this->objeto->getCodigoEnvio()})";

        $resultado = $this->con->ejecutar($_query);

        return $resultado;
    }

    public function detallesEnvio() {
        $_query = "
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
    
    where e.codigoEnvio = {$this->objeto->getCodigoEnvio()} and d.codigoStatus < 5
    
    order by d.codigoDetalleEnvio desc;";

        $resultado = $this->con->ejecutar($_query);

        return $resultado;
    }

    public function detallesEnvioH() {
        $_query = "call detallesEnvioH({$this->objeto->getCodigoEnvio()})";

        $resultado = $this->con->ejecutar($_query);

        return $resultado;
    }

    public function misEnvios() {
        $_query = "call misEnvios({$this->objeto->getCodigoUsuario()})";

        $resultado = $this->con->ejecutar($_query);

        $_json = '';

        $contador_pendientes = 0;
        $contador_completo = 0;
        $contador_revisado = 0;
        $contador_pendientesRevision = 0;
        $contador_recibido = 0;


        while($fila = $resultado->fetch_assoc()) {

            $btnVer = '<button id=\"'.$fila["codigoEnvio"].'\" class=\"ui btnVer icon secondary small button\"><i class=\"list ul icon\"></i></button>';

            $sub_query = "select e.codigoEnvio, d.codigoDetalleEnvio,s.descStatus
            from detalleEnvio d
            inner join envio e on e.codigoEnvio = d.codigoEnvio
            inner join status s on s.codigoStatus = d.codigoStatus
            
            where e.codigoEnvio =  {$fila["codigoEnvio"]} order by d.codigoDetalleEnvio desc;";

            $sub_resultado = $this->con->ejecutar($sub_query);


            while($sub_fila = $sub_resultado->fetch_assoc()) {

                switch($sub_fila["descStatus"]) {
                    case 'Pendiente de Revision':
                        $contador_pendientesRevision++;
                        break;

                    case 'Incompleto':
                        $contador_revisado++;
                        break;

                    case 'Recibido':
                        $contador_recibido++;
                        break;

                    case 'Completo':
                        $contador_completo++;
                        break;

                    case 'Pendiente':
                    $contador_pendientes++;
                    break;
                }
            }

            $label_pendientes= '<a class=\"ui grey label\">'.$contador_pendientesRevision.'</a>';
            $label_completo= '<a class=\"ui green label\">'.$contador_completo.'</a>';
            $label_revisado= '<a class=\"ui orange label\">'.$contador_revisado.'</a>';
            $label_recibido= '<a class=\"ui blue label\">'.$contador_recibido.'</a>';
            $label_finanzas= '<a class=\"ui yellow label\">'.$contador_pendientes.'</a>';

            $labels = '<div class=\"ui small labels\">'.$label_pendientes.$label_recibido.$label_completo.$label_revisado.$label_finanzas.'</div>';

            $object = '{
                            "codigoEnvio": "'.$fila["codigoEnvio"].'",
                            "correlativoEnvio": "'.$fila["correlativoEnvio"].'",
                            "fecha": "'.$fila["fecha"].'",
                            "hora": "'.$fila["hora"].'",
                            "documentos": "'.$labels.'",
                            "Acciones": "'.$btnVer.'"
                        }';

            $_json .= $object.',';


            $contador_pendientes = 0;
            $contador_completo = 0;
            $contador_revisado = 0;
            $contador_pendientesRevision = 0;
            $contador_recibido=0;
        }

        $_json = substr($_json,0, strlen($_json) - 1);

        echo '{"data": ['.$_json .']}';
    }

    public function misDetallesPendientes() {
        $_query = "call misDocumentosPendientes({$this->objeto->getCodigoUsuario()})";

        $resultado = $this->con->ejecutar($_query);

        $_json = '';

        while($fila = $resultado->fetch_assoc()) {


            $object = json_encode($fila);


            $boton = '<button detalle-envio=\"'.$fila["codigoDetalleEnvio"].'\" envio=\"'.$fila["codigoEnvio"].'\" type=\"button\" class=\"ui mini circular green icon button btnCambios\"><i class=\"sync icon\"></i></button>';

            $acciones = ', "opcion": "'.$boton.'"';

            $object = substr_replace($object, $acciones, strlen($object) -1, 0);
            
            $_json .=  $object.',';
           
        }

        $_json = substr($_json,0, strlen($_json) - 1);


         echo '{"data": ['.$_json .']}';
    }

    public function contarCompletos() {

        $_query = "select count(codigoDetalleEnvio) as numero from detalleEnvio where codigoStatus = 5 and codigoEnvio = {$this->objeto->getCodigoEnvio()}";
        $resultado = $this->con->ejecutar($_query);

        $numero = $resultado->fetch_assoc();

        
        return $numero["numero"];

    }

    public function contarDocumentosPaquete() {
        $_query = "select count(codigoDetalleEnvio) as numero from detalleEnvio where codigoEnvio = {$this->objeto->getCodigoEnvio()}";

        $resultado = $this->con->ejecutar($_query);

        $numero = $resultado->fetch_assoc();

        
        return $numero["numero"];
    }

    public function estadoPaquete() {

        $completos = $this->contarCompletos();
        $total = $this->contarDocumentosPaquete();

        if($completos == $total) {
            $this->cambiarEnvio(0);
            return true;
        } else {
            return false;
        }
    }

    public function actPaquetes() {

        $_query = 'call paquetesDiaSiguiente';

        $resultado = $this->con->ejecutar($_query);
        $resultado1 = $this->con->ejecutar($_query);
    
        $campo = $resultado->fetch_field()->name;

        if($campo == 'numero') {
            return 2;
        } else {
            while($id = $resultado1->fetch_assoc()) {
                $_query = "call actualizarFecha({$id["codigoEnvio"]})";
                $resultado = $this->con->ejecutar($_query);
            }

            return 1;
        }

    }

    public function mostrarPaquetes()
    {
        $_query = "	select Distinct(e.codigoEnvio), e.correlativoEnvio, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, u.nomUsuario, u.codigoUsuario, u.nombre, u.apellido from envio e
        inner join usuario u on u.codigoUsuario = e.codigoUsuario
        inner join detalleEnvio d on e.codigoEnvio = d.codigoEnvio
        where e.estado = 1  and d.codigoStatus < 5
        order by e.codigoEnvio desc;";

        $resultado = $this->con->ejecutar($_query);

        $_json = '';

        $contador_pendientesRevision = 0;
        $contador_completo = 0;
        $contador_recibido = 0;
        $contador_revisado = 0;
        $contador_pendientes = 0;


        while($fila = $resultado->fetch_assoc()) {

            $btnVer = '<button codigo-usuario=\"'.$fila["codigoUsuario"].'\" codigo-envio=\"'.$fila["codigoEnvio"].'\" id=\"'.$fila["codigoEnvio"].'\" class=\"ui btnVer icon secondary small button\"><i class=\"list ul icon\"></i></button>';
            $btnCorreo = '<button codigo-usuario=\"'.$fila["codigoUsuario"].'\" codigo-envio=\"'.$fila["codigoEnvio"].'\" class=\"ui btnCorreo icon teal small button\"><i class=\"envelope icon\"></i></button>';
            //$btnEliminar = '<button codigo-usuario=\"'.$fila["codigoUsuario"].'\" codigo-envio=\"'.$fila["codigoEnvio"].'\" class=\"ui btnEliminar icon red small button\"><i class=\"trash icon\"></i></button>';
            $btnEliminar = '';

            $sub_query = "select e.codigoEnvio, d.codigoDetalleEnvio,s.descStatus
            from detalleEnvio d
            inner join envio e on e.codigoEnvio = d.codigoEnvio
            inner join status s on s.codigoStatus = d.codigoStatus
            where e.codigoEnvio = {$fila["codigoEnvio"]}
            order by d.codigoDetalleEnvio desc;";

            $sub_resultado = $this->con->ejecutar($sub_query);


            while($sub_fila = $sub_resultado->fetch_assoc()) {

                switch($sub_fila["descStatus"]) {
                    case 'Pendiente de Revision':
                        $contador_pendientesRevision++;
                        break;

                    case 'Incompleto':
                        $contador_revisado++;
                        break;
                    
                    case 'Recibido': 
                        $contador_recibido++;
                        break;

                    case 'Completo':
                        $contador_completo++;
                        break;

                    case 'Pendiente':
                    $contador_pendientes++;
                    break;
                }
            }

            $label_pendientes= '<a class=\"ui grey label\">'.$contador_pendientesRevision.'</a>';
            $label_completo= '<a class=\"ui green label\">'.$contador_completo.'</a>';
            $label_revisado= '<a class=\"ui orange label\">'.$contador_revisado.'</a>';
            $label_recibido= '<a class=\"ui blue label\">'.$contador_recibido.'</a>';
            $label_finanzas= '<a class=\"ui yellow label\">'.$contador_pendientes.'</a>';

            $labels = '<div class=\"ui small labels\">'.$label_completo.$label_recibido.$label_revisado.$label_finanzas.$label_pendientes.'</div>';

            $object = '{
                            "codigoEnvio": "'.$fila["codigoEnvio"].'",
                            "correlativoEnvio": "'.$fila["correlativoEnvio"].'",
                            "fecha": "'.$fila["fecha"].'",
                            "hora": "'.$fila["hora"].'",
                            "nomUsuario": "'.$fila["nomUsuario"].'",
                            "nombre": "'.$fila["nombre"].' '.$fila["apellido"].'",
                            "documentos": "'.$labels.'",
                            "Acciones": "'.$btnCorreo.' '.$btnVer.' '.$btnEliminar.'"
                        }';

            $_json .= $object.',';


            $contador_pendientes = 0;
            $contador_recibido = 0;
            $contador_completo = 0;
            $contador_revisado = 0;
            $contador_pendientesRevision = 0;
        }

        $_json = substr($_json,0, strlen($_json) - 1);

        echo '{"data": ['.$_json .']}';
    }

    public function contarPaquetesManana() {

        $_query = 'select count(codigoEnvio) as numero from envio where estado = 2';

        $resultado = $this->con->ejecutar($_query);

        $num = $resultado->fetch_assoc();
    
        $num = $num['numero'];

        return $num;
    }

    public function contarDocumentosPendientes() {
        $_query = "call contarDocumentosPendientes({$this->objeto->getCodigoUsuario()})";

        $resultado = $this->con->ejecutar($_query);

        $num = $resultado->fetch_assoc();
    
        $num = $num['numero'];

        return $num;
    }

    public function mostrarPaquetesManana()
    {
        $_query = "	select Distinct(e.codigoEnvio), e.correlativoEnvio, DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, u.nomUsuario, u.codigoUsuario, u.nombre, u.apellido from envio e
        inner join usuario u on u.codigoUsuario = e.codigoUsuario
        inner join detalleEnvio d on e.codigoEnvio = d.codigoEnvio
        where e.estado = 2  
        order by e.codigoEnvio desc;";

        $resultado = $this->con->ejecutar($_query);

        $_json = '';

        $contador_pendientesRevision = 0;
        $contador_completo = 0;
        $contador_recibido = 0;
        $contador_revisado = 0;
        $contador_pendientes = 0;


        while($fila = $resultado->fetch_assoc()) {

            $btnVer = '<button codigo-usuario=\"'.$fila["codigoUsuario"].'\" codigo-envio=\"'.$fila["codigoEnvio"].'\" id=\"'.$fila["codigoEnvio"].'\" class=\"ui btnVer icon secondary small button\"><i class=\"list ul icon\"></i></button>';
            $btnCorreo = '<button codigo-usuario=\"'.$fila["codigoUsuario"].'\" codigo-envio=\"'.$fila["codigoEnvio"].'\" class=\"ui btnCorreo icon teal small button\"><i class=\"envelope icon\"></i></button>';
            // $btnEliminar = '<button codigo-usuario=\"'.$fila["codigoUsuario"].'\" codigo-envio=\"'.$fila["codigoEnvio"].'\" class=\"ui btnEliminar icon red small button\"><i class=\"trash icon\"></i></button>';

            $sub_query = "select e.codigoEnvio, d.codigoDetalleEnvio,s.descStatus
            from detalleEnvio d
            inner join envio e on e.codigoEnvio = d.codigoEnvio
            inner join status s on s.codigoStatus = d.codigoStatus
            
            where e.codigoEnvio =  {$fila["codigoEnvio"]} order by d.codigoDetalleEnvio desc;";

            $sub_resultado = $this->con->ejecutar($sub_query);

           
            while($sub_fila = $sub_resultado->fetch_assoc()) {

                switch($sub_fila["descStatus"]) {
                    case 'Pendiente de Revision':
                        $contador_pendientesRevision++;
                        break;

                    case 'Incompleto':
                        $contador_revisado++;
                        break;
                    
                    case 'Recibido': 
                        $contador_recibido++;
                        break;

                    case 'Completo':
                        $contador_completo++;
                        break;

                    case 'Pendiente':
                    $contador_pendientes++;
                    break;
                }
            }

            $label_pendientes= '<a class=\"ui grey label\">'.$contador_pendientesRevision.'</a>';
            $label_completo= '<a class=\"ui green label\">'.$contador_completo.'</a>';
            $label_revisado= '<a class=\"ui orange label\">'.$contador_revisado.'</a>';
            $label_recibido= '<a class=\"ui blue label\">'.$contador_recibido.'</a>';
            $label_finanzas= '<a class=\"ui yellow label\">'.$contador_pendientes.'</a>';

            $labels = '<div class=\"ui small labels\">'.$label_completo.$label_recibido.$label_revisado.$label_finanzas.$label_pendientes.'</div>';

            $object = '{
                            "codigoEnvio": "'.$fila["codigoEnvio"].'",
                            "correlativoEnvio": "'.$fila["correlativoEnvio"].'",
                            "fecha": "'.$fila["fecha"].'",
                            "hora": "'.$fila["hora"].'",
                            "nomUsuario": "'.$fila["nomUsuario"].'",
                            "nombre": "'.$fila["nombre"].' '.$fila["apellido"].'",
                            "documentos": "'.$labels.'",
                            "Acciones": "'.$btnCorreo.' '.$btnVer.'"
                        }';

            $_json .= $object.',';


            $contador_pendientes = 0;
            $contador_recibido = 0;
            $contador_completo = 0;
            $contador_revisado = 0;
            $contador_pendientesRevision = 0;
        }

        $_json = substr($_json,0, strlen($_json) - 1);

        echo '{"data": ['.$_json .']}';
    }

    public function cambiarEnvio($estado) {
        $_query = "update envio set estado = {$estado} where codigoEnvio = {$this->objeto->getCodigoEnvio()}";

        $resultado = $this->con->ejecutar($_query);

        return $resultado;
    }

    public function historialEnvios()
    {
        $_query = "select Distinct(e.codigoEnvio), e.correlativoEnvio as correlativo,
        DATE_FORMAT(e.fecha,'%d/%m/%Y') as fecha, e.hora, u.nomUsuario, u.nombre, u.apellido from envio e
         inner join usuario u on u.codigoUsuario = e.codigoUsuario
         inner join detalleEnvio d on e.codigoEnvio = d.codigoEnvio
         inner  join status s on s.codigoStatus = d.codigoStatus
         where d.codigoStatus = 5";

        $resultado = $this->con->ejecutar($_query);

        $_json = '';

        $contador_pendientesRevision = 0;
        $contador_completo = 0;
        $contador_revisado = 0;
        $contador_pendientes = 0;
        $contador_recibido = 0;


        while($fila = $resultado->fetch_assoc()) {

            $btnVer = '<button id=\"'.$fila["codigoEnvio"].'\" class=\"ui btnVer icon secondary small button\"><i class=\"list ul icon\"></i></button>';

            $sub_query = "select e.codigoEnvio, d.codigoDetalleEnvio,s.descStatus
            from detalleEnvio d
            inner join envio e on e.codigoEnvio = d.codigoEnvio
            inner join status s on s.codigoStatus = d.codigoStatus
            where e.codigoEnvio = {$fila["codigoEnvio"]}
             and descStatus != 'Pendiente' and descStatus != 'Recibido' and descStatus != 'Pendiente de Revision' 
            and descStatus != 'Incompleto'  order by d.codigoDetalleEnvio desc;";

            $sub_resultado = $this->con->ejecutar($sub_query);

            
            while($sub_fila = $sub_resultado->fetch_assoc()) {

                switch($sub_fila["descStatus"]) {
                    case 'Pendiente de Revision':
                        $contador_pendientesRevision++;
                        break;

                    case 'Incompleto':
                        $contador_revisado++;
                        break;
                    
                    case 'Recibido': 
                        $contador_recibido++;
                        break;

                    case 'Completo':
                        $contador_completo++;
                        break;

                    case 'Pendiente':
                    $contador_pendientes++;
                    break;
                }
            }

            $label_pendientes= '<a class=\"ui grey label\">'.$contador_pendientesRevision.'</a>';
            $label_completo= '<a class=\"ui green label\">'.$contador_completo.'</a>';
            $label_revisado= '<a class=\"ui orange label\">'.$contador_revisado.'</a>';
            $label_recibido= '<a class=\"ui blue label\">'.$contador_recibido.'</a>';
            $label_finanzas= '<a class=\"ui yellow label\">'.$contador_pendientes.'</a>';
            $labels = '<div class=\"ui small labels\">'.$label_pendientes.$label_recibido.$label_completo.$label_revisado.$label_finanzas.'</div>';

            $object = '{
                            "codigoEnvio": "'.$fila["codigoEnvio"].'",
                            "correlativo": "'.$fila["correlativo"].'",
                            "fecha": "'.$fila["fecha"].'",
                            "hora": "'.$fila["hora"].'",
                            "nomUsuario": "'.$fila["nomUsuario"].'",
                            "nombre": "'.$fila["nombre"].' '.$fila["apellido"].'",
                            "documentos": "'.$labels.'",
                            "Acciones": "'.$btnVer.'"
                        }';

            $_json .= $object.',';


            $contador_pendientes = 0;
            $contador_completo = 0;
            $contador_revisado = 0;
            $contador_pendientesRevision= 0;
            $contador_recibido = 0;
        }

        $_json = substr($_json,0, strlen($_json) - 1);

        echo '{"data": ['.$_json .']}';
    }


    public function reporteFechas() {
        $query = "call reporteFechas('{$this->objeto->getFecha()}','{$this->objeto->getFecha2()}')";

        $resultado = $this->con->ejecutar($query);

        return $resultado;
    }
}
