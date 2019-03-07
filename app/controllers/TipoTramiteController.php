<?php
/**
 * Created by PhpStorm.
 * User: jsidg
 * Date: 14/1/2019
 * Time: 14:45
 */

class TipoTramiteController extends ControladorBase
{

    public static function gestion() {
        self::loadMain();
        require_once './app/view/TipoTramite/gestion.php';
    }

    public function mostrarTiposTabla() {
        $dao = new DaoTipoTramite();

        $json = $dao->mostrarTipoTramite();

        echo '{"data": '.$json.'}';
    }

    public function eliminar() {

        $dao = new DaoTipoTramite();

        $dao->objeto->setCodigoTipoTramite($_REQUEST["id"]);

        if($dao->eliminar()) {
            echo 1;
        } else {
            echo 2;
        }
    }

    public function registrar() {
        $dao = new DaoTipoTramite();

        $datos = json_decode($_REQUEST["datos"]);

        $dao->objeto->setDescTipoTramite($datos->nombre);

        if($dao->registrar()) {
            echo 1;
        } else {
            echo 2;
        }
    }
}