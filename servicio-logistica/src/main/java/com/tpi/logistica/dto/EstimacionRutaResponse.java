package com.tpi.logistica.dto;

import lombok.*;
import java.util.List;

/**
 * DTO para respuesta de estimación de ruta.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EstimacionRutaResponse {
    private Double costoEstimado;
    private Double tiempoEstimadoHoras;
    private List<TramoEstimado> tramos;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class TramoEstimado {
        private String origenDescripcion;
        private String destinoDescripcion;
        private Double distanciaKm;
        private Double costoEstimado;
        private Double tiempoEstimadoHoras;
    }
}

