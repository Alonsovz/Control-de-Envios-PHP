<div id="app">

    <modal-registrar id_form="frmRegistrar" id="modalRegistrar" url="?1=ClienteController&2=registrar" titulo="Registrar Cliente"
        :campos="campos_registro" tamanio='tiny'></modal-registrar>

    <modal-editar id_form="frmEditar" id="modalEditar" url="?1=ClienteController&2=editar" titulo="Editar Cliente"
        :campos="campos_editar" tamanio='tiny'></modal-editar>

    <modal-eliminar id_form="frmEliminar" id="modalEliminar" url="?1=ClienteController&2=eliminar" titulo="Eliminar Cliente"
        sub_titulo="¿Está seguro de querer eliminar este Cliente?" :campos="campos_eliminar" tamanio='tiny'></modal-eliminar>

  
    




    <div class="ui grid">
        <div class="row">
            <div class="titulo">
            <i class="building icon"></i>
                Clientes Deloitte<font color="#85BC22" style="font-size: 28px;">.</font>
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
                <table id="dtClientes" class="ui selectable very compact celled table" style="width:100%; margin:auto;">
                    <thead>
                        <tr>
                            <th>N°</th>
                            <th>Código Cliente</th>
                            <th>Nombre</th>
                            <th>Calle</th>
                            <th>Población</th>
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

<script src="./res/tablas/tablaClientes.js"></script>
<script src="./res/js/modalRegistrar.js"></script>
<script src="./res/js/modalEditar.js"></script>
<script src="./res/js/modalEliminar.js"></script>

<script>
var app = new Vue({
        el: "#app",
        data: {
            campos_registro: [
                {
                    label: 'Código de Cliente',
                    name: 'codigoCliente',
                    type: 'text'
                },
                {
                    label: 'Nombre:',
                    name: 'nombreCliente',
                    type: 'text'
                },
                {
                    label: 'Calle:',
                    name: 'calle',
                    type: 'text'
                },
                {
                    label: 'Población',
                    name: 'poblacion',
                    type: 'text'
                }
            ],
            campos_editar: [
                {
                    label: 'Código de Cliente',
                    name: 'codigoCliente',
                    type: 'text'
                },
                {
                    label: 'Nombre:',
                    name: 'nombreCliente',
                    type: 'text'
                },
                {
                    label: 'Calle:',
                    name: 'calle',
                    type: 'text'
                },
                {
                    label: 'Población',
                    name: 'poblacion',
                    type: 'text'
                },
                {
                    name: 'idDetalle',
                    type: 'hidden'
                }
            ],
            campos_eliminar: [{
                name: 'idEliminar',
                type: 'hidden'
            }]
        },
        methods: {
            refrescarTabla() {
                tablaClientes.ajax.reload();
            },
            modalRegistrar() {
                $('#modalRegistrar').modal('setting', 'closable', false).modal(
                    'show');
            },
            cargarDatos() {
                var id = $("#idDetalle").val();

                fetch("?1=ClienteController&2=cargarDatosCliente&id=" + id)
                    .then(response => {
                        return response.json();
                    })
                    .then(dat => {
                        $('#frmEditar input[name="codigoCliente"]').val(dat.codigo);
                        $('#frmEditar input[name="nombreCliente"]').val(dat.nombreCliente);
                        $('#frmEditar input[name="calle"]').val(dat.calle);
                        $('#frmEditar input[name="poblacion"]').val(dat.poblacion);
                    })
                    .catch(err => {
                        console.log(err);
                    });
            }
        }
    });
</script>

<script>
        $(document).on("click", ".btnEliminar", function () {
            $('#modalEliminar').modal('setting', 'closable', false).modal('show');
            $('#idEliminar').val($(this).attr("id"));
        });
        $(document).on("click", ".btnEditar", function () {
            $('#modalEditar').modal('setting', 'closable', false).modal('show');
            $('#idDetalle').val($(this).attr("id"));
            app.cargarDatos();
        });

</script>
