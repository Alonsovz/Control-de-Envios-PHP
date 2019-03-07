<style>
    body {
        overflow: hidden;
    }
</style>

<script>
$(function() {
    overflowRestore();
});
</script>

<body class="body-login">
    <div id="fondo-dot"></div>
    <div id="app">
        <div class="contenedor" style="margin-top:0; height: 100vh; background: none !important; display: flex;
        align-items: center;
        justify-content: center;">
            <div class="cuadro" style="min-width: 525px">
                <div class="cuadro-ins" style="margin-top: -12%;">
                    <img src="./res/img/deloitteNigga.svg" alt="" id="logo-login">
                </div>
                <form id="frmLogin" method="POST" class="ui form">


                    <div class="two fields">
                        <div class="field">
                            <label for="">Nombre:</label>
                            <input type="text" class="requerido letras" name="nombre" id="nombre">
                            
                        </div>
                        <div class="field">
                            <label for="">Apellido:</label> 
                            <input type="text" class="requerido letras" name="apellido" id="apellido">

                        </div>
                    </div>
                    <div class="field">
                        <label for="">Nombre de Usuario Deloitte:</label>
                        <input type="text" class="requerido" v-model="nomUsuario" name="user" id="user">
                        <div class="ui pointing red basic label" id="msg">
                            El Usuario ya existe
                        </div>
                    </div>

                    <div class="field">
                        <label for="">E-mail:</label>
                        <input type="text" class="requerido" :value="correoUsuario" readonly name="correo" id="correo">

                    </div>
                    <div class="field">
                        <label for="">Área:</label>
                        <select name="area" id="area" class="ui dropdown">

                        </select>

                    </div>
                    <div class="two fields">
                        <div class="field">
                            <label for="">Contraseña:</label>
                            <div class="ui right labeled input">
                                <input type="password" class="requerido" name="pass" id="pass">
                                <div id="show-contra" class="ui basic label show-contra"><i style="margin: 0;" id="icon-contra" class="eye slash icon"></i></div>
                            </div>

                        </div>
                        <div class="field">
                            <label for="">Confirmar Contraseña:</label>
                            <div class="ui right labeled input">
                                <input type="password" class="requerido" name="confPass" id="confPass">
                                <div id="show-contra" class="ui basic label show-contra"><i style="margin: 0;" id="icon-contra" class="eye slash icon"></i></div>
                            </div>

                        </div>
                    </div>
                    <a id="label-error" style="margin: 0; display:none; text-align:center;" class="ui red fluid large label">
                        
                    </a>
                    <button style="margin-top: 15px;" class="ui green-deloitte fluid button" name="btnLogin" value="login" id="btnLogin" type="button"
                        @submit.prevent="">Registrarse</button>

                </form>
                <div style="text-align:center; margin-top:15px;" class="field">
                    <a href="?" class="ui bottom attached label">¿Ya posee una cuenta? Inicie Sesión</a>
                </div>
            </div>
        </div>
    </div>

    <script>
        $(function () {
            $('#nombre').focus();
            $('#msg').hide();
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

    <script>
        $(function() {
            $('#antPass').keyup(function() {
                $('#label-error').css('display', 'none');
            });
            $('#user').keyup(function(){
                $('#msg').hide();;
            });
        });
    </script>

    <script>
        $(function() {
            $('#btnLogin').click(function() {

                if(validarVacios('frmLogin', '#btnLogin') == 0)
                {
                    if($('#pass').val() != $('#confPass').val()) {

                        $('#label-error').html('Las contraseñas no concuerdan');
                        $('#label-error').css('display', 'inline-block');

                    } else {

                        $('#label-error').css('display', 'none');
                        $('#label-error').html('');
                        var gatos = {};
                        $('#frmLogin').addClass('loading');

                        $('#frmLogin').find(":input").each(function () {
                            gatos[this.name] = $(this).val();
                        });

                        gatos = JSON.stringify(gatos);

                        $.ajax({
                            type: 'POST',
                            url: '?1=UsuarioController&2=registrar',
                            data: {datos: gatos},
                            success: function(r) {
                                $('#frmLogin').removeClass('loading');
                                if(r == 1) {
                                    swal({
                                        title: 'Registrado',
                                        text: 'Se le notificará por correo cuando su cuenta sea autorizada',
                                        type: 'success'
                                    }).then((result) => {
                                        if (result.value) {
                                            location.href = '?';
                                        }
                                    });     
                                } 
                            }
                        });
                    }

                } else {
                    $('#label-error').html('Complete todos los campos');
                    $('#label-error').css('display', 'inline-block');
                }
                
            });
        });
    </script>
   
    <script>
        $(function() {
            var option = '';
            var areas = '<?php echo $areas?>';

            $.each(JSON.parse(areas), function() {
                option = `<option value="${this.codigoArea}">${this.descArea}</option>`;

                $('#area').append(option);
            });
        });
    </script>

    <script>
    let app = new Vue({
        el: '#app',

        data: {
            nomUsuario: '',
            sufix: '@deloitte.com',
            correo: ''
        },
        computed: {
            correoUsuario() {
                return this.nomUsuario + this.sufix;
            }
        }
    });
    
    </script>

    <script>
            //Comprobar que el usuario Deloite no exista

        $("#user").change(function(){
        
        var user=$("#user").val();

            $.ajax({
               type: 'POST',
               url: '?1=UsuarioController&2=getUserName',
               data:{user},
               success: function(r) {

                    if(r==1)
                    {
                        $("#msg").show();
                        $("#btnLogin").attr("disabled", true);

                    }    
                    else{

                          $("#btnLogin").attr("disabled", false);
                    }  
               }
           });

       

    });

    $("#user").keyup(function(){

        $("#btnLogin").attr("disabled", false);
    });
    </script>

</body>