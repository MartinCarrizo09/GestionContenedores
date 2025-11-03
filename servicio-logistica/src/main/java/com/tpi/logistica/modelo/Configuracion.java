package com.tpi.logistica.modelo;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

/**
 * Entidad Configuracion según DER.
 * Campos: id, clave, valor
 */
@Entity
@Table(name = "configuracion")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Configuracion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "La clave es obligatoria")
    @Column(unique = true, nullable = false)
    private String clave;

    @NotBlank(message = "El valor es obligatorio")
    @Column(nullable = false)
    private String valor;
}

