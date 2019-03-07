<?php

class EnvioController extends ControladorBase {

    // Vistas
    public function nuevoEnvio() {
        self::loadMain();
        $daoA = new DaoArea();
        $areas = $daoA->mostrarAreas();

        $daoC = new DaoCliente();
        $clientes = $daoC->mostrarClientesCmb();

        $daoD = new DaoDocumento();
        $documentos = $daoD->mostrarDocumentosCmb();

        $daoU = new DaoUsuario();
        $usuariosCMB = $daoU->mostrarUsuariosCmb();

        $daoT = new DaoTipoTramite();
        $tiposTramiteCMB = $daoT->mostrarTipoTramite();

        require_once './app/view/Envio/nuevo.php';
    }

    public function misEnvios() {
        self::loadMain();

        $dao = new DaoEnvio();

        $numDocumentosPendientes = $dao->numeroDocumentosPendientes();

        require_once './app/view/Envio/misEnvios.php';
    }

    public function controlEnvios()
    {
        self::loadMain();
        $dao = new DaoEnvio();
        $numPaquetesManana = $dao->contarPaquetesManana();

        $daoM = new DaoMensajero();
        $mensajerosCMB = $daoM->mostrarMensajerosCmb();

        require_once './app/view/Envio/controlEnvios.php';
    }

    public function detallesEnvio()
    {
        self::loadMain();
        require_once './app/view/Envio/detallesEnvio.php';
    }

    public function llamaReporte()
    {
        require_once './app/ReporteDiario/reporteDiario.php';
    }
    public function reporteRecibidos()
    {
        require_once './app/ReporteDiario/reporteRecibidos.php';
    }
    public function llamaReporteArea()
    {
        require_once './app/ReporteDiario/reporteArea.php';
    }
    public function llamaReporteUsuario()
    {
        require_once './app/ReporteDiario/reporteUsuario.php';
    }


    public function historialEnvios()
    {
        self::loadMain();
        require_once './app/view/Envio/historialEnvios.php';
    }
    // Métodos


    public function actPaquetes() {
        $dao = new DaoEnvio();

        echo $dao->actPaquetes();
    }

    public function mostrarPaquetes()
    {
        $dao = new DaoEnvio();

        echo $dao->mostrarPaquetes();
    }
    
    public function mostrarPaquetesManana()
    {
        $dao = new DaoEnvio();

        echo $dao->mostrarPaquetesManana();
    }

    public function historialEnviosP()
    {
        $dao = new DaoEnvio();

        echo $dao->historialEnvios();
    }

    public function numeroDocumentosPendientes() {
        $dao = new DaoEnvio();

        echo $dao->numeroDocumentosPendientes();
    }

    public function actualizarDetalle() {
        $dao = new DaoEnvio();

        $detalle = json_decode($_REQUEST["detalle"]);

        $dao->objeto->setCodigoEnvio($detalle->idEnvio);
        $dao->objeto->setCodigoDetalleEnvio($detalle->idDetalle);
        $dao->objeto->setCodigoStatus($detalle->idStatus);
        $dao->objeto->setObservacion($detalle->observacion);
        $dao->objeto->setCodigoMensajero($detalle->idMensajero);

        
        $res = $dao->actualizarDetalle();
        
        if($dao->estadoPaquete()) {
            $this->revisionPaquete();
        }

        echo $res;
    }

    public function getDetallesEnvio() {
        $dao = new DaoEnvio();

        $id = $_REQUEST["id"];

        $dao->objeto->setCodigoEnvio($id);

        $resultado = $dao->detallesEnvio();

        $json = '';

        while($fila = $resultado->fetch_assoc()) {

            $json .= json_encode($fila).',';

        }

        $json = substr($json, 0, strlen($json) - 1);

        echo'['.$json.']';
    }

    public function getDetallesEnvioH() {
        $dao = new DaoEnvio();

        $id = $_REQUEST["id"];

        $dao->objeto->setCodigoEnvio($id);

        $resultado = $dao->detallesEnvioH();

        $json = '';

        while($fila = $resultado->fetch_assoc()) {

            $json .= json_encode($fila).',';

        }

        $json = substr($json, 0, strlen($json) - 1);

        echo'['.$json.']';
    }

