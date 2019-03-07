var tablaPaquetes;

$(function() {
    if($('#dtPaquetes').length) {
        tablaPaquetes = $('#dtPaquetes').DataTable({
            "ajax": {
                "url": "?1=EnvioController&2=mostrarPaquetes",
                "type": "POST"
            },
            "columns": [
                {
                    "data": "codigoEnvio"
                },
                {
                    "data": "correlativoEnvio"
                },
                {
                    "data": "fecha"
                },
                {
                    "data": "hora"             
                }
                ,
                {
                    "data": "nomUsuario"             
                }
                ,
                {
                    "data": "nombre"             
                },
                {
                    "data": "documentos"
                },
                {
                    "data": "Acciones"             
                }
            ],
            "order": [
                [0, "desc"]
            ],
            "language": {
                "sProcessing": "Procesando...",
                "sLengthMenu": "Mostrar _MENU_ registros",
                "sZeroRecords": "No se encontraron resultados",
                "sEmptyTable": "Ningún dato disponible en esta tabla",
                "sInfo": "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
                "sInfoEmpty": "Mostrando registros del 0 al 0 de un total de 0 registros",
                "sInfoFiltered": "(filtrado de un total de _MAX_ registros)",
                "sInfoPostFix": "",
                "sSearch": "Buscar:",
                "sUrl": "",
                "sInfoThousands": ",",
                "sLoadingRecords": "Cargando...",
                "oPaginate": {
                    "sFirst": "Primero",
                    "sLast": "Último",
                    "sNext": "Siguiente",
                    "sPrevious": "Anterior"
                },
                "oAria": {
                    "sSortAscending": ": Activar para ordenar la columna de manera ascendente",
                    "sSortDescending": ": Activar para ordenar la columna de manera descendente"
                }
            }
        });

         // Ocultar columna de id de Usuario
         tablaPaquetes.column(0).visible(false);
    }
});