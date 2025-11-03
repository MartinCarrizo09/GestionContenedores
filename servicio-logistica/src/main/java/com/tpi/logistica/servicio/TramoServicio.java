package com.tpi.logistica.servicio;

import com.tpi.logistica.modelo.Tramo;
import com.tpi.logistica.modelo.Solicitud;
import com.tpi.logistica.repositorio.TramoRepositorio;
import com.tpi.logistica.repositorio.SolicitudRepositorio;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.time.Duration;
import java.util.List;
import java.util.Optional;

/**
 * Servicio que contiene la lógica de negocio para gestionar tramos.
 */
@Service
public class TramoServicio {

    private final TramoRepositorio repositorio;
    private final SolicitudRepositorio solicitudRepositorio;
    private final CalculoTarifaServicio calculoTarifaServicio;
    private final RestTemplate restTemplate;

    public TramoServicio(TramoRepositorio repositorio,
                        SolicitudRepositorio solicitudRepositorio,
                        CalculoTarifaServicio calculoTarifaServicio) {
        this.repositorio = repositorio;
        this.solicitudRepositorio = solicitudRepositorio;
        this.calculoTarifaServicio = calculoTarifaServicio;
        this.restTemplate = new RestTemplate();
    }

    public List<Tramo> listar() {
        return repositorio.findAll();
    }

    public Optional<Tramo> buscarPorId(Long id) {
        return repositorio.findById(id);
    }

    public List<Tramo> listarPorRuta(Long idRuta) {
        return repositorio.findByIdRuta(idRuta);
    }

    public List<Tramo> listarPorCamion(String patenteCamion) {
        return repositorio.findByPatenteCamion(patenteCamion);
    }

    public List<Tramo> listarPorEstado(String estado) {
        return repositorio.findByEstado(estado);
    }

    public Tramo guardar(Tramo nuevoTramo) {
        return repositorio.save(nuevoTramo);
    }

    public Tramo actualizar(Long id, Tramo datosActualizados) {
        return repositorio.findById(id)
                .map(tramo -> {
                    tramo.setIdRuta(datosActualizados.getIdRuta());
                    tramo.setPatenteCamion(datosActualizados.getPatenteCamion());
                    tramo.setOrigenDescripcion(datosActualizados.getOrigenDescripcion());
                    tramo.setDestinoDescripcion(datosActualizados.getDestinoDescripcion());
                    tramo.setDistanciaKm(datosActualizados.getDistanciaKm());
                    tramo.setEstado(datosActualizados.getEstado());
                    tramo.setFechaInicioEstimada(datosActualizados.getFechaInicioEstimada());
                    tramo.setFechaFinEstimada(datosActualizados.getFechaFinEstimada());
                    tramo.setFechaInicioReal(datosActualizados.getFechaInicioReal());
                    tramo.setFechaFinReal(datosActualizados.getFechaFinReal());
                    return repositorio.save(tramo);
                })
                .orElseThrow(() -> new RuntimeException("Tramo no encontrado"));
    }

    public void eliminar(Long id) {
        repositorio.deleteById(id);
    }

    /**
     * Asigna un camión a un tramo.
     * Valida que el camión pueda transportar el contenedor.
     */
    @Transactional
    public Tramo asignarCamion(Long idTramo, String patenteCamion, Double pesoContenedor, Double volumenContenedor) {
        // Validar capacidad del camión llamando a servicio-flota
        String urlFlota = "http://localhost:8081/api-flota/api/camiones/" + patenteCamion;

        try {
            // Aquí se debería hacer la llamada real al servicio de flota
            // Por ahora simulo la validación

            Tramo tramo = repositorio.findById(idTramo)
                    .orElseThrow(() -> new RuntimeException("Tramo no encontrado"));

            if (!"ESTIMADO".equals(tramo.getEstado())) {
                throw new RuntimeException("Solo se pueden asignar camiones a tramos en estado ESTIMADO");
            }

            tramo.setPatenteCamion(patenteCamion);
            tramo.setEstado("ASIGNADO");

            return repositorio.save(tramo);

        } catch (Exception e) {
            throw new RuntimeException("Error al validar capacidad del camión: " + e.getMessage());
        }
    }

    /**
     * Inicia un tramo registrando la fecha/hora real de inicio.
     */
    @Transactional
    public Tramo iniciarTramo(Long idTramo) {
        Tramo tramo = repositorio.findById(idTramo)
                .orElseThrow(() -> new RuntimeException("Tramo no encontrado"));

        if (!"ASIGNADO".equals(tramo.getEstado())) {
            throw new RuntimeException("Solo se pueden iniciar tramos en estado ASIGNADO");
        }

        tramo.setFechaInicioReal(LocalDateTime.now());
        tramo.setEstado("INICIADO");

        return repositorio.save(tramo);
    }

    /**
     * Finaliza un tramo registrando la fecha/hora real de fin.
     * Si es el último tramo de la ruta, calcula el costo y tiempo real total.
     */
    @Transactional
    public Tramo finalizarTramo(Long idTramo, Double kmReales, Double costoKmCamion, Double consumoCamion) {
        Tramo tramo = repositorio.findById(idTramo)
                .orElseThrow(() -> new RuntimeException("Tramo no encontrado"));

        if (!"INICIADO".equals(tramo.getEstado())) {
            throw new RuntimeException("Solo se pueden finalizar tramos en estado INICIADO");
        }

        tramo.setFechaFinReal(LocalDateTime.now());
        tramo.setDistanciaKm(kmReales); // Actualiza con distancia real
        tramo.setEstado("FINALIZADO");

        // Calcular costo real del tramo
        Double costoReal = calculoTarifaServicio.calcularCostoRealTramo(kmReales, costoKmCamion, consumoCamion);
        // Aquí deberías agregar un campo costoReal en la entidad Tramo

        tramo = repositorio.save(tramo);

        // Verificar si es el último tramo y actualizar la solicitud
        List<Tramo> tramosRuta = repositorio.findByIdRuta(tramo.getIdRuta());
        boolean todosFinalizados = tramosRuta.stream()
                .allMatch(t -> "FINALIZADO".equals(t.getEstado()));

        if (todosFinalizados) {
            // Calcular costo y tiempo real total
            actualizarSolicitudFinal(tramo.getIdRuta(), tramosRuta);
        }

        return tramo;
    }

    private void actualizarSolicitudFinal(Long idRuta, List<Tramo> tramos) {
        // Buscar la solicitud asociada a esta ruta
        // Calcular tiempo real total
        Duration tiempoTotal = Duration.ZERO;
        for (Tramo t : tramos) {
            if (t.getFechaInicioReal() != null && t.getFechaFinReal() != null) {
                tiempoTotal = tiempoTotal.plus(
                    Duration.between(t.getFechaInicioReal(), t.getFechaFinReal())
                );
            }
        }

        // Aquí deberías actualizar la solicitud con el tiempo real y costo real
        // y cambiar su estado a "ENTREGADA"
    }
}
