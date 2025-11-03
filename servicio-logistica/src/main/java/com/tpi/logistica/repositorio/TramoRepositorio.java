package com.tpi.logistica.repositorio;

import com.tpi.logistica.modelo.Tramo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio para gestionar las operaciones de persistencia de Tramo.
 */
@Repository
public interface TramoRepositorio extends JpaRepository<Tramo, Long> {

    List<Tramo> findByIdRuta(Long idRuta);

    List<Tramo> findByPatenteCamion(String patenteCamion);

    List<Tramo> findByEstado(String estado);
}

