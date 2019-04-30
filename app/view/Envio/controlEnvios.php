<div id="app">

    <div id="cargando" class="ui dimmer">
        <div class="ui big loader"></div>
    </div>

    <modal-detalles :detalles="detalles"></modal-detalles>

    <div class="ui tiny modal" id="modalConfirmar">

        <div class="header">
            Confirmar Correo
        </div>
        <div class="content">
            <h4>¿Desea enviar el correo con la revisión de este paquete?</h4>
        </div>
        <div class="actions">
            <button class="ui black deny button">
                Cancelar
            </button>
            <button class="ui right teal button" id="btnConfirmar" @click="correoPaquete">
                Aceptar
            </button>
        </div>
    </div>

    <div class="ui modal tiny" id="modalEliminar">

        <div class="header">
            Eliminar Paquete
        </div>
        <div class="content">
            <h4>¿Está seguro de querer eliminar este paquete?</h4>
        </div>
        <div class="actions">
            <button class="ui black deny button">
                Cancelar
            </button>
            <button class="ui right red button" id="btnEliminar" @click="eliminar">
                Eliminar
            </button>
        </div>
    </div>

    <div class="ui modal tiny" id="modalEliminarDetalle">

        <div class="header">
            Eliminar Documento
        </div>
        <div class="content">
            <h4>¿Está seguro de querer eliminar este documento?</h4>
        </div>
        <div class="actions">
            <button class="ui black deny button">
                Cancelar
            </button>
            <button class="ui right red button" id="btnEliminarDetalle" @click="eliminarDetalle">
                Eliminar
            </button>
        </div>
    </div>

    <div class="ui small second coupled modal" id="modalCambios">

        <div id="cargandoModal" class="ui inverted dimmer">
            <div class="ui big loader"></div>
        </div>

        <div class="header">
            Cambiar Estado
        </div>
        <div class="content">

            <div style="margin-bottom: 0em !important; width: 100% !important;" class="ui tiny fluid horizontal divided list">

                <div class="item">
                    <i class="tag icon"></i>
                    <div class="content">
                        {{datosDetalle.correlativo}}
                    </div>
                </div>
                <div class="item">
                    <i class="exchange icon"></i>
                    <div class="content">
                        {{datosDetalle.tramite}}
                    </div>
                </div>
                <div class="item">
                    <i class="building icon"></i>
                    <div class="content">
                        {{datosDetalle.cliente}}
                    </div>
                </div>
                <div class="item">
                    <i class="industry icon"></i>
                    <div class="content">
                        {{datosDetalle.area}}
                    </div>
                </div>
                <div class="item">
                    <i class="copy icon"></i>
                    <div class="content">
                        {{datosDetalle.tipoDoc}}
                    </div>
                </div>

            </div>
            <div class="ui divider"></div>
            <form action="" class="ui equal width form" id="frmAutorizar">
                <div class="field">
                    <label for="">Estado:</label>
                    <select v-model="cambiarDetalle.idStatus" class="ui dropdown" name="idEstado" id="idEstado">
                        <option value="2">Incompleto</option>
                        <option value="3">Recibido</option>
                        <option value="4">Pendiente</option>
                        <option value="5">Completo</option>
                        <option value="6">Eliminar</option>
                    </select>
                </div>
                <div class="field">
                    <label for="">Observación:</label>
                    <input v-model="cambiarDetalle.observacion" type="text" id="obs" name="obs">
                </div>
                <input type="hidden" id="idAutorizar" name="idAutorizar">
                <div class="field">
                    <div class="ui toggle checkbox">
                        <input type="checkbox" name="rbtnMensajero" id="rbtnMensajero" tabindex="0" value="rbtnMensajero">
                        <label>Agregar Mensajero</label>
                    </div>
                </div>

                <div class="field" id="mensaje">
                    <label for="">Mensajero:</label>
                    <select v-model="cambiarDetalle.idMensajero" class="ui dropdown" name="mensajero" id="mensajero">

                        <option v-for="mensajero in mensajeros" :value="parseInt(mensajero.codigoMensajero)">{{mensajero.nombre}}</option>

                    </select>
                </div>
            </form>
        </div>

        <div class="actions">
            <button @click="cerrarCambios" class="ui black button">
                Cancelar
            </button>
            <button @click="cambiarEstado" id="btnCambiar" class="ui right primary button">
                Cambiar Estado
            </button>
        </div>
    </div>

    <div class="ui grid">
        <div class="row">
            <div class="titulo">
                <i class="box icon"></i>
                Control de Envíos<font color="#85BC22" style="font-size: 28px;">.</font>
            </div>
        </div>
        <br><br><br>


        <div class="row">
            <div class="sixteen wide column">
                <table id="dtPaquetes" class="ui selectable very compact celled table" style="width:100%; margin:auto;">
                    <thead>
                        <tr>
                            <th>N°</th>
                            <th>Correlativo</th>
                            <th>Fecha</th>
                            <th>Hora</th>
                            <th>Usuario</th>
                            <th>Nombre</th>
                            <th>Documentos</th>
                            <th>Opciones</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>

        <div v-if="paquetesManana > 0" class="row">
            <h3 style="width: 100%;" class="ui dividing header">
                Paquetes agendados para mañana
            </h3>
        </div>

        <div v-if="paquetesManana > 0" class="row">
            <div class="sixteen wide column">
                <table id="dtManana" class="ui selectable very compact celled table" style="width:100%; margin:auto;">
                    <thead>
                        <tr>
                            <th>N°</th>
                            <th>Correlativo</th>
                            <th>Fecha</th>
                            <th>Hora</th>
                            <th>Usuario</th>
                            <th>Nombre</th>
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
<script src="./res/tablas/tablaPaquetes.js"></script>
<script src="./res/tablas/tablaManana.js"></script>
<script src="./res/js/modalDetalles.js"></script>

