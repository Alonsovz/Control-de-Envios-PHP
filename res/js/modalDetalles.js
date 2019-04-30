Vue.component('modal-detalles', {

    props: {
        detalles: {
            type: Array,
            required: false
        }
    },


    template: `<div class="ui longer fullscreen first coupled modal" id="modalDetalles">
    <div class="header">
        Documentos del Paquete
    </div>

    <div class="scrolling content">
        <form action="" class="ui form" id="frmDetalles">
            <table v-if="detalles" class="ui selectable very compact single line table">
                <thead>
                    <tr>
                        <th>Correlativo</th>
                        <th>Trámite</th>
                        <th>Cliente</th>
                        <th>Área</th>
                        <th>Tipo de Documento</th>
                        <th>N° Documento</th>
                        <th>Monto</th>
                        <th>Status</th>
                        <th>Mensajero</th>
                        <th>Observación</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="detalle in detalles" :codigo-detalle="detalle.codigoDetalleEnvio">
                            <td>{{detalle.correlativoDetalle}}</td>
                            <td>{{detalle.descTipoTramite}}</td>
                            <td>{{detalle.nombreCliente}}</td>
                            <td>{{detalle.descArea}}</td>
                            <td>{{detalle.descTipoDocumento}}</td>
                            <td>{{detalle.numDoc}}</td>
                            <td>{{detalle.monto}}</td>
                            <td v-if="detalle.descStatus == 'Pendiente'" style="background-color: #F6AD43;">
                                {{detalle.descStatus}}
                            </td>
                            <td v-else-if="detalle.descStatus == 'Incompleto'" style="background-color: #F67943;">
                                {{detalle.descStatus}}
                            </td>
                            <td v-else-if="detalle.descStatus == 'Recibido'" style="background-color:lightblue;">
                                {{detalle.descStatus}}
                            </td>
                            <td v-else-if="detalle.descStatus == 'Completo'" style="background-color: lightgreen;">
                                {{detalle.descStatus}}
                            </td>
                            <td v-else-if="detalle.descStatus == 'Pendiente de Revision'" style="background-color: rgba(149, 165, 166, 0.3);">
                                {{detalle.descStatus}}
                            </td>
                            <td>
                                {{detalle.mensajero}}
                            </td>
                            <td>
                                {{detalle.observacion}}
                            </td>
                            <td>
                            <button @click="$parent.modalCambiar(detalle.codigoDetalleEnvio, detalle.correlativoDetalle, detalle.descTipoTramite, detalle.nombreCliente, detalle.descArea, detalle.descTipoDocumento, detalle.descStatus, detalle.observacion)" type="button" class="ui mini circular primary icon button btnCambios">
                                <i class="edit icon"></i>
                            </button>
                            <!--<button @click="$parent.modalEliminarDetalle(detalle.codigoDetalleEnvio)" type="button" class="ui mini circular red icon button btnEliminarDetalle">
                                <i class="trash icon"></i>
                            </button>-->
                        </td>
                    </tr>
                </tbody>
            </table>
        </form>
    </div>
    <div class="actions">
        <button @click="$parent.cerrarModal" class="ui deny black button">
            Cerrar
        </button>
    </div>
</div>`

});