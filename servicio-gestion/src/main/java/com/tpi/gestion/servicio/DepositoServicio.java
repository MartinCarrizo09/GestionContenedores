package com.tpi.gestion.servicio;

import com.tpi.gestion.modelo.Deposito;
import com.tpi.gestion.repositorio.DepositoRepositorio;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * Servicio que contiene la lógica de negocio para gestionar depósitos.
 * Se encarga de coordinar las operaciones entre el controlador y el repositorio.
 */
@Service
public class DepositoServicio {

    private final DepositoRepositorio repositorio;

    // Inyección del repositorio por constructor (forma recomendada)
    public DepositoServicio(DepositoRepositorio repositorio) {
        this.repositorio = repositorio;
    }

    // Obtener todos los depósitos
    public List<Deposito> listar() {
        return repositorio.findAll();
    }

    // Buscar un depósito por su ID
    public Optional<Deposito> buscarPorId(Long id) {
        return repositorio.findById(id);
    }

    // Crear o actualizar un depósito
    public Deposito guardar(Deposito nuevoDeposito) {
        return repositorio.save(nuevoDeposito);
    }

    // Actualizar los datos de un depósito existente
    public Deposito actualizar(Long id, Deposito datosActualizados) {
        return repositorio.findById(id)
                .map(deposito -> {
                    deposito.setNombre(datosActualizados.getNombre());
                    deposito.setDireccion(datosActualizados.getDireccion());
                    deposito.setLatitud(datosActualizados.getLatitud());
                    deposito.setLongitud(datosActualizados.getLongitud());
                    deposito.setCostoEstadiaXdia(datosActualizados.getCostoEstadiaXdia());
                    return repositorio.save(deposito);
                })
                .orElseThrow(() -> new RuntimeException("Depósito no encontrado"));
    }

    // Eliminar un depósito
    public void eliminar(Long id) {
        repositorio.deleteById(id);
    }
}
