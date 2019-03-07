<div class="ui top fixed menu borderless" id="barra">
    <a class="item" id="btn-menu">
        <i class="material-icons">menu</i>
    </a>
    <a class="item" href="?1=UsuarioController&2=dashboard">
        <i class="material-icons">home</i>
    </a>
    <a class="item" id="logo-header">
        <img src="./res/img/deloitteNigga.svg" alt="" width="" class="logo" id="">
    </a>

    <!-- <div style="margin-right:10px;" id="notif" class="ui floated right dropdown tug floating item">
        <i class="bell icon"></i>

        <div class="menu">
            <div class="header">
                Notificaciones
                <div class="ui floated right tiny active inline loader"></div>
            </div>

            <div class="divider"></div>
            <div id="notificaciones-header">
                <a href="">
                    <div class="item">
                        <i class="certificate icon"></i>
                        Notificación 1
                    </div>
                </a>
                <a href="">
                    <div class="item">
                        <i class="certificate icon"></i>
                        Notificación 2
                    </div>
                </a>
            </div>
        </div>
         <a class="ui bottom right attached green-deloitte label">1</a>
    </div>
     -->

    <div style="margin-right:20px;" id="usuario-header" class="ui floated right dropdown tug floating item">
        <img class="ui avatar image" src="./res/img/userDef.png"> &nbsp;&nbsp; <?php echo $_SESSION["nomUsuario"] ?>
        <i class="dropdown icon"></i>
        <div class="menu">
            <div class="header">
                <?php echo $_SESSION["descRol"] ?>
            </div>
            <div class="divider"></div>
            <a href="?1=UsuarioController&2=config">
                <div class="item" id="#btnConf">
                    <i class="cog icon"></i>
                    Cuenta
                </div>
            </a>
            <a href="?1=UsuarioController&2=logout">
                <div style="color:#c0392b;" class="item">
                    <i class="power icon"></i>
                    Cerrar Sesi&oacute;n
                </div>
            </a>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        $('.ui.dropdown')
            .dropdown();
    });
</script>

<script>
    /* var socket = io.connect("http://localhost:3008");

    socket.on("new_order", function(data) {
        console.log(data);
    }); */
</script>