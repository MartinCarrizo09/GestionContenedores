package com.tpi.logistica.servicio;

import com.tpi.logistica.dto.googlemaps.GoogleMapsDistanceResponse;
import com.tpi.logistica.dto.googlemaps.DistanciaYDuracion;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * Servicio para integración con Google Maps Distance Matrix API.
 * Calcula distancias y tiempos reales entre ubicaciones.
 */
@Service
public class GoogleMapsService {

    private static final Logger logger = LoggerFactory.getLogger(GoogleMapsService.class);
    private static final String DISTANCE_MATRIX_URL = "https://maps.googleapis.com/maps/api/distancematrix/json";

    @Value("${google.maps.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate;

    public GoogleMapsService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /**
     * Calcula la distancia y duración entre dos direcciones.
     * @param origen Dirección de origen (ej: "Córdoba, Argentina" o coordenadas "-31.4167,-64.1833")
     * @param destino Dirección de destino
     * @return DistanciaYDuracion con información real de Google Maps
     */
    public DistanciaYDuracion calcularDistanciaYDuracion(String origen, String destino) {
        try {
            String url = UriComponentsBuilder.fromHttpUrl(DISTANCE_MATRIX_URL)
                    .queryParam("origins", origen)
                    .queryParam("destinations", destino)
                    .queryParam("key", apiKey)
                    .queryParam("language", "es")
                    .toUriString();

            logger.info("Llamando a Google Maps API: origen={}, destino={}", origen, destino);

            GoogleMapsDistanceResponse response = restTemplate.getForObject(url, GoogleMapsDistanceResponse.class);

            if (response == null || !"OK".equals(response.getStatus())) {
                logger.error("Error en respuesta de Google Maps: status={}",
                    response != null ? response.getStatus() : "null");
                throw new RuntimeException("Error al consultar Google Maps API");
            }

            if (response.getRows().isEmpty() || response.getRows().get(0).getElements().isEmpty()) {
                throw new RuntimeException("No se encontraron rutas entre origen y destino");
            }

            GoogleMapsDistanceResponse.Element element = response.getRows().get(0).getElements().get(0);

            if (!"OK".equals(element.getStatus())) {
                throw new RuntimeException("No se pudo calcular la ruta: " + element.getStatus());
            }

            // Convertir metros a kilómetros
            Double distanciaKm = element.getDistance().getValue() / 1000.0;

            // Convertir segundos a horas
            Double duracionHoras = element.getDuration().getValue() / 3600.0;

            logger.info("Resultado: distancia={}km ({}), duración={}h ({})",
                distanciaKm, element.getDistance().getText(),
                duracionHoras, element.getDuration().getText());

            return DistanciaYDuracion.builder()
                    .distanciaKm(distanciaKm)
                    .distanciaTexto(element.getDistance().getText())
                    .duracionHoras(duracionHoras)
                    .duracionTexto(element.getDuration().getText())
                    .origenDireccion(response.getOriginAddresses().get(0))
                    .destinoDireccion(response.getDestinationAddresses().get(0))
                    .build();

        } catch (Exception e) {
            logger.error("Error al llamar a Google Maps API", e);
            throw new RuntimeException("Error al calcular distancia: " + e.getMessage(), e);
        }
    }

    /**
     * Calcula distancia usando coordenadas (latitud, longitud).
     * @param origenLat Latitud origen
     * @param origenLng Longitud origen
     * @param destinoLat Latitud destino
     * @param destinoLng Longitud destino
     * @return DistanciaYDuracion
     */
    public DistanciaYDuracion calcularDistanciaPorCoordenadas(
            Double origenLat, Double origenLng,
            Double destinoLat, Double destinoLng) {

        String origen = String.format("%f,%f", origenLat, origenLng);
        String destino = String.format("%f,%f", destinoLat, destinoLng);

        return calcularDistanciaYDuracion(origen, destino);
    }
}

