<?php 

class DaoMensajero extends DaoBase {

    public function __construct() {
        parent::__construct();
        $this->objeto = new Mensajero();
    }

    public function mostrarMensajeros() {
        $_query = "call mostrarMensajeros()";

        $resultado = $this->con->ejecutar($_query);

        $_json = '';

        while($fila = $resultado->fetch_assoc()) {

            if($fila["nombre"] == 'No Asignado') {

            } else {
                $object = json_encode($fila);

                $btnEditar = '<button id=\"'.$fila["codigoMensajero"].'\" class=\"ui btnEditar icon blue small button\"><i class=\"edit icon\"></i></button>';
                $btnEliminar = '<button id=\"'.$fila["codigoMensajero"].'\" class=\"ui btnEliminar icon negative small button\"><i class=\"trash icon\"></i></button>';

                $acciones = ', "Acciones": "'.$btnEditar.' '.$btnEliminar.'"';

                $object = substr_replace($object, $acciones, strlen($object) -1, 0);

                $_json .= $object.',';
            }
        }

        $_json = substr($_json,0, strlen($_json) - 1);

        return '{"data": ['.$_json .']}';
    }

    public function registrar() {
        $_query = "call registrarMensajero('".$this->objeto->getNombre()."',1)";

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }


    public function cargarDatosMensajeros() {

        $_query = "select * from mensajero where codigoMensajero = ".$this->objeto->getCodigoMensajero();

        $resultado = $this->con->ejecutar($_query);

        $json = json_encode($resultado->fetch_assoc());

        return $json;
    }


    public function editar() {
        $_query = "call editarMensajero('".$this->objeto->getNombre()."', ".$this->objeto->getCodigoMensajero().")";

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }


    public function eliminar() {
        $_query = "update mensajero set idEliminado=2 where codigoMensajero = ".$this->objeto->getCodigoMensajero();

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function mostrarMensajerosCmb() {
        $_query = "select * from mensajero where idEliminado=1";

        $resultado = $this->con->ejecutar($_query);

        $json = '';

        while($fila = $resultado->fetch_assoc()) {
            $json .= json_encode($fila).',';
        }

        $json = substr($json,0, strlen($json) - 1);

        return '['.$json.']';
    }


}