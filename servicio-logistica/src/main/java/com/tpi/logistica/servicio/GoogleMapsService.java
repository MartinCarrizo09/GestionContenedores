package com.tpi.logistica.servicio;

import com.tpi.logistica.dto.googlemaps.GoogleMapsDistanceResponse;
import com.tpi.logistica.dto.googlemaps.DistanciaYDuracion;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * Servicio para integración con Google Maps Distance Matrix API.
 *
 * Responsabilidades:
 * - Consumir la API Distance Matrix de Google Maps
 * - Calcular distancias y tiempos entre ubicaciones
 * - Convertir unidades (metros→km, segundos→horas)
 * - Manejar errores HTTP y deserializar respuestas JSON
 *
 * Implementado con RestClient (cliente HTTP sincrónico moderno de Spring 6+).
 */
@Service
public class GoogleMapsService {

    private static final Logger logger = LoggerFactory.getLogger(GoogleMapsService.class);
    private static final String DISTANCE_MATRIX_URL = "https://maps.googleapis.com/maps/api/distancematrix/json";

    @Value("${google.maps.api.key}")
    private String apiKey;

    private final RestClient restClient;

    /**
     * Constructor con inyección por constructor del bean RestClient.
     * Spring inyectará automáticamente el bean definido en RestClientConfig.
     *
     * @param restClient cliente HTTP sincrónico reutilizable
     */
    public GoogleMapsService(RestClient restClient) {
        this.restClient = restClient;
    }


    /**
     * Calcula la distancia y duración entre dos direcciones.
     *
     * Flujo:
     * 1. Construye URL con parámetros de query (origen, destino, API key)
     * 2. Realiza GET a Google Maps Distance Matrix API
     * 3. Maneja errores HTTP (404, 400, 500, etc.)
     * 4. Deserializa JSON a GoogleMapsDistanceResponse
     * 5. Valida estructura de respuesta
     * 6. Convierte unidades (metros→km, segundos→horas)
     * 7. Retorna DTO interno simplificado
     *
     * @param origen Dirección de origen (ej: "Córdoba, Argentina" o "-31.4167,-64.1833")
     * @param destino Dirección de destino
     * @return DistanciaYDuracion con información real de Google Maps
     * @throws RuntimeException si falla la consulta o Google Maps retorna error
     */
    public DistanciaYDuracion calcularDistanciaYDuracion(String origen, String destino) {
        try {
            // Construcción de URL con parámetros query
            String url = UriComponentsBuilder.fromHttpUrl(DISTANCE_MATRIX_URL)
                    .queryParam("origins", origen)
                    .queryParam("destinations", destino)
                    .queryParam("key", apiKey)
                    .queryParam("language", "es")
                    .toUriString();

            logger.info("Llamando a Google Maps API: origen={}, destino={}", origen, destino);

            // Realiza GET sincrónico usando RestClient
            // onStatus() maneja códigos de estado HTTP específicos
            GoogleMapsDistanceResponse response = restClient.get()
                    .uri(url)
                    .retrieve()
                    // Manejo de errores HTTP: 4xx (cliente), 5xx (servidor)
                    .onStatus(status -> !status.is2xxSuccessful(),
                        (request, response_) -> {
                            logger.error("Error HTTP {} al llamar Google Maps: {}",
                                response_.getStatusCode(), response_.getStatusText());
                            throw new RuntimeException("Error HTTP " + response_.getStatusCode() +
                                " en Google Maps API");
                        })
                    // Deserializa JSON a DTO
                    .body(GoogleMapsDistanceResponse.class);

            // Validaciones de estructura de respuesta
            if (response == null || !"OK".equals(response.getStatus())) {
                logger.error("Error en respuesta de Google Maps: status={}",
                    response != null ? response.getStatus() : "null");
                throw new RuntimeException("Error al consultar Google Maps API: " +
                    (response != null ? response.getStatus() : "respuesta nula"));
            }

            if (response.getRows().isEmpty() || response.getRows().getFirst().getElements().isEmpty()) {
                logger.warn("No se encontraron rutas entre: {} y {}", origen, destino);
                throw new RuntimeException("No se encontraron rutas entre origen y destino");
            }

            // Extrae el primer (y único) elemento de la respuesta usando getFirst() (Java 21+)
            GoogleMapsDistanceResponse.Element element = response.getRows().getFirst().getElements().getFirst();

            // Valida que el elemento no contenga error
            if (!"OK".equals(element.getStatus())) {
                logger.error("Estado de elemento no válido: {}", element.getStatus());
                throw new RuntimeException("No se pudo calcular la ruta: " + element.getStatus());
            }

            // Conversión de unidades: Google Maps retorna metros y segundos
            Double distanciaKm = element.getDistance().getValue() / 1000.0;
            Double duracionHoras = element.getDuration().getValue() / 3600.0;

            logger.info("Resultado exitoso: distancia={}km, duración={}h",
                distanciaKm, duracionHoras);

            // Retorna DTO interno con información relevante
            return DistanciaYDuracion.builder()
                    .distanciaKm(distanciaKm)
                    .distanciaTexto(element.getDistance().getText())
                    .duracionHoras(duracionHoras)
                    .duracionTexto(element.getDuration().getText())
                    .origenDireccion(response.getOriginAddresses().getFirst())
                    .destinoDireccion(response.getDestinationAddresses().getFirst())
                    .build();

        } catch (RuntimeException e) {
            // Re-lanza excepciones ya controladas
            logger.error("Excepción controlada al calcular distancia", e);
            throw e;
        } catch (Exception e) {
            // Captura excepciones no previstas (conexión, timeout, etc.)
            logger.error("Error inesperado al llamar a Google Maps API", e);
            throw new RuntimeException("Error al calcular distancia: " + e.getMessage(), e);
        }
    }


    /**
     * Conveniencia: calcula distancia usando coordenadas en lugar de direcciones.
     *
     * Método helper que actúa como wrapper de calcularDistanciaYDuracion(),
     * formateando latitud y longitud al formato que espera Google Maps.
     *
     * Ejemplo: (lat=-31.4167, lng=-64.1833) → "-31.4167,-64.1833"
     *
     * @param origenLat Latitud de origen
     * @param origenLng Longitud de origen
     * @param destinoLat Latitud de destino
     * @param destinoLng Longitud de destino
     * @return DistanciaYDuracion con información real
     */
    public DistanciaYDuracion calcularDistanciaPorCoordenadas(
            Double origenLat, Double origenLng,
            Double destinoLat, Double destinoLng) {

        // Formatea coordenadas al formato: "latitud,longitud"
        String origen = String.format("%f,%f", origenLat, origenLng);
        String destino = String.format("%f,%f", destinoLat, destinoLng);

        logger.info("Calculando distancia por coordenadas: ({},{}) → ({},{})",
            origenLat, origenLng, destinoLat, destinoLng);

        return calcularDistanciaYDuracion(origen, destino);
    }
}

