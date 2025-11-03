package com.tpi.servicio_logistica.servicio;

import com.tpi.servicio_logistica.modelo.Ruta;
import com.tpi.servicio_logistica.repositorio.RutaRepositorio;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * Servicio que contiene la lógica de negocio para gestionar rutas.
 */
@Service
public class RutaServicio {

    private final RutaRepositorio repositorio;

    public RutaServicio(RutaRepositorio repositorio) {
        this.repositorio = repositorio;
    }

    public List<Ruta> listar() {
        return repositorio.findAll();
    }

    public Optional<Ruta> buscarPorId(Long id) {
        return repositorio.findById(id);
    }

    public List<Ruta> listarPorSolicitud(Long idSolicitud) {
        return repositorio.findByIdSolicitud(idSolicitud);
    }

    public Ruta guardar(Ruta nuevaRuta) {
        return repositorio.save(nuevaRuta);
    }

    public Ruta actualizar(Long id, Ruta datosActualizados) {
        return repositorio.findById(id)
                .map(ruta -> {
                    ruta.setIdSolicitud(datosActualizados.getIdSolicitud());
                    return repositorio.save(ruta);
                })
                .orElseThrow(() -> new RuntimeException("Ruta no encontrada"));
    }

    public void eliminar(Long id) {
        repositorio.deleteById(id);
    }
}

