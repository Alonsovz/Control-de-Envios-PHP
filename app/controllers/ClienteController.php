<?php

class ClienteController extends ControladorBase {

    public static function clientes()
    {
        self::loadMain();
        require_once './app/view/Clientes/clientes.php';
    }

    public function mostrarClientes() {
        $dao = new DaoCliente();

        echo $dao->mostrarClientes();
    }

    public function registrar() {
        $datos = $_REQUEST["datos"];

        $datos = json_decode($datos);

        $dao = new DaoCliente();

        $dao->objeto->setCodigo($datos->codigoCliente);
        $dao->objeto->setNombreCliente($datos->nombreCliente);
        $dao->objeto->setCalle($datos->calle);
        $dao->objeto->setPoblacion($datos->poblacion);

        echo $dao->registrar();
     
    }

    public function editar() {
        $datos = $_REQUEST["datos"];

        $datos = json_decode($datos);

        $dao = new DaoCliente();

        $dao->objeto->setCodigo($datos->codigoCliente);
        $dao->objeto->setNombreCliente($datos->nombreCliente);
        $dao->objeto->setCalle($datos->calle);
        $dao->objeto->setPoblacion($datos->poblacion);
        $dao->objeto->setCodigoCliente($datos->idDetalle);

        echo $dao->editar();
     
    }

    public function cargarDatosCliente() {
        $id = $_REQUEST["id"];

        $dao = new DaoCliente();

        $dao->objeto->setCodigoCliente($id);

        echo $dao->cargarDatosCliente();
    }

    public function eliminar() {
        $datos = $_REQUEST["id"];

        $dao = new DaoCliente();

        $dao->objeto->setCodigoCliente($datos);

        echo $dao->eliminar();
    }


}

?>