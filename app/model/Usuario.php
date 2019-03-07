<?php 

class Usuario extends ModeloBase{
    private $codigoUsuario;
    private $nombre;
    private $apellido;
    private $nomUsuario;
    private $email;
    private $pass;
    private $codigoRol;
    private $codigoArea;
    private $fecha;
    private $fecha2;
    private $idMensajero;

    public function __construct() {

    }

    /**
     * Get the value of codigoUsuario
     */ 
    public function getCodigoUsuario()
    {
        return $this->codigoUsuario;
    }

    /**
     * Set the value of codigoUsuario
     *
     * @return  self
     */ 
    public function setCodigoUsuario($codigoUsuario)
    {
        $this->codigoUsuario = $codigoUsuario;

        return $this;
    }

    /**
     * Get the value of nombre
     */ 
    public function getNombre()
    {
        return $this->nombre;
    }

    /**
     * Set the value of nombre
     *
     * @return  self
     */ 
    public function setNombre($nombre)
    {
        $this->nombre = $nombre;

        return $this;
    }

    /**
     * Get the value of apellido
     */ 
    public function getApellido()
    {
        return $this->apellido;
    }

    /**
     * Set the value of apellido
     *
     * @return  self
     */ 
    public function setApellido($apellido)
    {
        $this->apellido = $apellido;

        return $this;
    }

    /**
     * Get the value of nomUsuario
     */ 
    public function getNomUsuario()
    {
        return $this->nomUsuario;
    }

    /**
     * Set the value of nomUsuario
     *
     * @return  self
     */ 
    public function setNomUsuario($nomUsuario)
    {
        $this->nomUsuario = $nomUsuario;

        return $this;
    }

    /**
     * Get the value of pass
     */ 
    public function getPass()
    {
        return $this->pass;
    }

    /**
     * Set the value of pass
     *
     * @return  self
     */ 
    public function setPass($pass)
    {
        $this->pass = $pass;

        return $this;
    }

    /**
     * Get the value of codigoRol
     */ 
    public function getCodigoRol()
    {
        return $this->codigoRol;
    }

    /**
     * Set the value of codigoRol
     *
     * @return  self
     */ 
    public function setCodigoRol($codigoRol)
    {
        $this->codigoRol = $codigoRol;

        return $this;
    }

    /**
     * Get the value of email
     */ 
    public function getEmail()
    {
        return $this->email;
    }

    /**
     * Set the value of email
     *
     * @return  self
     */ 
    public function setEmail($email)
    {
        $this->email = $email;

        return $this;
    }

    /**
     * Get the value of codigoArea
     */ 
    public function getCodigoArea()
    {
        return $this->codigoArea;
    }

    /**
     * Set the value of codigoArea
     *
     * @return  self
     */ 
    public function setCodigoArea($codigoArea)
    {
        $this->codigoArea = $codigoArea;

        return $this;
    }

    public function getFecha()
    {
        return $this->fecha;
    }

    /**
     * Set the value of fecha
     *
     * @return  self
     */ 
    public function setFecha($fecha)
    {
        $this->fecha = $fecha;

        return $this;
    }

    public function getFecha2()
    {
        return $this->fecha2;
    }

    /**
     * Set the value of fecha
     *
     * @return  self
     */ 
    public function setFecha2($fecha2)
    {
        $this->fecha2 = $fecha2;

        return $this;
    }

    /**
     * Get the value of idMensajero
     */ 
    public function getIdMensajero()
    {
        return $this->idMensajero;
    }

    /**
     * Set the value of idMensajero
     *
     * @return  self
     */ 
    public function setIdMensajero($idMensajero)
    {
        $this->idMensajero = $idMensajero;

        return $this;
    }
}