    public function getMisEnvios() {
        session_start();
        $dao = new DaoEnvio();

        $dao->objeto->setCodigoUsuario($_SESSION["codigoUsuario"]);

        echo $dao->misEnvios();
    }

    public function misDetallesPendientes() {
        session_start();
        $dao = new DaoEnvio();

        $dao->objeto->setCodigoUsuario($_SESSION["codigoUsuario"]);

        echo $dao->misDetallesPendientes();
    }

    public function registrarEnvio() {

        session_start();
        
        $detalles = json_decode($_REQUEST["detalles"]);
        

        $dao = new DaoEnvio();
        $daoUsuario = new DaoUsuario();

        if( $_SESSION['rol']==0)
        {
            $dao->objeto->setCodigoUsuario($_SESSION["codigoUsuario"]);
            $daoUsuario->objeto->setCodigoUsuario($_SESSION["codigoUsuario"]);
        }
        else
        {
            $dao->objeto->setCodigoUsuario($_SESSION["idUsuario"]);
            $daoUsuario->objeto->setCodigoUsuario($_SESSION["idUsuario"]);
        }

        $codigoEnvio = $dao->encabezadoEnvio();
        $datosUsuario = json_decode($daoUsuario->cargarDatosUsuario());

        $dao->objeto->setCodigoEnvio($codigoEnvio);

        $contador = 0;

        foreach($detalles as $detalle) {
            $dao->objeto->setCodigoTipoTramite($detalle->tramite);
            $dao->objeto->setCodigoCliente($detalle->cliente);
            $dao->objeto->setCodigoTipoDocumento($detalle->tipoDocumento);
            $dao->objeto->setCodigoArea($detalle->area);
            $dao->objeto->setMonto($detalle->monto);
            $dao->objeto->setObservacion($detalle->observaciones);
            $dao->objeto->setNumDoc($detalle->numDocumento);

            if($dao->registrarDetalleEnvio()) {
                $contador++;
            } else {
                echo 'nell';
            }
        }

        require './app/mail/Mail.php';
        $mail = new Mail();

        if(!$mail->detalleEnvio($codigoEnvio, $datosUsuario, $daoUsuario->cuentasAdministrador())) {
            echo "El correo no fue enviado Correctamente";
        }

        if($contador == count($detalles)) {
            echo 1;
        } else {
            echo 2;
        }

    }

    public function revisionPaquete() {

        $idEnvio = $_REQUEST["idEnvio"];

        $idUsuario = $_REQUEST["idUsuario"];

        $daoUsuario = new DaoUsuario();
        $daoEnvio = new DaoEnvio();

        $daoEnvio->objeto->setCodigoEnvio($idEnvio);

        $datosEncabezado = $daoEnvio->getEncabezadoEnvio()->fetch_assoc();

        $daoUsuario->objeto->setCodigoUsuario($idUsuario);

        $datosUsuario = json_decode($daoUsuario->cargarDatosUsuario());

        require './app/mail/Mail.php';
        $mail = new Mail();

        $daoEnvio->objeto->setCodigoEnvio($idEnvio);
        $detalles = $daoEnvio->detallesEnvioH();

        // $daoEnvio->cambiarEnvio(0);

        if(!$mail->revisionPaquete($datosUsuario, $datosEncabezado, $detalles)) {
            echo 'Error al enviar el correo';
        } else {
            echo 1;
        }

    }

    public function numeroPaquetesManana(){
        $dao = new DaoEnvio();

        echo $dao->contarPaquetesManana();
    }

    public function setCodigo()
    {
        session_start();
       
        $id=$_REQUEST['datos'];
        $rol=$_REQUEST['rol'];

        $_SESSION['idUsuario']=$id;
        $_SESSION['rol']=$rol;
    

        echo $_SESSION['codigoUsuario'];

    }

    public function getRol()
    {
        
        echo $_SESSION["descRol"];
    }    
}
