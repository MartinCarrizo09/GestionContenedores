package com.tpi.gestion.servicio;

import com.tpi.gestion.dto.SolicitudLogisticaDTO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Optional;

/**
 * Cliente para comunicación con el servicio de logística.
 */
@Service
public class LogisticaClienteServicio {

    private final RestTemplate restTemplate;
    
    @Value("${servicio.logistica.url:http://localhost:8082/api-logistica}")
    private String logisticaBaseUrl;

    public LogisticaClienteServicio(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /**
     * Busca solicitudes por ID de contenedor en el servicio de logística.
     */
    public List<SolicitudLogisticaDTO> buscarSolicitudesPorContenedor(Long idContenedor) {
        try {
            String url = logisticaBaseUrl + "/solicitudes/pendientes?idContenedor=" + idContenedor;
            
            ResponseEntity<List<SolicitudLogisticaDTO>> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<List<SolicitudLogisticaDTO>>() {}
            );
            
            return response.getBody();
        } catch (Exception e) {
            // Log error y retornar lista vacía
            System.err.println("Error al consultar servicio de logística: " + e.getMessage());
            return List.of();
        }
    }

    /**
     * Obtiene la solicitud activa (no entregada) de un contenedor.
     */
    public Optional<SolicitudLogisticaDTO> obtenerSolicitudActiva(Long idContenedor) {
        List<SolicitudLogisticaDTO> solicitudes = buscarSolicitudesPorContenedor(idContenedor);
        
        // Retornar la primera solicitud no entregada
        return solicitudes.stream()
                .filter(s -> !"ENTREGADA".equals(s.getEstado()))
                .findFirst();
    }
}
