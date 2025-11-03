package com.tpi.logistica.dto.googlemaps;

import lombok.*;

/**
 * DTO simplificado con la información relevante de distancia y duración.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DistanciaYDuracion {
    private Double distanciaKm;
    private String distanciaTexto;
    private Double duracionHoras;
    private String duracionTexto;
    private String origenDireccion;
    private String destinoDireccion;
}

