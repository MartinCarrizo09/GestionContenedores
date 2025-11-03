package com.tpi.gestion.modelo;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.*;

/**
 * Representa un cliente del sistema.
 * Los clientes pueden generar solicitudes y tener contenedores asociados.
 */
@Entity
@Table(name = "clientes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;

    @NotBlank(message = "El apellido es obligatorio")
    private String apellido;

    @Email(message = "Debe ingresar un correo válido")
    @Column(unique = true)
    private String email;

    @Pattern(regexp = "^[0-9\\-\\+\\s]{6,20}$", message = "El teléfono contiene un formato inválido")
    private String telefono;
}
