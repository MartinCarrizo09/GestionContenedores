package com.tpi.logistica.servicio;

import com.tpi.logistica.modelo.Tramo;
import com.tpi.logistica.repositorio.TramoRepositorio;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * Servicio que contiene la lógica de negocio para gestionar tramos.
 */
@Service
public class TramoServicio {

    private final TramoRepositorio repositorio;

    public TramoServicio(TramoRepositorio repositorio) {
        this.repositorio = repositorio;
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
}
