package com.tpi.logistica.servicio;

import com.tpi.logistica.modelo.Solicitud;
import com.tpi.logistica.modelo.Ruta;
import com.tpi.logistica.modelo.Tramo;
import com.tpi.logistica.repositorio.SolicitudRepositorio;
import com.tpi.logistica.repositorio.RutaRepositorio;
import com.tpi.logistica.repositorio.TramoRepositorio;
import com.tpi.logistica.dto.EstimacionRutaRequest;
import com.tpi.logistica.dto.EstimacionRutaResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.ArrayList;

/**
 * Servicio que contiene la lógica de negocio para gestionar solicitudes.
 */
@Service
public class SolicitudServicio {

    private final SolicitudRepositorio repositorio;
    private final RutaRepositorio rutaRepositorio;
    private final TramoRepositorio tramoRepositorio;
    private final CalculoTarifaServicio calculoTarifaServicio;

    public SolicitudServicio(SolicitudRepositorio repositorio,
                            RutaRepositorio rutaRepositorio,
                            TramoRepositorio tramoRepositorio,
                            CalculoTarifaServicio calculoTarifaServicio) {
        this.repositorio = repositorio;
        this.rutaRepositorio = rutaRepositorio;
        this.tramoRepositorio = tramoRepositorio;
        this.calculoTarifaServicio = calculoTarifaServicio;
    }

    public List<Solicitud> listar() {
        return repositorio.findAll();
    }

    public Optional<Solicitud> buscarPorId(Long id) {
        return repositorio.findById(id);
    }

    public Optional<Solicitud> buscarPorNumeroSeguimiento(String numeroSeguimiento) {
        return repositorio.findByNumeroSeguimiento(numeroSeguimiento);
    }

    public List<Solicitud> listarPorCliente(Long idCliente) {
        return repositorio.findByIdCliente(idCliente);
    }

    public List<Solicitud> listarPorEstado(String estado) {
        return repositorio.findByEstado(estado);
    }

    public Solicitud guardar(Solicitud nuevaSolicitud) {
        if (repositorio.existsByNumeroSeguimiento(nuevaSolicitud.getNumeroSeguimiento())) {
            throw new RuntimeException("Ya existe una solicitud con ese número de seguimiento");
        }
        return repositorio.save(nuevaSolicitud);
    }

    public Solicitud actualizar(Long id, Solicitud datosActualizados) {
        return repositorio.findById(id)
                .map(solicitud -> {
                    solicitud.setNumeroSeguimiento(datosActualizados.getNumeroSeguimiento());
                    solicitud.setIdContenedor(datosActualizados.getIdContenedor());
                    solicitud.setIdCliente(datosActualizados.getIdCliente());
                    solicitud.setOrigenDireccion(datosActualizados.getOrigenDireccion());
                    solicitud.setOrigenLatitud(datosActualizados.getOrigenLatitud());
                    solicitud.setOrigenLongitud(datosActualizados.getOrigenLongitud());
                    solicitud.setDestinoDireccion(datosActualizados.getDestinoDireccion());
                    solicitud.setDestinoLatitud(datosActualizados.getDestinoLatitud());
                    solicitud.setDestinoLongitud(datosActualizados.getDestinoLongitud());
                    solicitud.setEstado(datosActualizados.getEstado());
                    solicitud.setCostoEstimado(datosActualizados.getCostoEstimado());
                    solicitud.setTiempoEstimado(datosActualizados.getTiempoEstimado());
                    solicitud.setCostoFinal(datosActualizados.getCostoFinal());
                    solicitud.setTiempoReal(datosActualizados.getTiempoReal());
                    return repositorio.save(solicitud);
                })
                .orElseThrow(() -> new RuntimeException("Solicitud no encontrada"));
    }

    public void eliminar(Long id) {
        repositorio.deleteById(id);
    }

    /**
     * Estima una ruta para una solicitud.
     * Calcula tramos, costos y tiempos estimados.
     */
    public EstimacionRutaResponse estimarRuta(EstimacionRutaRequest request) {
        // Simula un tramo directo (sin depósitos intermedios por ahora)
        // En una implementación real, aquí se consultaría Google Maps API

        Double distanciaKm = 150.0; // Simulated - debería venir de Google Maps
        Double consumoPromedio = 0.15; // 15L/100km promedio

        Double costoEstimado = calculoTarifaServicio.calcularCostoEstimadoTramo(distanciaKm, consumoPromedio);
        Double tiempoEstimado = calculoTarifaServicio.calcularTiempoEstimado(distanciaKm);

        EstimacionRutaResponse.TramoEstimado tramo = EstimacionRutaResponse.TramoEstimado.builder()
                .origenDescripcion(request.getOrigenDireccion())
                .destinoDescripcion(request.getDestinoDireccion())
                .distanciaKm(distanciaKm)
                .costoEstimado(costoEstimado)
                .tiempoEstimadoHoras(tiempoEstimado)
                .build();

        return EstimacionRutaResponse.builder()
                .costoEstimado(costoEstimado)
                .tiempoEstimadoHoras(tiempoEstimado)
                .tramos(List.of(tramo))
                .build();
    }

    /**
     * Asigna una ruta a una solicitud existente y la pasa a estado "PROGRAMADA".
     * Crea la ruta y sus tramos asociados.
     */
    @Transactional
    public Solicitud asignarRuta(Long idSolicitud, EstimacionRutaRequest datosRuta) {
        Solicitud solicitud = repositorio.findById(idSolicitud)
                .orElseThrow(() -> new RuntimeException("Solicitud no encontrada"));

        if (!"BORRADOR".equals(solicitud.getEstado())) {
            throw new RuntimeException("Solo se pueden asignar rutas a solicitudes en estado BORRADOR");
        }

        // Crear la ruta
        Ruta ruta = Ruta.builder()
                .idSolicitud(idSolicitud)
                .build();
        ruta = rutaRepositorio.save(ruta);

        // Crear tramo(s) - por ahora solo un tramo directo
        Double distanciaKm = 150.0; // Simulated
        Double consumoPromedio = 0.15;
        Double costoEstimado = calculoTarifaServicio.calcularCostoEstimadoTramo(distanciaKm, consumoPromedio);
        Double tiempoEstimado = calculoTarifaServicio.calcularTiempoEstimado(distanciaKm);

        Tramo tramo = Tramo.builder()
                .idRuta(ruta.getId())
                .origenDescripcion(solicitud.getOrigenDireccion())
                .destinoDescripcion(solicitud.getDestinoDireccion())
                .distanciaKm(distanciaKm)
                .estado("ESTIMADO")
                .fechaInicioEstimada(LocalDateTime.now().plusDays(1))
                .fechaFinEstimada(LocalDateTime.now().plusDays(1).plusHours(tiempoEstimado.longValue()))
                .build();
        tramoRepositorio.save(tramo);

        // Actualizar solicitud
        solicitud.setEstado("PROGRAMADA");
        solicitud.setCostoEstimado(costoEstimado);
        solicitud.setTiempoEstimado(tiempoEstimado);

        return repositorio.save(solicitud);
    }
}
