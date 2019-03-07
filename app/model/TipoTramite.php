<?php 

class TipoTramite extends ModeloBase {
    private $codigoTipoTramite;
    private $descTipoTramite;

    public function __construct()
    {
        parent::__construct();
    }

    /**
     * @return mixed
     */
    public function getCodigoTipoTramite()
    {
        return $this->codigoTipoTramite;
    }

    /**
     * @param mixed $codigoTipoTramite
     */
    public function setCodigoTipoTramite($codigoTipoTramite)
    {
        $this->codigoTipoTramite = $codigoTipoTramite;
    }

    /**
     * @return mixed
     */
    public function getDescTipoTramite()
    {
        return $this->descTipoTramite;
    }

    /**
     * @param mixed $descTipoTramite
     */
    public function setDescTipoTramite($descTipoTramite)
    {
        $this->descTipoTramite = $descTipoTramite;
    }


}