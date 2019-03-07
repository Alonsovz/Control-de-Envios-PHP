<?php
/**
 * Created by PhpStorm.
 * User: jsidg
 * Date: 14/1/2019
 * Time: 14:22
 */

class DaoTipoTramite extends DaoBase
{

    public function __construct()
    {
        parent::__construct();
        $this->objeto = new TipoTramite();
    }

    public function mostrarTipoTramite() {
        $_query = "select * from tipoTramite where estado = 1";

        $resultado = $this->con->ejecutar($_query);

        $json = '';

        while($fila = $resultado->fetch_assoc()) {

            $object = json_encode($fila);

            $btnEliminar = '<button id=\"'.$fila["codigoTipoTramite"].'\" class=\"ui btnEliminar icon negative small button\"><i class=\"trash icon\"></i></button>';

            $acciones = ', "Acciones": "'.$btnEliminar.'"';

            $object = substr_replace($object, $acciones, strlen($object) -1, 0);

            $json .= $object.',';
        }

        $json = substr($json,0, strlen($json) - 1);

        return '['.$json.']';
    }

    public function eliminar() {
        $query = "update tipoTramite set estado = 0 where codigoTipoTramite = {$this->objeto->getCodigoTipoTramite()}";

        $resultado = $this->con->ejecutar($query);

        return $resultado;
    }

    public function registrar() {
        $query = "insert into tipoTramite values(null,'{$this->objeto->getDescTipoTramite()}' , 1)";

        $resultado = $this->con->ejecutar($query);

        return $resultado;
    }
}