<script>
    var app = new Vue({
        el: '#app',
        data: {
            detalles: [],

            idEnvio: 0,

            mensajeros: JSON.parse('<?php echo $mensajerosCMB ?>'),

            paquetesManana: <?php echo $numPaquetesManana ?>,

            datosDetalle: {
                correlativo: '',
                tramite: '',
                cliente: '',
                area: '',
                tipoDoc: ''
            },

            idEliminar: 0,

            idEliminarDetalle: 0,

            datosCorreo: {
                idEnvio: 0,
                idUsuario: 0
            },

            cambiarDetalle: {
                idEnvio: 0,
                idDetalle: 0,
                idStatus: 2,
                idMensajero: 1,
                observacion: ''
            }
        },
        methods: {
            cargarDetalles(id, idUsuario) {

                this.idEnvio = parseInt(id);
                this.cambiarDetalle.idEnvio = parseInt(id);

                $('#frmDetalles').addClass('loading');
                $.ajax({
                    type: 'POST',
                    url: '?1=EnvioController&2=getDetallesEnvio',
                    data: {
                        id: id
                    },
                    success: function(data) {
                        app.detalles = JSON.parse(data);
                        $('#frmDetalles').removeClass('loading');
                    }
                });

                this.setearDatosCorreo(idUsuario, id);
            },

            reloadTabla() {
                tablaPaquetes.ajax.reload();
            },

            reloadTabla2() {
                if (this.paquetesManana > 0) {
                    tablaManana.ajax.reload();
                }
            },
            cerrarModal() {
                this.detalles = [];
            },

            modalCambiar(idDetalle, correlativo, tramite, cliente, area, tipoDoc, estado, obs) {

                // this.cambiarDetalle.idEnvio = idEnvio;

                this.datosDetalle.correlativo = correlativo;
                this.datosDetalle.tramite = tramite;
                this.datosDetalle.cliente = cliente;
                this.datosDetalle.area = area;
                this.datosDetalle.tipoDoc = tipoDoc;
                this.cambiarDetalle.observacion = obs;

                this.cambiarDetalle.idDetalle = parseInt(idDetalle);

                $("#idEstado option:contains(" + estado + ")").attr('selected', 'selected');


                $('#modalCambios').modal('setting', 'autofocus', false).modal('setting', 'closable', false)
                    .modal('show');
                $('#mensaje').hide();
                $('#modalDetalles').modal('hide');
            },

            modalEliminar(id) {

                this.idEliminar = id;

                $('#modalEliminar').modal('setting', 'autofocus', false).modal('setting', 'closable', false)
                    .modal('show');
            },

            modalEliminarDetalle(id) {
                this.idEliminarDetalle = id;

                $('#modalEliminarDetalle').modal('setting', 'autofocus', false).modal('setting', 'closable', false)
                    .modal('show');
            },

            eliminar() {
                $('#btnEliminar').addClass('loading');

                // $.ajax({
                //     type: 'POST',
                //     url:
                // });
            },

            cerrarCambios(param) {
                if (param == 1) {
                    $('#modalCambios').modal('hide');
                    $('#modalDetalles').modal('setting', 'autofocus', false)
                        .modal('setting', 'closable', false)
                        .modal('show');
                } else {
                    $('#modalCambios').modal('hide');
                }
                $('#mensaje').hide();
            },

            numeroPaquetesManana() {

                $.ajax({
                    type: 'POST',
                    url: '?1=EnvioController&2=numeroPaquetesManana',
                    success: function(r) {
                        app.paquetesManana = parseInt(r);
                    }
                });

            },

            cerrarModalDetalles() {
                console.log('inicio');
                $('#modalDetalles').modal('hide');
                console.log('fin');
            },

            eliminarDetalle(idDetalle) {
                // $('#btnEliminarDetalle').addClass('loading');

                $.ajax({
                    type: 'POST',
                    url: '?1=EnvioController&2=eliminarDetalle',
                    data: {
                        id: idDetalle
                    },
                    success: function(r) {

                        if (r == 11) {

                            swal({
                                title: null,
                                text: 'El documento fue eliminado',
                                type: 'success',
                                showConfirmButton: false,
                                timer: 1000
                            });

                            app.cargarDetalles(app.idEnvio, app.datosCorreo.idUsuario);
                            app.cerrarCambios(r);
                            app.reloadTabla();
                            app.reloadTabla2();

                            
                            $('#cargandoModal').removeClass('active');
                        }
                    }
                });

                this.cargarDetalles(app.idEnvio, app.datosCorreo.idUsuario);
            },

            cambiarEstado() {

                $('#cargandoModal').addClass('active');

                if (this.cambiarDetalle.idStatus == 6) {
                    this.eliminarDetalle(this.cambiarDetalle.idDetalle);
                } else {
                    var detalle = JSON.stringify(this.cambiarDetalle);

                    $.ajax({
                        type: 'POST',
                        url: '?1=EnvioController&2=actualizarDetalle',
                        data: {
                            detalle: detalle,
                            idUsuario: app.datosCorreo.idUsuario,
                            idEnvio: app.datosCorreo.idEnvio
                        },
                        success: function(r) {

                            if (r == 1) {
                                swal({
                                    title: null,
                                    text: 'Los cambios fueron guardados',
                                    type: 'success',
                                    showConfirmButton: false,
                                    timer: 1000
                                });

                            } else if (r == 11) {
                                swal({
                                    title: null,
                                    text: 'Los cambios fueron guardados y el correo de revisión fue enviado',
                                    type: 'success'
                                });
                            }

                            $('#mensaje').hide();
                            $('#rbtnMensajero').prop('checked', false);
                            app.cargarDetalles(app.idEnvio, app.datosCorreo.idUsuario);
                            app.cerrarCambios(r);
                            app.reloadTabla();
                            app.reloadTabla2();

                            $('#cargandoModal').removeClass('active');
                        }
                    });
                }
            },

            modalConfirmar(idUsuario, idEnvio) {
                this.setearDatosCorreo(idUsuario, idEnvio);
                $('#modalConfirmar').modal('show');
            },


            setearDatosCorreo(idUsuario, idEnvio) {

                // alert('setear: ' + idUsuario);

                this.datosCorreo.idUsuario = parseInt(idUsuario);
                this.datosCorreo.idEnvio = parseInt(idEnvio);
            },

            actualizarFechas() {
                $.ajax({
                    type: 'POST',
                    url: '?1=EnvioController&2=actPaquetes',
                    success: function(r) {}
                });
            },

            correoPaquete() {
                $('#modalConfirmar').modal('hide');
                $('#cargando').addClass('active');

                $.ajax({
                    type: 'POST',
                    url: '?1=EnvioController&2=revisionPaquete',
                    data: {
                        idUsuario: app.datosCorreo.idUsuario,
                        idEnvio: app.datosCorreo.idEnvio
                    },
                    success: function(r) {

                        if (r == 1) {
                            swal({
                                title: null,
                                text: 'El correo fué enviado',
                                type: 'success',
                                showConfirmButton: false,
                                timer: 1000
                            });
                        } else {
                            swal({
                                title: null,
                                text: 'Error al enviar el correo',
                                type: 'error',
                                showConfirmButton: false,
                                timer: 1000
                            });
                        }
                        app.reloadTabla();

                        $('#cargando').removeClass('active');
                    }
                });

            }


        },

        beforeMount() {
            this.actualizarFechas();
        }

    });
</script>

<script>
    $(function() {
        $('.sixteen.wide.column').children().children().css('margin', '0');
    });
</script>

<script>
    $(function() {
        $(document).on("click", ".btnVer", function() {
            $('#modalDetalles').modal('setting', 'autofocus', false).modal('setting', 'closable', false)
                .modal('show');
            app.cargarDetalles($(this).attr('codigo-envio'), $(this).attr('codigo-usuario'));
        });
        $(document).on("click", ".btnCorreo", function() {
            app.modalConfirmar($(this).attr('codigo-usuario'), $(this).attr('codigo-envio'));
        });
        $(document).on("click", ".btnEliminar", function() {
            app.modalEliminar($(this).attr('codigo-usuario'), $(this).attr('codigo-envio'));
        });
    });

    $('#rbtnMensajero').click(function() {
        if ($(this).prop('checked')) {
            $('#mensaje').show();
        } else {
            $('#mensaje').hide();
        }
    });
</script> 