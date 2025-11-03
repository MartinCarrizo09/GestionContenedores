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
@RequestMapping("/api/tramos")
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
}
