package com.tpi.gestion.repositorio;

import com.tpi.gestion.modelo.Contenedor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ContenedorRepositorio extends JpaRepository<Contenedor, Long> {

    // Buscar todos los contenedores de un cliente específico
    List<Contenedor> findByClienteId(Long idCliente);

    // Verificar si existe un contenedor con el mismo código
    boolean existsByCodigoIdentificacion(String codigoIdentificacion);

    // Buscar contenedor por código de identificación
    java.util.Optional<Contenedor> findByCodigoIdentificacion(String codigoIdentificacion);
}
