<div id="sidebar" class="ui sidebar inverted vertical menu">
    <a class="header item" id="titulo-menu">
        <b>Men&uacute;</b>
    </a>

    <?php

        if($_SESSION["descRol"] == 'Administrador') {
            require_once 'menuAdmin.php';
        } else {
            require_once 'menuSolicitante.php';
        }

    ?>

</div>

<div class="pusher">
    <div class="contenedor">