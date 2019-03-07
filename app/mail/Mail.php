<?php

require_once './app/composer/vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require './app/composer/vendor/phpmailer/phpmailer/src/Exception.php';
require './app/composer/vendor/phpmailer/phpmailer/src/PHPMailer.php';
require './app/composer/vendor/phpmailer/phpmailer/src/SMTP.php';

class Mail {

    private $correoSistema = "dtt.es.no.reply@gmail.com";

    private $URL_SERVER = "svapplocal:8080/sim/";

    public function __construct() {

    }

    public function composeAuthMail($datosUsuario, $estadoCuenta) {

        $emailFrom = $this->correoSistema;
        $emailFromName = 'Deloitte';

        $emailTo = $datosUsuario->email;
        $emailToName = $datosUsuario->nombre.' '. $datosUsuario->apellido;

        $mail = new PHPMailer();
        $mail->isSMTP();

        require_once './app/encode/Encode.php';

        $encode = new Encode();

        $mail->Host = "smtp.gmail.com";
        $mail->Port = 587;
        $mail->SMTPSecure = 'tls';
        $mail->SMTPAuth = true;
        $mail->isHTML(true);
        // $mail->SMTPDebug = 2;
        $mail->CharSet = 'UTF-8';

        $mail->Username = $this->correoSistema;
        $mail->Password = 'Deloitte123!';
        $mail->setFrom($emailFrom, $emailFromName);

        $mail->addAddress($emailTo, $emailToName);

        $mail->Subject = 'Control de Cuenta Deloitte';

        $plantilla = file_get_contents('./app/mail/correoAuth.html');

        if($estadoCuenta == 'Autorizada') {
            $celda = '<td style="padding: 20px 0px;"><a href="'.$this->URL_SERVER.'?1=UsuarioController&2=loginView&3='.$encode->encode('e', $datosUsuario->nomUsuario).'" style="padding: 10px; border-radius: 3px; background: #85BC22; text-decoration: none; color: #fff;">Iniciar Sesión</a></td>';
        } else {
            $celda = '<td></td>';
        }


        $plantilla = str_replace('%estadoCuenta%', $estadoCuenta, $plantilla);
        $plantilla = str_replace('%celda%', $celda, $plantilla);

        $mail->Body = $plantilla;
        $mail->AltBody = strip_tags($plantilla);
        // $mail->AltBody(strip_tags($plantilla));
        $mail->AddEmbeddedImage('./app/mail/deloitteNegro.png', 'logo');


        if($mail->Send())
        {
            return true;
        } else {
            return false;
        }
    }

    public function composeRestorePassMail($emailUsuario, $nomUsuario, $pass) {

        $emailFrom = $this->correoSistema;
        $emailFromName = 'Deloitte';

        $emailTo = $emailUsuario;
        // $emailToName = $datosUsuario->nombre.' '. $datosUsuario->apellido;
        $emailToName = $nomUsuario;

        $mail = new PHPMailer();
        $mail->isSMTP();

        $mail->Host = "smtp.gmail.com";
        $mail->Port = 587;
        $mail->SMTPSecure = 'tls';
        $mail->SMTPAuth = true;
        $mail->isHTML(true);
        $mail->CharSet = 'UTF-8';

        $mail->Username = $this->correoSistema;
        $mail->Password = 'Deloitte123!';
        $mail->setFrom($emailFrom, $emailFromName);

        $mail->addAddress($emailTo, $emailToName);

        $mail->Subject = 'Control de Cuenta Deloitte';

        $plantilla = file_get_contents('./app/mail/correoRestorePass.html');

        $plantilla = str_replace('%codigoPass%', $pass, $plantilla);

        $mail->msgHTML($plantilla);
        $mail->AddEmbeddedImage('./app/mail/deloitteNegro.png', 'logo');

        if($mail->Send())
        {
            return true;
        }
    }

