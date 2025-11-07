package com.tpi.gateway.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.jwt.NimbusReactiveJwtDecoder;
import org.springframework.security.oauth2.jwt.ReactiveJwtDecoder;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Configuración del decodificador JWT con soporte para múltiples issuers.
 * 
 * Esta configuración permite validar tokens que pueden tener diferentes issuers:
 * - http://localhost:9090/realms/tpi-backend (tokens obtenidos externamente)
 * - http://keycloak:9090/realms/tpi-backend (tokens obtenidos internamente)
 */
@Configuration
@Slf4j
public class JwtDecoderConfig {

    @Bean
    public ReactiveJwtDecoder reactiveJwtDecoder(
            @Value("${spring.security.oauth2.resourceserver.jwt.jwk-set-uri}") String jwkSetUri,
            @Value("${spring.security.oauth2.resourceserver.jwt.issuer-uri:}") String defaultIssuer,
            @Value("${spring.security.oauth2.resourceserver.jwt.allowed-issuers:}") String allowedIssuersConfig) {

        NimbusReactiveJwtDecoder decoder = NimbusReactiveJwtDecoder
                .withJwkSetUri(jwkSetUri)
                .build();

        // Parsear la lista de issuers permitidos desde la configuración
        // Formato esperado: "issuer1,issuer2,issuer3" o un solo issuer
        List<String> allowedIssuersList;
        if (allowedIssuersConfig != null && !allowedIssuersConfig.trim().isEmpty()) {
            allowedIssuersList = Arrays.stream(allowedIssuersConfig.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toList());
        } else {
            // Si no se especifica allowed-issuers, usar el issuer-uri por defecto
            if (defaultIssuer != null && !defaultIssuer.trim().isEmpty()) {
                allowedIssuersList = List.of(defaultIssuer.trim());
            } else {
                allowedIssuersList = List.of();
            }
        }

        // Configurar el validador
        if (!allowedIssuersList.isEmpty()) {
            log.info("🔐 Configurando JWT decoder con {} issuers permitidos:", allowedIssuersList.size());
            allowedIssuersList.forEach(issuer -> log.info("   ✓ {}", issuer));
            MultiIssuerJwtValidator validator = MultiIssuerJwtValidator.withIssuers(allowedIssuersList);
            decoder.setJwtValidator(validator);
        } else {
            log.warn("⚠️ No se configuraron issuers, el decoder puede no validar correctamente los tokens");
        }

        return decoder;
    }
}
