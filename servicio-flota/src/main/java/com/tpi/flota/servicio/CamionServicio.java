package com.tpi.flota.servicio;

import com.tpi.flota.modelo.Camion;
import com.tpi.flota.repositorio.CamionRepositorio;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * Servicio que contiene la lógica de negocio para gestionar camiones.
 */
@Service
public class CamionServicio {

    private final CamionRepositorio repositorio;

    public CamionServicio(CamionRepositorio repositorio) {
        this.repositorio = repositorio;
    }

    public List<Camion> listar() {
        return repositorio.findAll();
    }

    public Optional<Camion> buscarPorId(Long id) {
        return repositorio.findById(id);
    }

    public Optional<Camion> buscarPorPatente(String patente) {
        return repositorio.findByPatente(patente);
    }

    public List<Camion> listarDisponibles() {
        return repositorio.findByDisponible(true);
    }

    public Camion guardar(Camion nuevoCamion) {
        if (repositorio.existsByPatente(nuevoCamion.getPatente())) {
            throw new RuntimeException("Ya existe un camión con esa patente");
        }
        return repositorio.save(nuevoCamion);
    }

    public Camion actualizar(Long id, Camion datosActualizados) {
        return repositorio.findById(id)
                .map(camion -> {
                    camion.setPatente(datosActualizados.getPatente());
                    camion.setNombreTransportista(datosActualizados.getNombreTransportista());
                    camion.setTelefonoTransportista(datosActualizados.getTelefonoTransportista());
                    camion.setCapacidadPeso(datosActualizados.getCapacidadPeso());
                    camion.setCapacidadVolumen(datosActualizados.getCapacidadVolumen());
                    camion.setConsumoCombustibleKm(datosActualizados.getConsumoCombustibleKm());
                    camion.setCostoKm(datosActualizados.getCostoKm());
                    camion.setDisponible(datosActualizados.getDisponible());
                    return repositorio.save(camion);
                })
                .orElseThrow(() -> new RuntimeException("Camión no encontrado"));
    }

    public Camion cambiarDisponibilidad(Long id, Boolean disponible) {
        return repositorio.findById(id)
                .map(camion -> {
                    camion.setDisponible(disponible);
                    return repositorio.save(camion);
                })
                .orElseThrow(() -> new RuntimeException("Camión no encontrado"));
    }

    public void eliminar(Long id) {
        repositorio.deleteById(id);
    }
}

