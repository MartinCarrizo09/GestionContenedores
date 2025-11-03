package com.tpi.logistica.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO para respuesta de seguimiento de solicitud con historial cronológico.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SeguimientoSolicitudResponse {
    private Long idSolicitud;
    private String numeroSeguimiento;
    private String estadoActual;
    private Double costoEstimado;
    private Double costoFinal;
    private Double tiempoEstimadoHoras;
    private Double tiempoRealHoras;
    private List<EventoSeguimiento> historial;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class EventoSeguimiento {
        private LocalDateTime fecha;
        private String evento;
        private String descripcion;
        private String estado;
    }
}

