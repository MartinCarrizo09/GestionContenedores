package com.tpi.logistica.controlador;

import com.tpi.logistica.dto.googlemaps.DistanciaYDuracion;
import com.tpi.logistica.servicio.GoogleMapsService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador de ejemplo para pruebas de integración con Google Maps.
 *
 * Endpoints de demostración:
 * - GET /api-logistica/google-maps/distancia (por direcciones)
 * - GET /api-logistica/google-maps/distancia-coords (por coordenadas)
 *
 * Nota: Este es un controlador DEMO. En producción, estos cálculos
 * deberían estar dentro de servicios de negocio reales.
 */
@RestController
@RequestMapping("/google-maps")
public class GoogleMapsControlador {

    private static final Logger logger = LoggerFactory.getLogger(GoogleMapsControlador.class);

    private final GoogleMapsService googleMapsService;

    /**
     * Constructor con inyección de GoogleMapsService.
     * Spring resuelve automáticamente todas las dependencias.
     */
    public GoogleMapsControlador(GoogleMapsService googleMapsService) {
        this.googleMapsService = googleMapsService;
    }

    /**
     * Calcula distancia y duración entre dos direcciones.
     *
     * Ejemplo de request:
     * GET /api-logistica/google-maps/distancia?origen=Córdoba,Argentina&destino=Buenos Aires,Argentina
     *
     * Response exitoso (200):
     * {
     *   "distanciaKm": 702.0,
     *   "distanciaTexto": "702 km",
     *   "duracionHoras": 7.5,
     *   "duracionTexto": "7 hours 30 mins",
     *   "origenDireccion": "Córdoba, Argentina",
     *   "destinoDireccion": "Buenos Aires, Argentina"
     * }
     *
     * Response error (400):
     * {
     *   "error": "Parámetros origen y destino son requeridos"
     * }
     *
     * Response error (500):
     * {
     *   "error": "Error al calcular distancia: No se encontraron rutas"
     * }
     *
     * @param origen Dirección de origen (ej: "Córdoba, Argentina")
     * @param destino Dirección de destino
     * @return DTO con distancia, duración y direcciones geocodificadas
     */
    @GetMapping("/distancia")
    public ResponseEntity<?> calcularDistancia(
            @RequestParam(required = true) String origen,
            @RequestParam(required = true) String destino) {

        logger.info("Request recibido: calcular distancia de {} a {}", origen, destino);

        // Validación de parámetros
        if (origen == null || origen.isBlank() || destino == null || destino.isBlank()) {
            logger.warn("Parámetros inválidos: origen={}, destino={}", origen, destino);
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse("Parámetros origen y destino son requeridos"));
        }

        try {
            // Llama al servicio para calcular distancia
            DistanciaYDuracion resultado = googleMapsService
                    .calcularDistanciaYDuracion(origen, destino);

            logger.info("Cálculo exitoso: {}km en {}h",
                resultado.getDistanciaKm(),
                resultado.getDuracionHoras());

            return ResponseEntity.ok(resultado);

        } catch (RuntimeException e) {
            // Captura errores de Google Maps o validación
            logger.error("Error al calcular distancia", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Error al calcular distancia: " + e.getMessage()));
        }
    }

    /**
     * Calcula distancia usando coordenadas (latitud, longitud).
     *
     * Ejemplo de request:
     * GET /api-logistica/google-maps/distancia-coords?lat1=-31.4167&lng1=-64.1833&lat2=-34.6037&lng2=-58.3816
     *
     * Response exitoso (200): igual al endpoint /distancia
     *
     * Response error (400):
     * {
     *   "error": "Todos los parámetros de coordenadas son requeridos"
     * }
     *
     * @param lat1 Latitud de origen
     * @param lng1 Longitud de origen
     * @param lat2 Latitud de destino
     * @param lng2 Longitud de destino
     * @return DTO con distancia y duración
     */
    @GetMapping("/distancia-coords")
    public ResponseEntity<?> calcularDistanciaPorCoordenadas(
            @RequestParam(required = true) Double lat1,
            @RequestParam(required = true) Double lng1,
            @RequestParam(required = true) Double lat2,
            @RequestParam(required = true) Double lng2) {

        logger.info("Request recibido: calcular distancia de ({},{}) a ({},{})",
                lat1, lng1, lat2, lng2);

        // Validación de parámetros (null se captura automáticamente con required=true)
        if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
            logger.warn("Parámetros de coordenadas inválidos");
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse("Todos los parámetros de coordenadas son requeridos"));
        }

        try {
            // Llama al servicio con coordenadas
            DistanciaYDuracion resultado = googleMapsService
                    .calcularDistanciaPorCoordenadas(lat1, lng1, lat2, lng2);

            logger.info("Cálculo exitoso por coordenadas: {}km", resultado.getDistanciaKm());

            return ResponseEntity.ok(resultado);

        } catch (RuntimeException e) {
            logger.error("Error al calcular distancia por coordenadas", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Error al calcular distancia: " + e.getMessage()));
        }
    }

    /**
     * DTO simple para respuestas de error.
     * Permite mantener una estructura uniforme en las respuestas.
     */
    public static class ErrorResponse {
        public String error;

        public ErrorResponse(String error) {
            this.error = error;
        }

        // Getters para serialización JSON
        public String getError() {
            return error;
        }

        public void setError(String error) {
            this.error = error;
        }
    }
}

