<?php 

class Documento extends ModeloBase {

    private $codigoTipoDocumento;
    private $descTipoDocumento;

    public function __construct() {
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
     * Get the value of descTipoDocumento
     */ 
    public function getDescTipoDocumento()
    {
        return $this->descTipoDocumento;
    }

    /**
     * Set the value of descTipoDocumento
     *
     * @return  self
     */ 
    public function setDescTipoDocumento($descTipoDocumento)
    {
        $this->descTipoDocumento = $descTipoDocumento;

        return $this;
    }
}