<?php

class MensajeroController extends ControladorBase {

    public static function gestion() {
        self::loadMain();
        
        require_once './app/view/Mensajeros/gestion.php';
    }




    public function mostrarMensajeros() {
        $dao = new DaoMensajero();

        echo $dao->mostrarMensajeros();
    }

    public function registrar() {
        $datos = $_REQUEST["datos"];

        $datos = json_decode($datos);

        $dao = new DaoMensajero();

        $dao->objeto->setNombre($datos->nombre);
        echo $dao->registrar();

    }


    public function cargarDatosMensajeros() {
        $id = $_REQUEST["id"];

        $dao = new DaoMensajero();

        $dao->objeto->setCodigoMensajero($id);

        echo $dao->cargarDatosMensajeros();
    }


    public function editar() {
        $datos = $_REQUEST["datos"];

        $datos = json_decode($datos);

        $dao = new DaoMensajero();

        $dao->objeto->setNombre($datos->nombre);
        $dao->objeto->setCodigoMensajero($datos->idDetalle);

        echo $dao->editar();
    }


    public function eliminar() {
        $datos = $_REQUEST["id"];

        $dao = new DaoMensajero();

        $dao->objeto->setCodigoMensajero($datos);

        echo $dao->eliminar();
    }

}