package com.tpi.logistica.controlador;

import com.tpi.logistica.modelo.Solicitud;
import com.tpi.logistica.servicio.SolicitudServicio;
import com.tpi.logistica.dto.EstimacionRutaRequest;
import com.tpi.logistica.dto.EstimacionRutaResponse;
import com.tpi.logistica.dto.SeguimientoSolicitudResponse;
import com.tpi.logistica.dto.ContenedorPendienteResponse;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para gestionar solicitudes.
 */
@RestController
@RequestMapping("/solicitudes")
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

    /**
     * Registra una nueva solicitud de transporte.
     * El cliente puede crear una solicitud sin estar registrado previamente.
     * 
     * ✅ Requisito 1 del TPI (rol: CLIENTE)
     * Estado inicial: BORRADOR
     */
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

    /**
     * Estima una ruta para una solicitud.
     * Calcula distancias reales usando Google Maps API y costos estimados.
     * 
     * ✅ Requisito 3 del TPI (rol: OPERADOR)
     * Devuelve: tramos, costos estimados, tiempos estimados
     */
    @PostMapping("/estimar-ruta")
    public ResponseEntity<EstimacionRutaResponse> estimarRuta(@Valid @RequestBody EstimacionRutaRequest request) {
        EstimacionRutaResponse estimacion = servicio.estimarRuta(request);
        return ResponseEntity.ok(estimacion);
    }

    /**
     * Asigna una ruta estimada a una solicitud.
     * Crea la ruta, sus tramos en estado ESTIMADO y cambia solicitud a PROGRAMADA.
     * 
     * ✅ Requisito 4 del TPI (rol: OPERADOR)
     * Transición: BORRADOR → PROGRAMADA
     * Crea: Ruta + Tramos (estado ESTIMADO)
     */
    @PostMapping("/{id}/asignar-ruta")
    public ResponseEntity<Solicitud> asignarRuta(@PathVariable Long id,
                                                 @Valid @RequestBody EstimacionRutaRequest datosRuta) {
        Solicitud solicitud = servicio.asignarRuta(id, datosRuta);
        return ResponseEntity.ok(solicitud);
    }

    @GetMapping("/seguimiento-detallado/{numeroSeguimiento}")
    public ResponseEntity<SeguimientoSolicitudResponse> obtenerSeguimientoDetallado(
            @PathVariable String numeroSeguimiento) {
        SeguimientoSolicitudResponse seguimiento = servicio.obtenerSeguimiento(numeroSeguimiento);
        return ResponseEntity.ok(seguimiento);
    }

    /**
     * Lista contenedores pendientes de entrega.
     * Excluye solicitudes en estado COMPLETADA, CANCELADA o ENTREGADA.
     * Permite filtrar por estado específico o por ID de contenedor.
     * 
     * ✅ Requisito 5 del TPI (rol: OPERADOR)
     * Devuelve: información de solicitud + ubicación actual + tramo activo
     */
    @GetMapping("/pendientes")
    public ResponseEntity<List<ContenedorPendienteResponse>> listarPendientes(
            @RequestParam(required = false) String estado,
            @RequestParam(required = false) Long idContenedor) {
        List<ContenedorPendienteResponse> pendientes = servicio.listarPendientes(estado, idContenedor);
        return ResponseEntity.ok(pendientes);
    }
}
