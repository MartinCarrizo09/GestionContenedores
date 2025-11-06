package com.tpi.logistica.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

/**
 * Configuración de URLs de otros microservicios.
 * Permite cambiar entre localhost (desarrollo) y nombres de servicio (Docker).
 */
@Configuration
public class MicroserviciosConfig {

    @Value("${servicio.gestion.url:http://localhost:8080/api-gestion}")
    private String servicioGestionUrl;

    @Value("${servicio.flota.url:http://localhost:8081/api-flota}")
    private String servicioFlotaUrl;

    public String getServicioGestionUrl() {
        return servicioGestionUrl;
    }

    public String getServicioFlotaUrl() {
        return servicioFlotaUrl;
    }
}
