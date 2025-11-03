package com.tpi.gestion.repositorio;

import com.tpi.gestion.modelo.Deposito;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Interfaz que gestiona las operaciones de persistencia
 * sobre la entidad Depósito usando Spring Data JPA.
 */
@Repository
public interface DepositoRepositorio extends JpaRepository<Deposito, Long> {
}
