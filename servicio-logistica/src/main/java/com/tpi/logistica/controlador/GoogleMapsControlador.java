package com.tpi.logistica.controlador;

import com.tpi.logistica.dto.googlemaps.DistanciaYDuracion;
import com.tpi.logistica.servicio.GoogleMapsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador para probar la integración con Google Maps API.
 */
@RestController
@RequestMapping("/api/google-maps")
public class GoogleMapsControlador {

    private final GoogleMapsService googleMapsService;

    public GoogleMapsControlador(GoogleMapsService googleMapsService) {
        this.googleMapsService = googleMapsService;
    }

    /**
     * Endpoint de prueba para calcular distancia entre dos direcciones.
     *
     * Ejemplo: GET /api/google-maps/distancia?origen=Córdoba,Argentina&destino=Buenos Aires,Argentina
     */
    @GetMapping("/distancia")
    public ResponseEntity<DistanciaYDuracion> calcularDistancia(
            @RequestParam String origen,
            @RequestParam String destino) {

        DistanciaYDuracion resultado = googleMapsService.calcularDistanciaYDuracion(origen, destino);
        return ResponseEntity.ok(resultado);
    }

    /**
     * Endpoint de prueba usando coordenadas.
     *
     * Ejemplo: GET /api/google-maps/distancia-coordenadas?origenLat=-31.4167&origenLng=-64.1833&destinoLat=-34.6037&destinoLng=-58.3816
     */
    @GetMapping("/distancia-coordenadas")
    public ResponseEntity<DistanciaYDuracion> calcularDistanciaCoordenadas(
            @RequestParam Double origenLat,
            @RequestParam Double origenLng,
            @RequestParam Double destinoLat,
            @RequestParam Double destinoLng) {

        DistanciaYDuracion resultado = googleMapsService.calcularDistanciaPorCoordenadas(
            origenLat, origenLng, destinoLat, destinoLng
        );
        return ResponseEntity.ok(resultado);
    }
}

