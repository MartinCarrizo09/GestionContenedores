-- =====================================================
-- BASE DE DATOS COMPLETA - GESTIÓN DE CONTENEDORES
-- Basado en el Diagrama ER del TP
-- =====================================================
-- 
-- Este archivo contiene:
-- 1. Creación de schemas (gestion, flota, logistica)
-- 2. Creación de todas las tablas según el diagrama ER
-- 3. Más de 50 registros de datos de prueba
-- 4. Índices para optimizar consultas
-- 5. Queries de verificación
--
-- EJECUTAR EN: Supabase SQL Editor
-- =====================================================

-- ============================================================
-- PASO 1: LIMPIAR Y CREAR SCHEMAS
-- ============================================================

-- Eliminar schemas existentes si quieres empezar desde cero
-- CUIDADO: Esto borrará todos los datos
-- DROP SCHEMA IF EXISTS gestion CASCADE;
-- DROP SCHEMA IF EXISTS flota CASCADE;
-- DROP SCHEMA IF EXISTS logistica CASCADE;

CREATE SCHEMA IF NOT EXISTS gestion;
CREATE SCHEMA IF NOT EXISTS flota;
CREATE SCHEMA IF NOT EXISTS logistica;


-- ============================================================
-- PASO 2: SCHEMA GESTION - Tablas según diagrama ER
-- ============================================================

-- Tabla: CLIENTE
CREATE TABLE IF NOT EXISTS gestion.clientes (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefono VARCHAR(50)
);

COMMENT ON TABLE gestion.clientes IS 'Clientes del sistema - representantes de empresas';
COMMENT ON COLUMN gestion.clientes.email IS 'Email único para login/contacto';


-- Tabla: DEPOSITOS
CREATE TABLE IF NOT EXISTS gestion.depositos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    direccion TEXT NOT NULL,
    latitud DOUBLE PRECISION,
    longitud DOUBLE PRECISION,
    costo_estadia_xdia DOUBLE PRECISION CHECK (costo_estadia_xdia >= 0)
);

COMMENT ON TABLE gestion.depositos IS 'Depósitos intermedios para almacenamiento temporal';
COMMENT ON COLUMN gestion.depositos.costo_estadia_xdia IS 'Costo de estadía por día';


-- Tabla: CONTENEDORES
CREATE TABLE IF NOT EXISTS gestion.contenedores (
    id BIGSERIAL PRIMARY KEY,
    codigo_identificacion VARCHAR(100) UNIQUE NOT NULL,
    peso DOUBLE PRECISION NOT NULL CHECK (peso > 0),
    volumen DOUBLE PRECISION NOT NULL CHECK (volumen > 0),
    id_cliente BIGINT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES gestion.clientes(id) ON DELETE CASCADE
);

CREATE INDEX idx_contenedor_cliente ON gestion.contenedores(id_cliente);
CREATE INDEX idx_contenedor_codigo ON gestion.contenedores(codigo_identificacion);

COMMENT ON TABLE gestion.contenedores IS 'Contenedores físicos a transportar';
COMMENT ON COLUMN gestion.contenedores.codigo_identificacion IS 'Código único del contenedor';


-- Tabla: TARIFAS
CREATE TABLE IF NOT EXISTS gestion.tarifas (
    id BIGSERIAL PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL,
    rango_peso_min DOUBLE PRECISION,
    rango_peso_max DOUBLE PRECISION,
    rango_volumen_min DOUBLE PRECISION,
    rango_volumen_max DOUBLE PRECISION,
    valor DOUBLE PRECISION NOT NULL CHECK (valor >= 0)
);

CREATE INDEX idx_tarifa_peso ON gestion.tarifas(rango_peso_min, rango_peso_max);
CREATE INDEX idx_tarifa_volumen ON gestion.tarifas(rango_volumen_min, rango_volumen_max);

COMMENT ON TABLE gestion.tarifas IS 'Tarifas según rangos de peso y volumen';


-- ============================================================
-- PASO 3: SCHEMA FLOTA - Tablas según diagrama ER
-- ============================================================

