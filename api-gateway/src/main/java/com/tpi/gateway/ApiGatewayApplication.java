package com.tpi.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;

/**
 * API Gateway - Punto de entrada único al sistema TPI Backend
 * 
 * Características:
 * - Enrutamiento centralizado a 3 microservicios
 * - Autenticación y autorización con Keycloak
 * - Circuit Breaker para resiliencia
 * - CORS configurado
 * - Health checks y métricas
 * 
 * @author Martín Carrizo
 * @version 2.0
 */
@SpringBootApplication
public class ApiGatewayApplication {

	public static void main(String[] args) {
		SpringApplication.run(ApiGatewayApplication.class, args);
	}
}
