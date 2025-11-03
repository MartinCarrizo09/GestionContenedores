package com.tpi.gestion.modelo;

/**
 * Enumeración que representa los posibles estados de un contenedor.
 */
public enum EstadoContenedor {
    DISPONIBLE,      // El contenedor está libre y puede ser usado
    EN_USO,          // Actualmente está asignado a una solicitud
    MANTENIMIENTO    // Fuera de servicio temporalmente
}
