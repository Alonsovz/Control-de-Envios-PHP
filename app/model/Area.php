<?php 

class Area extends ModeloBase {

    private $codigoArea;
    private $descArea;
    private $fecha;
    private $fecha2;

    public function __construct() {

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

    /**
     * Get the value of descArea
     */ 
    public function getDescArea()
    {
        return $this->descArea;
    }

    /**
     * Set the value of descArea
     *
     * @return  self
     */ 
    public function setDescArea($descArea)
    {
        $this->descArea = $descArea;

        return $this;
    }
}