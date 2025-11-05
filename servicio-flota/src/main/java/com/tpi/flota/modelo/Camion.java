package com.tpi.flota.modelo;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.*;

/**
 * Entidad que representa un camión de la flota.
 * Según DER: patente, nombre_transportista, telefono_transportista,
 * capacidad_peso, capacidad_volumen, consumo_combustible_km, costo_km, disponible
 */
@Entity
@Table(name = "camiones", schema = "flota")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Camion {

    @Id
    @NotBlank(message = "La patente es obligatoria")
    @Column(nullable = false)
    private String patente;

    @NotBlank(message = "El nombre del transportista es obligatorio")
    @Column(name = "nombre_transportista")
    private String nombreTransportista;

    @Column(name = "telefono_transportista")
    private String telefonoTransportista;

    @PositiveOrZero(message = "La capacidad de peso debe ser mayor o igual a 0")
    @Column(name = "capacidad_peso")
    private Double capacidadPeso;

    @PositiveOrZero(message = "La capacidad de volumen debe ser mayor o igual a 0")
    @Column(name = "capacidad_volumen")
    private Double capacidadVolumen;

    @Positive(message = "El consumo de combustible debe ser mayor a 0")
    @Column(name = "consumo_combustible_km")
    private Double consumoCombustibleKm;

    @Positive(message = "El costo por km debe ser mayor a 0")
    @Column(name = "costo_km")
    private Double costoKm;

    @Builder.Default
    @Column(nullable = false)
    private Boolean disponible = true;
}

