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
import com.tpi.logistica.dto.ContenedorPendienteResponse;
import com.tpi.logistica.dto.googlemaps.DistanciaYDuracion;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;

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
    private final RestTemplate restTemplate;

    public SolicitudServicio(SolicitudRepositorio repositorio,
                            RutaRepositorio rutaRepositorio,
                            TramoRepositorio tramoRepositorio,
                            CalculoTarifaServicio calculoTarifaServicio,
                            GoogleMapsService googleMapsService,
                            RestTemplate restTemplate) {
        this.repositorio = repositorio;
        this.rutaRepositorio = rutaRepositorio;
        this.tramoRepositorio = tramoRepositorio;
        this.calculoTarifaServicio = calculoTarifaServicio;
        this.googleMapsService = googleMapsService;
        this.restTemplate = restTemplate;
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
        
        // ✅ IMPLEMENTADO: Validar que el cliente exista, si no, crearlo automáticamente
        Long idCliente = nuevaSolicitud.getIdCliente();
        validarOCrearCliente(idCliente);
        
        // ✅ IMPLEMENTADO: Validar que el contenedor exista
        Long idContenedor = nuevaSolicitud.getIdContenedor();
        validarContenedor(idContenedor);
        
        // Estado inicial debe ser BORRADOR
        if (nuevaSolicitud.getEstado() == null || nuevaSolicitud.getEstado().isEmpty()) {
            nuevaSolicitud.setEstado("BORRADOR");
        }
        
        return repositorio.save(nuevaSolicitud);
    }
    
    /**
     * Valida que el cliente exista en servicio-gestion.
     * Si no existe, crea un cliente genérico automáticamente (Requisito 1 del TPI).
     */
    private void validarOCrearCliente(Long idCliente) {
        String urlGestion = "http://localhost:8080/clientes/" + idCliente;
        
        try {
            // Intentar obtener el cliente
            restTemplate.getForObject(urlGestion, ClienteDTO.class);
            // Si no lanza excepción, el cliente existe
            
        } catch (HttpClientErrorException.NotFound e) {
            // Cliente no existe - crear automáticamente
            System.out.println("⚠️ Cliente ID " + idCliente + " no encontrado. Creando automáticamente...");
            
            ClienteDTO nuevoCliente = new ClienteDTO();
            nuevoCliente.setNombre("Cliente");
            nuevoCliente.setApellido("AutoGenerado-" + idCliente);
            nuevoCliente.setEmail("cliente" + idCliente + "@autogenerado.com");
            nuevoCliente.setTelefono("+54-11-0000-0000");
            nuevoCliente.setCuil("20-" + String.format("%08d", idCliente) + "-0");
            
            try {
                restTemplate.postForObject("http://localhost:8080/clientes", nuevoCliente, ClienteDTO.class);
                System.out.println("✅ Cliente ID " + idCliente + " creado automáticamente");
            } catch (Exception ex) {
                throw new RuntimeException("Error al crear cliente automáticamente: " + ex.getMessage());
            }
            
        } catch (Exception e) {
            throw new RuntimeException("Error al validar cliente con servicio-gestion: " + e.getMessage() + 
                ". Verifique que el servicio-gestion esté disponible en http://localhost:8080");
        }
    }
    
    /**
     * Valida que el contenedor exista en servicio-gestion.
     */
    private void validarContenedor(Long idContenedor) {
        String urlGestion = "http://localhost:8080/contenedores/" + idContenedor;
        
        try {
            restTemplate.getForObject(urlGestion, ContenedorDTO.class);
            // Si no lanza excepción, el contenedor existe
            
        } catch (HttpClientErrorException.NotFound e) {
            throw new RuntimeException("El contenedor con ID " + idContenedor + " no existe. " +
                "Debe crear el contenedor antes de registrar la solicitud.");
                
        } catch (Exception e) {
            throw new RuntimeException("Error al validar contenedor con servicio-gestion: " + e.getMessage() + 
                ". Verifique que el servicio-gestion esté disponible en http://localhost:8080");
        }
    }
    
    /**
     * DTO interno para cliente (servicio-gestion).
     */
    private static class ClienteDTO {
        private Long id;
        private String nombre;
        private String apellido;
        private String email;
        private String telefono;
        private String cuil;
        
        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getNombre() { return nombre; }
        public void setNombre(String nombre) { this.nombre = nombre; }
        public String getApellido() { return apellido; }
        public void setApellido(String apellido) { this.apellido = apellido; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getTelefono() { return telefono; }
        public void setTelefono(String telefono) { this.telefono = telefono; }
        public String getCuil() { return cuil; }
        public void setCuil(String cuil) { this.cuil = cuil; }
    }
    
    /**
     * DTO interno para contenedor (servicio-gestion).
     */
    private static class ContenedorDTO {
        private Long id;
        private String codigoIdentificacion;
        private Double peso;
        private Double volumen;
        
        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getCodigoIdentificacion() { return codigoIdentificacion; }
        public void setCodigoIdentificacion(String codigoIdentificacion) { this.codigoIdentificacion = codigoIdentificacion; }
        public Double getPeso() { return peso; }
        public void setPeso(Double peso) { this.peso = peso; }
        public Double getVolumen() { return volumen; }
        public void setVolumen(Double volumen) { this.volumen = volumen; }
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
     * Obtiene todas las solicitudes pendientes de entrega (no están en estado ENTREGADA).
     * Permite filtrar por estado específico o por ID de contenedor.
     */
    public List<ContenedorPendienteResponse> listarPendientes(String estadoFiltro, Long idContenedor) {
        List<Solicitud> solicitudes;
        
        if (idContenedor != null) {
            // Filtrar por contenedor específico - excluir completadas y canceladas
            solicitudes = repositorio.findByIdContenedor(idContenedor).stream()
                    .filter(s -> !esEstadoFinal(s.getEstado()))
                    .toList();
        } else if (estadoFiltro != null && !estadoFiltro.isEmpty()) {
            // Filtrar por estado específico
            solicitudes = repositorio.findByEstado(estadoFiltro);
        } else {
            // Obtener todas EXCEPTO las completadas, canceladas y entregadas
            solicitudes = repositorio.findAll().stream()
                    .filter(s -> !esEstadoFinal(s.getEstado()))
                    .toList();
        }
        
        return solicitudes.stream()
                .map(this::convertirAContenedorPendiente)
                .toList();
    }
    
    /**
     * Verifica si un estado es final (no pendiente de entrega).
     * Estados finales: completada, cancelada, entregada
     */
    private boolean esEstadoFinal(String estado) {
        if (estado == null) return false;
        String estadoLower = estado.toLowerCase();
        return estadoLower.equals("completada") || 
               estadoLower.equals("cancelada") || 
               estadoLower.equals("entregada");
    }

    /**
     * Convierte una Solicitud a ContenedorPendienteResponse con información del tramo actual.
     */
    private ContenedorPendienteResponse convertirAContenedorPendiente(Solicitud solicitud) {
        // Buscar ruta asociada
        List<Ruta> rutas = rutaRepositorio.findByIdSolicitud(solicitud.getId());
        
        ContenedorPendienteResponse.ContenedorPendienteResponseBuilder builder = 
                ContenedorPendienteResponse.builder()
                .idSolicitud(solicitud.getId())
                .numeroSeguimiento(solicitud.getNumeroSeguimiento())
                .idContenedor(solicitud.getIdContenedor())
                .idCliente(solicitud.getIdCliente())
                .estado(solicitud.getEstado())
                .costoEstimado(solicitud.getCostoEstimado())
                .costoFinal(solicitud.getCostoFinal());
        
        // Determinar ubicación actual basándose en el estado y tramos
        if (!rutas.isEmpty()) {
            Ruta ruta = rutas.get(0);
            List<Tramo> tramos = tramoRepositorio.findByIdRuta(ruta.getId());
            
            // Buscar el tramo activo (iniciado pero no finalizado)
            Optional<Tramo> tramoActivo = tramos.stream()
                    .filter(t -> "INICIADO".equals(t.getEstado()) || "ASIGNADO".equals(t.getEstado()))
                    .findFirst();
            
            if (tramoActivo.isPresent()) {
                Tramo tramo = tramoActivo.get();
                
                if ("INICIADO".equals(tramo.getEstado())) {
                    builder.ubicacionActual("EN_TRANSITO")
                           .descripcionUbicacion("En viaje de " + tramo.getOrigenDescripcion() + 
                                                " hacia " + tramo.getDestinoDescripcion());
                } else {
                    builder.ubicacionActual("EN_DEPOSITO")
                           .descripcionUbicacion("En depósito: " + tramo.getOrigenDescripcion());
                }
                
                builder.tramoActual(ContenedorPendienteResponse.TramoActual.builder()
                        .idTramo(tramo.getId())
                        .origen(tramo.getOrigenDescripcion())
                        .destino(tramo.getDestinoDescripcion())
                        .estadoTramo(tramo.getEstado())
                        .patenteCamion(tramo.getPatenteCamion())
                        .build());
            } else {
                // Buscar último tramo finalizado
                Optional<Tramo> ultimoFinalizado = tramos.stream()
                        .filter(t -> "FINALIZADO".equals(t.getEstado()))
                        .reduce((first, second) -> second); // Obtener el último
                
                if (ultimoFinalizado.isPresent()) {
                    builder.ubicacionActual("EN_DEPOSITO")
                           .descripcionUbicacion("En depósito: " + 
                                                ultimoFinalizado.get().getDestinoDescripcion());
                } else {
                    builder.ubicacionActual("PENDIENTE_ASIGNACION")
                           .descripcionUbicacion("Pendiente de asignación de camión");
                }
            }
        } else {
            builder.ubicacionActual("ORIGEN")
                   .descripcionUbicacion("En punto de origen: " + solicitud.getOrigenDireccion());
        }
        
        return builder.build();
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
