package com.tpi.flota.controlador;

import com.tpi.flota.modelo.Camion;
import com.tpi.flota.servicio.CamionServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/camiones")
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

    @GetMapping("/{patente}")
    public ResponseEntity<Camion> buscarPorPatente(@PathVariable String patente) {
        return servicio.buscarPorPatente(patente)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/aptos")
    public List<Camion> buscarCamionesAptos(@RequestParam Double peso, @RequestParam Double volumen) {
        return servicio.encontrarCamionesAptos(peso, volumen);
    }

    @PostMapping
    public ResponseEntity<Camion> crear(@Valid @RequestBody Camion camion) {
        return ResponseEntity.ok(servicio.guardar(camion));
    }

    @PutMapping("/{patente}")
    public ResponseEntity<Camion> actualizar(@PathVariable String patente,
                                             @Valid @RequestBody Camion datos) {
        return ResponseEntity.ok(servicio.actualizar(patente, datos));
    }

    @PatchMapping("/{patente}/disponibilidad")
    public ResponseEntity<Camion> cambiarDisponibilidad(@PathVariable String patente,
                                                        @RequestParam Boolean disponible) {
        return ResponseEntity.ok(servicio.cambiarDisponibilidad(patente, disponible));
    }

    @DeleteMapping("/{patente}")
    public ResponseEntity<Void> eliminar(@PathVariable String patente) {
        servicio.eliminar(patente);
        return ResponseEntity.noContent().build();
    }
}

