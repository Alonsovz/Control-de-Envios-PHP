<?php
/**
 * Created by PhpStorm.
 * User: jsidg
 * Date: 14/1/2019
 * Time: 14:47
 */
?>
<div id="app">

    <modal-registrar id_form="frmRegistrar" id="modalRegistrar" url="?1=TipoTramiteController&2=registrar" titulo="Registrar Tipo de Trámite"
                     :campos="campos_registro" tamanio='tiny'></modal-registrar>

    <modal-eliminar id_form="frmEliminar" id="modalEliminar" url="?1=TipoTramiteController&2=eliminar" titulo="Eliminar Tipo de Trámite"
                    sub_titulo="¿Está seguro de querer eliminar este Mensajero?" :campos="campos_eliminar" tamanio='tiny'></modal-eliminar>






    <div class="ui grid">
        <div class="row">
            <div class="titulo">
                <i class="exchange fast icon"></i>
                Tipo de Trámite Deloitte<font color="#85BC22" style="font-size: 28px;">.</font>
            </div>
        </div>
        <div class="row title-bar">
            <div class="sixteen wide column">
                <button class="ui right floated positive labeled icon button" @click="modalRegistrar" id="btnModalRegistro">
                    <i class="plus icon"></i>
                    Agregar
                </button>
            </div>
        </div>
        <div class="row title-bar">
            <div class="sixteen wide column">
                <div class="ui divider"></div>
            </div>
        </div>
        <div class="row">
            <div class="sixteen wide column">
                <table id="dtTipoTramite" class="ui selectable very compact celled table" style="width:100%; margin:auto;">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Tipo de Trámite</th>
                        <th>Opciones</th>
                    </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="./res/tablas/tablaTipoTramite.js"></script>
<script src="./res/js/modalRegistrar.js"></script>
<script src="./res/js/modalEliminar.js"></script>

<script>
    var app = new Vue({
        el: "#app",
        data: {
            campos_registro: [{
                label: 'Tipo de Trámite:',
                name: 'nombre',
                type: 'text'
            }

            ],
            campos_eliminar: [{
                name: 'idEliminar',
                type: 'hidden'
            }]
        },
        methods: {
            refrescarTabla() {
                tablaTipoTramite.ajax.reload();
            },
            modalRegistrar() {
                $('#modalRegistrar').modal('setting', 'closable', false).modal(
                    'show');
            }
        }
    });
</script>

<script>
    $(document).on("click", ".btnEliminar", function () {
        $('#modalEliminar').modal('setting', 'closable', false).modal('show');
        $('#idEliminar').val($(this).attr("id"));
    });
</script>



