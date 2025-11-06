package com.tpi.gestion.dto;

import lombok.*;

/**
 * DTO para respuesta del estado de un contenedor.
 * Combina información del contenedor (servicio-gestion) con su estado de transporte (servicio-logistica).
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EstadoContenedorResponse {

    // Datos del contenedor
    private Long idContenedor;
    private String codigoIdentificacion;
    private Double peso;
    private Double volumen;
    
    // Datos del cliente
    private ClienteInfo cliente;
    
    // Datos de la solicitud y transporte
    private SolicitudInfo solicitud;
    
    // Ubicación actual
    private String ubicacionActual;
    private String descripcionUbicacion;
    
    // Tramo actual (si existe)
    private TramoInfo tramoActual;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ClienteInfo {
        private Long id;
        private String nombre;
        private String apellido;
        private String email;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SolicitudInfo {
        private Long id;
        private String numeroSeguimiento;
        private String estado;
        private Double costoEstimado;
        private Double costoFinal;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TramoInfo {
        private String origen;
        private String destino;
        private String estadoTramo;
        private String patenteCamion;
    }
}