    public function notificacionRegistroUsuario($datosUsuario, $arrayAdministradores) {

        $emailFrom = $this->correoSistema;
        $emailFromName = 'Deloitte';

        $mail = new PHPMailer();
        $mail->isSMTP();

        $mail->Host = "smtp.gmail.com";
        $mail->Port = 587;
        $mail->SMTPSecure = 'tls';
        $mail->SMTPAuth = true;
        $mail->isHTML(true);
        $mail->CharSet = 'UTF-8';

        $mail->Username = $this->correoSistema;
        $mail->Password = 'Deloitte123!';
        $mail->setFrom($emailFrom, $emailFromName);

        foreach ($arrayAdministradores as $administrador) {
            $mail->addAddress($administrador->email, $administrador->nombre.' '.$administrador->apellido);
        }

        $mail->Subject = 'Control de Cuenta Deloitte';

        $plantilla = file_get_contents('./app/mail/correoNuevoUsuario.html');

        $plantilla = str_replace('%fecha%', date('d/m/Y'), $plantilla);
        $plantilla = str_replace('%nombre%', $datosUsuario->nombre, $plantilla);
        $plantilla = str_replace('%apellido%', $datosUsuario->apellido, $plantilla);
        $plantilla = str_replace('%usuario%', $datosUsuario->nomUsuario, $plantilla);
        $plantilla = str_replace('%rol%', $datosUsuario->descRol, $plantilla);

        $mail->msgHTML($plantilla);
        $mail->AddEmbeddedImage('./app/mail/deloitteNegro.png', 'logo');

        if($mail->Send())
        {
            return true;
        }

    }

    public function detalleEnvio($codigoEnvio, $datosUsuario, $arrayAdministradores) {

        $emailFrom = $this->correoSistema;
        $emailFromName = 'Deloitte';

        $nombreUsuario = $datosUsuario->nombre.' '. $datosUsuario->apellido;
        $emailUsuario = $datosUsuario->email;


        $mail = new PHPMailer();
        $mail->isSMTP();

        require_once './app/encode/Encode.php';

        $encode = new Encode();

        $mail->Host = "smtp.gmail.com";
        $mail->Port = 587;
        $mail->SMTPSecure = 'tls';
        $mail->SMTPAuth = true;
        $mail->isHTML(true);
        // $mail->SMTPDebug = 2;
        $mail->CharSet = 'UTF-8';

        $mail->Username = $this->correoSistema;
        $mail->Password = 'Deloitte123!';
        $mail->setFrom($emailFrom, $emailFromName);

        foreach ($arrayAdministradores as $administrador) {
            $mail->addAddress($administrador->email, $administrador->nombre.' '.$administrador->apellido);
        }

        $mail->addAddress($emailUsuario,$nombreUsuario);

        $mail->Subject = 'Control de Envios';


        $dao = new DaoEnvio();

        $dao->objeto->setCodigoEnvio($codigoEnvio);

        $datosEncabezado = $dao->getEncabezadoEnvio()->fetch_assoc();

        $detallesEnvio = $dao->detallesEnvioH();

        $celda = '';

        while($fila = $detallesEnvio->fetch_assoc()){

            $celda .= '<tr>
                        <td>'.$fila["correlativoDetalle"].'</td>
                        <td>'.$fila["descTipoTramite"].'</td>
                        <td>'.$fila["nombreCliente"].'</td>
                        <td>'.$fila["descArea"].'</td>
                        <td>'.$fila["descTipoDocumento"].'</td>
                        <td>'.$fila["numDoc"].'</td>
                        <td>'.$fila["descStatus"].'</td>
                        <td>'.$fila["monto"].'</td>
                        <td>'.$fila["mensajero"].'</td>
                        <td>'.$fila["observacion"].'</td>
                    </tr>';
        }

        $plantilla = file_get_contents('./app/mail/correoEnvios.html');

        $nota= '';


        if($datosEncabezado["estado"] == 2) {
            $nota = '<tr>
                        <td style="padding: 20px 0px; color: rgba(0,50,250,1)"><b>Nota:</b> ya que el paquete se registró despues de las 13:00 de la tarde será agendado para enviarse el día de mañana</td>
                    </tr>';
        }

        
        $plantilla = str_replace('%nomUsuario%', $datosEncabezado["nomUsuario"], $plantilla);
        $plantilla = str_replace('%fecha%', $datosEncabezado["fecha"], $plantilla);
        $plantilla = str_replace('%correlativo%', $datosEncabezado["correlativoEnvio"], $plantilla);
        $plantilla = str_replace('%hora%', $datosEncabezado["hora"], $plantilla);
        $plantilla = str_replace('%nombre%', $datosEncabezado["nombre"], $plantilla);
        $plantilla = str_replace('%apellido%', $datosEncabezado["apellido"], $plantilla);
        $plantilla = str_replace('%lista%', $celda, $plantilla);
        $plantilla = str_replace('%nota%', $nota, $plantilla);

        $mail->Body = $plantilla;
        $mail->AltBody = strip_tags($plantilla);
        // $mail->AltBody(strip_tags($plantilla));
        $mail->AddEmbeddedImage('./app/mail/deloitteNegro.png', 'logo');


        if($mail->Send())
        {
            return true;
        } else {
            return false;
        }
    }

