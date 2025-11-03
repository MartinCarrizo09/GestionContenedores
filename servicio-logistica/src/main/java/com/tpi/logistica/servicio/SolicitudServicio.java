package com.tpi.logistica.servicio;

import com.tpi.logistica.modelo.Solicitud;
import com.tpi.logistica.modelo.Ruta;
import com.tpi.logistica.modelo.Tramo;
import com.tpi.logistica.repositorio.SolicitudRepositorio;
import com.tpi.logistica.repositorio.RutaRepositorio;
import com.tpi.logistica.repositorio.TramoRepositorio;
import com.tpi.logistica.dto.EstimacionRutaRequest;
import com.tpi.logistica.dto.EstimacionRutaResponse;
import com.tpi.logistica.dto.SeguimientoSolicitudResponse;
import com.tpi.logistica.dto.googlemaps.DistanciaYDuracion;
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
    private final GoogleMapsService googleMapsService;

    public SolicitudServicio(SolicitudRepositorio repositorio,
                            RutaRepositorio rutaRepositorio,
                            TramoRepositorio tramoRepositorio,
                            CalculoTarifaServicio calculoTarifaServicio,
                            GoogleMapsService googleMapsService) {
        this.repositorio = repositorio;
        this.rutaRepositorio = rutaRepositorio;
        this.tramoRepositorio = tramoRepositorio;
        this.calculoTarifaServicio = calculoTarifaServicio;
        this.googleMapsService = googleMapsService;
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
     * Calcula tramos, costos y tiempos estimados usando Google Maps API.
     */
    public EstimacionRutaResponse estimarRuta(EstimacionRutaRequest request) {
        // Calcular distancia real usando Google Maps API
        DistanciaYDuracion distancia;

        if (request.getOrigenLatitud() != null && request.getOrigenLongitud() != null &&
            request.getDestinoLatitud() != null && request.getDestinoLongitud() != null) {
            // Usar coordenadas si están disponibles
            distancia = googleMapsService.calcularDistanciaPorCoordenadas(
                request.getOrigenLatitud(), request.getOrigenLongitud(),
                request.getDestinoLatitud(), request.getDestinoLongitud()
            );
        } else {
            // Usar direcciones textuales
            distancia = googleMapsService.calcularDistanciaYDuracion(
                request.getOrigenDireccion(),
                request.getDestinoDireccion()
            );
        }

        Double distanciaKm = distancia.getDistanciaKm();
        Double tiempoEstimado = distancia.getDuracionHoras();
        Double consumoPromedio = 0.15; // 15L/100km promedio

        Double costoEstimado = calculoTarifaServicio.calcularCostoEstimadoTramo(distanciaKm, consumoPromedio);

        EstimacionRutaResponse.TramoEstimado tramo = EstimacionRutaResponse.TramoEstimado.builder()
                .origenDescripcion(distancia.getOrigenDireccion())
                .destinoDescripcion(distancia.getDestinoDireccion())
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
     * Crea la ruta y sus tramos asociados usando datos reales de Google Maps.
     */
    @Transactional
    public Solicitud asignarRuta(Long idSolicitud, EstimacionRutaRequest datosRuta) {
        Solicitud solicitud = repositorio.findById(idSolicitud)
                .orElseThrow(() -> new RuntimeException("Solicitud no encontrada"));

        if (!"BORRADOR".equals(solicitud.getEstado())) {
            throw new RuntimeException("Solo se pueden asignar rutas a solicitudes en estado BORRADOR");
        }

        // Calcular distancia real usando Google Maps
        DistanciaYDuracion distancia;

        if (solicitud.getOrigenLatitud() != null && solicitud.getOrigenLongitud() != null &&
            solicitud.getDestinoLatitud() != null && solicitud.getDestinoLongitud() != null) {
            distancia = googleMapsService.calcularDistanciaPorCoordenadas(
                solicitud.getOrigenLatitud(), solicitud.getOrigenLongitud(),
                solicitud.getDestinoLatitud(), solicitud.getDestinoLongitud()
            );
        } else {
            distancia = googleMapsService.calcularDistanciaYDuracion(
                solicitud.getOrigenDireccion(),
                solicitud.getDestinoDireccion()
            );
        }

        // Crear la ruta
        Ruta ruta = Ruta.builder()
                .idSolicitud(idSolicitud)
                .build();
        ruta = rutaRepositorio.save(ruta);

        // Crear tramo(s) con datos reales de Google Maps
        Double distanciaKm = distancia.getDistanciaKm();
        Double tiempoEstimadoHoras = distancia.getDuracionHoras();
        Double consumoPromedio = 0.15;
        Double costoEstimado = calculoTarifaServicio.calcularCostoEstimadoTramo(distanciaKm, consumoPromedio);

        Tramo tramo = Tramo.builder()
                .idRuta(ruta.getId())
                .origenDescripcion(distancia.getOrigenDireccion())
                .destinoDescripcion(distancia.getDestinoDireccion())
                .distanciaKm(distanciaKm)
                .estado("ESTIMADO")
                .fechaInicioEstimada(LocalDateTime.now().plusDays(1))
                .fechaFinEstimada(LocalDateTime.now().plusDays(1).plusHours(tiempoEstimadoHoras.longValue()))
                .build();
        tramoRepositorio.save(tramo);

        // Actualizar solicitud con datos reales
        solicitud.setEstado("PROGRAMADA");
        solicitud.setCostoEstimado(costoEstimado);
        solicitud.setTiempoEstimado(tiempoEstimadoHoras);

        return repositorio.save(solicitud);
    }

    /**
     * Obtiene el seguimiento detallado de una solicitud con historial cronológico.
     */
    public SeguimientoSolicitudResponse obtenerSeguimiento(String numeroSeguimiento) {
        Solicitud solicitud = repositorio.findByNumeroSeguimiento(numeroSeguimiento)
                .orElseThrow(() -> new RuntimeException("Solicitud no encontrada"));

        // Buscar ruta asociada
        List<Ruta> rutas = rutaRepositorio.findByIdSolicitud(solicitud.getId());
        List<SeguimientoSolicitudResponse.EventoSeguimiento> historial = new ArrayList<>();

        // Agregar evento de creación de solicitud
        historial.add(SeguimientoSolicitudResponse.EventoSeguimiento.builder()
                .fecha(LocalDateTime.now().minusDays(5)) // Simulado
                .evento("SOLICITUD_CREADA")
                .descripcion("Solicitud creada en el sistema")
                .estado("BORRADOR")
                .build());

        // Si hay ruta, agregar eventos de tramos
        if (!rutas.isEmpty()) {
            Ruta ruta = rutas.get(0);
            List<Tramo> tramos = tramoRepositorio.findByIdRuta(ruta.getId());

            historial.add(SeguimientoSolicitudResponse.EventoSeguimiento.builder()
                    .fecha(LocalDateTime.now().minusDays(4)) // Simulado
                    .evento("RUTA_ASIGNADA")
                    .descripcion("Ruta calculada con " + tramos.size() + " tramo(s)")
                    .estado("PROGRAMADA")
                    .build());

            // Agregar eventos de cada tramo
            for (Tramo tramo : tramos) {
                if (tramo.getFechaInicioReal() != null) {
                    historial.add(SeguimientoSolicitudResponse.EventoSeguimiento.builder()
                            .fecha(tramo.getFechaInicioReal())
                            .evento("TRAMO_INICIADO")
                            .descripcion("Inicio de tramo: " + tramo.getOrigenDescripcion() +
                                       " → " + tramo.getDestinoDescripcion())
                            .estado("EN_TRANSITO")
                            .build());
                }

                if (tramo.getFechaFinReal() != null) {
                    historial.add(SeguimientoSolicitudResponse.EventoSeguimiento.builder()
                            .fecha(tramo.getFechaFinReal())
                            .evento("TRAMO_FINALIZADO")
                            .descripcion("Fin de tramo: " + tramo.getOrigenDescripcion() +
                                       " → " + tramo.getDestinoDescripcion())
                            .estado(tramo.getEstado())
                            .build());
                }
            }
        }

        // Ordenar cronológicamente
        historial.sort((a, b) -> a.getFecha().compareTo(b.getFecha()));

        return SeguimientoSolicitudResponse.builder()
                .idSolicitud(solicitud.getId())
                .numeroSeguimiento(solicitud.getNumeroSeguimiento())
                .estadoActual(solicitud.getEstado())
                .costoEstimado(solicitud.getCostoEstimado())
                .costoFinal(solicitud.getCostoFinal())
                .tiempoEstimadoHoras(solicitud.getTiempoEstimado())
                .tiempoRealHoras(solicitud.getTiempoReal())
                .historial(historial)
                .build();
    }
}
