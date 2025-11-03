package com.tpi.logistica.modelo;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;

/**
 * Entidad Ruta según DER.
 * Campos: id, id_solicitud
 */
@Entity
@Table(name = "rutas")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Ruta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "El ID de la solicitud es obligatorio")
    @Column(name = "id_solicitud")
    private Long idSolicitud;
}

