<?php 

class Envio extends ModeloBase {
    private $codigoEnvio;
    private $fecha;
    private $fecha2;
    private $codigoUsuario;
    private $codigoDetalleEnvio;
    private $codigoTipoTramite;
    private $codigoCliente;
    private $codigoTipoDocumento;
    private $codigoArea;
    private $monto;
    private $observacion;
    private $numDoc;
    private $codigoStatus;
    private $codigoMensajero;

    public function __construct() {
        
    }

    /**
     * Get the value of codigoEnvio
     */ 
    public function getCodigoEnvio()
    {
        return $this->codigoEnvio;
    }

    /**
     * Set the value of codigoEnvio
     *
     * @return  self
     */ 
    public function setCodigoEnvio($codigoEnvio)
    {
        $this->codigoEnvio = $codigoEnvio;

        return $this;
    }

    /**
     * Get the value of fecha
     */ 
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
     * Get the value of codigoDetalleEnvio
     */ 
    public function getCodigoDetalleEnvio()
    {
        return $this->codigoDetalleEnvio;
    }

    /**
     * Set the value of codigoDetalleEnvio
     *
     * @return  self
     */ 
    public function setCodigoDetalleEnvio($codigoDetalleEnvio)
    {
        $this->codigoDetalleEnvio = $codigoDetalleEnvio;

        return $this;
    }

    /**
     * Get the value of codigoTipoTramite
     */ 
    public function getCodigoTipoTramite()
    {
        return $this->codigoTipoTramite;
    }

    /**
     * Set the value of codigoTipoTramite
     *
     * @return  self
     */ 
    public function setCodigoTipoTramite($codigoTipoTramite)
    {
        $this->codigoTipoTramite = $codigoTipoTramite;

        return $this;
    }

    /**
     * Get the value of codigoCliente
     */ 
    public function getCodigoCliente()
    {
        return $this->codigoCliente;
    }

    /**
     * Set the value of codigoCliente
     *
     * @return  self
     */ 
    public function setCodigoCliente($codigoCliente)
    {
        $this->codigoCliente = $codigoCliente;

        return $this;
    }

    /**
     * Get the value of codigoTipoDocumento
     */ 
    public function getCodigoTipoDocumento()
    {
        return $this->codigoTipoDocumento;
    }

    /**
     * Set the value of codigoTipoDocumento
     *
     * @return  self
     */ 
    public function setCodigoTipoDocumento($codigoTipoDocumento)
    {
        $this->codigoTipoDocumento = $codigoTipoDocumento;

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
     * Get the value of observacion
     */ 
    public function getObservacion()
    {
        return $this->observacion;
    }

    /**
     * Set the value of observacion
     *
     * @return  self
     */ 
    public function setObservacion($observacion)
    {
        $this->observacion = $observacion;

        return $this;
    }

    /**
     * Get the value of codigoStatus
     */ 
    public function getCodigoStatus()
    {
        return $this->codigoStatus;
    }

    /**
     * Set the value of codigoStatus
     *
     * @return  self
     */ 
    public function setCodigoStatus($codigoStatus)
    {
        $this->codigoStatus = $codigoStatus;

        return $this;
    }

    /**
     * Get the value of monto
     */ 
    public function getMonto()
    {
        return $this->monto;
    }

    /**
     * Set the value of monto
     *
     * @return  self
     */ 
    public function setMonto($monto)
    {
        $this->monto = $monto;

        return $this;
    }

    /**
     * Get the value of numDoc
     */ 
    public function getNumDoc()
    {
        return $this->numDoc;
    }

    /**
     * Set the value of numDoc
     *
     * @return  self
     */ 
    public function setNumDoc($numDoc)
    {
        $this->numDoc = $numDoc;

        return $this;
    }

    /**
     * Get the value of codigoMensajero
     */ 
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
}