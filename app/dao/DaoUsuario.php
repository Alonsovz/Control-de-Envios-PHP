<?php 

class DaoUsuario extends DaoBase {

    public function __construct() {
        parent::__construct();
        $this->objeto = new Usuario();
    }


    public function login() {
        $_query = "call login('".$this->objeto->getNomUsuario()."', '".sha1($this->objeto->getPass())."')";

        $resultado = $this->con->ejecutar($_query);

        if($resultado->num_rows == 1) {

            $fila = $resultado->fetch_assoc();

            if($fila["descAuth"] == "Autorizado") {
                session_start();
                $_SESSION["codigoUsuario"] = $fila["codigoUsuario"];
                $_SESSION["nombre"] = $fila["nombre"];
                $_SESSION["apellido"] = $fila["apellido"];
                $_SESSION["email"] = $fila["email"];
                $_SESSION["nomUsuario"] = $fila["nomUsuario"];
                $_SESSION["descRol"] = $fila["descRol"];
                $_SESSION["descArea"] = $fila["descArea"];
                
                return 1;
            } 
            else {
                return 2;
            }
        } else {
            return 0;
        }
    }

    public function getCodigoUsuarioByPass($code) {
        $_query = "select codigoUsuario from usuario where pass = '".$code."' and nomUsuario = '".$this->objeto->getNomUsuario()."'";
        $resultado = $this->con->ejecutar($_query);

        $datos = $resultado->fetch_assoc();

        return $datos["codigoUsuario"];
    }

    public function cargarDatosUsuario() {

        $_query = "select u.*, r.descRol, a.descAuth
        from usuario u
        inner join rol r on r.codigoRol = u.codigoRol
        inner join authUsuario a on a.codigoAuth = u.codigoAuth
        inner join area ar on ar.codigoArea = u.codigoArea
        where u.codigoUsuario = ".$this->objeto->getCodigoUsuario();

        $resultado = $this->con->ejecutar($_query);

        $json = json_encode($resultado->fetch_assoc());

        return $json;
    }


