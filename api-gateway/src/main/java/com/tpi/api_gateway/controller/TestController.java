package com.tpi.api_gateway.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class TestController {

    @GetMapping("/public/health")
    public String health() {
        return "API Gateway funcionando - No requiere autenticación";
    }

    @GetMapping("/profile")
    @PreAuthorize("isAuthenticated()")
    public String profile(Authentication auth) {
        return "Hola, " + auth.getName() + "! Tus roles: " + auth.getAuthorities();
    }

    @GetMapping("/cliente/info")
    @PreAuthorize("hasRole('cliente')")
    public String clienteInfo() {
        return "Información para clientes - Solo accesible por rol 'cliente'";
    }

    @GetMapping("/operador/dashboard")
    @PreAuthorize("hasRole('operador')")
    public String operadorDashboard() {
        return "Dashboard de operador - Solo accesible por rol 'operador'";
    }

    @GetMapping("/transportista/rutas")
    @PreAuthorize("hasRole('transportista')")
    public String transportistaRutas() {
        return "Rutas asignadas - Solo accesible por rol 'transportista'";
    }

    @GetMapping("/admin/panel")
    @PreAuthorize("hasRole('admin-tpi')")
    public String adminPanel() {
        return "Panel de administración - Solo accesible por admin-tpi";
    }
}

