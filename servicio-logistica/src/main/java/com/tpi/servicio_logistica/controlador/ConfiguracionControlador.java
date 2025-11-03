package com.tpi.servicio_logistica.controlador;

import com.tpi.servicio_logistica.modelo.Configuracion;
import com.tpi.servicio_logistica.servicio.ConfiguracionServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para gestionar configuraciones.
 */
@RestController
@RequestMapping("/api/configuraciones")
public class ConfiguracionControlador {

    private final ConfiguracionServicio servicio;

    public ConfiguracionControlador(ConfiguracionServicio servicio) {
        this.servicio = servicio;
    }

    @GetMapping
    public List<Configuracion> listarTodas() {
        return servicio.listar();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Configuracion> buscarPorId(@PathVariable Long id) {
        return servicio.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/clave/{clave}")
    public ResponseEntity<Configuracion> buscarPorClave(@PathVariable String clave) {
        return servicio.buscarPorClave(clave)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Configuracion> crear(@Valid @RequestBody Configuracion configuracion) {
        Configuracion nueva = servicio.guardar(configuracion);
        return ResponseEntity.ok(nueva);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Configuracion> actualizar(@PathVariable Long id,
                                                    @Valid @RequestBody Configuracion datos) {
        return ResponseEntity.ok(servicio.actualizar(id, datos));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}

