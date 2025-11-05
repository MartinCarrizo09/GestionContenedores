# 🚀 Guía de Implementación de Supabase

## 📋 Índice
1. [Introducción](#introducción)
2. [Arquitectura](#arquitectura)
3. [Prerequisitos](#prerequisitos)
4. [Configuración de Supabase](#configuración-de-supabase)
5. [Configuración del Proyecto](#configuración-del-proyecto)
6. [Ejecución](#ejecución)
7. [Verificación](#verificación)
8. [Troubleshooting](#troubleshooting)

---

## 📖 Introducción

Este proyecto implementa una arquitectura de microservicios con **base de datos compartida en Supabase (PostgreSQL)** usando **separación por schemas**.

### ✅ Características implementadas:
- ✅ Conexión SSL segura a Supabase
- ✅ Pool de conexiones HikariCP optimizado
- ✅ Separación por schemas (gestion, flota, logistica)
- ✅ Variables de entorno para credenciales
- ✅ Validación de esquemas existentes (NO recrea tablas)
- ✅ Configuración lista para Docker

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│          SUPABASE POSTGRESQL DATABASE                   │
│  (jqshojwvwpoovjffscyv.supabase.co:5432)               │
│                                                         │
│  ┌───────────────┐  ┌────────────┐  ┌───────────────┐ │
│  │ Schema:       │  │ Schema:    │  │ Schema:       │ │
│  │ gestion       │  │ flota      │  │ logistica     │ │
│  ├───────────────┤  ├────────────┤  ├───────────────┤ │
│  │ • clientes    │  │ • camiones │  │ • solicitudes │ │
│  │ • contenedores│  │            │  │ • rutas       │ │
│  │ • depositos   │  │            │  │ • tramos      │ │
│  │ • tarifas     │  │            │  │               │ │
│  └───────────────┘  └────────────┘  └───────────────┘ │
└─────────────────────────────────────────────────────────┘
         ▲                  ▲                  ▲
         │                  │                  │
         │ SSL              │ SSL              │ SSL
         │ (5432)           │ (5432)           │ (5432)
         │                  │                  │
┌────────┴────────┐ ┌───────┴────────┐ ┌───────┴─────────┐
│ servicio-gestion│ │ servicio-flota │ │servicio-logistica│
│   (Port 8080)   │ │  (Port 8081)   │ │   (Port 8082)    │
│ default_schema: │ │ default_schema:│ │ default_schema:  │
│    gestion      │ │     flota      │ │    logistica     │
└─────────────────┘ └────────────────┘ └──────────────────┘
```

### 🔑 Características clave:
- **Una base de datos, tres schemas**: Cada microservicio accede solo a su schema
- **SSL obligatorio**: `sslmode=require` en todas las conexiones
- **HikariCP**: Pool de conexiones optimizado (10 max, 5 min idle)
- **Hibernate validate**: NO crea/recrea tablas, solo valida estructura

---

## ✅ Prerequisitos

### 1. Base de Datos Supabase
- ✅ Cuenta en [Supabase](https://supabase.com)
- ✅ Proyecto creado
- ✅ Schemas creados: `gestion`, `flota`, `logistica`
- ✅ Tablas creadas en cada schema (ver estructura abajo)

### 2. Software Local
- ✅ Java 21
- ✅ Maven 3.8+
- ✅ IDE (IntelliJ IDEA, VS Code, Eclipse)

---

## 🗄️ Configuración de Supabase

### Paso 1: Crear los Schemas

Conectarse a Supabase SQL Editor y ejecutar:

```sql
-- Crear schemas
CREATE SCHEMA IF NOT EXISTS gestion;
CREATE SCHEMA IF NOT EXISTS flota;
CREATE SCHEMA IF NOT EXISTS logistica;

-- Verificar
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name IN ('gestion', 'flota', 'logistica');
```

### Paso 2: Crear las tablas

#### Schema `gestion`:

```sql
-- Establecer el schema por defecto
SET search_path TO gestion;

-- Tabla clientes
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

-- Tabla contenedores
CREATE TABLE IF NOT EXISTS contenedores (
    id BIGSERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    peso_kg DOUBLE PRECISION NOT NULL CHECK (peso_kg > 0),
    volumen_m3 DOUBLE PRECISION NOT NULL CHECK (volumen_m3 > 0),
    estado VARCHAR(50) DEFAULT 'disponible',
    cliente_id BIGINT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Tabla depositos
CREATE TABLE IF NOT EXISTS depositos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    direccion TEXT NOT NULL,
    latitud DOUBLE PRECISION NOT NULL,
    longitud DOUBLE PRECISION NOT NULL,
    capacidad_maxima INTEGER,
    costo_diario DOUBLE PRECISION NOT NULL CHECK (costo_diario >= 0)
);

-- Tabla tarifas
CREATE TABLE IF NOT EXISTS tarifas (
    id BIGSERIAL PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL,
    tipo_tarifa VARCHAR(50) NOT NULL,
    valor DOUBLE PRECISION NOT NULL CHECK (valor >= 0),
    vigente BOOLEAN DEFAULT true,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Schema `flota`:

```sql
-- Establecer el schema por defecto
SET search_path TO flota;

-- Tabla camiones
CREATE TABLE IF NOT EXISTS camiones (
    patente VARCHAR(20) PRIMARY KEY,
    nombre_transportista VARCHAR(255) NOT NULL,
    telefono_transportista VARCHAR(50),
    capacidad_peso DOUBLE PRECISION NOT NULL CHECK (capacidad_peso > 0),
    capacidad_volumen DOUBLE PRECISION NOT NULL CHECK (capacidad_volumen > 0),
    consumo_combustible_km DOUBLE PRECISION NOT NULL CHECK (consumo_combustible_km > 0),
    costo_km DOUBLE PRECISION NOT NULL CHECK (costo_km > 0),
    disponible BOOLEAN DEFAULT true
);
```

#### Schema `logistica`:

```sql
-- Establecer el schema por defecto
SET search_path TO logistica;

-- Tabla solicitudes
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
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla rutas
CREATE TABLE IF NOT EXISTS rutas (
    id BIGSERIAL PRIMARY KEY,
    solicitud_id BIGINT UNIQUE NOT NULL,
    cantidad_tramos INTEGER DEFAULT 0,
    cantidad_depositos INTEGER DEFAULT 0,
    FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id) ON DELETE CASCADE
);

-- Tabla tramos
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
    FOREIGN KEY (ruta_id) REFERENCES rutas(id) ON DELETE CASCADE
);

-- Tabla configuracion (opcional - para parámetros del sistema)
CREATE TABLE IF NOT EXISTS configuracion (
    clave VARCHAR(100) PRIMARY KEY,
    valor TEXT NOT NULL,
    descripcion TEXT,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Paso 3: Verificar las tablas creadas

```sql
-- Ver tablas en schema gestion
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'gestion';

-- Ver tablas en schema flota
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'flota';

-- Ver tablas en schema logistica
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'logistica';
```

---

## ⚙️ Configuración del Proyecto

### Paso 1: Obtener credenciales de Supabase

1. Ve a tu proyecto en [Supabase](https://supabase.com/dashboard)
2. Navega a **Settings** > **Database**
3. Copia los siguientes datos:
   - **Host**: `jqshojwvwpoovjffscyv.supabase.co`
   - **Database name**: `postgres`
   - **Port**: `5432`
   - **User**: `postgres.jqshojwvwpoovjffscyv`
   - **Password**: `Salchicha123`

### Paso 2: Configurar variables de entorno

#### Opción 1: Archivo `.env` (recomendado para desarrollo local)

```bash
# Copia el archivo de ejemplo
cp .env.example .env

# Edita .env y completa tu password
SUPABASE_DB_PASSWORD=tu_password_real_aqui
```

#### Opción 2: Variables de entorno del sistema (Windows PowerShell)

```powershell
# Configurar password de Supabase
$env:SUPABASE_DB_PASSWORD="Salchicha123"

# Verificar
echo $env:SUPABASE_DB_PASSWORD
```

#### Opción 3: Configurar en IDE (IntelliJ IDEA)

1. Run > Edit Configurations
2. Selecciona tu aplicación Spring Boot
3. En "Environment variables" agrega:
   ```
   SUPABASE_DB_PASSWORD=tu_password_real_aqui
   ```

---

## 🚀 Ejecución

### Compilar el proyecto

```bash
# Desde la raíz del proyecto
mvn clean install
```

### Ejecutar cada servicio

#### Opción 1: Con Maven

```bash
# Terminal 1 - Servicio Gestión
cd servicio-gestion
mvn spring-boot:run

# Terminal 2 - Servicio Flota
cd servicio-flota
mvn spring-boot:run

# Terminal 3 - Servicio Logística
cd servicio-logistica
mvn spring-boot:run
```

#### Opción 2: Con IDE

1. Abre cada proyecto como módulo Maven
2. Configura las variables de entorno (ver paso anterior)
3. Ejecuta la clase `*Application.java` de cada servicio

#### Opción 3: Con JAR compilado

```bash
# Compilar
mvn clean package -DskipTests

# Ejecutar servicio-gestion
java -jar servicio-gestion/target/servicio-gestion-0.0.1-SNAPSHOT.jar

# Ejecutar servicio-flota
java -jar servicio-flota/target/servicio-flota-0.0.1-SNAPSHOT.jar

# Ejecutar servicio-logistica
java -jar servicio-logistica/target/servicio-logistica-0.0.1-SNAPSHOT.jar
```

---

## ✅ Verificación

### 1. Verificar que los servicios iniciaron correctamente

Deberías ver en los logs:

```
✅ Servicio Gestión:
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
Tomcat started on port(s): 8080

✅ Servicio Flota:
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
Tomcat started on port(s): 8081

✅ Servicio Logística:
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
Tomcat started on port(s): 8082
```

### 2. Probar endpoints básicos

```bash
# Servicio Gestión
curl http://localhost:8080/api-gestion/health

# Servicio Flota
curl http://localhost:8081/api-flota/health

# Servicio Logística
curl http://localhost:8082/api-logistica/health
```

### 3. Verificar conexión a Supabase

En los logs deberías ver:

```sql
Hibernate: 
    select
        c1_0.id,
        c1_0.nombre,
        ...
    from
        gestion.clientes c1_0
```

✅ Nota el prefijo **`gestion.`** antes del nombre de la tabla.

---

## 🐛 Troubleshooting

### Problema 1: "password authentication failed"

**Causa**: Password incorrecta o no configurada.

**Solución**:
1. Ve a Supabase > Settings > Database
2. Resetea el password
3. Actualiza `SUPABASE_DB_PASSWORD` en tu `.env` o variables de entorno
4. Reinicia los servicios

---

### Problema 2: "relation does not exist"

**Causa**: Las tablas no existen en el schema correcto.

**Solución**:
```sql
-- Verificar en qué schema están las tablas
SELECT table_schema, table_name 
FROM information_schema.tables 
WHERE table_name = 'clientes';

-- Si están en 'public', moverlas al schema correcto
ALTER TABLE public.clientes SET SCHEMA gestion;
```

---

### Problema 3: "SSL connection required"

**Causa**: Supabase requiere SSL obligatorio.

**Solución**: Verifica que tu URL incluya `?sslmode=require`:
```yaml
url: jdbc:postgresql://jqshojwvwpoovjffscyv.supabase.co:5432/postgres?sslmode=require
```

---

### Problema 4: "HikariPool - Connection is not available"

**Causa**: Límite de conexiones alcanzado o firewall bloqueando.

**Solución**:
1. Verifica que Supabase permita conexiones desde tu IP
2. Reduce `maximum-pool-size` en `application.yml`:
```yaml
hikari:
  maximum-pool-size: 5  # Reducir de 10 a 5
```

---

### Problema 5: "Table validation failed"

**Causa**: La estructura de las entidades JPA no coincide con las tablas en Supabase.

**Solución temporal** (solo para desarrollo):
```yaml
hibernate:
  ddl-auto: update  # Cambia de 'validate' a 'update'
```

⚠️ **IMPORTANTE**: Vuelve a `validate` en producción.

---

## 📊 Monitoreo de Conexiones

### Verificar conexiones activas en Supabase

```sql
SELECT 
    datname,
    usename,
    application_name,
    client_addr,
    state,
    query
FROM pg_stat_activity
WHERE datname = 'postgres'
AND usename LIKE 'postgres.%';
```

---

## 🔐 Seguridad

### ✅ Buenas prácticas implementadas:

1. ✅ **SSL obligatorio**: Todas las conexiones usan `sslmode=require`
2. ✅ **Credenciales en variables de entorno**: No hardcodeadas
3. ✅ **Pool de conexiones limitado**: Máximo 10 conexiones por servicio
4. ✅ **Separación por schemas**: Aislamiento de datos entre servicios
5. ✅ **Timeout configurado**: Previene conexiones colgadas

### ⚠️ Recomendaciones adicionales:

- [ ] Rotar passwords periódicamente
- [ ] Usar Row Level Security (RLS) en Supabase
- [ ] Implementar rate limiting en los endpoints
- [ ] Configurar IP whitelisting en Supabase (solo IPs permitidas)

---

## 📚 Referencias

- [Supabase PostgreSQL Connection](https://supabase.com/docs/guides/database/connecting-to-postgres)
- [HikariCP Configuration](https://github.com/brettwooldridge/HikariCP#configuration-knobs-baby)
- [Spring Boot External Configuration](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config)
- [PostgreSQL SSL Support](https://www.postgresql.org/docs/current/libpq-ssl.html)

---

## 📞 Soporte

Si encuentras problemas:

1. Revisa la sección [Troubleshooting](#troubleshooting)
2. Verifica los logs de cada servicio
3. Consulta la consola de Supabase (Database > Logs)
4. Contacta al equipo de desarrollo

---

**✅ Implementación completada por**: Martin Carrizo
**📅 Fecha**: Noviembre 2025
**🔖 Versión**: 1.0.0
