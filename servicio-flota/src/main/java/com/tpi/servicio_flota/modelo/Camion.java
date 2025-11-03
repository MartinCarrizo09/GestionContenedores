package com.tpi.servicio_flota.modelo;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import lombok.*;

/**
 * Entidad que representa un camión de la flota.
 * Según DER: patente, nombre_transportista, telefono_transportista,
 * capacidad_peso, capacidad_volumen, consumo_combustible_km, costo_km, disponible
 */
@Entity
@Table(name = "camiones")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Camion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "La patente es obligatoria")
    @Column(unique = true, nullable = false)
    private String patente;

    @NotBlank(message = "El nombre del transportista es obligatorio")
    @Column(name = "nombre_transportista")
    private String nombreTransportista;

    @Column(name = "telefono_transportista")
    private String telefonoTransportista;

    @Positive(message = "La capacidad de peso debe ser mayor a 0")
    @Column(name = "capacidad_peso")
    private Double capacidadPeso;

    @Positive(message = "La capacidad de volumen debe ser mayor a 0")
    @Column(name = "capacidad_volumen")
    private Double capacidadVolumen;

    @Positive(message = "El consumo de combustible debe ser mayor a 0")
    @Column(name = "consumo_combustible_km")
    private Double consumoCombustibleKm;

    @Positive(message = "El costo por km debe ser mayor a 0")
    @Column(name = "costo_km")
    private Double costoKm;

    @Column(nullable = false)
    private Boolean disponible = true;
}

