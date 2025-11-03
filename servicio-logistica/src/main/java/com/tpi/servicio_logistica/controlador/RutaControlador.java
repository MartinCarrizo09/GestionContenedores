package com.tpi.servicio_logistica.controlador;

import com.tpi.servicio_logistica.modelo.Ruta;
import com.tpi.servicio_logistica.servicio.RutaServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para gestionar rutas.
 */
@RestController
@RequestMapping("/api/rutas")
public class RutaControlador {

    private final RutaServicio servicio;

    public RutaControlador(RutaServicio servicio) {
        this.servicio = servicio;
    }

    @GetMapping
    public List<Ruta> listarTodas() {
        return servicio.listar();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Ruta> buscarPorId(@PathVariable Long id) {
        return servicio.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/solicitud/{idSolicitud}")
    public List<Ruta> listarPorSolicitud(@PathVariable Long idSolicitud) {
        return servicio.listarPorSolicitud(idSolicitud);
    }

    @PostMapping
    public ResponseEntity<Ruta> crear(@Valid @RequestBody Ruta ruta) {
        Ruta nueva = servicio.guardar(ruta);
        return ResponseEntity.ok(nueva);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Ruta> actualizar(@PathVariable Long id,
                                          @Valid @RequestBody Ruta datos) {
        return ResponseEntity.ok(servicio.actualizar(id, datos));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}

