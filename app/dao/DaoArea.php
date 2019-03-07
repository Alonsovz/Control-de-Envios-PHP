<?php 

class DaoArea extends DaoBase {
    
    public function __construct() {
        parent::__construct();
        $this->objeto = new Area();
    }

    public function mostrarAreas() {
        $_query = "select * from area where idEliminado=1";

        $resultado = $this->con->ejecutar($_query);

        $json = '';

        while($fila = $resultado->fetch_assoc()) {
            $json .= json_encode($fila).',';
        }

        $json = substr($json,0, strlen($json) - 1);

        return '['.$json.']';
    }

    public function mostrarAreasSelect() {
        $_query = "select * from area where idEliminado=1";

        $resultado = $this->con->ejecutar($_query);

        $json = '';

        while($fila = $resultado->fetch_assoc()) {
            $json .= '{"val": '.$fila['codigoArea'].', "text": "'.$fila['descArea'].'"},';
        }

        $json = substr($json,0, strlen($json) - 1);

        return '['.$json.']';
    }

    public function mostrarAreasDT() {
        $_query = "call mostrarArea()";

        $resultado = $this->con->ejecutar($_query);

        $_json = '';

        while($fila = $resultado->fetch_assoc()) {

            $object = json_encode($fila);

            $btnEditar = '<button id=\"'.$fila["codigoArea"].'\" class=\"ui btnEditar icon blue small button\"><i class=\"edit icon\"></i></button>';
            $btnEliminar = '<button id=\"'.$fila["codigoArea"].'\" class=\"ui btnEliminar icon negative small button\"><i class=\"trash icon\"></i></button>';

            $acciones = ', "Acciones": "'.$btnEditar.' '.$btnEliminar.'"';

            $object = substr_replace($object, $acciones, strlen($object) -1, 0);

            $_json .= $object.',';
        }

        $_json = substr($_json,0, strlen($_json) - 1);

        return '{"data": ['.$_json .']}';
    }

    public function registrar() {
        $_query = "call registrarArea('".$this->objeto->getDescArea()."',1)";

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function editar() {
        $_query = "call editarArea('".$this->objeto->getDescArea()."',".$this->objeto->getCodigoArea().")";

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function cargarDatosArea() {
        $_query = "select * from area where codigoArea = ".$this->objeto->getCodigoArea();

        $resultado = $this->con->ejecutar($_query);

        $json = json_encode($resultado->fetch_assoc());

        return $json;
    }

    public function eliminar() {
        $_query = "update  area set idEliminado=2 where codigoArea = ".$this->objeto->getCodigoArea();

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function reporteArea() {
        $query = "call reporteArea({$this->objeto->getCodigoArea()})";

        $resultado = $this->con->ejecutar($query);

        return $resultado;
    }


    public function reporteAreaDiario() {
        $query = "call reporteAreaDiario({$this->objeto->getCodigoArea()})";

        $resultado = $this->con->ejecutar($query);

        return $resultado;
    }

    public function reporteAreaPorFechas() {
        $query = "call reporteAreaPorFechas({$this->objeto->getCodigoArea()},'{$this->objeto->getFecha()}','{$this->objeto->getFecha2()}')";

        $resultado = $this->con->ejecutar($query);

        return $resultado;
    }

}