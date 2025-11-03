package com.tpi.gestion.controlador;

import com.tpi.gestion.modelo.Contenedor;
import com.tpi.gestion.servicio.ContenedorServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/contenedores")
public class ContenedorControlador {

    private final ContenedorServicio servicio;

    public ContenedorControlador(ContenedorServicio servicio) {
        this.servicio = servicio;
    }

    @GetMapping
    public List<Contenedor> listarTodos() {
        return servicio.listar();
    }

    @GetMapping("/cliente/{idCliente}")
    public List<Contenedor> listarPorCliente(@PathVariable Long idCliente) {
        return servicio.listarPorCliente(idCliente);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Contenedor> buscarPorId(@PathVariable Long id) {
        return servicio.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Contenedor> crear(@Valid @RequestBody Contenedor contenedor) {
        return ResponseEntity.ok(servicio.guardar(contenedor));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Contenedor> actualizar(@PathVariable Long id,
                                                 @Valid @RequestBody Contenedor datos) {
        return ResponseEntity.ok(servicio.actualizar(id, datos));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