    public function registrar() {
        $_query = "call registrarUsuario('".$this->objeto->getNombre()."', '".$this->objeto->getApellido()."','".$this->objeto->getNomUsuario()."', '".$this->objeto->getEmail()."', '".sha1($this->objeto->getPass())."', ".$this->objeto->getCodigoArea().", ".$this->objeto->getCodigoRol().",1)";

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function autorizar($estado) {
        $_query = "update usuario set codigoAuth = {$estado} where codigoUsuario = ".$this->objeto->getCodigoUsuario();
        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function restablecerContraConfig()
    {
        $_query = "update usuario set pass = '".sha1($this->objeto->getPass())."' where codigoUsuario = ".$this->objeto->getCodigoUsuario();
        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function cuentasAdministrador() {
        $_query = "call cuentasAdministrador()";
        $resultado = $this->con->ejecutar($_query);

        $array = [];

        while($fila = $resultado->fetch_object()) {
            array_push($array, $fila);
        }

        return $array;
    }

    public function cambiarDatos() {
        $_query = "update usuario set nombre = '".$this->objeto->getNombre()."', apellido='".$this->objeto->getApellido()."' where codigoUsuario = ".$this->objeto->getCodigoUsuario();
        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function eliminarCuenta() {
        $_query = "update usuario set codigoAuth = 4 where codigoUsuario = ".$this->objeto->getCodigoUsuario();
        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    //verificar si el usuario y el correo existen por seguridad
    public function enviarDatos()
    {


    }

    public function resetPassword($code) {

        $codigoUsuario = $this->getCodigoUsuarioByPass($code);

        $_query = "update usuario set pass = '".sha1($this->objeto->getPass())."' where codigoUsuario = ".$codigoUsuario;
        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }

    }

    //Actualizar con el generador de codigo
    public function reestablecer($psswd)
    {
        $_query = "update usuario set pass = '{$psswd}' where nomUsuario = '".$this->objeto->getNomUsuario()."' and email ='".$this->objeto->getEmail()."'";
        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function editar() {
        $_query = "call editarUsuario('".$this->objeto->getNombre()."', '".$this->objeto->getApellido()."','".$this->objeto->getNomUsuario()."', '".$this->objeto->getEmail()."', ".$this->objeto->getCodigoRol().", ".$this->objeto->getCodigoArea().", ".$this->objeto->getCodigoUsuario().")";

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function eliminar() {
        $_query = "update usuario set idEliminado=2 where codigoUsuario = ".$this->objeto->getCodigoUsuario();

        $resultado = $this->con->ejecutar($_query);

        if($resultado) {
            return 1;
        } else {
            return 0;
        }
    }

    public function datosNomUsuario(){

        $_query = "call datosNomUsuario('{$this->objeto->getNomUsuario()}')";

        $resultado = $this->con->ejecutar($_query);

        $datos = $resultado->fetch_object();

        return $datos;
    }

    public function mostrarUsuarios() {
        $_query = "call mostrarUsuarios()";

        $resultado = $this->con->ejecutar($_query);

        $_json = '';

        while($fila = $resultado->fetch_assoc()) {

            $object = json_encode($fila);

            $btnAutorizar = '<button id=\"'.$fila["codigoUsuario"].'\" class=\"ui btnAutorizar icon yellow small button\"><i class=\"key icon\"></i></button>';
            $btnEditar = '<button id=\"'.$fila["codigoUsuario"].'\" class=\"ui btnEditar icon blue small button\"><i class=\"edit icon\"></i></button>';
            $btnEliminar = '<button id=\"'.$fila["codigoUsuario"].'\" class=\"ui btnEliminar icon negative small button\"><i class=\"trash icon\"></i></button>';

            $acciones = ', "Acciones": "'.$btnAutorizar.' '.$btnEditar.' '.$btnEliminar.'"';

            $object = substr_replace($object, $acciones, strlen($object) -1, 0);

            $_json .= $object.',';
        }

        $_json = substr($_json,0, strlen($_json) - 1);

        return '{"data": ['.$_json .']}';
    }

    public function mostrarUsuariosCmb() {
        $_query = "select * from usuario where idEliminado=1 and codigoAuth=1";

        $resultado = $this->con->ejecutar($_query);

        $json = '';

        while($fila = $resultado->fetch_assoc()) {
            $json .= json_encode($fila).',';
        }

        $json = substr($json,0, strlen($json) - 1);

        return '['.$json.']';
    }

    public function reporteUsuario() {
        $query = "call reporteUsuario({$this->objeto->getCodigoUsuario()})";

        $resultado = $this->con->ejecutar($query);

        return $resultado;
    }


    public function reporteUsuarioDiario() {
        $query = "call reporteUsuarioDiario({$this->objeto->getCodigoUsuario()})";

        $resultado = $this->con->ejecutar($query);

        return $resultado;
    }


    public function reporteUsuarioPorFechas() {
        $query = "call reporteUsuarioPorFechas({$this->objeto->getCodigoUsuario()},'{$this->objeto->getFecha()}','{$this->objeto->getFecha2()}')";

        $resultado = $this->con->ejecutar($query);

        return $resultado;
    }

    public function getPass(){

        $_query="select pass from usuario WHERE codigoUsuario=".$this->objeto->getCodigoUsuario();

        $resultado=$this->con->ejecutar($_query)->fetch_assoc();
        
        return $resultado['pass'];
    }


    public function getUserName()
    {

        $_query="select nomUsuario from usuario WHERE nomUsuario='".$this->objeto->getNomUsuario()."'";
       

        $resultado=$this->con->ejecutar($_query)->fetch_assoc();
        if($resultado['nomUsuario']!=null)
        {
            return 1;
        }
        else
        {
            return 0;
        }
        
        

    }

    public function getEmail()
    {
        $_query="select count(email) as email from usuario where email='".$this->objeto->getEmail()."' and nomUsuario='".$this->objeto->getNomUsuario()."' ";
       

        $resultado=$this->con->ejecutar($_query)->fetch_assoc();
        return $resultado['email'];

    }

}