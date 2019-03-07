var tablaDocumentosPendientes;

$(function() {
    if($('#dtDocumentosPend').length) {
        tablaDocumentosPendientes = $('#dtDocumentosPend').DataTable({
            "ajax": {
                "url": "?1=EnvioController&2=misDetallesPendientes",
                "type": "POST"
            },
            "columns": [
                {
                    "data": "codigoDetalleEnvio"             
                },
                {
                    "data": "correlativoDetalle"             
                },
                {
                    "data": "descTipoTramite"             
                },
                {
                    "data": "nombreCliente"             
                },
                {
                    "data": "descArea"             
                },
                {
                    "data": "descTipoDocumento"             
                },
                {
                    "data": "numDoc"             
                },
                {
                    "data": "descStatus"             
                },
                {
                    "data": "monto"             
                },
                {
                    "data": "mensajero"             
                },
                {
                    "data": "observacion"             
                },
                {
                    "data": "opcion"
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
        tablaDocumentosPendientes.column(0).visible(false);
       
         
    }
});