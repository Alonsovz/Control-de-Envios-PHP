<script src="./res/plugins/v-money.js"></script>

<style>
    .contenedor {
        width: 92vw;
    }
</style>
<?php
 $_SESSION['rol']=0;
if($_SESSION["descRol"]=="Administrador") {?>
<script>
    $(function() {
    overflowRestore();
});


 $(document).ready(function(){

    
    $('#modalEleccion').modal('setting', 'autofocus', false).modal('setting', 'closable', false).modal('show');
    // $('#btnSeleccionarUsuario').hide();
    });


      $(function ()
      {



      });  
</script>
<?php }?>


<script>
    var fecha;
    $(function() {
        fecha = new Date();
        fecha = fecha.getDate() + '/' + (fecha.getMonth() + 1) + '/' + fecha.getFullYear();

        $('#fecha-header').html('Fecha: ' + fecha);
    });
</script>

<div id="app">

    <div class="ui tiny modal" id="modalEleccion">

    <div class="header">
        <i class="paper plane icon"></i>Envío Deloitte<font color="#85BC22" style="font-size: 28px;">.</font>
    </div>
    <div class="content">
        <form class="ui form" id="frmEnvio">
            <div class="field">
                <label for="">A nombre de: </label>

                <!--select de usuario-->
                <select @change="seleccionarUsuario()" name="usuario" id="usuario" class="ui search dropdown">
                    <option v-for="option in usuarioOps" :value="option.codigoUsuario">{{option.nombre + ' ' + option.apellido }}</option>
                </select>
                
                </div>
        </form>
    </div>
    <div class="actions">
        <button class="ui black left button" type="button" onclick="location.href='?1=UsuarioController&2=dashboard'">
            Cancelar
        </button>
        <button class="ui blue right button" id="btnSeleccionarUsuario">
            Seleccionar Usuario
        </button>
    </div>
