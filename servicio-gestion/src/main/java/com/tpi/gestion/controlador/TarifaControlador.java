package com.tpi.gestion.controlador;

import com.tpi.gestion.modelo.Tarifa;
import com.tpi.gestion.servicio.TarifaServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/tarifas")
public class TarifaControlador {

    private final TarifaServicio servicio;

    public TarifaControlador(TarifaServicio servicio) {
        this.servicio = servicio;
    }

    @GetMapping
    @PreAuthorize("hasRole('OPERADOR')")
    public List<Tarifa> listarTodos() {
        return servicio.listar();
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('OPERADOR')")
    public ResponseEntity<Tarifa> buscarPorId(@PathVariable Long id) {
        return servicio.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasRole('OPERADOR')")
    public ResponseEntity<Tarifa> crear(@Valid @RequestBody Tarifa tarifa) {
        return ResponseEntity.ok(servicio.guardar(tarifa));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('OPERADOR')")
    public ResponseEntity<Tarifa> actualizar(@PathVariable Long id,
                                             @Valid @RequestBody Tarifa datos) {
        return ResponseEntity.ok(servicio.actualizar(id, datos));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('OPERADOR')")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/aplicable")
    @PreAuthorize("hasRole('OPERADOR')")
    public ResponseEntity<Tarifa> buscarTarifaAplicable(@RequestParam Double peso,
                                                        @RequestParam Double volumen) {
        return servicio.buscarTarifaAplicable(peso, volumen)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
