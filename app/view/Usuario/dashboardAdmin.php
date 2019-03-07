<?php
            $fechaMaxima = date('Y-m-d');
            $fechaMax = strtotime ( '-0 day' , strtotime ( $fechaMaxima ) ) ;
            $fechaMax = date ( 'Y-m-d' , $fechaMax );

            $fechaMinima = date('Y-m-d');
            $fechaMin = strtotime ( '-1 day' , strtotime ( $fechaMinima ) ) ;
            $fechaMin = date ( 'Y-m-d' , $fechaMin );
?>

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
<div class="row tiles" id="contenedor-tiles" style="display: flex !important; align-items: baseline; justify-content: space-between">

    <a href="?1=EnvioController&2=nuevoEnvio"  style="width: 24%;" class="tiles-tiles ui green inverted segment">
        <h3>Nuevo Envío</h3>
        <div class="ui divider"></div>
        <i class="paper plane icon"></i>
    </a>

    <a href="?1=EnvioController&2=controlEnvios" style="width: 24%;"  class="tiles-tiles ui blue inverted segment">
        <h3>Control de Envíos</h3>
        <div class="ui divider"></div>
        <i class="box icon"></i>
    </a>

    <a href="?1=EnvioController&2=misEnvios" style="width: 24%;"  class="tiles-tiles ui orange inverted segment">
        <h3>Mis Envíos</h3>
        <div class="ui divider"></div>
        <i class="envelope icon"></i>
    </a>

   <a style="width: 24%;" id="btnReportes"  class="tiles-tiles ui teal inverted segment">
        <h3>Reportes</h3>
        <div class="ui divider"></div>
        <i class="save icon"></i>
    </a>
