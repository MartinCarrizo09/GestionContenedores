package com.tpi.flota.repositorio;

import com.tpi.flota.modelo.Camion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repositorio para gestionar las operaciones de persistencia de Camion.
 */
@Repository
public interface CamionRepositorio extends JpaRepository<Camion, Long> {

    Optional<Camion> findByPatente(String patente);

    List<Camion> findByDisponible(Boolean disponible);

    boolean existsByPatente(String patente);
}

