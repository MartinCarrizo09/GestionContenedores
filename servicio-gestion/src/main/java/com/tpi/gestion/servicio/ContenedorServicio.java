package com.tpi.gestion.servicio;

import com.tpi.gestion.modelo.Cliente;
import com.tpi.gestion.modelo.Contenedor;
import com.tpi.gestion.repositorio.ClienteRepositorio;
import com.tpi.gestion.repositorio.ContenedorRepositorio;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ContenedorServicio {

    private final ContenedorRepositorio contenedorRepo;
    private final ClienteRepositorio clienteRepo;

    public ContenedorServicio(ContenedorRepositorio contenedorRepo, ClienteRepositorio clienteRepo) {
        this.contenedorRepo = contenedorRepo;
        this.clienteRepo = clienteRepo;
    }

    public List<Contenedor> listar() {
        return contenedorRepo.findAll();
    }

    public List<Contenedor> listarPorCliente(Long idCliente) {
        return contenedorRepo.findByClienteId(idCliente);
    }

    public Optional<Contenedor> buscarPorId(Long id) {
        return contenedorRepo.findById(id);
    }

    public Contenedor guardar(Contenedor nuevo) {
        if (contenedorRepo.existsByCodigoIdentificacion(nuevo.getCodigoIdentificacion())) {
            throw new RuntimeException("Ya existe un contenedor con ese código de identificación");
        }

        // Validar que el cliente exista antes de guardar
        Cliente cliente = clienteRepo.findById(nuevo.getCliente().getId())
                .orElseThrow(() -> new RuntimeException("El cliente indicado no existe"));

        nuevo.setCliente(cliente);
        return contenedorRepo.save(nuevo);
    }

    public Contenedor actualizar(Long id, Contenedor datos) {
        return contenedorRepo.findById(id)
                .map(c -> {
                    c.setCodigoIdentificacion(datos.getCodigoIdentificacion());
                    c.setPeso(datos.getPeso());
                    c.setVolumen(datos.getVolumen());
                    
                    // Buscar y cargar el cliente completo si viene un ID de cliente
                    if (datos.getCliente() != null && datos.getCliente().getId() != null) {
                        Cliente cliente = clienteRepo.findById(datos.getCliente().getId())
                                .orElseThrow(() -> new RuntimeException("El cliente indicado no existe"));
                        c.setCliente(cliente);
                    }
                    
                    return contenedorRepo.save(c);
                })
                .orElseThrow(() -> new RuntimeException("Contenedor no encontrado"));
    }

    public void eliminar(Long id) {
        contenedorRepo.deleteById(id);
    }
}