</div>

    <div class="ui grid">
        <div class="row">
            <div class="titulo">
                <i class="paper plane icon"></i>
                Envíos Deloitte<font color="#85BC22" style="font-size: 28px;">.</font>
                <?php
                if($_SESSION["descRol"]=="Administrador") {?>
                <center>A nombre de: <font color="#85BC22"><span id="nombreActual">{{usuarioActual}}</span></font>
                </center>

                <?php }?>
                <span style="float:right;">
                    <small>
                        <small id="fecha-header">Fecha</small>
                    </small>

                    <button @click="guardarEnvio" class="ui green-deloitte mini circular icon button"><i class="check icon"></i></button>
                    <button @click="agregarDetalle" class="ui primary mini circular icon button"><i class="plus icon"></i></button>
                </span>
            </div>
        </div>

        <div class="row ">
            <div class="sixteen wide column">
                <form action="" class="ui form" id="frmEnvios">
                    <table class="ui green very compact table">
                        <thead class="super-compact">
                            <tr>
                                <th class="two wide">Trámite</th>
                                <th class="four wide">Cliente</th>
                                <th class="two wide">Área</th>
                                <th class="two wide">Tipo Doc</th>
                                <th class="one wide">N° Doc</th>
                                <th class="two wide">Monto</th>
                                <th class="two wide">Observaciones</th>
                                <th class="one wide"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="(envio, index) in envios">
                                <td>
                                    <div class="ui mini input">
                                        <select class="ui search selection dropdown requerido" v-model="envio.tramite">
                                            <option v-for="tipo in tiposTramite" :value="tipo.codigoTipoTramite">{{tipo.descTipoTramite}}</option>
                                        </select>
                                    </div>
                                </td>
                                <td>
                                    <div class="ui mini input">
                                        <select v-model="envio.cliente" class="ui search selection dropdown" id="clientes" name="clientes">
                                            <option v-for="option in clientesOps" :value="option.codigoCliente">{{option.nombreCliente}}</option>
                                        </select>
                                    </div>
                                </td>
                                <td>
                                    <div class="ui mini input">
                                        <select v-model="envio.area" class="ui search selection dropdown" id="area" name="area">
                                            <option v-for="option in areaOps" :value="option.codigoArea">{{option.descArea}}</option>
                                        </select>
                                    </div>
                                </td>
                                <td>
                                    <div class="ui mini input">
                                        <select v-model="envio.tipoDocumento" class="ui search selection dropdown" id="documentos" name="documentos">
                                            <option v-for="option in tipoDocumentoOps" :value="option.codigoTipoDocumento">{{option.descTipoDocumento}}</option>
                                        </select>
                                    </div>
                                </td>
                                <td>
                                    <div class="ui mini input">
                                        <input class="requerido" v-model="envio.numDocumento" type="text">
                                    </div>
                                </td>
                                <td>
                                    <div class="ui mini input">
                                        <!-- <input class="requerido" mask="dinero" v-model="envio.monto" type="text"> -->
                                        <money v-model="envio.monto" v-bind="money" class="requerido"></money>
                                    </div>
                                </td>
                                <td>
                                    <div class="ui mini input">
                                        <input class="requerido" v-model="envio.observaciones" type="text">
                                    </div>
                                </td>
                                <td>
                                    <button type="button" @click="eliminarDetalle(index)" class="ui negative mini circular icon button"><i
                                            class="times icon"></i></button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    var app = new Vue({
        el: '#app',
        data: {
            envios: [{
                tramite: '1',
                cliente: '1',
                area: '1',
                tipoDocumento: '1',
                numDocumento: '',
                monto: '',
                observaciones: ''
            }],
            clientesOps: <?php echo $clientes?>,

            usuarioOps: <?php echo $usuariosCMB?>,

            areaOps: <?php echo $areas?>,

            tipoDocumentoOps: <?php echo $documentos?>,

            tiposTramite: <?php echo $tiposTramiteCMB?>,

            usuarioActual: '',

            money: {
                decimal: '.',
                thousands: ',',
                prefix: '$ ',
                suffix: '',
                precision: 2,
                masked: true
            },

            descRol: '<?php echo $_SESSION["descRol"];?>'

        },
        methods: {
            guardarEnvio() {

                if (this.envios.length) {

                    $('#frmEnvios').addClass('loading');
                    $.ajax({
                        type: 'POST',
                        data: {
                            detalles: JSON.stringify(this.envios)
                        },
                        url: '?1=EnvioController&2=registrarEnvio',
                        success: function (r) {
                            $('#frmEnvios').removeClass('loading');
                            if (r == 1) {
                                swal({
                                    title: 'Completado',
                                    type: 'success'
                                }).then((result) => {
                                    if (result.value) {
                                        app.envios = [{
                                            tramite: '1',
                                            cliente: '1',
                                            area: '1',
                                            tipoDocumento: '1',
                                            numDocumento: '',
                                            monto: '',
                                            observaciones: ''
                                        }];

                                        app.modalNuevoEnvio();
                                    }
                                });           
                            }
                            
                        }
                    });
                }

            },

            modalNuevoEnvio() {

                if(this.descRol == 'Administrador') {
                    $('#modalNuevoEnvio').modal('setting', 'autofocus', false).modal('setting', 'closable', false).modal('show');
                }

            },

            agregarDetalle() {
                this.envios.push({
                    tramite: '1',
                    cliente: '1',
                    area: '1',
                    tipoDocumento: '1',
                    numDocumento: '',
                    monto: '',
                    observaciones: ''
                });
            },
            eliminarDetalle(index) {
                this.envios.splice(index, 1);
            },

            seleccionarUsuario() {
                var select = document.getElementById('usuario');

                var selectedOption = select.options[select.selectedIndex];
                var nombre=selectedOption.text;
                this.usuarioActual = nombre;

            },

            usuarioInicial() {
                var select = document.getElementById('usuario');

                var selectedOption = select.options[0];
                var nombre=selectedOption.text;
                this.usuarioActual = nombre;
            }
        },

        mounted() {
            $('.ui.dropdown').dropdown();
            $('.ui.dropdown.selection').css('max-width', '100%');
            $('.ui.dropdown.selection').css('min-width', '100%');
            $('.ui.dropdown.selection').css('width', '100%');
            $('input[mask="dinero"]').mask('$0');

            this.usuarioInicial();
        },
        updated() {
            $('.ui.dropdown').dropdown();
            $('.ui.dropdown.selection').css('max-width', '100%');
            $('.ui.dropdown.selection').css('min-width', '100%');
            $('.ui.dropdown.selection').css('width', '100%');
            $('input[mask="dinero"]').mask('$0');
        }
    });
</script>

<script>
    $(function () {
        $("#btnSeleccionarUsuario").click(function () {

            var datos = $("#usuario").val();
            var rol = 1

            $.ajax({
                type: 'POST',
                url: '?1=EnvioController&2=setCodigo',
                data: {
                    datos: datos,
                    rol: rol
                },
                success: function (r) {
                    $('#modalEleccion').modal('hide');
                }
            });
        });
    });
</script>
        
<script>
     $(function () {
        $("#btnSi").click(function () {

            $('#modalEleccion').modal('setting', 'autofocus', false).modal('setting', 'closable', false).modal('show');
            // $('#nombreActual').html("");
           
        });

        $("#btnNo").click(function () {
            $('#nombreActual').html("");
            location.href="?1=UsuarioController&2=dashboard";
            
        });

    });
</script>



<div class="ui modal" id="modalNuevoEnvio">
  <div class="header">
    Envío
  </div>
  <div class="image content">
    <div class="description">
      <div class="ui header">¿Desea Realizar otro envio?</div>
    </div>
  </div>
  <div class="actions">
    <button class="ui black deny button" id="btnNo">
        No
    </button>
    <button class="ui green button" id="btnSi">
      Si
    </button>
  </div>
</div>