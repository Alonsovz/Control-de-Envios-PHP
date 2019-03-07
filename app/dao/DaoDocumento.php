<?php 

class DaoDocumento extends DaoBase {

    public function __construct() {
        parent::__construct();
        $this->objeto = new Documento();
    }

    public function mostrarDocumentosCmb() {
        $_query = "select * from tipoDocumento where idEliminado=1";

        $resultado = $this->con->ejecutar($_query);

        $json = '';

        while($fila = $resultado->fetch_assoc()) {
            $json .= json_encode($fila).',';
        }

        $json = substr($json,0, strlen($json) - 1);

        return '['.$json.']';
    }

    public function mostrarDocumentos() {
        $_query = "call mostrarDocumentos()";

        $resultado = $this->con->ejecutar($_query);

        $_json = '';

        while($fila = $resultado->fetch_assoc()) {

            $object = json_encode($fila);

            $btnEditar = '<button id=\"'.$fila["codigoTipoDocumento"].'\" class=\"ui btnEditar icon blue small button\"><i class=\"edit icon\"></i></button>';
            $btnEliminar = '<button id=\"'.$fila["codigoTipoDocumento"].'\" class=\"ui btnEliminar icon negative small button\"><i class=\"trash icon\"></i></button>';

            $acciones = ', "Acciones": "'.$btnEditar.' '.$btnEliminar.'"';

            $object = substr_replace($object, $acciones, strlen($object) -1, 0);

            $_json .= $object.',';
        }

        $_json = substr($_json,0, strlen($_json) - 1);

        return '{"data": ['.$_json .']}';
    }

    public function registrar() {
        $_query = "call registrarDocumentos('".$this->objeto->getDescTipoDocumento()."',1)";

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }


    public function editar() {
        $_query = "call editarDocumento('".$this->objeto->getDescTipoDocumento()."',".$this->objeto->getCodigoTipoDocumento().")";

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function cargarDatosDocumento() {
        $_query = "select * from tipoDocumento where codigoTipoDocumento = ".$this->objeto->getCodigoTipoDocumento();

        $resultado = $this->con->ejecutar($_query);

        $json = json_encode($resultado->fetch_assoc());

        return $json;
    }

    public function eliminar() {
        $_query = "update tipoDocumento set idEliminado=2 where codigoTipoDocumento= ".$this->objeto->getCodigoTipoDocumento();

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }
}