-- Tabla: CAMIONES
CREATE TABLE IF NOT EXISTS flota.camiones (
    patente VARCHAR(20) PRIMARY KEY,
    nombre_transportista VARCHAR(255) NOT NULL,
    telefono_transportista VARCHAR(50),
    capacidad_peso DOUBLE PRECISION NOT NULL CHECK (capacidad_peso > 0),
    capacidad_volumen DOUBLE PRECISION NOT NULL CHECK (capacidad_volumen > 0),
    consumo_combustible_km DOUBLE PRECISION NOT NULL CHECK (consumo_combustible_km > 0),
    costo_km DOUBLE PRECISION NOT NULL CHECK (costo_km > 0),
    disponible BOOLEAN DEFAULT true,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_camion_disponible ON flota.camiones(disponible);
CREATE INDEX idx_camion_transportista ON flota.camiones(nombre_transportista);

COMMENT ON TABLE flota.camiones IS 'Flota de camiones - patente como PK';
COMMENT ON COLUMN flota.camiones.patente IS 'Patente única del camión';


-- ============================================================
-- PASO 4: SCHEMA LOGISTICA - Tablas según diagrama ER
-- ============================================================

-- Tabla: SOLICITUDES
CREATE TABLE IF NOT EXISTS logistica.solicitudes (
    id BIGSERIAL PRIMARY KEY,
    numero_seguimiento VARCHAR(50) UNIQUE NOT NULL,
    id_contenedor BIGINT NOT NULL,
    id_cliente BIGINT NOT NULL,
    origen_direccion TEXT NOT NULL,
    origen_latitud DOUBLE PRECISION,
    origen_longitud DOUBLE PRECISION,
    destino_direccion TEXT NOT NULL,
    destino_latitud DOUBLE PRECISION,
    destino_longitud DOUBLE PRECISION,
    estado VARCHAR(50) NOT NULL DEFAULT 'pendiente',
    costo_estimado DOUBLE PRECISION,
    tiempo_estimado DOUBLE PRECISION,
    costo_final DOUBLE PRECISION,
    tiempo_real DOUBLE PRECISION
);

CREATE INDEX idx_solicitud_numero ON logistica.solicitudes(numero_seguimiento);
CREATE INDEX idx_solicitud_cliente ON logistica.solicitudes(id_cliente);
CREATE INDEX idx_solicitud_contenedor ON logistica.solicitudes(id_contenedor);
CREATE INDEX idx_solicitud_estado ON logistica.solicitudes(estado);

COMMENT ON TABLE logistica.solicitudes IS 'Solicitudes de transporte';
COMMENT ON COLUMN logistica.solicitudes.estado IS 'Estados: pendiente, en_proceso, completada, cancelada';


-- Tabla: RUTAS
CREATE TABLE IF NOT EXISTS logistica.rutas (
    id BIGSERIAL PRIMARY KEY,
    id_solicitud BIGINT UNIQUE NOT NULL,
    FOREIGN KEY (id_solicitud) REFERENCES logistica.solicitudes(id) ON DELETE CASCADE
);

CREATE INDEX idx_ruta_solicitud ON logistica.rutas(id_solicitud);

COMMENT ON TABLE logistica.rutas IS 'Rutas planificadas - una ruta por solicitud';


-- Tabla: TRAMOS
CREATE TABLE IF NOT EXISTS logistica.tramos (
    id BIGSERIAL PRIMARY KEY,
    id_ruta BIGINT NOT NULL,
    patente_camion VARCHAR(20),
    origen_descripcion TEXT,
    destino_descripcion TEXT,
    distancia_km DOUBLE PRECISION,
    estado VARCHAR(50) NOT NULL DEFAULT 'pendiente',
    fecha_inicio_estimada TIMESTAMP,
    fecha_fin_estimada TIMESTAMP,
    fecha_inicio_real TIMESTAMP,
    fecha_fin_real TIMESTAMP,
    costo_real DOUBLE PRECISION,
    FOREIGN KEY (id_ruta) REFERENCES logistica.rutas(id) ON DELETE CASCADE,
    FOREIGN KEY (patente_camion) REFERENCES flota.camiones(patente) ON DELETE SET NULL
);

CREATE INDEX idx_tramo_ruta ON logistica.tramos(id_ruta);
CREATE INDEX idx_tramo_camion ON logistica.tramos(patente_camion);
CREATE INDEX idx_tramo_estado ON logistica.tramos(estado);

COMMENT ON TABLE logistica.tramos IS 'Tramos de cada ruta';
COMMENT ON COLUMN logistica.tramos.estado IS 'Estados: pendiente, en_curso, completado, cancelado';


-- Tabla: CONFIGURACION
CREATE TABLE IF NOT EXISTS logistica.configuracion (
    id BIGSERIAL PRIMARY KEY,
    clave VARCHAR(100) UNIQUE NOT NULL,
    valor TEXT NOT NULL
);

CREATE INDEX idx_config_clave ON logistica.configuracion(clave);

COMMENT ON TABLE logistica.configuracion IS 'Configuración del sistema';


-- ============================================================
-- PASO 5: INSERTAR DATOS DE PRUEBA (50+ registros)
-- ============================================================

-- ==================== SCHEMA GESTION ====================

-- Clientes (15 registros)
INSERT INTO gestion.clientes (nombre, apellido, email, telefono) VALUES
('Juan Carlos', 'Rodríguez', 'jrodriguez@logisticadelsur.com', '+54 351 400-1000'),
('María Elena', 'Martínez', 'mmartinez@transportesunidos.com', '+54 351 400-2000'),
('Roberto', 'Gómez', 'rgomez@elprogreso.com', '+54 351 400-3000'),
('Ana Paula', 'Fernández', 'afernandez@districentral.com', '+54 351 400-4000'),
('Diego', 'López', 'dlopez@exportargentina.com', '+54 351 400-5000'),
('Patricia', 'Sánchez', 'psanchez@delnorte.com', '+54 351 400-6000'),
('Gabriel', 'Torres', 'gtorres@metalcor.com', '+54 351 400-7000'),
('Laura', 'Ruiz', 'lruiz@alimentosfrescos.com', '+54 351 400-8000'),
('Fernando', 'Castro', 'fcastro@comercialcentro.com', '+54 351 400-9000'),
('Silvia', 'Morales', 'smorales@distribuidoraeste.com', '+54 351 400-1100'),
('Lucas', 'Romero', 'lromero@importexport.com', '+54 351 400-1200'),
('Marina', 'Díaz', 'mdiaz@logisticacba.com', '+54 351 400-1300'),
('Sebastián', 'Álvarez', 'salvarez@transportescba.com', '+54 351 400-1400'),
('Valentina', 'Herrera', 'vherrera@cargasrapidas.com', '+54 351 400-1500'),
('Maximiliano', 'Benítez', 'mbenitez@distribuidoranacional.com', '+54 351 400-1600')
ON CONFLICT (email) DO NOTHING;

-- Depósitos (8 registros)
INSERT INTO gestion.depositos (nombre, direccion, latitud, longitud, costo_estadia_xdia) VALUES
('Depósito Central Córdoba', 'Av. Circunvalación Km 5, Córdoba', -31.4201, -64.1888, 150.00),
('Depósito Zona Norte', 'Ruta 9 Km 680, Córdoba', -31.3500, -64.1500, 120.00),
('Depósito Zona Sur', 'Camino a Alta Gracia Km 12, Córdoba', -31.5000, -64.2000, 130.00),
('Depósito Zona Este', 'Ruta E-55 Km 8, Córdoba', -31.4000, -64.1000, 125.00),
('Depósito Zona Oeste', 'Av. de Circunvalación Km 10, Córdoba', -31.4500, -64.2500, 140.00),
('Depósito Aeropuerto', 'Zona Aeropuerto Internacional, Córdoba', -31.3236, -64.2080, 200.00),
('Depósito Industrial Norte', 'Parque Industrial Ferreyra, Córdoba', -31.3800, -64.1200, 110.00),
('Depósito Rural Este', 'Zona Rural Km 15, Córdoba', -31.4300, -64.0800, 100.00)
ON CONFLICT DO NOTHING;

-- Contenedores (25 registros)
INSERT INTO gestion.contenedores (codigo_identificacion, peso, volumen, id_cliente) VALUES
-- Cliente 1
('CONT-20-001', 2300.0, 33.2, 1),
('CONT-20-002', 2350.0, 33.2, 1),
('CONT-40-001', 3800.0, 67.7, 1),
-- Cliente 2
('CONT-20-003', 2280.0, 33.0, 2),
('CONT-40-002', 3850.0, 68.0, 2),
('CONT-40-003', 3780.0, 67.5, 2),
-- Cliente 3
('CONT-40-004', 4200.0, 75.0, 3),
('CONT-40-005', 4150.0, 74.5, 3),
-- Cliente 4
('REEF-20-001', 3000.0, 28.3, 4),
('REEF-20-002', 3050.0, 28.5, 4),
('REEF-40-001', 4800.0, 59.3, 4),
-- Cliente 5
('TANK-20-001', 3500.0, 26.0, 5),
('TANK-20-002', 3480.0, 25.8, 5),
('TANK-40-001', 5200.0, 52.0, 5),
-- Cliente 6
('OPEN-20-001', 2400.0, 32.5, 6),
('OPEN-40-001', 4000.0, 65.0, 6),
-- Cliente 7
('FLAT-20-001', 2800.0, 30.0, 7),
('FLAT-40-001', 5000.0, 60.0, 7),
-- Cliente 8
('CONT-20-004', 2320.0, 33.1, 8),
('CONT-40-006', 3820.0, 67.8, 8),
-- Clientes adicionales
('CONT-20-005', 2290.0, 32.8, 9),
('CONT-40-007', 3900.0, 68.5, 10),
('REEF-20-003', 3100.0, 28.0, 11),
('TANK-20-003', 3450.0, 26.2, 12),
('CONT-40-008', 4050.0, 70.0, 13)
ON CONFLICT (codigo_identificacion) DO NOTHING;

-- Tarifas (15 registros - diferentes rangos)
INSERT INTO gestion.tarifas (descripcion, rango_peso_min, rango_peso_max, rango_volumen_min, rango_volumen_max, valor) VALUES
-- Tarifas para contenedores pequeños
('Tarifa Contenedor Pequeño - Corta Distancia', 0, 3000, 0, 35, 3000.00),
('Tarifa Contenedor Pequeño - Media Distancia', 0, 3000, 0, 35, 4500.00),
('Tarifa Contenedor Pequeño - Larga Distancia', 0, 3000, 0, 35, 7000.00),
-- Tarifas para contenedores medianos
('Tarifa Contenedor Mediano - Corta Distancia', 3001, 4500, 35, 70, 4000.00),
('Tarifa Contenedor Mediano - Media Distancia', 3001, 4500, 35, 70, 6000.00),
('Tarifa Contenedor Mediano - Larga Distancia', 3001, 4500, 35, 70, 9500.00),
-- Tarifas para contenedores grandes
('Tarifa Contenedor Grande - Corta Distancia', 4501, 10000, 70, 150, 5500.00),
('Tarifa Contenedor Grande - Media Distancia', 4501, 10000, 70, 150, 8000.00),
('Tarifa Contenedor Grande - Larga Distancia', 4501, 10000, 70, 150, 12000.00),
-- Tarifas para cargas muy pesadas
('Tarifa Carga Pesada - Corta Distancia', 10001, 20000, 150, 300, 8000.00),
('Tarifa Carga Pesada - Media Distancia', 10001, 20000, 150, 300, 12000.00),
('Tarifa Carga Pesada - Larga Distancia', 10001, 20000, 150, 300, 18000.00),
-- Tarifas especiales para alto volumen
('Tarifa Volumen Alto - Peso Bajo', 0, 2000, 80, 200, 6500.00),
('Tarifa Volumen Muy Alto - Peso Bajo', 0, 2000, 200, 500, 10000.00),
('Tarifa Express - Cualquier Tamaño', 0, 50000, 0, 500, 15000.00)
ON CONFLICT DO NOTHING;


-- ==================== SCHEMA FLOTA ====================

-- Camiones (15 registros)
INSERT INTO flota.camiones (patente, nombre_transportista, telefono_transportista, capacidad_peso, capacidad_volumen, consumo_combustible_km, costo_km, disponible) VALUES
-- Camiones originales del ejemplo
('AB123CD', 'Carlos Rodríguez', '+54 351 111-2222', 5000.0, 30.0, 0.35, 120.0, true),
('EF456GH', 'Laura Martínez', '+54 351 333-4444', 8000.0, 45.0, 0.45, 150.0, true),
('IJ789KL', 'Roberto Sánchez', '+54 351 555-6666', 10000.0, 60.0, 0.55, 180.0, true),
-- Camiones adicionales disponibles
('MN012OP', 'Ana García', '+54 351 777-8888', 6000.0, 35.0, 0.38, 130.0, true),
('QR345ST', 'Miguel Torres', '+54 351 999-0000', 7500.0, 40.0, 0.42, 145.0, true),
('UV678WX', 'Patricia López', '+54 351 111-3333', 9000.0, 50.0, 0.50, 165.0, true),
('YZ901AB', 'Diego Fernández', '+54 351 222-4444', 12000.0, 70.0, 0.60, 200.0, true),
('CD234EF', 'Gabriela Ruiz', '+54 351 333-5555', 5500.0, 32.0, 0.36, 125.0, true),
('OP123QR', 'Lucas Romero', '+54 351 666-8888', 3000.0, 20.0, 0.25, 100.0, true),
('ST456UV', 'Marina Díaz', '+54 351 777-9999', 4000.0, 25.0, 0.30, 110.0, true),
-- Camiones en uso
('GH567IJ', 'Fernando Castro', '+54 351 444-6666', 8500.0, 48.0, 0.48, 160.0, false),
('KL890MN', 'Silvia Morales', '+54 351 555-7777', 11000.0, 65.0, 0.58, 190.0, false),
-- Camiones premium
('WX012YZ', 'Ricardo Álvarez', '+54 351 888-1111', 15000.0, 80.0, 0.70, 220.0, true),
('AB345CD', 'Mónica Herrera', '+54 351 888-2222', 13500.0, 75.0, 0.65, 210.0, true),
('EF678GH', 'Jorge Benítez', '+54 351 888-3333', 14000.0, 78.0, 0.68, 215.0, true)
ON CONFLICT (patente) DO NOTHING;


-- ==================== SCHEMA LOGISTICA ====================

-- Configuración (10 registros)
INSERT INTO logistica.configuracion (clave, valor) VALUES
('velocidad_promedio_camion', '60'),
('tiempo_carga_descarga_min', '30'),
('margen_seguridad_tiempo', '15'),
('radio_busqueda_deposito', '100'),
('costo_administrativo', '500'),
('iva_porcentaje', '21'),
('email_notificaciones', 'logistica@gestioncontenedores.com'),
('habilitar_notificaciones', 'true'),
('max_distancia_tramo', '300'),
('tiempo_descanso_conductor', '60')
ON CONFLICT (clave) DO NOTHING;

-- Solicitudes (15 registros)
INSERT INTO logistica.solicitudes (numero_seguimiento, id_contenedor, id_cliente, origen_direccion, origen_latitud, origen_longitud, destino_direccion, destino_latitud, destino_longitud, estado, costo_estimado, tiempo_estimado, costo_final, tiempo_real) VALUES
-- Solicitudes pendientes
('SOL-2025-001', 1, 1, 'Av. Colón 1234, Córdoba', -31.4201, -64.1888, 'Ruta 9 Km 680', -31.3500, -64.1500, 'pendiente', 3775.00, 1.5, NULL, NULL),
('SOL-2025-002', 4, 2, 'Calle San Martín 567, Córdoba', -31.4100, -64.1900, 'Camino a Alta Gracia Km 12', -31.5000, -64.2000, 'pendiente', 4140.00, 2.0, NULL, NULL),
('SOL-2025-003', 7, 3, 'Bv. San Juan 890, Córdoba', -31.4150, -64.1850, 'Ruta E-55 Km 8', -31.4000, -64.1000, 'pendiente', 3615.00, 1.2, NULL, NULL),
('SOL-2025-012', 21, 9, 'Av. Vélez Sarsfield 500, Córdoba', -31.4250, -64.1880, 'Depósito Central', -31.4201, -64.1888, 'pendiente', 3200.00, 1.0, NULL, NULL),
('SOL-2025-013', 22, 10, 'Calle Deán Funes 200, Córdoba', -31.4180, -64.1850, 'Depósito Zona Norte', -31.3500, -64.1500, 'pendiente', 4800.00, 2.5, NULL, NULL),
-- Solicitudes en proceso
('SOL-2025-004', 9, 4, 'Av. Vélez Sarsfield 2345, Córdoba', -31.4300, -64.1950, 'Zona Aeropuerto Internacional', -31.3236, -64.2080, 'en_proceso', 3935.00, 1.8, NULL, NULL),
('SOL-2025-005', 12, 5, 'Calle Independencia 678, Córdoba', -31.4180, -64.1880, 'Av. Circunvalación Km 5', -31.4201, -64.1888, 'en_proceso', 4660.00, 1.0, NULL, NULL),
('SOL-2025-014', 23, 11, 'Parque Industrial, Lote 8', -31.3850, -64.1250, 'Depósito Zona Sur', -31.5000, -64.2000, 'en_proceso', 5200.00, 2.8, NULL, NULL),
-- Solicitudes completadas
('SOL-2025-006', 15, 6, 'Av. Rivadavia 1111, Córdoba', -31.4220, -64.1920, 'Ruta 9 Km 680', -31.3500, -64.1500, 'completada', 5092.00, 2.5, 5150.00, 2.7),
('SOL-2025-007', 17, 7, 'Parque Industrial Norte, Lote 15', -31.3800, -64.1700, 'Depósito Central', -31.4201, -64.1888, 'completada', 4200.00, 1.5, 4180.00, 1.4),
('SOL-2025-010', 19, 8, 'Zona Rural Km 5', -31.4400, -64.2100, 'Depósito Industrial Norte', -31.3800, -64.1200, 'completada', 6800.00, 3.0, 6750.00, 2.9),
('SOL-2025-011', 20, 8, 'Ruta E-55 Km 15', -31.4100, -64.0900, 'Depósito Aeropuerto', -31.3236, -64.2080, 'completada', 7200.00, 3.5, 7380.00, 3.8),
-- Solicitudes canceladas
('SOL-2025-008', 18, 7, 'Zona Rural Km 8.5', -31.4500, -64.2200, 'Av. Circunvalación Km 10', -31.4500, -64.2500, 'cancelada', 8825.00, 3.5, NULL, NULL),
('SOL-2025-009', 2, 1, 'Depósito Zona Norte', -31.3500, -64.1500, 'Depósito Zona Sur', -31.5000, -64.2000, 'cancelada', 6200.00, 2.8, NULL, NULL),
-- Solicitud adicional completada
('SOL-2025-015', 25, 13, 'Av. Rafael Núñez 4500, Córdoba', -31.3900, -64.2300, 'Depósito Rural Este', -31.4300, -64.0800, 'completada', 9500.00, 4.2, 9650.00, 4.5)
ON CONFLICT (numero_seguimiento) DO NOTHING;

-- Rutas (10 registros - solo para solicitudes con rutas activas o completadas)
INSERT INTO logistica.rutas (id_solicitud) VALUES
(4),  -- SOL-2025-004 (en_proceso)
(5),  -- SOL-2025-005 (en_proceso)
(6),  -- SOL-2025-006 (completada)
(7),  -- SOL-2025-007 (completada)
(8),  -- SOL-2025-014 (en_proceso)
(10), -- SOL-2025-010 (completada)
(11), -- SOL-2025-011 (completada)
(15)  -- SOL-2025-015 (completada)
ON CONFLICT (id_solicitud) DO NOTHING;

-- Tramos (20 registros - distribuidos en las rutas)
INSERT INTO logistica.tramos (id_ruta, patente_camion, origen_descripcion, destino_descripcion, distancia_km, estado, fecha_inicio_estimada, fecha_fin_estimada, fecha_inicio_real, fecha_fin_real, costo_real) VALUES
-- Tramos para ruta 1 (SOL-2025-004 - en_proceso)
(1, 'AB123CD', 'Av. Vélez Sarsfield 2345, Córdoba', 'Av. Circunvalación', 9.2, 'completado', CURRENT_TIMESTAMP - INTERVAL '6 hours', CURRENT_TIMESTAMP - INTERVAL '5 hours', CURRENT_TIMESTAMP - INTERVAL '6 hours', CURRENT_TIMESTAMP - INTERVAL '5 hours', 1100.00),
(1, 'AB123CD', 'Av. Circunvalación', 'Zona Aeropuerto Internacional', 9.5, 'en_curso', CURRENT_TIMESTAMP - INTERVAL '5 hours', CURRENT_TIMESTAMP + INTERVAL '1 hour', CURRENT_TIMESTAMP - INTERVAL '5 hours', NULL, NULL),

-- Tramos para ruta 2 (SOL-2025-005 - en_proceso)
(2, 'EF456GH', 'Calle Independencia 678, Córdoba', 'Av. Circunvalación Km 5', 3.2, 'en_curso', CURRENT_TIMESTAMP - INTERVAL '1 hour', CURRENT_TIMESTAMP + INTERVAL '30 minutes', CURRENT_TIMESTAMP - INTERVAL '1 hour', NULL, NULL),

-- Tramos para ruta 3 (SOL-2025-006 - completada)
(3, 'IJ789KL', 'Av. Rivadavia 1111, Córdoba', 'Punto control Norte', 8.5, 'completado', CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '1 hour', CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '55 minutes', 1020.00),
(3, 'IJ789KL', 'Punto control Norte', 'Ruta 9 Km 680', 8.3, 'completado', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '1 hour', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '55 minutes', CURRENT_TIMESTAMP - INTERVAL '5 days', 996.00),

-- Tramos para ruta 4 (SOL-2025-007 - completada)
(4, 'MN012OP', 'Parque Industrial Norte, Lote 15', 'Depósito Central', 12.8, 'completado', CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '90 minutes', CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '85 minutes', 1536.00),

-- Tramos para ruta 5 (SOL-2025-014 - en_proceso)
(5, 'QR345ST', 'Parque Industrial, Lote 8', 'Depósito Intermedio', 15.2, 'completado', CURRENT_TIMESTAMP - INTERVAL '4 hours', CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP - INTERVAL '4 hours', CURRENT_TIMESTAMP - INTERVAL '3 hours', 1824.00),
(5, 'QR345ST', 'Depósito Intermedio', 'Depósito Zona Sur', 18.5, 'en_curso', CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP + INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '3 hours', NULL, NULL),

-- Tramos para ruta 6 (SOL-2025-010 - completada)
(6, 'UV678WX', 'Zona Rural Km 5', 'Depósito Industrial Norte', 22.3, 'completado', CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '10 days' + INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '10 days' + INTERVAL '110 minutes', 2676.00),

-- Tramos para ruta 7 (SOL-2025-011 - completada)
(7, 'YZ901AB', 'Ruta E-55 Km 15', 'Punto control Este', 12.5, 'completado', CURRENT_TIMESTAMP - INTERVAL '12 days', CURRENT_TIMESTAMP - INTERVAL '12 days' + INTERVAL '90 minutes', CURRENT_TIMESTAMP - INTERVAL '12 days', CURRENT_TIMESTAMP - INTERVAL '12 days' + INTERVAL '85 minutes', 1500.00),
(7, 'YZ901AB', 'Punto control Este', 'Depósito Aeropuerto', 16.8, 'completado', CURRENT_TIMESTAMP - INTERVAL '12 days' + INTERVAL '90 minutes', CURRENT_TIMESTAMP - INTERVAL '11 days', CURRENT_TIMESTAMP - INTERVAL '12 days' + INTERVAL '85 minutes', CURRENT_TIMESTAMP - INTERVAL '11 days', 2016.00),

-- Tramos para ruta 8 (SOL-2025-015 - completada)
(8, 'CD234EF', 'Av. Rafael Núñez 4500, Córdoba', 'Depósito Central (parada)', 18.2, 'completado', CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_TIMESTAMP - INTERVAL '15 days' + INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_TIMESTAMP - INTERVAL '15 days' + INTERVAL '115 minutes', 2184.00),
(8, 'CD234EF', 'Depósito Central (parada)', 'Depósito Zona Este (intermedio)', 14.5, 'completado', CURRENT_TIMESTAMP - INTERVAL '15 days' + INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '14 days', CURRENT_TIMESTAMP - INTERVAL '15 days' + INTERVAL '115 minutes', CURRENT_TIMESTAMP - INTERVAL '14 days' + INTERVAL '90 minutes', 1740.00),
(8, 'CD234EF', 'Depósito Zona Este (intermedio)', 'Depósito Rural Este', 25.3, 'completado', CURRENT_TIMESTAMP - INTERVAL '14 days' + INTERVAL '90 minutes', CURRENT_TIMESTAMP - INTERVAL '13 days', CURRENT_TIMESTAMP - INTERVAL '14 days' + INTERVAL '90 minutes', CURRENT_TIMESTAMP - INTERVAL '13 days', 3036.00),

-- Tramos adicionales para mejor cobertura de datos
(1, 'AB123CD', 'Depósito temporal A', 'Destino final', 5.8, 'pendiente', CURRENT_TIMESTAMP + INTERVAL '1 hour', CURRENT_TIMESTAMP + INTERVAL '3 hours', NULL, NULL, NULL),
(2, 'EF456GH', 'Parada intermedia', 'Destino final B', 8.2, 'pendiente', CURRENT_TIMESTAMP + INTERVAL '30 minutes', CURRENT_TIMESTAMP + INTERVAL '2 hours', NULL, NULL, NULL),
(5, 'QR345ST', 'Checkpoint C', 'Destino final SOL-014', 6.5, 'pendiente', CURRENT_TIMESTAMP + INTERVAL '2 hours', CURRENT_TIMESTAMP + INTERVAL '4 hours', NULL, NULL, NULL),
(3, 'IJ789KL', 'Verificación final', 'Punto entrega', 2.1, 'completado', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '30 minutes', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '25 minutes', 252.00),
(4, 'MN012OP', 'Control de calidad', 'Entrega cliente', 3.8, 'completado', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '85 minutes', CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '85 minutes', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '30 minutes', 456.00)
ON CONFLICT DO NOTHING;


-- ============================================================
-- PASO 6: QUERIES DE VERIFICACIÓN
-- ============================================================

-- Resumen general del sistema
SELECT 
    'Clientes' as entidad,
    COUNT(*) as total
FROM gestion.clientes
UNION ALL
SELECT 'Depósitos', COUNT(*) FROM gestion.depositos
UNION ALL
SELECT 'Contenedores', COUNT(*) FROM gestion.contenedores
UNION ALL
SELECT 'Tarifas', COUNT(*) FROM gestion.tarifas
UNION ALL
SELECT 'Camiones', COUNT(*) FROM flota.camiones
UNION ALL
SELECT 'Solicitudes', COUNT(*) FROM logistica.solicitudes
UNION ALL
SELECT 'Rutas', COUNT(*) FROM logistica.rutas
UNION ALL
SELECT 'Tramos', COUNT(*) FROM logistica.tramos
UNION ALL
SELECT 'Configuraciones', COUNT(*) FROM logistica.configuracion
ORDER BY entidad;

-- Verificar relaciones
SELECT 
    'Total de registros insertados:' as resumen,
    (SELECT COUNT(*) FROM gestion.clientes) +
    (SELECT COUNT(*) FROM gestion.depositos) +
    (SELECT COUNT(*) FROM gestion.contenedores) +
    (SELECT COUNT(*) FROM gestion.tarifas) +
    (SELECT COUNT(*) FROM flota.camiones) +
    (SELECT COUNT(*) FROM logistica.solicitudes) +
    (SELECT COUNT(*) FROM logistica.rutas) +
    (SELECT COUNT(*) FROM logistica.tramos) +
    (SELECT COUNT(*) FROM logistica.configuracion) as total;


-- ============================================================
-- SCRIPT COMPLETADO EXITOSAMENTE
-- ============================================================
-- 
-- Total de datos insertados: 50+ registros
-- - 15 clientes
-- - 8 depósitos
-- - 25 contenedores
-- - 15 tarifas
-- - 15 camiones
-- - 15 solicitudes
-- - 8 rutas
-- - 20 tramos
-- - 10 configuraciones
--
-- TOTAL: 131 registros
-- ============================================================
