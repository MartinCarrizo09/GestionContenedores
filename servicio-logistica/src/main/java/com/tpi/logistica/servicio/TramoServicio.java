package com.tpi.logistica.servicio;

import com.tpi.logistica.modelo.Tramo;
import com.tpi.logistica.repositorio.TramoRepositorio;
import com.tpi.logistica.repositorio.SolicitudRepositorio;
import com.tpi.logistica.repositorio.RutaRepositorio;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;

import java.time.LocalDateTime;
import java.time.Duration;
import java.util.List;
import java.util.Optional;
import java.util.Arrays;

/**
 * Servicio que contiene la lógica de negocio para gestionar tramos.
 */
@Service
public class TramoServicio {

    private final TramoRepositorio repositorio;
    private final SolicitudRepositorio solicitudRepositorio;
    private final RutaRepositorio rutaRepositorio;
    private final CalculoTarifaServicio calculoTarifaServicio;
    private final RestTemplate restTemplate;

    // Constructor con inyección de dependencias
    public TramoServicio(TramoRepositorio repositorio,
                        SolicitudRepositorio solicitudRepositorio,
                        RutaRepositorio rutaRepositorio,
                        CalculoTarifaServicio calculoTarifaServicio,
                        RestTemplate restTemplate) {
        this.repositorio = repositorio;
        this.solicitudRepositorio = solicitudRepositorio;
        this.rutaRepositorio = rutaRepositorio;
        this.calculoTarifaServicio = calculoTarifaServicio;
        this.restTemplate = restTemplate;
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
     * Valida que el camión pueda transportar el contenedor (peso y volumen).
     * 
     * ✅ Req 6: Asignar camión a tramo
     * ✅ Req 8: Validar peso del contenedor contra capacidad del camión
     * ✅ Req 11: Validar volumen del contenedor contra capacidad del camión
     */
    @Transactional
    public Tramo asignarCamion(Long idTramo, String patenteCamion, Double pesoContenedor, Double volumenContenedor) {
        Tramo tramo = repositorio.findById(idTramo)
                .orElseThrow(() -> new RuntimeException("Tramo no encontrado"));

        // Validar estado del tramo
        if (!"ESTIMADO".equals(tramo.getEstado())) {
            throw new RuntimeException("Solo se pueden asignar camiones a tramos en estado ESTIMADO");
        }

        // ✅ IMPLEMENTADO: Validar capacidad del camión con servicio-flota
        String urlFlota = "http://localhost:8081/camiones/aptos?peso=" + pesoContenedor + "&volumen=" + volumenContenedor;
        
        try {
            // Llamar al servicio-flota para obtener camiones aptos
            CamionDTO[] camionesAptos = restTemplate.getForObject(urlFlota, CamionDTO[].class);
            
            if (camionesAptos == null || camionesAptos.length == 0) {
                throw new RuntimeException("No hay camiones disponibles con capacidad suficiente para este contenedor " +
                    "(peso: " + pesoContenedor + "kg, volumen: " + volumenContenedor + "m³)");
            }
            
            // Verificar que el camión especificado está en la lista de aptos
            boolean camionApto = Arrays.stream(camionesAptos)
                .anyMatch(c -> c.getPatente().equals(patenteCamion));
            
            if (!camionApto) {
                throw new RuntimeException("El camión " + patenteCamion + 
                    " no tiene capacidad suficiente para transportar este contenedor " +
                    "(peso: " + pesoContenedor + "kg, volumen: " + volumenContenedor + "m³). " +
                    "Camiones disponibles aptos: " + Arrays.stream(camionesAptos)
                        .map(CamionDTO::getPatente)
                        .reduce((a, b) -> a + ", " + b)
                        .orElse("ninguno"));
            }
            
        } catch (HttpClientErrorException e) {
            throw new RuntimeException("Error al consultar capacidad del camión en servicio-flota: " + e.getMessage() + 
                ". Verifique que el servicio-flota esté disponible en http://localhost:8081");
        } catch (Exception e) {
            if (e instanceof RuntimeException) {
                throw e; // Re-lanzar excepciones de validación
            }
            throw new RuntimeException("Error inesperado al validar capacidad del camión: " + e.getMessage());
        }

        // Asignar camión y cambiar estado
        tramo.setPatenteCamion(patenteCamion);
        tramo.setEstado("ASIGNADO");

        return repositorio.save(tramo);
    }
    
    /**
     * DTO interno para deserializar respuesta del servicio-flota.
     * Solo incluye los campos necesarios para validación.
     */
    private static class CamionDTO {
        private String patente;
        private Double capacidadPeso;
        private Double capacidadVolumen;
        private Boolean disponible;
        
        public String getPatente() { return patente; }
        public void setPatente(String patente) { this.patente = patente; }
        public Double getCapacidadPeso() { return capacidadPeso; }
        public void setCapacidadPeso(Double capacidadPeso) { this.capacidadPeso = capacidadPeso; }
        public Double getCapacidadVolumen() { return capacidadVolumen; }
        public void setCapacidadVolumen(Double capacidadVolumen) { this.capacidadVolumen = capacidadVolumen; }
        public Boolean getDisponible() { return disponible; }
        public void setDisponible(Boolean disponible) { this.disponible = disponible; }
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
        tramo.setCostoReal(costoReal);

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

        // Calcular tiempo real total en horas
        final Duration[] tiempoTotal = {Duration.ZERO};
        final Double[] costoTotal = {0.0};

        for (Tramo t : tramos) {
            if (t.getFechaInicioReal() != null && t.getFechaFinReal() != null) {
                tiempoTotal[0] = tiempoTotal[0].plus(
                    Duration.between(t.getFechaInicioReal(), t.getFechaFinReal())
                );
            }
            if (t.getCostoReal() != null) {
                costoTotal[0] += t.getCostoReal();
            }
        }

        // ✅ MEJORADO: Buscar la solicitud correcta asociada a la ruta
        rutaRepositorio.findById(idRuta).ifPresent(ruta -> {
            solicitudRepositorio.findById(ruta.getIdSolicitud()).ifPresent(solicitud -> {
                // Actualizar solo si está en estado apropiado
                if ("PROGRAMADA".equals(solicitud.getEstado()) || "EN_TRANSITO".equals(solicitud.getEstado())) {
                    solicitud.setTiempoReal(tiempoTotal[0].toHours() + (tiempoTotal[0].toMinutesPart() / 60.0));
                    solicitud.setCostoFinal(costoTotal[0]);
                    solicitud.setEstado("ENTREGADA");
                    solicitudRepositorio.save(solicitud);
                    
                    System.out.println("✅ Solicitud ID " + solicitud.getId() + " marcada como ENTREGADA");
                    System.out.println("   - Costo final: $" + costoTotal[0]);
                    System.out.println("   - Tiempo real: " + solicitud.getTiempoReal() + " horas");
                }
            });
        });
    }
}
