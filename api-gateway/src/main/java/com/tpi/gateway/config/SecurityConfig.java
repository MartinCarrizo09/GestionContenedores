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

@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {

    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
        http

            .csrf(csrf -> csrf.disable())
            


            .authorizeExchange(exchanges -> exchanges

                .pathMatchers("/auth/**").permitAll()
                .pathMatchers("/actuator/health/**").permitAll()
                .pathMatchers(HttpMethod.OPTIONS, "/**").permitAll()  
                

                .pathMatchers(HttpMethod.POST, "/api/logistica/solicitudes").hasRole("CLIENTE")
                .pathMatchers(HttpMethod.GET, "/api/gestion/contenedores/*/estado").hasRole("CLIENTE")
                .pathMatchers(HttpMethod.GET, "/api/gestion/contenedores/codigo/*/estado").hasRole("CLIENTE")
                .pathMatchers(HttpMethod.GET, "/api/logistica/solicitudes/cliente/*").hasRole("CLIENTE")
                

                .pathMatchers(HttpMethod.POST, "/api/logistica/solicitudes/estimar-ruta").hasRole("OPERADOR")
                .pathMatchers(HttpMethod.POST, "/api/logistica/solicitudes/*/asignar-ruta").hasRole("OPERADOR")
                .pathMatchers(HttpMethod.GET, "/api/logistica/solicitudes/pendientes").hasRole("OPERADOR")
                .pathMatchers(HttpMethod.PUT, "/api/logistica/tramos/*/asignar-camion").hasRole("OPERADOR")
                

                .pathMatchers(HttpMethod.PATCH, "/api/logistica/tramos/*/iniciar").hasRole("TRANSPORTISTA")
                .pathMatchers(HttpMethod.PATCH, "/api/logistica/tramos/*/finalizar").hasRole("TRANSPORTISTA")
                .pathMatchers(HttpMethod.GET, "/api/logistica/tramos/camion/*").hasRole("TRANSPORTISTA")
                

                .pathMatchers("/api/gestion/depositos/**").hasRole("OPERADOR")
                .pathMatchers("/api/gestion/tarifas/**").hasRole("OPERADOR")
                .pathMatchers("/api/flota/camiones/**").hasRole("OPERADOR")
                .pathMatchers("/api/gestion/clientes/**").hasRole("OPERADOR")

                .pathMatchers("/api/gestion/contenedores/**").hasRole("OPERADOR")
                

                .pathMatchers(HttpMethod.GET, "/api/**").authenticated()
                

                .anyExchange().authenticated()
            )
            

            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt
                    .jwtAuthenticationConverter(grantedAuthoritiesExtractor())
                )
            );
        
        return http.build();
    }
    
    @Bean
    public ReactiveJwtAuthenticationConverterAdapter grantedAuthoritiesExtractor() {
        JwtAuthenticationConverter jwtAuthenticationConverter = new JwtAuthenticationConverter();
        
        jwtAuthenticationConverter.setJwtGrantedAuthoritiesConverter(jwt -> {

            Map<String, Object> realmAccess = jwt.getClaim("realm_access");
            
            if (realmAccess == null) {
                return List.of();
            }
            
            @SuppressWarnings("unchecked")
            List<String> roles = (List<String>) realmAccess.get("roles");
            
            if (roles == null || roles.isEmpty()) {
                return List.of();
            }
            

            return roles.stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role.toUpperCase()))
                .collect(Collectors.toList());
        });
        
        return new ReactiveJwtAuthenticationConverterAdapter(jwtAuthenticationConverter);
    }
}
