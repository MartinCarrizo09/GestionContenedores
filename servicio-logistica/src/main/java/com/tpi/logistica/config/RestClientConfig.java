package com.tpi.logistica.config;

import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

/**
 * Configuración para RestClient (cliente HTTP sincrónico de Spring 6+).
 *
 * RestClient es el cliente HTTP moderno recomendado para Spring Boot 3.2+,
 * reemplazando gradualmente a RestTemplate. Ofrece una API más fluida y expresiva.
 *
 * Ventajas respecto a RestTemplate:
 * - API más intuitiva y moderna (fluent API)
 * - Mejor manejo de errores con callbacks
 * - Integración nativa con Spring Framework 6
 *
 * Este bean es reutilizable y puede inyectarse en cualquier @Service o @Component.
 */
@Configuration
public class RestClientConfig {

    /**
     * Define un bean de RestClient reutilizable para toda la aplicación.
     *
     * RestClient.builder() proporciona métodos para:
     * - Configurar timeouts
     * - Añadir interceptores
     * - Personalizar estrategias de manejo de errores
     * - Configurar headers por defecto
     *
     * @return instancia de RestClient lista para inyectar
     */
    @Bean
    public RestClient restClient() {
        return RestClient.builder()
                // Configuraciones opcionales (agregar según necesidad):
                // .requestTimeout(Duration.ofSeconds(30))
                // .defaultHeader("Content-Type", "application/json")
                .build();
    }
}

