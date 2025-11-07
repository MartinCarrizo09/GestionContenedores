package com.tpi.gestion.controlador;

import com.tpi.gestion.modelo.Deposito;
import com.tpi.gestion.servicio.DepositoServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/depositos")
public class DepositoControlador {

    private final DepositoServicio servicio;


    public DepositoControlador(DepositoServicio servicio) {
        this.servicio = servicio;
    }


    @GetMapping
    public List<Deposito> listarTodos() {
        return servicio.listar();
    }


    @GetMapping("/{id}")
    public ResponseEntity<Deposito> buscarPorId(@PathVariable Long id) {
        return servicio.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }


    @PostMapping
    public ResponseEntity<Deposito> crear(@Valid @RequestBody Deposito deposito) {
        Deposito nuevo = servicio.guardar(deposito);
        return ResponseEntity.ok(nuevo);
    }


    @PutMapping("/{id}")
    public ResponseEntity<Deposito> actualizar(@PathVariable Long id,
                                               @Valid @RequestBody Deposito datos) {
        return ResponseEntity.ok(servicio.actualizar(id, datos));
    }


    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
