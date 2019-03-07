
<?php 
     $id=$_SESSION['codigoUsuario'];

?>
<script>
    $(document).ready(function() {
        // $('#nomUser').val(<?php echo "'".$_SESSION['nomUsuario']."'"; ?>);
        // $('#nom').val(<?php echo "'".$_SESSION['nombre']."'"; ?>);
        // $('#ape').val(<?php echo "'".$_SESSION['apellido']."'"; ?>);

    });
</script>

<!-- <input type="hidden" id="idUser" name="idUser" value=<?php echo '"'.$_SESSION['idUsuario'].'"'; ?> -->

<!-- modal de registro -->
<div class="ui tiny modal" id="modalCambiarNomUser">

    <div class="header">
    <i class="user icon"></i> Mi usuario Deloitte<font color="#85BC22" style="font-size: 28px;">.</font>
    </div>
    <div class="content">
        <form class="ui form" id="frmCambiarNomUser">
            <div class="field">
                <label for="">Nombre de Usuario:</label>
                <input class="reqRegistrar" type="text" name="nomUser" id="nomUser" value=<?php echo '"'.$_SESSION['nomUsuario'].'"'; ?>>
                <div class="ui red pointing label" style="display: none;">
                </div>
            </div>
        </form>
    </div>
    <div class="actions">
        <button class="ui black deny button" id="btnCancelarRegistrar">
            Cancelar
        </button>
        <button class="ui blue right button" id="btnGuardarNomUser">
            Guardar Cambios
        </button>
    </div>
</div>


<!-- modal de registro -->
<div class="ui tiny modal" id="modalCambiarNom">

    <div class="header">
    <i class="street view icon"></i> Datos Personales
    </div>
    <div class="content">
        <form class="ui form" id="frmCambiarNom">
            <div class="two fields">
                <div class="field">
                    <label for="">Nombres:</label>
                    <input class="reqRegistrar letras" type="text" name="nom" id="nom" value=<?php echo '"'.$_SESSION['nombre'].'"'; ?>>
                    <div class="ui red pointing label" style="display: none;">
                    </div>
                </div>
                <div class="field">
                    <label for="">Apellidos:</label>
                    <input class="reqRegistrar letras" type="text" name="ape" id="ape" value=<?php echo '"'.$_SESSION['apellido'].'"'; ?>>
                    <div class="ui red pointing label" style="display: none;">
                    </div>
                </div>
            </div>
        </form>
    </div>
    <div class="actions">
        <button class="ui black deny button" id="btnCancelarRegistrar">
            Cancelar
        </button>
        <button class="ui blue right button" id="btnGuardarNom">
            Guardar Cambios
        </button>
    </div>
</div>

<!-- modal de registro -->
<div class="ui tiny modal" id="modalCambiarContra">

    <div class="header">
    <i class="cogs icon"></i> Cambiar Contraseña
    </div>
    <div class="content">
        <form class="ui form" id="frmCambiarContra">
            
                <label for="">Contraseña Actual:</label>
                <div class="two fields">
                <input type="password" name="antPass" id="antPass" class="requerido">
                <div id="show-contra" class="ui basic label show-contra"><i style="margin: 0;" id="icon-contra" class="eye slash icon"></i></div>
                <a id="label-error" style="display: none; margin: 0; text-align:center;" class="ui red fluid large label">Datos
                        Incorrectos</a>
                <div class="ui red pointing label" style="display: none;">
                </div>
            </div>
                <label for="">Nueva Contraseña:</label>
                <div class="two fields">
                <input  type="password" name="nuPass" id="nuPass" class="requerido">
                <div id="show-contra" class="ui basic label show-contra"><i style="margin: 0;" id="icon-contra" class="eye slash icon"></i></div>
                <div class="ui red pointing label" style="display: none;">
                </div>
            </div>
        </form>
    </div>
    <div class="actions">
        <button class="ui black deny button" id="btnCancelarModificar">
            Cancelar
        </button>
        <button class="ui blue right button" id="btnGuardarContra">
            Guardar Cambios
        </button>
    </div>
</div>

<!-- modal de registro -->
<div class="ui tiny modal" id="modalEliminarCuenta">

    <div class="header">
       <i class="trash icon"></i> Eliminar cuenta Deloitte<font color="#85BC22" style="font-size: 28px;">.</font>
    </div>
    <div class="content">
        <form class="ui form" id="frmEliminarCuenta">
            
                <label for="">Ingrese su <code style="padding: 0px 3px; background: rgba(255, 0, 0, .1); color: rgba(255, 0, 0, 0.8); border-radius: 2px;">contraseña</code> para confirmar:</label>
                <div class="two fields">
                <input class="requerido" type="password" name="Pass" id="Pass">
                <div id="show-contra" class="ui basic label show-contra"><i style="margin: 0;" id="icon-contra" class="eye slash icon"></i></div>
                <div class="ui red pointing label" style="display: none;">
                </div>
            </div>
        </form>
    </div>
    <div class="actions">
        <button class="ui black deny button" id="btnCancelarEliminar">
            Cancelar
        </button>
        <button class="ui red right button" id="btnConfEliminarCuenta">
            Eliminar Cuenta
        </button>
    </div>