    public function revisionPaquete($datosUsuario, $datosEncabezado, $detalles) {
        $emailFrom = $this->correoSistema;
        $emailFromName = 'Deloitte';

        $emailTo = $datosUsuario->email;
        $emailToName = $datosUsuario->nombre.' '.$datosUsuario->apellido;

        $mail = new PHPMailer();
        $mail->isSMTP();

        $mail->Host = "smtp.gmail.com";
        $mail->Port = 587;
        $mail->SMTPSecure = 'tls';
        $mail->SMTPAuth = true;
        $mail->isHTML(true);
        // $mail->SMTPDebug = 2;
        $mail->CharSet = 'UTF-8';

        $mail->Username = $this->correoSistema;
        $mail->Password = 'Deloitte123!';
        $mail->setFrom($emailFrom, $emailFromName);

        $mail->addAddress($emailTo, $emailToName);

        $mail->Subject = 'Control de Envios';


        $plantilla = file_get_contents('./app/mail/correoRevision.html');

        

        $plantilla = str_replace('%nomUsuario%', $datosEncabezado["nomUsuario"], $plantilla);
        $plantilla = str_replace('%correlativo%', $datosEncabezado["correlativoEnvio"], $plantilla);
        $plantilla = str_replace('%fecha%', $datosEncabezado["fecha"], $plantilla);
        $plantilla = str_replace('%hora%', $datosEncabezado["hora"], $plantilla);
        $plantilla = str_replace('%nombre%', $datosEncabezado["nombre"], $plantilla);
        $plantilla = str_replace('%apellido%', $datosEncabezado["apellido"], $plantilla);
        
        $docsCompletos = '';
        $docsIncompleto = '';
        $docsRecibido = '';
        $docsPendientes = '';
        $docsPendienteRevision = '';

        while($fila = $detalles->fetch_assoc()){

            switch ($fila["descStatus"]) {
                case 'Pendiente':
                    $docsPendientes .= '<tr>
                                <td>'.$fila["correlativoDetalle"].'</td>
                                <td>'.$fila["descTipoTramite"].'</td>
                                <td>'.$fila["nombreCliente"].'</td>
                                <td>'.$fila["descArea"].'</td>
                                <td>'.$fila["descTipoDocumento"].'</td>
                                <td>'.$fila["numDoc"].'</td>
                                <td>'.$fila["descStatus"].'</td>
                                <td>'.$fila["monto"].'</td>
                                <td>'.$fila["mensajero"].'</td>
                                <td>'.$fila["observacion"].'</td>
                            </tr>';
                    break;

                case 'Incompleto':
                    $docsIncompleto .= '<tr>
                                <td>'.$fila["correlativoDetalle"].'</td>
                                <td>'.$fila["descTipoTramite"].'</td>
                                <td>'.$fila["nombreCliente"].'</td>
                                <td>'.$fila["descArea"].'</td>
                                <td>'.$fila["descTipoDocumento"].'</td>
                                <td>'.$fila["numDoc"].'</td>
                                <td>'.$fila["descStatus"].'</td>
                                <td>'.$fila["monto"].'</td>
                                <td>'.$fila["mensajero"].'</td>
                                <td>'.$fila["observacion"].'</td>
                            </tr>';
                    break;

                case 'Completo':
                    $docsCompletos .= '<tr>
                                <td>'.$fila["correlativoDetalle"].'</td>
                                <td>'.$fila["descTipoTramite"].'</td>
                                <td>'.$fila["nombreCliente"].'</td>
                                <td>'.$fila["descArea"].'</td>
                                <td>'.$fila["descTipoDocumento"].'</td>
                                <td>'.$fila["numDoc"].'</td>
                                <td>'.$fila["descStatus"].'</td>
                                <td>'.$fila["monto"].'</td>
                                <td>'.$fila["mensajero"].'</td>
                                <td>'.$fila["observacion"].'</td>
                            </tr>';
                    break;

                case 'Recibido':
                    $docsRecibido .= '<tr>
                                <td>'.$fila["correlativoDetalle"].'</td>
                                <td>'.$fila["descTipoTramite"].'</td>
                                <td>'.$fila["nombreCliente"].'</td>
                                <td>'.$fila["descArea"].'</td>
                                <td>'.$fila["descTipoDocumento"].'</td>
                                <td>'.$fila["numDoc"].'</td>
                                <td>'.$fila["descStatus"].'</td>
                                <td>'.$fila["monto"].'</td>
                                <td>'.$fila["mensajero"].'</td>
                                <td>'.$fila["observacion"].'</td>
                            </tr>';
                    break;
                    case 'Pendiente de Revision':
                    $docsPendienteRevision .= '<tr>
                                <td>'.$fila["correlativoDetalle"].'</td>
                                <td>'.$fila["descTipoTramite"].'</td>
                                <td>'.$fila["nombreCliente"].'</td>
                                <td>'.$fila["descArea"].'</td>
                                <td>'.$fila["descTipoDocumento"].'</td>
                                <td>'.$fila["numDoc"].'</td>
                                <td>'.$fila["descStatus"].'</td>
                                <td>'.$fila["monto"].'</td>
                                <td>'.$fila["mensajero"].'</td>
                                <td>'.$fila["observacion"].'</td>
                            </tr>';
                    break;

                default:
                    # code...
                    break;
            }

        }

        $contenido = '';

        if(strlen($docsCompletos) > 0) {

            $contenido .= '<tr><td><br>
                            <h3>Documentos Completados</h3>
                            <table border="1" style="width:100%; border-collapse: collapse; background: rgba(46, 204, 113, 0.3);">
                            <tr>
                                <th>Codigo Documento</th>
                                <th>Tramite</th>
                                <th>Cliente</th>
                                <th>Area</th>
                                <th>Tipo Documento</th>
                                <th>N° Documento</th>
                                <th>Status</th>
                                <th>Monto</th>
                                <th>Mensajero</th>
                                <th>Observacion</th>
                            </tr>
                            '.$docsCompletos.'
                        </table>
                        </td></tr>';
        }
        if(strlen($docsIncompleto) > 0) {

            $contenido .= '<tr><td><br>
                            <h3>Documentos Incompletos</h3>
                            <table border="1" style="width:100%; border-collapse: collapse; background: rgba(230, 126, 34, 0.3);">
                            <tr>
                                <th>Codigo Documento</th>
                                <th>Tramite</th>
                                <th>Cliente</th>
                                <th>Area</th>
                                <th>Tipo Documento</th>
                                <th>N° Documento</th>
                                <th>Status</th>
                                <th>Monto</th>
                                <th>Mensajero</th>
                                <th>Observacion</th>
                            </tr>
                            '.$docsIncompleto.'
                        </table></td></tr>';
        }

        if(strlen($docsRecibido) > 0) {

            $contenido .= '<tr><td><br>
                            <h3>Documentos Recibidos</h3>
                            <table border="1" style="width:100%; border-collapse: collapse; background: rgba(52, 152, 219, 0.3);">
                            <tr>
                                <th>Codigo Documento</th>
                                <th>Tramite</th>
                                <th>Cliente</th>
                                <th>Area</th>
                                <th>Tipo Documento</th>
                                <th>N° Documento</th>
                                <th>Status</th>
                                <th>Monto</th>
                                <th>Mensajero</th>
                                <th>Observacion</th>
                            </tr>
                            '.$docsRecibido.'
                        </table></td></tr>';
        }

        if(strlen($docsPendientes) > 0) {

            $contenido .= '<tr><td><br>
                            <h3>Documentos Pendientes</h3>
                            <table border="1" style="width:100%; border-collapse: collapse; background: rgba(241, 196, 15, 0.3);">
                            <tr>
                                <th>Codigo Documento</th>
                                <th>Tramite</th>
                                <th>Cliente</th>
                                <th>Area</th>
                                <th>Tipo Documento</th>
                                <th>N° Documento</th>
                                <th>Status</th>
                                <th>Monto</th>
                                <th>Mensajero</th>
                                <th>Observacion</th>
                            </tr>
                            '.$docsPendientes.'
                        </table></td></tr>';
        }
        if(strlen($docsPendienteRevision) > 0) {

            $contenido .= '<tr><td><br>
                            <h3>Documentos Pendientes de Revision</h3>
                            <table border="1" style="width:100%; border-collapse: collapse; background:  rgba(149, 165, 166, 0.3);">
                            <tr>
                                <th>Codigo Documento</th>
                                <th>Tramite</th>
                                <th>Cliente</th>
                                <th>Area</th>
                                <th>Tipo Documento</th>
                                <th>N° Documento</th>
                                <th>Status</th>
                                <th>Monto</th>
                                <th>Mensajero</th>
                                <th>Observacion</th>
                            </tr>
                            '.$docsPendienteRevision.'
                        </table></td></tr>';
        }

        $plantilla = str_replace('%contenido%', $contenido, $plantilla);

        $mail->Body = $plantilla;
        $mail->AltBody = strip_tags($plantilla);
        // $mail->AltBody(strip_tags($plantilla));
        $mail->AddEmbeddedImage('./app/mail/deloitteNegro.png', 'logo');


        if($mail->Send())
        {
            return true;
        } else {
            return false;
        }
    }

}