</div>
<div id="app">
<!-- modal para reportes-->
<div class="ui tiny modal" id="modalReportes" style="width:40%;">

    <div class="header">
       <i class="clipboard outline icon"></i> Reportes Deloitte<font color="#85BC22" style="font-size: 28px;">.</font>
    </div><br>
    <div class="content">
        <div class="ui form">
          <div class="field">
            <a href="?1=EnvioController&2=llamaReporte" class="ui green fluid button" id="btnReportes" target="_blank">
              <i class="calendar icon"></i>Reporte Diario General
            </a>
          </div>
          <div class="field">
            <a href="?1=EnvioController&2=reporteRecibidos" class="ui blue fluid button" id="btnReportes" target="_blank">
              <i class="shipping fast icon"></i>Documentos para Mensajeros
            </a>
          </div>
        </div>
    </div>
    <br>
    <div class="ui divider"></div>

    <div class="content">
        <h3>Otros reportes</h3><div class="ui divider"></div>
            <center>
                <h4>
                <button type="button" class="ui blue deny button" id="btnAreas">
                    Por Áreas
                </button>
                <button type="button" class="ui teal right button" id="btnUsuarios">
                    Por Usuario
                </button>
                <button type="button" class="ui violet right button" id="btnFechas">
                    Por Fechas
                </button>
                <!-- <button class="ui grey right button" id="btnxEstado">
                    Por Estado
                </button> -->


            <br><br>
            <!-- <div id="paramEstados">
                <div class="ui form">
                    <div class="field">
                        <select name="cmbEstado" id="cmbEstado">
                            <option value="1">Pendiente de Revisión</option>
                            <option value="2"></option>
                            <option value="3"></option>
                            <option value="4"></option>
                            <option value="5"></option>
                        </select>
                    </div>
                </div>
            </div> -->
                     <div id="fechas">
                        <div class="two fields">
                            <h5><label for="" style="width:100%; margin: auto;" id="labFechaInicio"><i class="calendar icon">
                            </i>Fecha inicial:</label>
                                    <input type="date" name="fechaIncial" id="fecha1fecha" required max=<?php echo $fechaMin;?>>
                            <label for="" style="width:100%;margin: auto;text-align: center;" id="labFechaFinal"><i class="calendar icon"></i>Fecha final:</label>
                                     <input type="date" name="fechaFinal" id="fecha2fecha" required max=<?php echo $fechaMax;?>></h5>
                            <button type="button" class="ui green right button" id="btnGenerarReporteFecha">
                                Generar reporte
                            </button>

                        </div>
                    </div>
                    <div id="cmbArea">
                        <h4><label for="">Seleccione el área: </label>

                        <!--select de areas-->
                        <select name="area" id="area" class="ui search dropdown" style="margin: auto; width: 60%;">
                        </select>
                        </h4>

                        <div class="ui form" style="margin: auto; display: flex; justify-content:center;">
                            <div class="inline fields">
                            <div class="field">
                                    <div class="">
                                        <label style="color:red;"><b>Opciones:</b></label>
                                    </div>
                                </div>
                                <div class="field">
                                    <div class="ui radio checkbox">
                                        <input type="radio" name="opcion" id="historialA" tabindex="0" value="historialA">
                                        <label>Historial</label>
                                    </div>
                                </div>
                                <div class="field">
                                    <div class="ui radio checkbox">
                                        <input type="radio" name="opcion" id="diarioA" tabindex="0" value="diarioA">
                                        <label>Diario</label>
                                    </div>
                                </div>
                                <div class="field">
                                    <div class="ui radio checkbox">
                                        <input type="radio" name="opcion" id="porfechasA" tabindex="0" value="porfechasA">
                                        <label>Por Fechas</label>
                                    </div>
                                </div>

                            </div>

                         </div>

                        <button type="button" class="ui teal right button" id="btnGenerarReporteAreaHistorial">
                            Generar reporte
                        </button>

                        <button type="button" class="ui red right button" id="btnGenerarReporteAreaDiario">
                            Generar reporte
                        </button>

                         <div class="two fields" id="fechasArea">
                            <h5><label for="" style="width:100%; margin: auto;" id="labFechaInicio"><i class="calendar icon">
                            </i>Fecha inicial:</label>
                                    <input type="date" name="fecha1Area" id="fecha1Area" required max=<?php echo $fechaMin;?>>
                            <label for="" style="width:100%;margin: auto;text-align: center;" id="labFechaFinal"><i class="calendar icon"></i>Fecha final:</label>
                                     <input type="date" name="fecha2Area" id="fecha2Area" required max=<?php echo $fechaMax;?>></h5>

                        </div><br>
                        <button type="button" class="ui green right button" id="btnGenerarReporteAreaPorFechas">
                            Generar reporte
                        </button>


                    </div>
            <div id="cmbUsuario">
                <h4> <label for="">Seleccione el usuario: </label>

                  <!--select de areas-->
                  <select name="usuario" id="usuario" class="ui search dropdown">
                    </select></h4>
                    <div class="ui form" style="margin: auto; display: flex; justify-content:center;">
                            <div class="inline fields">
                            <div class="field">
                                    <div class="">
                                        <label style="color:red;"><b>Opciones:</b></label>
                                    </div>
                                </div>
                                <div class="field">
                                    <div class="ui radio checkbox">
                                        <input type="radio" name="opcion1" id="historialU" tabindex="0" value="historialU">
                                        <label>Historial</label>
                                    </div>
                                </div>
                                <div class="field">
                                    <div class="ui radio checkbox">
                                        <input type="radio" name="opcion1" id="diarioU" tabindex="0" value="diarioU">
                                        <label>Diario</label>
                                    </div>
                                </div>
                                <div class="field">
                                    <div class="ui radio checkbox">
                                        <input type="radio" name="opcion1" id="porfechasU" tabindex="0" value="porfechasU">
                                        <label>Por Fechas</label>
                                    </div>
                                </div>

                            </div>
                        </div>
                        <button type="button" class="ui teal right button" id="btnGenerarReporteUsuarioHistorial">
                            Generar reporte
                        </button>

                        <button type="button" class="ui red right button" id="btnGenerarReporteUsuarioDiario">
                            Generar reporte
                        </button>

                         <div class="two fields" id="fechasUsuario">
                            <h5><label for="" style="width:100%; margin: auto;" id="labFechaInicio"><i class="calendar icon">
                            </i>Fecha inicial:</label>
                                    <input type="date" name="fecha1Usuario" id="fecha1Usuario" required max=<?php echo $fechaMin;?>>
                            <label for="" style="width:100%;margin: auto;text-align: center;" id="labFechaFinal"><i class="calendar icon"></i>Fecha final:</label>
                                     <input type="date" name="fecha2Usuario" id="fecha2Usuario" required max=<?php echo $fechaMax;?>></h5>

                        </div><br>
                        <button type="button" class="ui green right button" id="btnGenerarReporteUsuarioPorFechas">
                            Generar reporte
                        </button>
                        </div>
        </center>
    </div>
    <div class="actions">
        <button type="button" class="ui black deny button" id="btnCancelar">
            Cancelar
        </button>
    </div>
