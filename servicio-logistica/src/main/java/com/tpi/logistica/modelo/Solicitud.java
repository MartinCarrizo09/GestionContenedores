package com.tpi.logistica.modelo;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

/**
 * Entidad Solicitud según DER.
 * Campos: id, numero_seguimiento, id_contenedor, id_cliente,
 * origen_direccion, origen_latitud, origen_longitud,
 * destino_direccion, destino_latitud, destino_longitud,
 * estado, costo_estimado, tiempo_estimado, costo_final, tiempo_real
 */
@Entity
@Table(name = "solicitudes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Solicitud {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "El número de seguimiento es obligatorio")
    @Column(name = "numero_seguimiento", unique = true, nullable = false)
    private String numeroSeguimiento;

    @NotNull(message = "El ID del contenedor es obligatorio")
    @Column(name = "id_contenedor")
    private Long idContenedor;

    @NotNull(message = "El ID del cliente es obligatorio")
    @Column(name = "id_cliente")
    private Long idCliente;

    @Column(name = "origen_direccion")
    private String origenDireccion;

    @Column(name = "origen_latitud")
    private Double origenLatitud;

    @Column(name = "origen_longitud")
    private Double origenLongitud;

    @Column(name = "destino_direccion")
    private String destinoDireccion;

    @Column(name = "destino_latitud")
    private Double destinoLatitud;

    @Column(name = "destino_longitud")
    private Double destinoLongitud;

    @NotBlank(message = "El estado es obligatorio")
    @Column(nullable = false)
    private String estado;

    @Column(name = "costo_estimado")
    private Double costoEstimado;

    @Column(name = "tiempo_estimado")
    private Double tiempoEstimado;

    @Column(name = "costo_final")
    private Double costoFinal;

    @Column(name = "tiempo_real")
    private Double tiempoReal;
}

