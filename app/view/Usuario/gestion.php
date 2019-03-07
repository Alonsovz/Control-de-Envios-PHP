<script>
    console.log(<?php echo $areasDeloitte;?>)
</script>
<div id="app">

    <modal-registrar id_form="frmRegistrar" id="modalRegistrar" url="?1=UsuarioController&2=registrar" titulo="Registrar Usuario"
        :campos="campos_registro" tamanio='tiny'></modal-registrar>

    <modal-editar id_form="frmEditar" id="modalEditar" url="?1=UsuarioController&2=editar" titulo="Editar Usuario"
        :campos="campos_editar" tamanio='tiny'></modal-editar>

    <modal-eliminar id_form="frmEliminar" id="modalEliminar" url="?1=UsuarioController&2=eliminar" titulo="Eliminar Usuario"
        sub_titulo="¿Está seguro de querer eliminar este usuario?" :campos="campos_eliminar" tamanio='tiny'></modal-eliminar>

    <div class="ui tiny modal" id="modalAutorizar">

        <div class="header">
            Autorizar Usuario
        </div>
        <div class="content">      
            <form action="" class="ui equal width form" id="frmAutorizar">
                <div class="fields">
                    <div  class="field">
                        <label for="">Estado:</label>
                        <select class="ui dropdown" name="idEstado" id="idEstado">
                            <option value="1">Autorizado</option>
                            <option value="3">Restringido</option>
                        </select>
                    </div>
                    <input type="hidden" id="idAutorizar" name="idAutorizar">
                </div>
            </form> 
        </div>

        <div class="actions">
            <button class="ui black deny button">
                Cancelar
            </button>
            <button id="btnAutorizar" class="ui right yellow button">
                Cambiar Estado
            </button>
        </div>
    </div>




    <div class="ui grid">
        <div class="row">
            <div class="titulo">
            <i class="users icon"></i>
                Usuarios Deloitte<font color="#85BC22" style="font-size: 28px;">.</font>
            </div>
        </div>
        <div class="row title-bar">
            <div class="sixteen wide column">
                <button class="ui right floated positive labeled icon button" @click="modalRegistrar" id="btnModalRegistro">
                    <i class="plus icon"></i>
                    Registrar
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
                <table id="dtUsuarios" class="ui selectable very compact celled table" style="width:100%; margin:auto;">
                    <thead>
                        <tr>
                            <th>N°</th>
                            <th>Nombres</th>
                            <th>Apellido</th>
                            <th>Usuario</th>
                            <th>Email</th>
                            <th>Área</th>
                            <th>Rol</th>
                            <th>Autorización</th>
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

<script src="./res/tablas/tablaUsuarios.js"></script>
<script src="./res/js/modalRegistrar.js"></script>
<script src="./res/js/modalEditar.js"></script>
<script src="./res/js/modalEliminar.js"></script>

<script>
var app = new Vue({
        el: "#app",
        data: {
            campos_registro: [{
                    label: 'Nombre:',
                    name: 'nombre',
                    type: 'text'
                },
                {
                    label: 'Apellido:',
                    name: 'apellido',
                    type: 'text'
                },
                {
                    label: 'Nombre de Usuario Deloitte:',
                    name: 'user',
                    type: 'text',
                    id: 'usuario'
                },
                {
                    label: 'Correo Electrónico:',
                    name: 'correo',
                    mask: 'correoElectronico',
                    type: 'text'
                },
                {
                    label: 'Contraseña:',
                    name: 'pass',
                    type: 'password'
                },
                {
                    label: 'Área:',
                    name: 'area',
                    type: 'select',
                    options: <?php echo $areasDeloitte;?>
                },
                {
                    label: 'Rol:',
                    name: 'rol',
                    type: 'select',
                    options: [
                        {
                            val: 2,
                            text: 'Solicitante'
                        },
                        {
                            val: 1,
                            text: 'Administrador'
                        },
                    ]
                }
            ],
            campos_editar: [
                {
                    label: 'Nombre:',
                    name: 'nombre',
                    type: 'text'
                },
                {
                    label: 'Apellido:',
                    name: 'apellido',
                    type: 'text'
                },
                {
                    label: 'Nombre de Usuario Deloitte:',
                    name: 'user',
                    type: 'text'
                },
                {
                    label: 'Correo Electrónico:',
                    name: 'correo',
                    mask: 'correoElectronico',
                    type: 'text'
                },
                {
                    label: 'Área:',
                    name: 'area',
                    type: 'select',
                    options:<?php echo $areasDeloitte;?>
                },
                {
                    label: 'Rol:',
                    name: 'rol',
                    type: 'select',
                    options: [
                        {
                            val: 2,
                            text: 'Solicitante'
                        },{
                            val: 1,
                            text: 'Administrador'
                        }
                    ]
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
                tablaUsuarios.ajax.reload();
            },
            modalRegistrar() {
                $('#modalRegistrar').modal('setting', 'closable', false).modal(
                    'show');
            },
            cargarDatos() {
                var id = $("#idDetalle").val();

                fetch("?1=UsuarioController&2=cargarDatosUsuario&id=" + id)
                    .then(response => {
                        return response.json();
                    })
                    .then(dat => {

                        console.log(dat);

                        // $('#frmEditar input[name="idDetalle"]').val(dat.codigoUsuari);
                        $('#frmEditar input[name="nombre"]').val(dat.nombre);
                        $('#frmEditar input[name="apellido"]').val(dat.apellido);
                        $('#frmEditar input[name="user"]').val(dat.nomUsuario);
                        $('#frmEditar input[name="correo"]').val(dat.email);
                        $('#frmEditar select[name="rol"]').dropdown('set selected', dat.codigoRol);
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

        $(document).on("click", ".btnAutorizar", function () {
            $('#modalAutorizar').modal('setting', 'autofocus', false).modal('setting', 'closable', false).modal('show');
            $('#idAutorizar').val($(this).attr("id"));
        });
</script>


<script>
    $(function() {
        $('#btnAutorizar').click(function() {

            $('#frmAutorizar').addClass('loading');

            var idUsuario = $('#idAutorizar').val();
            var idEstado = $('#idEstado').val();

           $.ajax({
               type: 'POST',
               url: '?1=UsuarioController&2=autorizar',
               data: {
                   id: idUsuario, 
                   estado: idEstado
               },
               success: function(r) {
                $('#frmAutorizar').removeClass('loading');
                   if(r == 1) {
                    swal({
                            title: 'Autorizado',
                            text: 'Los cambios han sido guardados',
                            type: 'success',
                            showConfirmButton: false,
                            timer: 1500
                        });
                        $('#modalAutorizar').modal('hide');
                        app.refrescarTabla();
                   }
               }
           });
        });
    });


    $("#usuario").change(function(){

       var user=$("#usuario").val();

            $.ajax({
            type: 'POST',
            url: '?1=UsuarioController&2=getUserName',
            data:{user},
            success: function(r) {

                    if(r==1)
                    {
                        
                        $("#btnRegistrar").attr("disabled", true);
                        $("#usuario").siblings('div.ui.red.pointing.label').html('El usuario ya existe!')
                        $("#usuario").siblings('div.ui.red.pointing.label').css('display', 'inline-block');
                    }    
                    else{

                        $("#btnRegistrar").attr("disabled", false);
                    }  
            }
                });

    });

    $("#usuario").keyup(function(){

        $("#btnRegistrar").attr("disabled", false);
    });




</script>
     