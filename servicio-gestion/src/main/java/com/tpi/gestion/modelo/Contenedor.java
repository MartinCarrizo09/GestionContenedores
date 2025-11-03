package com.tpi.gestion.modelo;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.*;

/**
 * Entidad que representa un contenedor físico a transportar.
 * Está asociado a un cliente y se usa en los traslados logísticos.
 */
@Entity
@Table(name = "contenedores")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Contenedor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @DecimalMin(value = "0.1", message = "El peso del contenedor debe ser mayor a 0")
    private Double pesoKg;

    @DecimalMin(value = "0.1", message = "El volumen del contenedor debe ser mayor a 0")
    private Double volumenM3;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EstadoContenedor estado;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cliente_id", nullable = false)
    @NotNull(message = "El contenedor debe pertenecer a un cliente")
    private Cliente cliente;
}
