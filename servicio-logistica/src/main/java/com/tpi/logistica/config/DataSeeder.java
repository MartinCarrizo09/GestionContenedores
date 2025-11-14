package com.tpi.logistica.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.LocalDateTime;
import java.sql.Timestamp;

@Configuration
public class DataSeeder {

    private static final Logger log = LoggerFactory.getLogger(DataSeeder.class);

    @Bean
    CommandLineRunner seedLogisticaData(JdbcTemplate jdbc) {
        return args -> {
            try {
                log.info("DataSeeder: iniciando verificación e inserción de datos de prueba en esquema logistica...");
                // Verificar si existen registros
                Integer solicitudes = jdbc.queryForObject("select count(1) from logistica.solicitudes", Integer.class);
                Integer rutas = jdbc.queryForObject("select count(1) from logistica.rutas", Integer.class);
                Integer tramos = jdbc.queryForObject("select count(1) from logistica.tramos", Integer.class);
                log.info("DataSeeder: conteos actuales -> solicitudes={}, rutas={}, tramos={}", solicitudes, rutas, tramos);

                // Insertar Solicitud id=1 si no existe
                Integer existeSolicitud1 = jdbc.queryForObject("select count(1) from logistica.solicitudes where id = 1", Integer.class);
                if (existeSolicitud1 == null || existeSolicitud1 == 0) {
                    log.info("Insertando solicitud de prueba id=1");
                    jdbc.update(
                        "insert into logistica.solicitudes (id, numero_seguimiento, id_contenedor, id_cliente, origen_direccion, destino_direccion, estado) values (1, ?, ?, ?, ?, ?, ?)",
                        "SEG-SEED-0001", 1L, 1L, "Origen Seed", "Destino Seed", "PROGRAMADA"
                    );
                }

                // Insertar Ruta id=1 para solicitud 1 si no existe
                Integer existeRuta1 = jdbc.queryForObject("select count(1) from logistica.rutas where id = 1", Integer.class);
                if (existeRuta1 == null || existeRuta1 == 0) {
                    log.info("Insertando ruta de prueba id=1 para solicitud id=1");
                    jdbc.update(
                        "insert into logistica.rutas (id, id_solicitud) values (1, 1)"
                    );
                }

                // Insertar Tramo id=1 para ruta 1 si no existe, en estado INICIADO
                Integer existeTramo1 = jdbc.queryForObject("select count(1) from logistica.tramos where id = 1", Integer.class);
                if (existeTramo1 == null || existeTramo1 == 0) {
                    log.info("Insertando tramo de prueba id=1 para ruta id=1 en estado INICIADO");
                    LocalDateTime inicio = LocalDateTime.now().minusDays(3);
                    jdbc.update(
                        "insert into logistica.tramos (id, id_ruta, origen_descripcion, destino_descripcion, distancia_km, estado, fecha_inicio_real) values (1, 1, ?, ?, ?, ?, ?)",
                        "Origen Seed", "Destino Seed", 10.0, "INICIADO", Timestamp.valueOf(inicio)
                    );
                }
            } catch (Exception e) {
                log.warn("DataSeeder: no se pudo ejecutar (posible ausencia de tablas aún): {}", e.getMessage());
            }
        };
    }
}


