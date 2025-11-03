package com.tpi.flota.controlador;

import com.tpi.flota.modelo.Camion;
import com.tpi.flota.servicio.CamionServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para gestionar los camiones de la flota.
 */
@RestController
@RequestMapping("/api/camiones")
public class CamionControlador {

    private final CamionServicio servicio;

    public CamionControlador(CamionServicio servicio) {
        this.servicio = servicio;
    }

    @GetMapping
    public List<Camion> listarTodos() {
        return servicio.listar();
    }

    @GetMapping("/disponibles")
    public List<Camion> listarDisponibles() {
        return servicio.listarDisponibles();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Camion> buscarPorId(@PathVariable Long id) {
        return servicio.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/patente/{patente}")
    public ResponseEntity<Camion> buscarPorPatente(@PathVariable String patente) {
        return servicio.buscarPorPatente(patente)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Camion> crear(@Valid @RequestBody Camion camion) {
        return ResponseEntity.ok(servicio.guardar(camion));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Camion> actualizar(@PathVariable Long id,
                                             @Valid @RequestBody Camion datos) {
        return ResponseEntity.ok(servicio.actualizar(id, datos));
    }

    @PatchMapping("/{id}/disponibilidad")
    public ResponseEntity<Camion> cambiarDisponibilidad(@PathVariable Long id,
                                                        @RequestParam Boolean disponible) {
        return ResponseEntity.ok(servicio.cambiarDisponibilidad(id, disponible));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}

