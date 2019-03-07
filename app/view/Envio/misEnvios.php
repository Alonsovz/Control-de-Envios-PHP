<div id="app">

    <modal-detalles :detalles="detalles"></modal-detalles>

    <div class="ui tiny second coupled modal" id="modalCambios">

        <div class="header">
            Actualizar Documento
        </div>
        <div class="content">
            <form v-on:submit.prevent action="" class="ui equal width form" id="frmAutorizar">
                <div class="field">
                    <label for="">Observación o Comentario:</label>
                    <input v-model="cambiarDetalle.observacion" type="text" id="obs" name="obs">
                </div>
                <input type="hidden" id="idAutorizar" name="idAutorizar">
            </form>
        </div>

        <div class="actions">
            <button type="button" @click="cerrarCambios" class="ui black button">
                Cancelar
            </button>
            <button type="button" @click="cambiarEstado" id="btnCambiar" class="ui right green button">
                Actualizar
            </button>
        </div>
    </div>

    <div class="ui grid">
        <div class="row">
            <div class="titulo">
                <i class="envelope icon"></i>
                Mis Envíos<font color="#85BC22" style="font-size: 28px;">.</font>
            </div>
        </div>

        <div v-if="numeroDocumentosPendientes > 0" class="row">
            <h3 style="width: 100%;" class="ui dividing header">
                Documentos Pendientes
            </h3>
        </div>

        <div v-if="numeroDocumentosPendientes > 0" class="row">
            <div class="sixteen wide column">
                <table id="dtDocumentosPend" class="ui selectable very compact celled table" style="width:100%; margin:auto;">
                    <thead>
                        <tr>
                            <th>Id</th>
                            <th>Código</th>
                            <th>Tipo de trámite</th>
                            <th>Cliente</th>
                            <th>Área</th>
                            <th>Tipo de Documento</th>
                            <th>N° Doc</th>
                            <th>Estado</th>
                            <th>Monto</th>
                            <th>Mensajero</th>
                            <th>Observación</th>
                            <th>Opcion</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>








        <div class="row">
            <h3 style="width: 100%;" class="ui dividing header">
                Envios Realizados
            </h3>
        </div>

        <div class="row">
            <div class="sixteen wide column">
                <table id="dtPaquetes" class="ui selectable very compact celled table" style="width:100%; margin:auto;">
                    <thead>
                        <tr>
                            <th>N°</th>
                            <th>Correlativo</th>
                            <th>Fecha</th>
                            <th>Hora</th>
                            <th>Documentos</th>
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

<script src="./res/tablas/tablaMisEnvios.js"></script>
<script src="./res/tablas/tablaDocPendiente.js"></script>
<script src="./res/js/modalMisDetalles.js"></script>

<script>
    var app = new Vue({
        el: '#app',
        data: {
            detalles: [],

            idEnvio: 0,

            numeroDocumentosPendientes: <?php echo $numDocumentosPendientes?>,

            datosDetalle: {
                tramite: '',
                cliente: '',
                area: '',
                tipoDoc: ''
            },

            cambiarDetalle: {
                idEnvio: 0,
                idDetalle: 0,
                idStatus: 1,
                observacion: '',
                idMensajero: 1
            },

            pendientes: []
        },
        methods: {
            cargarDetalles(id) {

                this.idEnvio = parseInt(id);

                $('#frmDetalles').addClass('loading');
                $.ajax({
                    type: 'POST',
                    url: '?1=EnvioController&2=getDetallesEnvioH',
                    data: {
                        id: id
                    },
                    success: function (data) {
                        app.detalles = JSON.parse(data);
                        $('#frmDetalles').removeClass('loading');
                    }
                });
            },

            cargarPendientes() {
                $.ajax({
                    type: 'POST',
                    url: '?1=EnvioController&2=misDetallesPendientes',
                    success: function (data) {
                        app.pendientes = JSON.parse(data);
                    }
                });
            },

            reloadTabla() {
                tablaPaquetes.ajax.reload();
            },

            cerrarModal() {
                this.detalles = [];
            },

            modalCambiar(idDetalle, codigoEnvio) {

                this.cambiarDetalle.idEnvio = parseInt(codigoEnvio);
                this.cambiarDetalle.idDetalle = parseInt(idDetalle);

                $('#modalCambios').modal('setting', 'autofocus', false).modal('setting', 'closable', false)
                    .modal('show');
                $('#modalDetalles').modal('hide');
            },

            cerrarCambios() {
                $('#modalCambios').modal('hide');
            },

            refrescarTablaPendientes(){
                tablaDocumentosPendientes.ajax.reload();
            },
            getNumeroDocumentosPendientes() {
                $.ajax({
                    type: 'POST',
                    url: '?1=EnvioController&2=numeroDocumentosPendientes',
                    success: function(data) {
                        app.numeroDocumentosPendientes = parseInt(data);
                    }
                })
            },

            cambiarEstado() {

                var detalle = JSON.stringify(this.cambiarDetalle);

                $.ajax({
                    type: 'POST',
                    url: '?1=EnvioController&2=actualizarDetalle',
                    data: {
                        detalle: detalle
                    },
                    success: function (r) {

                        if (r == 1) {
                            swal({
                                title: null,
                                text: 'Los cambios fueron guardados',
                                type: 'success',
                                showConfirmButton: false,
                                timer: 1000
                            });
                            app.cambiarDetalle.observacion = '';
                            app.cargarDetalles(app.idEnvio);
                            app.cerrarCambios();
                            app.cargarPendientes();
                            app.reloadTabla();
                            app.refrescarTablaPendientes();
                            app.getNumeroDocumentosPendientes();
                        }

                    }
                });

            }
        },
        mounted() {
            this.cargarPendientes();
        }
    });
</script>


<script>
    $(function () {
        $('.sixteen.wide.column').children().children().css('margin', '0');
    });
</script>

<script>
$(function() {
    $(document).on("click", '.btnCambios', function(){
        var detalle = $(this).attr('detalle-envio');
        var envio = $(this).attr('envio');


        app.modalCambiar(detalle, envio);
    });
});
</script>

<script>
    $(function () {
        $(document).on("click", ".btnVer", function () {
            $('#modalDetalles').modal('setting', 'autofocus', false).modal('setting', 'closable', false)
                .modal('show');
            app.cargarDetalles($(this).attr('id'));
        });
    });
</script>
