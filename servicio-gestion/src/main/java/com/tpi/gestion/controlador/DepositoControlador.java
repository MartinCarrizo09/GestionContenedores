package com.tpi.gestion.controlador;

import com.tpi.gestion.modelo.Deposito;
import com.tpi.gestion.servicio.DepositoServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para gestionar los depósitos.
 * Expone los endpoints HTTP para crear, consultar, actualizar y eliminar.
 */
@RestController
@RequestMapping("/depositos")
public class DepositoControlador {

    private final DepositoServicio servicio;

    // Inyección del servicio por constructor
    public DepositoControlador(DepositoServicio servicio) {
        this.servicio = servicio;
    }

    // 🔹 Obtener todos los depósitos
    @GetMapping
    public List<Deposito> listarTodos() {
        return servicio.listar();
    }

    // 🔹 Obtener un depósito por su ID
    @GetMapping("/{id}")
    public ResponseEntity<Deposito> buscarPorId(@PathVariable Long id) {
        return servicio.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 🔹 Crear un nuevo depósito
    @PostMapping
    public ResponseEntity<Deposito> crear(@Valid @RequestBody Deposito deposito) {
        Deposito nuevo = servicio.guardar(deposito);
        return ResponseEntity.ok(nuevo);
    }

    // 🔹 Actualizar un depósito existente
    @PutMapping("/{id}")
    public ResponseEntity<Deposito> actualizar(@PathVariable Long id,
                                               @Valid @RequestBody Deposito datos) {
        return ResponseEntity.ok(servicio.actualizar(id, datos));
    }

    // 🔹 Eliminar un depósito
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
