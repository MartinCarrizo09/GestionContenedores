package com.tpi.logistica.servicio;

import org.springframework.stereotype.Service;

/**
 * Servicio para calcular tarifas de traslado.
 * Implementa las reglas de negocio del TP.
 */
@Service
public class CalculoTarifaServicio {

    // Valores configurables (deberían venir de Configuracion)
    private static final Double CARGO_GESTION_BASE = 5000.0;
    private static final Double COSTO_LITRO_COMBUSTIBLE = 1200.0;
    private static final Double COSTO_KM_BASE = 150.0;
    private static final Double VELOCIDAD_PROMEDIO_KMH = 60.0;

    /**
     * Calcula el costo estimado de un tramo.
     * Fórmula: CARGO_GESTION + (distancia * COSTO_KM_BASE) + (distancia * consumoPromedio * COSTO_LITRO)
     */
    public Double calcularCostoEstimadoTramo(Double distanciaKm, Double consumoPromedioCamiones) {
        Double cargoGestion = CARGO_GESTION_BASE;
        Double costoKm = distanciaKm * COSTO_KM_BASE;
        Double costoCombustible = distanciaKm * consumoPromedioCamiones * COSTO_LITRO_COMBUSTIBLE;

        return cargoGestion + costoKm + costoCombustible;
    }

    /**
     * Calcula el costo REAL de un tramo cuando se conoce el camión específico.
     * Fórmula: CARGO_GESTION + (distancia * costoKmCamion) + (distancia * consumoCamion * COSTO_LITRO)
     */
    public Double calcularCostoRealTramo(Double distanciaKm, Double costoKmCamion, Double consumoCamion) {
        Double cargoGestion = CARGO_GESTION_BASE;
        Double costoKm = distanciaKm * costoKmCamion;
        Double costoCombustible = distanciaKm * consumoCamion * COSTO_LITRO_COMBUSTIBLE;

        return cargoGestion + costoKm + costoCombustible;
    }

    /**
     * Calcula el costo de estadía en depósito.
     * Fórmula: días * costoEstadiaXdia
     */
    public Double calcularCostoEstadia(Long diasEstadia, Double costoEstadiaXdia) {
        return diasEstadia * costoEstadiaXdia;
    }

    /**
     * Calcula el tiempo estimado en horas para un tramo.
     */
    public Double calcularTiempoEstimado(Double distanciaKm) {
        return distanciaKm / VELOCIDAD_PROMEDIO_KMH;
    }

    /**
     * Obtiene el consumo promedio de una lista de camiones aptos.
     */
    public Double calcularConsumoPromedio(java.util.List<Double> consumos) {
        if (consumos.isEmpty()) {
            return 0.1; // Default si no hay camiones
        }
        return consumos.stream()
                .mapToDouble(Double::doubleValue)
                .average()
                .orElse(0.1);
    }
}

