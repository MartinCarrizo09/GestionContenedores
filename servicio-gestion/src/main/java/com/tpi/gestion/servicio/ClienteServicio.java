package com.tpi.gestion.servicio;

import com.tpi.gestion.modelo.Cliente;
import com.tpi.gestion.repositorio.ClienteRepositorio;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ClienteServicio {

    private final ClienteRepositorio repositorio;

    public ClienteServicio(ClienteRepositorio repositorio) {
        this.repositorio = repositorio;
    }

    public List<Cliente> listar() {
        return repositorio.findAll();
    }

    public Optional<Cliente> buscarPorId(Long id) {
        return repositorio.findById(id);
    }

    public Cliente guardar(Cliente cliente) {
        if (repositorio.existsByEmail(cliente.getEmail())) {
            throw new RuntimeException("Ya existe un cliente con ese correo electrónico");
        }
        return repositorio.save(cliente);
    }

    public Cliente actualizar(Long id, Cliente datos) {
        return repositorio.findById(id)
                .map(c -> {
                    c.setNombre(datos.getNombre());
                    c.setApellido(datos.getApellido());
                    c.setEmail(datos.getEmail());
                    c.setTelefono(datos.getTelefono());
                    return repositorio.save(c);
                })
                .orElseThrow(() -> new RuntimeException("Cliente no encontrado"));
    }

    public void eliminar(Long id) {
        if (!repositorio.existsById(id)) {
            throw new RuntimeException("Cliente no encontrado con ID: " + id);
        }
        repositorio.deleteById(id);
    }
}
