package com.tpi.servicio_logistica.controlador;

import com.tpi.servicio_logistica.modelo.Solicitud;
import com.tpi.servicio_logistica.servicio.SolicitudServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para gestionar solicitudes.
 */
@RestController
@RequestMapping("/api/solicitudes")
public class SolicitudControlador {

    private final SolicitudServicio servicio;

    public SolicitudControlador(SolicitudServicio servicio) {
        this.servicio = servicio;
    }

    @GetMapping
    public List<Solicitud> listarTodas() {
        return servicio.listar();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Solicitud> buscarPorId(@PathVariable Long id) {
        return servicio.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/seguimiento/{numeroSeguimiento}")
    public ResponseEntity<Solicitud> buscarPorNumeroSeguimiento(@PathVariable String numeroSeguimiento) {
        return servicio.buscarPorNumeroSeguimiento(numeroSeguimiento)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/cliente/{idCliente}")
    public List<Solicitud> listarPorCliente(@PathVariable Long idCliente) {
        return servicio.listarPorCliente(idCliente);
    }

    @GetMapping("/estado/{estado}")
    public List<Solicitud> listarPorEstado(@PathVariable String estado) {
        return servicio.listarPorEstado(estado);
    }

    @PostMapping
    public ResponseEntity<Solicitud> crear(@Valid @RequestBody Solicitud solicitud) {
        Solicitud nueva = servicio.guardar(solicitud);
        return ResponseEntity.ok(nueva);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Solicitud> actualizar(@PathVariable Long id,
                                               @Valid @RequestBody Solicitud datos) {
        return ResponseEntity.ok(servicio.actualizar(id, datos));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}

