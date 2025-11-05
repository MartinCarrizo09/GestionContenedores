-- ============================================================
-- SCRIPTS SQL PARA SUPABASE - GESTIONCONTENEDORES
-- ============================================================
-- 
-- Estos scripts crean los 3 schemas y todas las tablas
-- necesarias para el sistema de gestión de contenedores.
--
-- INSTRUCCIONES:
-- 1. Ve a Supabase > SQL Editor
-- 2. Ejecuta este script completo
-- 3. Verifica que todo se creó correctamente
--
-- ============================================================

-- ============================================================
-- PASO 1: CREAR SCHEMAS
-- ============================================================

CREATE SCHEMA IF NOT EXISTS gestion;
CREATE SCHEMA IF NOT EXISTS flota;
CREATE SCHEMA IF NOT EXISTS logistica;

-- Verificar schemas creados
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name IN ('gestion', 'flota', 'logistica');


-- ============================================================
-- PASO 2: SCHEMA GESTION
-- ============================================================

SET search_path TO gestion;

-- Tabla: clientes
CREATE TABLE IF NOT EXISTS clientes (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefono VARCHAR(50),
    direccion TEXT,
    latitud DOUBLE PRECISION,
    longitud DOUBLE PRECISION,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE clientes IS 'Clientes del sistema que solicitan transporte de contenedores';
COMMENT ON COLUMN clientes.latitud IS 'Latitud de la ubicación del cliente (-90 a 90)';
COMMENT ON COLUMN clientes.longitud IS 'Longitud de la ubicación del cliente (-180 a 180)';


-- Tabla: contenedores
CREATE TABLE IF NOT EXISTS contenedores (
    id BIGSERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    peso_kg DOUBLE PRECISION NOT NULL CHECK (peso_kg > 0),
    volumen_m3 DOUBLE PRECISION NOT NULL CHECK (volumen_m3 > 0),
    estado VARCHAR(50) DEFAULT 'disponible',
    cliente_id BIGINT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE SET NULL
);

CREATE INDEX idx_contenedor_cliente ON contenedores(cliente_id);
CREATE INDEX idx_contenedor_estado ON contenedores(estado);

COMMENT ON TABLE contenedores IS 'Contenedores físicos a transportar';
COMMENT ON COLUMN contenedores.codigo IS 'Código único de identificación del contenedor';
COMMENT ON COLUMN contenedores.peso_kg IS 'Peso del contenedor en kilogramos';
COMMENT ON COLUMN contenedores.volumen_m3 IS 'Volumen del contenedor en metros cúbicos';
COMMENT ON COLUMN contenedores.estado IS 'Estado: disponible, en_transito, entregado';


-- Tabla: depositos
CREATE TABLE IF NOT EXISTS depositos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    direccion TEXT NOT NULL,
    latitud DOUBLE PRECISION NOT NULL,
    longitud DOUBLE PRECISION NOT NULL,
    capacidad_maxima INTEGER,
    costo_diario DOUBLE PRECISION NOT NULL CHECK (costo_diario >= 0),
    activo BOOLEAN DEFAULT true,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_deposito_activo ON depositos(activo);

COMMENT ON TABLE depositos IS 'Depósitos intermedios para almacenamiento temporal';
COMMENT ON COLUMN depositos.costo_diario IS 'Costo de estadía por día en el depósito';
COMMENT ON COLUMN depositos.capacidad_maxima IS 'Capacidad máxima de contenedores';


-- Tabla: tarifas
CREATE TABLE IF NOT EXISTS tarifas (
    id BIGSERIAL PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL,
    tipo_tarifa VARCHAR(50) NOT NULL,
    rango_peso_min DOUBLE PRECISION,
    rango_peso_max DOUBLE PRECISION,
    rango_volumen_min DOUBLE PRECISION,
    rango_volumen_max DOUBLE PRECISION,
    valor DOUBLE PRECISION NOT NULL CHECK (valor >= 0),
    vigente BOOLEAN DEFAULT true,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tarifa_tipo ON tarifas(tipo_tarifa);
CREATE INDEX idx_tarifa_vigente ON tarifas(vigente);

COMMENT ON TABLE tarifas IS 'Tarifas del sistema según peso y volumen';
COMMENT ON COLUMN tarifas.tipo_tarifa IS 'Tipo: base, peso, volumen, distancia';
COMMENT ON COLUMN tarifas.valor IS 'Valor de la tarifa en moneda local';


-- ============================================================
-- PASO 3: SCHEMA FLOTA
-- ============================================================

SET search_path TO flota;

-- Tabla: camiones
CREATE TABLE IF NOT EXISTS camiones (
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

CREATE INDEX idx_camion_disponible ON camiones(disponible);
CREATE INDEX idx_camion_transportista ON camiones(nombre_transportista);

COMMENT ON TABLE camiones IS 'Flota de camiones disponibles para transporte';
COMMENT ON COLUMN camiones.patente IS 'Patente/dominio del camión (identificador único)';
COMMENT ON COLUMN camiones.capacidad_peso IS 'Capacidad máxima de peso en kg';
COMMENT ON COLUMN camiones.capacidad_volumen IS 'Capacidad máxima de volumen en m³';
COMMENT ON COLUMN camiones.consumo_combustible_km IS 'Consumo de combustible por kilómetro';
COMMENT ON COLUMN camiones.costo_km IS 'Costo base por kilómetro recorrido';


-- ============================================================
-- PASO 4: SCHEMA LOGISTICA
-- ============================================================

SET search_path TO logistica;

-- Tabla: solicitudes
CREATE TABLE IF NOT EXISTS solicitudes (
    id BIGSERIAL PRIMARY KEY,
    numero_seguimiento VARCHAR(50) UNIQUE NOT NULL,
    cliente_id BIGINT NOT NULL,
    contenedor_id BIGINT NOT NULL,
    estado VARCHAR(50) DEFAULT 'borrador',
    origen_direccion TEXT NOT NULL,
    origen_latitud DOUBLE PRECISION NOT NULL,
    origen_longitud DOUBLE PRECISION NOT NULL,
    destino_direccion TEXT NOT NULL,
    destino_latitud DOUBLE PRECISION NOT NULL,
    destino_longitud DOUBLE PRECISION NOT NULL,
    costo_estimado DOUBLE PRECISION,
    tiempo_estimado_horas DOUBLE PRECISION,
    costo_real DOUBLE PRECISION,
    tiempo_real_horas DOUBLE PRECISION,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_entrega TIMESTAMP
);

CREATE INDEX idx_solicitud_numero ON solicitudes(numero_seguimiento);
CREATE INDEX idx_solicitud_cliente ON solicitudes(cliente_id);
CREATE INDEX idx_solicitud_contenedor ON solicitudes(contenedor_id);
CREATE INDEX idx_solicitud_estado ON solicitudes(estado);
CREATE INDEX idx_solicitud_fecha ON solicitudes(fecha_creacion);

COMMENT ON TABLE solicitudes IS 'Solicitudes de transporte de contenedores';
COMMENT ON COLUMN solicitudes.numero_seguimiento IS 'Número único para tracking del cliente';
COMMENT ON COLUMN solicitudes.estado IS 'Estado: borrador, programada, en_transito, entregada';
COMMENT ON COLUMN solicitudes.costo_estimado IS 'Costo estimado antes de iniciar el transporte';
COMMENT ON COLUMN solicitudes.costo_real IS 'Costo real calculado al finalizar';


-- Tabla: rutas
CREATE TABLE IF NOT EXISTS rutas (
    id BIGSERIAL PRIMARY KEY,
    solicitud_id BIGINT UNIQUE NOT NULL,
    cantidad_tramos INTEGER DEFAULT 0,
    cantidad_depositos INTEGER DEFAULT 0,
    distancia_total_km DOUBLE PRECISION,
    duracion_estimada_horas DOUBLE PRECISION,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id) ON DELETE CASCADE
);

CREATE INDEX idx_ruta_solicitud ON rutas(solicitud_id);

COMMENT ON TABLE rutas IS 'Rutas planificadas para las solicitudes';
COMMENT ON COLUMN rutas.cantidad_tramos IS 'Número de tramos en la ruta';
COMMENT ON COLUMN rutas.cantidad_depositos IS 'Número de depósitos intermedios';


-- Tabla: tramos
CREATE TABLE IF NOT EXISTS tramos (
    id BIGSERIAL PRIMARY KEY,
    ruta_id BIGINT NOT NULL,
    orden INTEGER NOT NULL,
    tipo_tramo VARCHAR(50) NOT NULL,
    estado VARCHAR(50) DEFAULT 'estimado',
    origen_direccion TEXT NOT NULL,
    origen_latitud DOUBLE PRECISION NOT NULL,
    origen_longitud DOUBLE PRECISION NOT NULL,
    destino_direccion TEXT NOT NULL,
    destino_latitud DOUBLE PRECISION NOT NULL,
    destino_longitud DOUBLE PRECISION NOT NULL,
    distancia_km DOUBLE PRECISION,
    duracion_estimada_horas DOUBLE PRECISION,
    costo_estimado DOUBLE PRECISION,
    costo_real DOUBLE PRECISION,
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    camion_patente VARCHAR(20),
    observaciones TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ruta_id) REFERENCES rutas(id) ON DELETE CASCADE,
    CONSTRAINT unique_ruta_orden UNIQUE (ruta_id, orden)
);

CREATE INDEX idx_tramo_ruta ON tramos(ruta_id);
CREATE INDEX idx_tramo_camion ON tramos(camion_patente);
CREATE INDEX idx_tramo_estado ON tramos(estado);
CREATE INDEX idx_tramo_orden ON tramos(ruta_id, orden);

COMMENT ON TABLE tramos IS 'Tramos individuales de cada ruta';
COMMENT ON COLUMN tramos.tipo_tramo IS 'Tipo: origen-deposito, deposito-deposito, deposito-destino, origen-destino';
COMMENT ON COLUMN tramos.estado IS 'Estado: estimado, asignado, iniciado, finalizado';
COMMENT ON COLUMN tramos.orden IS 'Orden del tramo en la ruta (1, 2, 3...)';


-- Tabla: configuracion
CREATE TABLE IF NOT EXISTS configuracion (
    clave VARCHAR(100) PRIMARY KEY,
    valor TEXT NOT NULL,
    tipo VARCHAR(50) DEFAULT 'string',
    descripcion TEXT,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE configuracion IS 'Parámetros de configuración del sistema';
COMMENT ON COLUMN configuracion.tipo IS 'Tipo de dato: string, number, boolean, json';


-- Insertar configuración inicial
INSERT INTO configuracion (clave, valor, tipo, descripcion) VALUES
('costo_km_base', '100.0', 'number', 'Costo base por kilómetro'),
('precio_combustible', '150.0', 'number', 'Precio del combustible por litro'),
('margen_ganancia', '0.25', 'number', 'Margen de ganancia (25%)'),
('tiempo_carga_descarga', '2.0', 'number', 'Tiempo estimado de carga/descarga en horas')
ON CONFLICT (clave) DO NOTHING;


-- ============================================================
-- PASO 5: PERMISOS Y SEGURIDAD
-- ============================================================

-- Habilitar Row Level Security (RLS) en todas las tablas
-- Nota: Ajustar según tus necesidades de seguridad

ALTER TABLE gestion.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE gestion.contenedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE gestion.depositos ENABLE ROW LEVEL SECURITY;
ALTER TABLE gestion.tarifas ENABLE ROW LEVEL SECURITY;

ALTER TABLE flota.camiones ENABLE ROW LEVEL SECURITY;

ALTER TABLE logistica.solicitudes ENABLE ROW LEVEL SECURITY;
ALTER TABLE logistica.rutas ENABLE ROW LEVEL SECURITY;
ALTER TABLE logistica.tramos ENABLE ROW LEVEL SECURITY;
ALTER TABLE logistica.configuracion ENABLE ROW LEVEL SECURITY;


-- Políticas de acceso (ajustar según rol de usuario)
-- Por ahora, permitir acceso completo para el usuario de la API

-- Schema gestion
CREATE POLICY "Permitir acceso completo a clientes" ON gestion.clientes FOR ALL USING (true);
CREATE POLICY "Permitir acceso completo a contenedores" ON gestion.contenedores FOR ALL USING (true);
CREATE POLICY "Permitir acceso completo a depositos" ON gestion.depositos FOR ALL USING (true);
CREATE POLICY "Permitir acceso completo a tarifas" ON gestion.tarifas FOR ALL USING (true);

-- Schema flota
CREATE POLICY "Permitir acceso completo a camiones" ON flota.camiones FOR ALL USING (true);

-- Schema logistica
CREATE POLICY "Permitir acceso completo a solicitudes" ON logistica.solicitudes FOR ALL USING (true);
CREATE POLICY "Permitir acceso completo a rutas" ON logistica.rutas FOR ALL USING (true);
CREATE POLICY "Permitir acceso completo a tramos" ON logistica.tramos FOR ALL USING (true);
CREATE POLICY "Permitir acceso completo a configuracion" ON logistica.configuracion FOR ALL USING (true);


-- ============================================================
-- PASO 6: FUNCIONES ÚTILES
-- ============================================================

-- Función para actualizar fecha_modificacion automáticamente
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_modificacion = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a tablas con fecha_modificacion
CREATE TRIGGER update_tarifa_modtime
    BEFORE UPDATE ON gestion.tarifas
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_configuracion_modtime
    BEFORE UPDATE ON logistica.configuracion
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();


-- ============================================================
-- PASO 7: VERIFICACIÓN
-- ============================================================

-- Verificar schemas
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name IN ('gestion', 'flota', 'logistica')
ORDER BY schema_name;

-- Verificar tablas en gestion
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'gestion'
ORDER BY table_name;

-- Verificar tablas en flota
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'flota'
ORDER BY table_name;

-- Verificar tablas en logistica
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'logistica'
ORDER BY table_name;

-- Contar registros de configuración inicial
SELECT COUNT(*) as configuraciones_creadas 
FROM logistica.configuracion;


-- ============================================================
-- PASO 8: DATOS DE PRUEBA (OPCIONAL)
-- ============================================================

-- Insertar datos de prueba en gestion.clientes
INSERT INTO gestion.clientes (nombre, apellido, email, telefono, direccion, latitud, longitud) VALUES
('Juan', 'Pérez', 'juan.perez@example.com', '+54 351 123-4567', 'Av. Colón 123, Córdoba', -31.4201, -64.1888),
('María', 'González', 'maria.gonzalez@example.com', '+54 351 987-6543', 'Bv. San Juan 456, Córdoba', -31.4135, -64.1810)
ON CONFLICT (email) DO NOTHING;

-- Insertar datos de prueba en gestion.depositos
INSERT INTO gestion.depositos (nombre, direccion, latitud, longitud, capacidad_maxima, costo_diario) VALUES
('Depósito Central Córdoba', 'Ruta 9 Km 695, Córdoba', -31.4000, -64.2000, 100, 500.00),
('Depósito Norte Buenos Aires', 'Panamericana Km 35, Buenos Aires', -34.5500, -58.4800, 150, 750.00)
ON CONFLICT DO NOTHING;

-- Insertar datos de prueba en flota.camiones
INSERT INTO flota.camiones (patente, nombre_transportista, telefono_transportista, capacidad_peso, capacidad_volumen, consumo_combustible_km, costo_km, disponible) VALUES
('AB123CD', 'Carlos Rodríguez', '+54 351 111-2222', 5000.0, 30.0, 0.35, 120.0, true),
('EF456GH', 'Laura Martínez', '+54 351 333-4444', 8000.0, 45.0, 0.45, 150.0, true),
('IJ789KL', 'Roberto Sánchez', '+54 351 555-6666', 10000.0, 60.0, 0.55, 180.0, true)
ON CONFLICT (patente) DO NOTHING;


-- ============================================================
-- SCRIPT COMPLETADO
-- ============================================================

SELECT 
    'Script ejecutado exitosamente!' as mensaje,
    (SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name IN ('gestion', 'flota', 'logistica')) as schemas_creados,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'gestion') as tablas_gestion,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'flota') as tablas_flota,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'logistica') as tablas_logistica;

-- Resetear search_path
SET search_path TO public;
