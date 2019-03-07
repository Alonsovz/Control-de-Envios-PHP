<?php 

class DocumentoController extends ControladorBase {

    // Vistas 

    public function gestion() {
        self::loadMain();
        require_once './app/view/Documento/gestion.php';
    }

    public function mostrarTiposDT() {
        $dao = new DaoDocumento();
        echo $dao->mostrarDocumentos();
    }


    public function registrar() {
        $datos = $_REQUEST["datos"];

        $datos = json_decode($datos);

        $dao = new DaoDocumento();

        $dao->objeto->setDescTipoDocumento($datos->descTipoDocumento);


        echo $dao->registrar();
     
    }

    public function cargarDatosDocumento() {
        $id = $_REQUEST["id"];

        $dao = new DaoDocumento();

        $dao->objeto->setCodigoTipoDocumento($id);

        echo $dao->cargarDatosDocumento();
    }

    public function editar() {
        $datos = $_REQUEST["datos"];

        $datos = json_decode($datos);

        $dao = new DaoDocumento();
        
        $dao->objeto->setDescTipoDocumento($datos->descTipoDocumento);
        $dao->objeto->setCodigoTipoDocumento($datos->idDetalle);

        echo $dao->editar();
    }
    public function eliminar() {
        $datos = $_REQUEST["id"];

        $dao = new DaoDocumento();

        $dao->objeto->setCodigoTipoDocumento($datos);

        echo $dao->eliminar();
    }
}