</div>
</div>



 <script>
    $(document).ready(function(){
        $('#fechas').hide();
        $('#cmbUsuario').hide();
        $('#cmbArea').hide();
        $('#btnGenerarReporteAreaHistorial').hide();
        $('#btnGenerarReporteAreaDiario').hide();
        $('#btnGenerarReporteAreaPorFechas').hide();
        $('#btnGenerarReporteUsuarioPorFechas').hide();
        $('#btnGenerarReporteUsuarioHistorial').hide();
        $('#btnGenerarReporteUsuarioDiario').hide();
        $('#fechasArea').hide();
        $('#fechasUsuario').hide();
    });

        $(document).on("click", "#btnAreas", function () {
            $('#fechas').hide();
            $('#cmbUsuario').hide();
            $('#cmbEstado').hide();
            $('#cmbArea').show();
        });
        $(document).on("click", "#btnFechas", function () {
            $('#cmbUsuario').hide();
            $('#cmbArea').hide();
            $('#cmbEstado').hide();
            $('#fechas').show();
        });
        $(document).on("click", "#btnUsuarios", function () {
            $('#cmbArea').hide();
            $('#fechas').hide();
            $('#cmbEstado').hide();
            $('#cmbUsuario').show();
        });
        $('#btxEstado').click(function() {
            $('#cmbArea').hide();
            $('#fechas').hide();
            $('#cmbUsuario').hide();
            $('#cmbEstado').show();
        });
</script>
<script>

        $(document).on("click", "#historialA", function () {
            $('#btnGenerarReporteAreaHistorial').show();
            $('#btnGenerarReporteAreaDiario').hide();
            $('#btnGenerarReporteAreaPorFechas').hide();
            $('#fechasArea').hide();


            $(document).on("click", "#btnGenerarReporteAreaHistorial", function () {
                var idU = $('#area').val();
                window.open('?1=UsuarioController&2=reporteArea&area='+idU,'_blank');
            });
        });

        $(document).on("click", "#diarioA", function () {
            $('#btnGenerarReporteAreaHistorial').hide();
            $('#btnGenerarReporteAreaDiario').show();
            $('#btnGenerarReporteAreaPorFechas').hide();
            $('#fechasArea').hide();

            $(document).on("click", "#btnGenerarReporteAreaDiario", function () {
                var idU = $('#area').val();
                window.open('?1=UsuarioController&2=reporteAreaDiario&area='+idU,'_blank');
            });
        });

        $(document).on("click", "#porfechasA", function () {
                $('#btnGenerarReporteAreaHistorial').hide();
                $('#btnGenerarReporteAreaDiario').hide();
                $('#btnGenerarReporteAreaPorFechas').show();
                $('#fechasArea').show();

                $(document).on("click", "#btnGenerarReporteAreaPorFechas", function () {
                    var idU = $('#area').val();
                    var fecha = $('#fecha1Area').val();
                    var fecha2 = $('#fecha2Area').val();
            window.open('?1=UsuarioController&2=reporteAreaPorFechas&area='+idU+'&fecha='+fecha+'&fecha2='+fecha2,'_blank');
            return false;


            });
        });

        $(document).on("click", "#historialU", function () {
            $('#btnGenerarReporteUsuarioHistorial').show();
            $('#btnGenerarReporteUsuarioDiario').hide();
            $('#btnGenerarReporteUsuarioPorFechas').hide();
            $('#fechasUsuario').hide();


           $(document).on("click", "#btnGenerarReporteUsuarioHistorial", function () {
                var idU = $('#usuario').val();
                window.open('?1=UsuarioController&2=reporteUsuario&usuario='+idU,'_blank');
                return false;
            });
        });

        $(document).on("click", "#diarioU", function () {
            $('#btnGenerarReporteUsuarioHistorial').hide();
            $('#btnGenerarReporteUsuarioDiario').show();
            $('#btnGenerarReporteUsuarioPorFechas').hide();
            $('#fechasUsuario').hide();

            $(document).on("click", "#btnGenerarReporteUsuarioDiario", function () {
                var idU = $('#usuario').val();
                window.open('?1=UsuarioController&2=reporteUsuarioDiario&usuario='+idU,'_blank');
                return false;
            });
        });

        $(document).on("click", "#porfechasU", function () {
                $('#btnGenerarReporteUsuarioHistorial').hide();
                $('#btnGenerarReporteUsuarioDiario').hide();
                $('#btnGenerarReporteUsuarioPorFechas').show();
                $('#fechasUsuario').show();

                $(document).on("click", "#btnGenerarReporteUsuarioPorFechas", function () {
                    var idU = $('#usuario').val();
                    var fecha = $('#fecha1Usuario').val();
                    var fecha2 = $('#fecha2Usuario').val();
            window.open('?1=UsuarioController&2=reporteUsuarioPorFechas&usuario='+idU+'&fecha='+fecha+'&fecha2='+fecha2,'_blank');
            return false;


            });
        });


         $(document).on("click", "#btnGenerarReporteFecha", function () {
                    var fecha = $('#fecha1fecha').val();
                    var fecha2 = $('#fecha2fecha').val();
            window.open('?1=UsuarioController&2=reporteFechas&fecha='+fecha+'&fecha2='+fecha2,'_blank');
            return false;
        });


