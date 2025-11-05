package com.tpi.logistica.controlador;

import com.tpi.logistica.modelo.Tramo;
import com.tpi.logistica.servicio.TramoServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para gestionar tramos.
 */
@RestController
@RequestMapping("/tramos")
public class TramoControlador {

    private final TramoServicio servicio;

    public TramoControlador(TramoServicio servicio) {
        this.servicio = servicio;
    }

    @GetMapping
    public List<Tramo> listarTodos() {
        return servicio.listar();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Tramo> buscarPorId(@PathVariable Long id) {
        return servicio.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/ruta/{idRuta}")
    public List<Tramo> listarPorRuta(@PathVariable Long idRuta) {
        return servicio.listarPorRuta(idRuta);
    }

    @GetMapping("/camion/{patenteCamion}")
    public List<Tramo> listarPorCamion(@PathVariable String patenteCamion) {
        return servicio.listarPorCamion(patenteCamion);
    }

    @GetMapping("/estado/{estado}")
    public List<Tramo> listarPorEstado(@PathVariable String estado) {
        return servicio.listarPorEstado(estado);
    }

    @PostMapping
    public ResponseEntity<Tramo> crear(@Valid @RequestBody Tramo tramo) {
        return ResponseEntity.ok(servicio.guardar(tramo));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Tramo> actualizar(@PathVariable Long id,
                                           @Valid @RequestBody Tramo datos) {
        return ResponseEntity.ok(servicio.actualizar(id, datos));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/asignar-camion")
    public ResponseEntity<Tramo> asignarCamion(@PathVariable Long id,
                                               @RequestParam String patente,
                                               @RequestParam Double peso,
                                               @RequestParam Double volumen) {
        Tramo tramo = servicio.asignarCamion(id, patente, peso, volumen);
        return ResponseEntity.ok(tramo);
    }

    @PatchMapping("/{id}/iniciar")
    public ResponseEntity<Tramo> iniciarTramo(@PathVariable Long id) {
        Tramo tramo = servicio.iniciarTramo(id);
        return ResponseEntity.ok(tramo);
    }

    @PatchMapping("/{id}/finalizar")
    public ResponseEntity<Tramo> finalizarTramo(@PathVariable Long id,
                                               @RequestParam Double kmReales,
                                               @RequestParam Double costoKmCamion,
                                               @RequestParam Double consumoCamion) {
        Tramo tramo = servicio.finalizarTramo(id, kmReales, costoKmCamion, consumoCamion);
        return ResponseEntity.ok(tramo);
    }
}
