package com.tpi.gestion.controlador;

import com.tpi.gestion.modelo.Contenedor;
import com.tpi.gestion.servicio.ContenedorServicio;
import com.tpi.gestion.dto.EstadoContenedorResponse;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/contenedores")
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

    /**
     * Buscar contenedor por código de identificación.
     * Permite buscar con el código alfanumérico (ej: CONT001, REEF-20-00173)
     */
    @GetMapping("/codigo/{codigo}")
    public ResponseEntity<Contenedor> buscarPorCodigo(@PathVariable String codigo) {
        return servicio.buscarPorCodigo(codigo)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Consulta el estado actual de un contenedor por CÓDIGO.
     * Devuelve información del contenedor, cliente, solicitud activa y ubicación actual.
     * 
     * ✅ Requisito 2 del TPI (rol: CLIENTE)
     * Devuelve: datos del contenedor + cliente + solicitud activa + ubicación + tramo actual
     */
    @GetMapping("/codigo/{codigo}/estado")
    public ResponseEntity<EstadoContenedorResponse> obtenerEstadoPorCodigo(@PathVariable String codigo) {
        EstadoContenedorResponse estado = servicio.obtenerEstadoPorCodigo(codigo);
        return ResponseEntity.ok(estado);
    }

    /**
     * Consulta el estado actual de un contenedor por ID.
     * Devuelve información del contenedor, cliente, solicitud activa y ubicación actual.
     * 
     * ✅ Requisito 2 del TPI (rol: CLIENTE)
     * Devuelve: datos del contenedor + cliente + solicitud activa + ubicación + tramo actual
     */
    // Ruta más específica PRIMERO - debe ir antes de /{id}
    @GetMapping("/{id}/estado")
    public ResponseEntity<EstadoContenedorResponse> obtenerEstado(@PathVariable Long id) {
        EstadoContenedorResponse estado = servicio.obtenerEstado(id);
        return ResponseEntity.ok(estado);
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