$(document).on("click", "#btnReportes", function () {
            $('#modalReportes').modal('setting', 'autofocus', false).modal('setting', 'closable', false).modal('show');
        });
</script>



<?php
 require_once './vendor/autoload.php';
 $con = new mysqli("localhost","root","","deloitte_mensajeria");
$sql="call clientesConMasEnvios()";
$res=$con->query($sql);

$Cantidad=mysqli_num_rows($res);

$clientes=null;
$i=1;

if ($Cantidad==1) {
  while ($fila=$res->fetch_assoc()) {
   $clientes[$i]=$fila['Cliente'];
   $i++;
  }
}


?>
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback(drawChart);

      function drawChart() {

        var data = google.visualization.arrayToDataTable([
          ['Cliente', 'Cantidad'],
           <?php
          while ($fila=$res->fetch_assoc()) {
          echo "['".$fila["nombreCliente"]."',".$fila["Cliente"]."],";
         // ['Work',     11],

          }
          ?>
        ]);

        var options = {
          title: 'Clientes que han recibido mayor cantidad de  envíos durante la última semana'
        };

        var chart = new google.visualization.PieChart(document.getElementById('piechart'));

        chart.draw(data, options);
      }

    </script>


<?php
 require_once './vendor/autoload.php';
 $con = new mysqli("localhost","root","","deloitte_mensajeria");
$sql="call usuariosEnvios()";
$res=$con->query($sql);

$Cantidad=mysqli_num_rows($res);

$usuarios=null;
$i=1;

if ($Cantidad==1) {
  while ($fila=$res->fetch_assoc()) {
   $usuarios[$i]=$fila['Usuario'];
   $i++;
  }
}


?>

    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
      google.charts.load("current", {packages:["corechart"]});
      google.charts.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
          ['Usuario', 'Cantidad'],
           <?php
          while ($fila=$res->fetch_assoc()) {
          echo "['".$fila["nomUsuario"]."',".$fila["Usuario"]."],";
          }
          ?>
        ]);

        var options = {
          title: 'Usuarios que han enviado mas paquetes durante la última semana',
          pieHole: 0.4,
        };

        var chart = new google.visualization.PieChart(document.getElementById('donutchart'));
        chart.draw(data, options);
      }
    </script>
  </head>
  <body>

    <table style="width: 100vw; margin:auto; padding: 0;">
    <thead>
        <a class="btnGraficos ui center teal button" style="margin:auto;" href="?1=UsuarioController&2=dashboard">
            <b><i class="chart bar icon"></i>Actualizar gráficos</b>
        </a>

    </thead>
    <tbody style="width: 100%;">
    <tr style="width:100%;">
        <td style="width: 50%;">
            <br>
            <div id="piechart" style="width: 100%; height: 50vh;"></div>
        </td>
        <td style="width: 50%;">
            <br>
            <div id="donutchart" style="width: 100%; height: 50vh;"></div>
        </td>
    </tr>
    </tbody>
    <table>
    </body>
</div>



 <script>
        $(function() {
            var option = '';
            var areas = '<?php echo $areas?>';

            $.each(JSON.parse(areas), function() {
                option = `<option value="${this.codigoArea}">${this.descArea}</option>`;

                $('#area').append(option);
            });
        });


        $(function() {
            var option = '';
            var usuarios = '<?php echo $usuariosCMB?>';

            $.each(JSON.parse(usuarios), function() {
                option = `<option value="${this.codigoUsuario}">${this.nombre} ${this.apellido}</option>`;

                $('#usuario').append(option);
            });
        });

    </script>
