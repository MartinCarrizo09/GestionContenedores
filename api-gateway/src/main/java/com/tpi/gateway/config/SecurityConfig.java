package com.tpi.gateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.ReactiveJwtAuthenticationConverterAdapter;
import org.springframework.security.web.server.SecurityWebFilterChain;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import reactor.core.publisher.Mono;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Configuración de Spring Security para API Gateway con Keycloak
 * 
 * Roles del sistema:
 * - CLIENTE: Puede crear solicitudes y consultar estado de contenedores
 * - OPERADOR: Gestiona rutas, asigna camiones, administra maestros
 * - TRANSPORTISTA: Inicia y finaliza tramos de transporte
 * 
 * Endpoints públicos:
 * - /auth/** (Keycloak)
 * - /actuator/health
 * 
 * Todos los demás endpoints requieren autenticación JWT
 */
@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {

    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
        http
            // Deshabilitar CSRF (no necesario para API REST con JWT)
            .csrf(csrf -> csrf.disable())
            
            // Configuración de autorización
            // IMPORTANTE: Las reglas más específicas deben ir ANTES de las generales
            .authorizeExchange(exchanges -> exchanges
                // ========== Endpoints públicos ==========
                .pathMatchers("/auth/**").permitAll()
                .pathMatchers("/actuator/health/**").permitAll()
                .pathMatchers(HttpMethod.OPTIONS, "/**").permitAll()  // CORS preflight
                
                // ========== CLIENTE - Requisitos 1 y 2 (ESPECÍFICOS PRIMERO) ==========
                .pathMatchers(HttpMethod.POST, "/api/logistica/solicitudes").hasRole("CLIENTE")
                .pathMatchers(HttpMethod.GET, "/api/gestion/contenedores/*/estado").hasRole("CLIENTE")
                .pathMatchers(HttpMethod.GET, "/api/logistica/solicitudes/cliente/*").hasRole("CLIENTE")
                
                // ========== OPERADOR - Requisitos 3, 4, 5, 6, 10 (ESPECÍFICOS PRIMERO) ==========
                .pathMatchers(HttpMethod.POST, "/api/logistica/solicitudes/estimar-ruta").hasRole("OPERADOR")
                .pathMatchers(HttpMethod.POST, "/api/logistica/solicitudes/*/asignar-ruta").hasRole("OPERADOR")
                .pathMatchers(HttpMethod.GET, "/api/logistica/solicitudes/pendientes").hasRole("OPERADOR")
                .pathMatchers(HttpMethod.PUT, "/api/logistica/tramos/*/asignar-camion").hasRole("OPERADOR")
                
                // ========== TRANSPORTISTA - Requisitos 7 y 9 (ESPECÍFICOS PRIMERO) ==========
                .pathMatchers(HttpMethod.PATCH, "/api/logistica/tramos/*/iniciar").hasRole("TRANSPORTISTA")
                .pathMatchers(HttpMethod.PATCH, "/api/logistica/tramos/*/finalizar").hasRole("TRANSPORTISTA")
                .pathMatchers(HttpMethod.GET, "/api/logistica/tramos/camion/*").hasRole("TRANSPORTISTA")
                
                // ========== CRUD de maestros (Operador) - REGLAS GENERALES DESPUÉS ==========
                .pathMatchers("/api/gestion/depositos/**").hasRole("OPERADOR")
                .pathMatchers("/api/gestion/tarifas/**").hasRole("OPERADOR")
                .pathMatchers("/api/flota/camiones/**").hasRole("OPERADOR")
                .pathMatchers("/api/gestion/clientes/**").hasRole("OPERADOR")
                // IMPORTANTE: Esta regla debe ir DESPUÉS de la regla específica de CLIENTE para /contenedores/*/estado
                .pathMatchers("/api/gestion/contenedores/**").hasRole("OPERADOR")
                
                // ========== Endpoints generales GET (cualquier rol autenticado) ==========
                .pathMatchers(HttpMethod.GET, "/api/**").authenticated()
                
                // Cualquier otra petición debe estar autenticada
                .anyExchange().authenticated()
            )
            
            // Configuración de OAuth2 Resource Server (Keycloak JWT)
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt
                    .jwtAuthenticationConverter(grantedAuthoritiesExtractor())
                )
            );
        
        return http.build();
    }
    
    /**
     * Extrae los roles de Keycloak del token JWT
     * 
     * Los roles en Keycloak vienen en el claim "realm_access.roles"
     * Este converter los convierte a GrantedAuthority con prefijo ROLE_
     */
    @Bean
    public ReactiveJwtAuthenticationConverterAdapter grantedAuthoritiesExtractor() {
        JwtAuthenticationConverter jwtAuthenticationConverter = new JwtAuthenticationConverter();
        
        jwtAuthenticationConverter.setJwtGrantedAuthoritiesConverter(jwt -> {
            // Extraer roles de realm_access.roles
            Map<String, Object> realmAccess = jwt.getClaim("realm_access");
            
            if (realmAccess == null) {
                return List.of();
            }
            
            @SuppressWarnings("unchecked")
            List<String> roles = (List<String>) realmAccess.get("roles");
            
            if (roles == null || roles.isEmpty()) {
                return List.of();
            }
            
            // Convertir roles a GrantedAuthority con prefijo ROLE_
            return roles.stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role.toUpperCase()))
                .collect(Collectors.toList());
        });
        
        return new ReactiveJwtAuthenticationConverterAdapter(jwtAuthenticationConverter);
    }
}
