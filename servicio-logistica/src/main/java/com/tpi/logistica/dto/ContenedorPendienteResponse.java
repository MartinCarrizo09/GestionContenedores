package com.tpi.logistica.dto;

import lombok.*;

/**
 * DTO para respuesta de contenedores pendientes de entrega.
 * Combina información de Solicitud y Tramo para mostrar ubicación actual.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ContenedorPendienteResponse {

    private Long idSolicitud;
    private String numeroSeguimiento;
    private Long idContenedor;
    private Long idCliente;
    
    // Estado de la solicitud
    private String estado;
    
    // Ubicación actual
    private String ubicacionActual;
    private String descripcionUbicacion;
    
    // Datos del tramo actual (si existe)
    private TramoActual tramoActual;
    
    // Costos
    private Double costoEstimado;
    private Double costoFinal;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TramoActual {
        private Long idTramo;
        private String origen;
        private String destino;
        private String estadoTramo;
        private String patenteCamion;
    }
}
