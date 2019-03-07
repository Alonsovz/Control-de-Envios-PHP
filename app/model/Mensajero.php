<?php 

class Mensajero extends ModeloBase{
    private $codigoMensajero;
    private $nombre;


    public function getCodigoMensajero()
    {
        return $this->codigoMensajero;
    }

    /**
     * Set the value of codigoMensajero
     *
     * @return  self
     */ 
    public function setCodigoMensajero($codigoMensajero)
    {
        $this->codigoMensajero = $codigoMensajero;

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

}