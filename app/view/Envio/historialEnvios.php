<div id="app">

    <modal-detalles :detalles="detalles"></modal-detalles>

   

    <div class="ui grid">
        <div class="row">
            <div class="titulo">
                <i class="box icon"></i>
                Historial de Envíos<font color="#85BC22" style="font-size: 28px;">.</font>
            </div>
        </div>
        <br><br><br>


        <div class="row">
            <div class="sixteen wide column">
                <table id="dtHistorial" class="ui selectable very compact celled table" style="width:100%; margin:auto;">
                    <thead>
                        <tr>
                            <th>N°</th>
                            <th>Fecha</th>
                            <th>Hora</th>
                            <th>Usuario</th>
                            <th>Nombre</th>
                            <th>Documentos</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<script src="./res/tablas/tablaHistorial.js"></script>
<script src="./res/js/modalHistorialD.js"></script>

<script>
    var app = new Vue({
        el: '#app',
        data: {
            detalles: []
        },
        methods: {
            cargarDetalles(id) {

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

            cerrarModal() {
                this.detalles = [];
            },

            modalCambiar() {
                $('#modalCambios').modal('setting', 'autofocus', false).modal('setting', 'closable', false)
                .modal('show');
                $('#modalDetalles').modal('hide');
            },

            cambiarEstado() {
                $('#modalDetalles').modal('setting', 'autofocus', false).modal('setting', 'closable', false)
                .modal('show');
                $('#modalCambios').modal('hide');
            }
        }
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