</div>

        <div class="ui grid">
            <div class="row">
                <div class="sixteen wide column">
                    <div class="barra-titulo">
                        <p class="texto-barra-titulo">
                        <h1>
                            <i class="user icon"></i>
                            Configuración de cuenta
                        </h1>
                        <hr>
                        </p>
                    </div>
                </div>
            </div>

            <div class="row">
        
                <div class="eight wide column">
                    <h3 class="ui header"><font color=""><i class="user outline icon"></font></i>Usuario Deloitte<font color="#85BC22" style="font-size: 28px;">.</font></h3>
                    <h4><?php echo '<p class="user-info">'.$_SESSION['nomUsuario'].'</p>' ?></h4>
                    <div class="ui divider"></div>
                    <h3 class="ui header">  <i class="street view  icon"></i>Nombre Completo.</h3>
                    <h4><?php echo '<p class="user-info">'.$_SESSION['nombre'].' '.$_SESSION['apellido'].'</p>' ?></h4>
                    <div class="ui divider"></div>
                    <h3 class="ui header">  <i class="cog icon"></i>Permisos de la cuenta.</h3>
                    <h4><?php echo '<p class="user-info">'.$_SESSION['descRol'].'</p>' ?></h4>
                </div>

                 <div class="four wide column right floated">
                <center><h3><i class="cogs icon"></i> Opciones de configuración.</h3></center>
                    <div class="ui list">
                        <div class="item">
                            <button class="ui right floated fluid green-deloitte  button" id="btnCambiarNom" type="button"><i class="street view icon"></i>Datos Personales</button>
                        </div>
                        <div class="item">
                            <button class="ui right floated fluid green-deloitte button" id="btnCambiarContra" type="button"><i class="lock icon"></i>Modificar contraseña</button>
                        </div>
                    </div>
                </div>

            </div>

        </div>
        <script>
        $(function () {
            $('#antPass').keyup(function () {
                $('#label-error').css('display', 'none');
            });
        });
    </script>
<script>
 $(document).on("click", "#btnCambiarNom", function () {
            $('#modalCambiarNom').modal('setting', 'autofocus', false).modal('setting', 'closable', false).modal('show');
        });
        
        $(document).on("click", "#btnCambiarContra", function () {
            $('#modalCambiarContra').modal('setting', 'autofocus', false).modal('setting', 'closable', false).modal('show');
        });

        $(function() {
        $('#btnGuardarNom').click(function() {
            var idU=<?php echo $id ?>;
            var nombreUser = $('#nom').val();
            var apeUser = $('#ape').val();

           $.ajax({
               type: 'POST',
               url: '?1=UsuarioController&2=actualizarDatosPersonales',
               data: {
                   id: idU,
                   nom: nombreUser,
                   ape:apeUser
               },
               success: function(r) {
                $('#frmCambiarNom').removeClass('loading');
                   if(r == 1) {
                    swal({
                            title: 'Cambios realizados',
                            text: 'Para verificar sus cambios deberá iniciar sesión nuevamente',
                            type: 'success',
                            showConfirmButton: true
                        }).then((result) => {
                                        if (result.value) {
                                            location.href = '?';
                                        }
                                    }); 
                        
                        $('#modalCambiarNom').modal('hide');

                   }
               }
           });
        });
    });


    // Metodo para comprobar que la contraseña exista
    $("#antPass").change(function(){
        var idU=<?php echo $id ?>;
        var pass=$("#antPass").val();

            $.ajax({
               type: 'POST',
               url: '?1=UsuarioController&2=getPass',
               data:{idU,pass},
               success: function(r) {

                        var data=JSON.parse(r);
                        if(data['pass']!=data['passEnc'])
                        {
                            
                            $('#btnGuardarContra').hide();
                            $('#label-error').css('display','block');
                        }
                        else
                        {
                            $('#btnGuardarContra').show();
                           
                        }
               }
           });

       

    });

    



    $(function() {
        $('#btnGuardarContra').click(function() {

            if(validarVacios('frmCambiarContra') == 0) {
                var idU=<?php echo $id ?>;
                var contraAnterior = $('#antPass').val();
                var contraNueva = $('#nuPass').val();

                $.ajax({
                    type: 'POST',
                    url: '?1=UsuarioController&2=reestablecerContra',
                    data: {
                        id: idU,
                        nuPass: contraNueva,
                    },
                    success: function(r) {
                        $('#frmCambiarContra').removeClass('loading');
                        if(r == 1) {
                            swal({
                                title: 'Cambios realizados',
                                text: 'Al iniciar sesión nuevamente debe utilizar su nueva contraseña',
                                type: 'success',
                                showConfirmButton: true
                            });

                            $('#modalCambiarContra').modal('hide');

                        }else{
                            $('#label-error').html('Datos Incorrectos');
                            $('#label-error').css('display', 'inline-block');
                        }
                    }
                });
            }

        });
    });


    $("#btnCancelarModificar").click(function(){

            resetFrm('frmCambiarContra');
             $('#label-error').css('display', 'none');
             $('#antPass').val("");
             $('#nuPass').val("");
             $('#btnGuardarContra').show();

    });


</script>
 <script>
        $(function () {
            $('.show-contra').mousedown(function () {
                $(this).children().attr('class', 'eye icon');
                $(this).siblings('input.requerido').attr('type', 'text');
            });


            $('.show-contra').mouseup(function () {
                $(this).children().attr('class', 'eye slash icon');
                $(this).siblings('input.requerido').attr('type', 'password');
            });

        });
    </script>

    