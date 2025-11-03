package com.tpi.gestion.controlador;

import com.tpi.gestion.modelo.Tarifa;
import com.tpi.gestion.servicio.TarifaServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tarifas")
public class TarifaControlador {

    private final TarifaServicio servicio;

    public TarifaControlador(TarifaServicio servicio) {
        this.servicio = servicio;
    }

    @GetMapping
    public List<Tarifa> listarTodos() {
        return servicio.listar();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Tarifa> buscarPorId(@PathVariable Long id) {
        return servicio.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Tarifa> crear(@Valid @RequestBody Tarifa tarifa) {
        return ResponseEntity.ok(servicio.guardar(tarifa));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Tarifa> actualizar(@PathVariable Long id,
                                             @Valid @RequestBody Tarifa datos) {
        return ResponseEntity.ok(servicio.actualizar(id, datos));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
