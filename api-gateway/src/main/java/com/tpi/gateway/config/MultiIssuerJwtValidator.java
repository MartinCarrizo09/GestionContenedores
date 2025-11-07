package com.tpi.gateway.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.OAuth2ErrorCodes;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult;
import org.springframework.security.oauth2.jwt.Jwt;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Validador JWT personalizado que acepta múltiples issuers.
 * 
 * Este validador resuelve el problema de discrepancia entre:
 * - Tokens obtenidos internamente (issuer: http://keycloak:9090/realms/tpi-backend)
 * - Tokens obtenidos externamente (issuer: http://localhost:9090/realms/tpi-backend)
 * 
 * Ambos son válidos ya que apuntan al mismo Keycloak, solo difieren en la URL de acceso.
 */
@Slf4j
public class MultiIssuerJwtValidator implements OAuth2TokenValidator<Jwt> {

    private final List<String> allowedIssuers;
    private final List<OAuth2TokenValidator<Jwt>> validators;

    public MultiIssuerJwtValidator(List<String> allowedIssuers) {
        this.allowedIssuers = new ArrayList<>(allowedIssuers);
        this.validators = allowedIssuers.stream()
                .map(issuer -> org.springframework.security.oauth2.jwt.JwtValidators.createDefaultWithIssuer(issuer))
                .collect(Collectors.toList());
        
        log.info("🔐 MultiIssuerJwtValidator inicializado con {} issuers permitidos:", allowedIssuers.size());
        allowedIssuers.forEach(issuer -> log.info("   ✓ {}", issuer));
    }

    @Override
    public OAuth2TokenValidatorResult validate(Jwt jwt) {
        String tokenIssuer = jwt.getIssuer().toString();
        log.debug("🔍 Validando token con issuer: {}", tokenIssuer);

        // Verificar si el issuer del token está en la lista de permitidos
        if (!allowedIssuers.contains(tokenIssuer)) {
            log.warn("❌ Token rechazado: issuer '{}' no está en la lista de issuers permitidos", tokenIssuer);
            OAuth2Error error = new OAuth2Error(
                    OAuth2ErrorCodes.INVALID_TOKEN,
                    String.format("Token issuer '%s' no está permitido. Issuers permitidos: %s", 
                            tokenIssuer, String.join(", ", allowedIssuers)),
                    null
            );
            return OAuth2TokenValidatorResult.failure(error);
        }

        // Intentar validar con cada validador hasta que uno tenga éxito
        List<OAuth2Error> allErrors = new ArrayList<>();
        
        for (OAuth2TokenValidator<Jwt> validator : validators) {
            OAuth2TokenValidatorResult result = validator.validate(jwt);
            if (result.getErrors().isEmpty()) {
                // Si llegamos aquí, la validación fue exitosa
                log.debug("✅ Token validado exitosamente con issuer: {}", tokenIssuer);
                return OAuth2TokenValidatorResult.success();
            } else {
                // Acumular errores para reportarlos si todos fallan
                allErrors.addAll(result.getErrors());
            }
        }

        // Si llegamos aquí, todas las validaciones fallaron
        log.warn("❌ Todas las validaciones fallaron para issuer: {}", tokenIssuer);
        OAuth2Error oauthError = new OAuth2Error(
                OAuth2ErrorCodes.INVALID_TOKEN,
                "Token no válido según todos los validadores",
                null
        );
        return OAuth2TokenValidatorResult.failure(oauthError);
    }

    /**
     * Factory method para crear un validador con múltiples issuers desde una lista de strings.
     */
    public static MultiIssuerJwtValidator withIssuers(String... issuers) {
        return new MultiIssuerJwtValidator(Arrays.asList(issuers));
    }

    /**
     * Factory method para crear un validador con múltiples issuers desde una lista.
     */
    public static MultiIssuerJwtValidator withIssuers(List<String> issuers) {
        return new MultiIssuerJwtValidator(issuers);
    }
}

