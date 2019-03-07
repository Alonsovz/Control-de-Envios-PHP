<?php 

class AreaController extends ControladorBase {

    public function gestion() {
        self::loadMain();
        require_once './app/view/Area/gestion.php';
    }

    public function mostrarArea() {
        $dao = new DaoArea();
        echo $dao->mostrarAreasDT();
    }

    public function registrar() {
        $datos = $_REQUEST["datos"];

        $datos = json_decode($datos);

        $dao = new DaoArea();

        $dao->objeto->setDescArea($datos->descArea);


        echo $dao->registrar();
     
    }

    public function cargarDatosArea() {
        $id = $_REQUEST["id"];

        $dao = new DaoArea();

        $dao->objeto->setCodigoArea($id);

        echo $dao->cargarDatosArea();
    }

    public function editar() {
        $datos = $_REQUEST["datos"];

        $datos = json_decode($datos);

        $dao = new DaoArea();
        
        $dao->objeto->setDescArea($datos->descArea);
        $dao->objeto->setCodigoArea($datos->idDetalle);

        echo $dao->editar();
    }

    public function eliminar() {
        $datos = $_REQUEST["id"];

        $dao = new DaoArea();

        $dao->objeto->setCodigoArea($datos);

        echo $dao->eliminar();
    }

}