package com.tpi.logistica.servicio;

import com.tpi.logistica.config.MicroserviciosConfig;
import com.tpi.logistica.dto.DepositoDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;

@Service
public class DepositoServicio {

    private static final Logger log = LoggerFactory.getLogger(DepositoServicio.class);
    private static final Double RADIO_BUSQUEDA_KM = 100.0; // Radio de búsqueda en kilómetros

    private final RestTemplate restTemplate;
    private final MicroserviciosConfig microserviciosConfig;

    public DepositoServicio(RestTemplate restTemplate, MicroserviciosConfig microserviciosConfig) {
        this.restTemplate = restTemplate;
        this.microserviciosConfig = microserviciosConfig;
    }

    /**
     * Busca depósitos intermedios en la ruta entre origen y destino
     */
    public List<DepositoDTO> buscarDepositosEnRuta(
            Double origenLat, Double origenLng,
            Double destinoLat, Double destinoLng) {
        
        log.info("Buscando depósitos intermedios entre ({},{}) y ({},{})",
                origenLat, origenLng, destinoLat, destinoLng);

        try {
            // Obtener todos los depósitos disponibles
            String url = microserviciosConfig.getServicioGestionUrl() + "/depositos";
            
            ResponseEntity<List<DepositoDTO>> response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    null,
                    new ParameterizedTypeReference<List<DepositoDTO>>() {}
            );

            List<DepositoDTO> todosLosDepositos = response.getBody();
            
            if (todosLosDepositos == null || todosLosDepositos.isEmpty()) {
                log.warn("No se encontraron depósitos en el sistema");
                return List.of();
            }

            // Filtrar depósitos que estén en la ruta (dentro del radio de búsqueda)
            List<DepositoDTO> depositosEnRuta = new ArrayList<>();
            
            for (DepositoDTO deposito : todosLosDepositos) {
                if (deposito.getLatitud() == null || deposito.getLongitud() == null) {
                    continue;
                }

                // Verificar si el depósito está entre origen y destino
                if (estaEnRuta(
                        origenLat, origenLng,
                        destinoLat, destinoLng,
                        deposito.getLatitud(), deposito.getLongitud())) {
                    
                    depositosEnRuta.add(deposito);
                    log.info("Depósito encontrado en ruta: {} ({}, {})",
                            deposito.getNombre(), deposito.getLatitud(), deposito.getLongitud());
                }
            }

            log.info("Total de depósitos encontrados en ruta: {}", depositosEnRuta.size());
            
            // Ordenar depósitos por distancia desde el origen
            depositosEnRuta.sort((d1, d2) -> {
                double dist1 = calcularDistancia(origenLat, origenLng, d1.getLatitud(), d1.getLongitud());
                double dist2 = calcularDistancia(origenLat, origenLng, d2.getLatitud(), d2.getLongitud());
                return Double.compare(dist1, dist2);
            });

            return depositosEnRuta;

        } catch (Exception e) {
            log.error("Error al buscar depósitos en ruta: {}", e.getMessage(), e);
            return List.of();
        }
    }

    /**
     * Verifica si un punto (depósito) está en la ruta entre origen y destino
     */
    private boolean estaEnRuta(
            Double origenLat, Double origenLng,
            Double destinoLat, Double destinoLng,
            Double puntoLat, Double puntoLng) {

        // Calcular distancia total de la ruta directa
        double distanciaDirecta = calcularDistancia(origenLat, origenLng, destinoLat, destinoLng);

        // Calcular distancia pasando por el punto (origen -> punto -> destino)
        double distanciaConPunto = 
                calcularDistancia(origenLat, origenLng, puntoLat, puntoLng) +
                calcularDistancia(puntoLat, puntoLng, destinoLat, destinoLng);

        // Si la diferencia es pequeña (dentro del margen), el punto está en la ruta
        double margenPorcentaje = 0.15; // 15% de margen
        double diferenciaPermitida = distanciaDirecta * margenPorcentaje;

        boolean estaEnRuta = (distanciaConPunto - distanciaDirecta) <= diferenciaPermitida;

        log.debug("Verificando punto ({}, {}): distanciaDirecta={}km, distanciaConPunto={}km, diferencia={}km, permitida={}km, estaEnRuta={}",
                puntoLat, puntoLng, distanciaDirecta, distanciaConPunto, 
                (distanciaConPunto - distanciaDirecta), diferenciaPermitida, estaEnRuta);

        return estaEnRuta;
    }

    /**
     * Calcula la distancia entre dos puntos usando la fórmula de Haversine
     * Retorna la distancia en kilómetros
     */
    private double calcularDistancia(Double lat1, Double lon1, Double lat2, Double lon2) {
        final int RADIO_TIERRA_KM = 6371;

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return RADIO_TIERRA_KM * c;
    }
}
