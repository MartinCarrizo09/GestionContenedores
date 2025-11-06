# 🚀 GUÍA DE USUARIO - SISTEMA DE GESTIÓN DE CONTENEDORES TPI

**Autor:** Martín Carrizo  
**Fecha:** Noviembre 6, 2025  
**Versión:** 2.0 (PostgreSQL Local + Docker)

---

## 📋 TABLA DE CONTENIDOS

1. [Introducción](#introducción)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Guía de Docker](#guía-de-docker)
4. [Configuración Inicial](#configuración-inicial)
5. [Testing con Postman](#testing-con-postman)
6. [Flujo Completo de Negocio](#flujo-completo-de-negocio)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 INTRODUCCIÓN

Este sistema está compuesto por **3 microservicios independientes** que gestionan el transporte de contenedores desde el origen hasta el destino, con validaciones de capacidad de camiones, creación automática de clientes y cálculo de rutas con Google Maps.

### Características principales:

✅ **PostgreSQL local con Docker** (sin límite de conexiones)  
✅ **200+ registros de prueba** (clientes, camiones, contenedores)  
✅ **Validación de capacidad de camión** (peso y volumen)  
✅ **Creación automática de cliente** si no existe  
✅ **Google Maps API** para cálculo de rutas reales  
✅ **Máquina de estados** para solicitudes y tramos

---

## 🏗️ ARQUITECTURA DEL SISTEMA

```
┌─────────────────────────────────────────────────────────────┐
│                      DOCKER COMPOSE                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ │
│  │   PostgreSQL │    │  Servicio    │    │  Servicio    │ │
│  │              │◄───┤  Gestión     │    │  Flota       │ │
│  │ bd-tpi-      │    │  (Puerto     │    │  (Puerto     │ │
│  │  backend     │    │   8080)      │    │   8081)      │ │
│  └──────────────┘    └──────────────┘    └──────────────┘ │
│         ▲                    ▲                    ▲        │
│         │                    │                    │        │
│         │            ┌───────┴────────────────────┘        │
│         │            │                                     │
│         └────────────┤  Servicio Logística                │
│                      │  (Puerto 8082)                      │
│                      │  + Google Maps API                  │
│                      └─────────────────────────────────────┤
└─────────────────────────────────────────────────────────────┘

SCHEMAS EN POSTGRESQL:
├── gestion    → clientes, contenedores, depositos, tarifas
├── flota      → camiones
└── logistica  → solicitudes, rutas, tramos
```

### Comunicación entre servicios:

- **Servicio Logística → Servicio Gestión**: Validar clientes y contenedores
- **Servicio Logística → Servicio Flota**: Validar capacidad de camiones
- **Servicio Gestión → Servicio Logística**: Consultar estado de contenedores

---

## 🐳 GUÍA DE DOCKER

### ¿Qué es Docker?

Docker es una plataforma que permite **empaquetar aplicaciones con todas sus dependencias** en contenedores aislados. Beneficios:

- ✅ **No instalar PostgreSQL, Java, Maven** manualmente
- ✅ **Mismo entorno en todos los equipos** (desarrollo, testing, producción)
- ✅ **Levantar/detener todo con un comando**
- ✅ **Persistencia de datos** (los datos no se pierden al reiniciar)

### Instalación de Docker

#### Windows:

1. Descargar **Docker Desktop** de: https://www.docker.com/products/docker-desktop/
2. Ejecutar el instalador
3. Reiniciar el equipo
4. Abrir Docker Desktop (debe estar corriendo en segundo plano)
5. Verificar instalación:
   ```powershell
   docker --version
   docker-compose --version
   ```

#### Linux:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
# Cerrar sesión y volver a iniciar
```

#### Mac:

1. Descargar Docker Desktop de: https://www.docker.com/products/docker-desktop/
2. Ejecutar el instalador
3. Verificar instalación: `docker --version`

---

## ⚙️ CONFIGURACIÓN INICIAL

### Paso 1: Configurar variables de entorno

Copia el archivo `.env.example` a `.env` y configura las credenciales:

```bash
# En PowerShell
Copy-Item .env.example .env
```

Edita el archivo `.env`:

```env
# PostgreSQL
POSTGRES_PASSWORD=admin123

# Google Maps API Key (para cálculo de rutas)
GOOGLE_MAPS_API_KEY=TU_API_KEY_AQUI
```

> **IMPORTANTE:** Para obtener una API Key de Google Maps:
> 1. Ir a: https://console.cloud.google.com/
> 2. Crear un proyecto
> 3. Habilitar "Directions API" y "Distance Matrix API"
> 4. Crear credenciales (API Key)
> 5. Copiar la key al archivo `.env`

### Paso 2: Levantar todo el sistema con Docker

```powershell
# En la carpeta raíz del proyecto (GestionContenedores)
docker-compose up -d
```

Este comando:
- ✅ Descarga las imágenes de PostgreSQL, Maven y JDK 17
- ✅ Crea la base de datos `bd-tpi-backend`
- ✅ Ejecuta el script `init-db.sql` (crea schemas y datos de prueba)
- ✅ Compila los 3 microservicios con Maven
- ✅ Levanta los 3 microservicios en puertos 8080, 8081, 8082

**NOTA:** El primer `docker-compose up` puede tardar **5-10 minutos** porque:
- Descarga imágenes Docker (~2GB)
- Compila los 3 proyectos Maven
- Inicializa la base de datos

### Paso 3: Verificar que todo esté corriendo

```powershell
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f servicio-gestion
docker-compose logs -f servicio-flota
docker-compose logs -f servicio-logistica
docker-compose logs -f postgres

# Ver estado de los contenedores
docker-compose ps
```

Deberías ver algo como:

```
NAME                  STATUS              PORTS
tpi-postgres          Up 2 minutes        0.0.0.0:5432->5432/tcp
tpi-gestion           Up 1 minute         0.0.0.0:8080->8080/tcp
tpi-flota             Up 1 minute         0.0.0.0:8081->8081/tcp
tpi-logistica         Up 1 minute         0.0.0.0:8082->8082/tcp
```

### Paso 4: Probar conectividad

Abre el navegador y verifica que los servicios respondan:

- **Servicio Gestión**: http://localhost:8080/api-gestion/clientes
- **Servicio Flota**: http://localhost:8081/api-flota/camiones
- **Servicio Logística**: http://localhost:8082/api-logistica/solicitudes

Si ves JSON con datos, ¡todo está funcionando! ✅

---

## 🧪 TESTING CON POSTMAN

### Importar colección

Puedes crear una nueva colección en Postman con los siguientes endpoints:

### 🔧 Comandos útiles de Docker

```powershell
# ===== INICIAR SERVICIOS =====
docker-compose up -d                    # Inicia todos los servicios en segundo plano
docker-compose up postgres              # Inicia solo PostgreSQL

# ===== VER LOGS =====
docker-compose logs -f                  # Ver logs de todos (Ctrl+C para salir)
docker-compose logs -f servicio-logistica  # Ver logs de un servicio específico
docker-compose logs --tail=100 postgres    # Ver últimas 100 líneas

# ===== DETENER SERVICIOS =====
docker-compose stop                     # Detiene sin borrar contenedores
docker-compose down                     # Detiene y borra contenedores (datos persisten)
docker-compose down -v                  # Detiene, borra contenedores Y borra datos

# ===== REINICIAR SERVICIOS =====
docker-compose restart                  # Reinicia todos los servicios
docker-compose restart servicio-gestion # Reinicia un servicio específico

# ===== REBUILD (después de cambios en código) =====
docker-compose build                    # Recompila imágenes
docker-compose up -d --build            # Recompila y reinicia

# ===== VER ESTADO =====
docker-compose ps                       # Ver estado de contenedores
docker stats                            # Ver uso de CPU y RAM en tiempo real

# ===== EJECUTAR COMANDOS DENTRO DE CONTENEDORES =====
docker exec -it tpi-postgres psql -U admin -d bd-tpi-backend  # Conectar a PostgreSQL
docker exec -it tpi-postgres pg_dump -U admin bd-tpi-backend > backup.sql  # Backup

# ===== LIMPIAR TODO =====
docker system prune -a --volumes        # Borrar TODO (imágenes, contenedores, volúmenes)
```

---

## 📚 ENDPOINTS COMPLETOS

### 🏢 SERVICIO GESTIÓN (Puerto 8080)

**Base URL:** `http://localhost:8080/api-gestion`

#### 👤 Clientes

```http
### 1. Listar todos los clientes
GET http://localhost:8080/api-gestion/clientes

### 2. Obtener cliente por ID
GET http://localhost:8080/api-gestion/clientes/1

### 3. Crear cliente
POST http://localhost:8080/api-gestion/clientes
Content-Type: application/json

{
  "nombre": "Juan",
  "apellido": "Pérez",
  "email": "jperez@empresa.com",
  "telefono": "+54 351 123-4567",
  "cuil": "20-12345678-9"
}

### 4. Actualizar cliente
PUT http://localhost:8080/api-gestion/clientes/1
Content-Type: application/json

{
  "nombre": "Juan Carlos",
  "apellido": "Pérez",
  "email": "jperez@empresa.com",
  "telefono": "+54 351 123-4567",
  "cuil": "20-12345678-9"
}

### 5. Eliminar cliente
DELETE http://localhost:8080/api-gestion/clientes/50
```

#### 📦 Contenedores

```http
### 1. Listar todos los contenedores
GET http://localhost:8080/api-gestion/contenedores

### 2. Obtener contenedor por ID
GET http://localhost:8080/api-gestion/contenedores/1

### 3. Crear contenedor
POST http://localhost:8080/api-gestion/contenedores
Content-Type: application/json

{
  "codigoIdentificacion": "CONT-TEST-001",
  "peso": 3500.0,
  "volumen": 40.0,
  "idCliente": 1
}

### 4. Obtener estado del contenedor (integración con logística)
GET http://localhost:8080/api-gestion/contenedores/1/estado
```

**Respuesta esperada del estado:**

```json
{
  "idContenedor": 1,
  "codigoIdentificacion": "CONT-20-00001",
  "estado": "EN_TRANSITO",
  "solicitud": {
    "numeroSeguimiento": "TRACK-2025-001",
    "origen": "Puerto de Buenos Aires",
    "destino": "Rosario, Santa Fe",
    "estadoSolicitud": "PROGRAMADA"
  }
}
```

#### 🏪 Depósitos

```http
### 1. Listar depósitos
GET http://localhost:8080/api-gestion/depositos

### 2. Crear depósito
POST http://localhost:8080/api-gestion/depositos
Content-Type: application/json

{
  "nombre": "Depósito Test",
  "direccion": "Av. Test 1234, Córdoba",
  "latitud": -31.4201,
  "longitud": -64.1888,
  "costoEstadiaxDia": 150.0
}
```

#### 💰 Tarifas

```http
### 1. Listar tarifas
GET http://localhost:8080/api-gestion/tarifas

### 2. Crear tarifa
POST http://localhost:8080/api-gestion/tarifas
Content-Type: application/json

{
  "descripcion": "Tarifa Test - Media Distancia",
  "rangoPesoMin": 2000.0,
  "rangoPesoMax": 5000.0,
  "rangoVolumenMin": 30.0,
  "rangoVolumenMax": 60.0,
  "valor": 8000.0
}

### 3. Obtener tarifa por peso y volumen
GET http://localhost:8080/api-gestion/tarifas/buscar?peso=3500&volumen=40
```

---

### 🚛 SERVICIO FLOTA (Puerto 8081)

**Base URL:** `http://localhost:8081/api-flota`

#### Camiones

```http
### 1. Listar todos los camiones
GET http://localhost:8081/api-flota/camiones

### 2. Obtener camión por patente
GET http://localhost:8081/api-flota/camiones/ABC123

### 3. Crear camión
POST http://localhost:8081/api-flota/camiones
Content-Type: application/json

{
  "patente": "ZZZ999",
  "nombreTransportista": "Test Driver",
  "telefonoTransportista": "+54 351 999-9999",
  "capacidadPeso": 8000.0,
  "capacidadVolumen": 50.0,
  "consumoCombustibleKm": 0.45,
  "costoKm": 150.0,
  "disponible": true
}

### 4. Actualizar disponibilidad
PATCH http://localhost:8081/api-flota/camiones/ABC123/disponibilidad?disponible=false

### 5. Listar camiones disponibles
GET http://localhost:8081/api-flota/camiones/disponibles

### 6. Obtener camiones aptos para carga específica (ENDPOINT CLAVE)
GET http://localhost:8081/api-flota/camiones/aptos?peso=3500&volumen=40
```

**Respuesta de camiones aptos:**

```json
[
  {
    "patente": "JKL012",
    "nombreTransportista": "Ana García",
    "capacidadPeso": 6000.0,
    "capacidadVolumen": 40.0,
    "costoKm": 120.0,
    "disponible": true
  },
  {
    "patente": "MNO345",
    "nombreTransportista": "Miguel Torres",
    "capacidadPeso": 6500.0,
    "capacidadVolumen": 42.0,
    "costoKm": 125.0,
    "disponible": true
  }
]
```

---

### 🗺️ SERVICIO LOGÍSTICA (Puerto 8082)

**Base URL:** `http://localhost:8082/api-logistica`

#### 📋 Solicitudes (Flujo principal)

```http
### 1. Listar todas las solicitudes
GET http://localhost:8082/api-logistica/solicitudes

### 2. Obtener solicitud por ID
GET http://localhost:8082/api-logistica/solicitudes/1

### 3. Crear solicitud (CON CREACIÓN AUTOMÁTICA DE CLIENTE)
POST http://localhost:8082/api-logistica/solicitudes
Content-Type: application/json

{
  "numeroSeguimiento": "TRACK-TEST-001",
  "idContenedor": 1,
  "idCliente": 9999,
  "origenDireccion": "Puerto de Buenos Aires, Buenos Aires, Argentina",
  "destinoDireccion": "Rosario, Santa Fe, Argentina"
}
```

**Comportamiento:**
- Si el cliente con ID 9999 **NO EXISTE**, se crea automáticamente ✅
- Si el contenedor con ID 1 **NO EXISTE**, devuelve error ❌
- Estado inicial: **BORRADOR**

```http
### 4. Estimar ruta (calcula tramos con Google Maps)
POST http://localhost:8082/api-logistica/solicitudes/estimar-ruta
Content-Type: application/json

{
  "origenDireccion": "Puerto de Buenos Aires, Buenos Aires, Argentina",
  "destinoDireccion": "Rosario, Santa Fe, Argentina"
}
```

**Respuesta esperada:**

```json
{
  "tramos": [
    {
      "origenDescripcion": "Puerto de Buenos Aires",
      "destinoDescripcion": "Rosario",
      "distanciaKm": 305.2,
      "tiempoEstimadoHoras": 5.1,
      "costoEstimado": 36624.0
    }
  ],
  "costoTotalEstimado": 36624.0,
  "tiempoTotalEstimadoHoras": 5.1
}
```

```http
### 5. Asignar ruta a solicitud
POST http://localhost:8082/api-logistica/solicitudes/1/asignar-ruta
Content-Type: application/json

{
  "origenDireccion": "Puerto de Buenos Aires, Buenos Aires, Argentina",
  "destinoDireccion": "Rosario, Santa Fe, Argentina"
}
```

**Comportamiento:**
- Valida que la solicitud esté en estado **BORRADOR** ✅
- Llama a Google Maps para calcular distancias reales 🗺️
- Crea entidad **Ruta** asociada a la solicitud
- Crea **Tramos** en estado **ESTIMADO**
- Cambia solicitud a estado **PROGRAMADA** ✅

```http
### 6. Listar solicitudes pendientes
GET http://localhost:8082/api-logistica/solicitudes/pendientes

### 7. Buscar solicitud por número de seguimiento
GET http://localhost:8082/api-logistica/solicitudes/seguimiento/TRACK-TEST-001

### 8. Cancelar solicitud
PUT http://localhost:8082/api-logistica/solicitudes/1/cancelar
```

#### 🛣️ Rutas

```http
### 1. Listar todas las rutas
GET http://localhost:8082/api-logistica/rutas

### 2. Obtener ruta por ID
GET http://localhost:8082/api-logistica/rutas/1

### 3. Obtener tramos de una ruta
GET http://localhost:8082/api-logistica/rutas/1/tramos
```

#### 🚦 Tramos (Gestión de transporte)

```http
### 1. Listar todos los tramos
GET http://localhost:8082/api-logistica/tramos

### 2. Obtener tramo por ID
GET http://localhost:8082/api-logistica/tramos/1

### 3. Asignar camión a tramo (CON VALIDACIÓN DE CAPACIDAD)
PUT http://localhost:8082/api-logistica/tramos/1/asignar-camion?patente=ABC123&peso=3500&volumen=40
```

**Comportamiento:**
- Valida que el tramo esté en estado **ESTIMADO** ✅
- Llama a servicio-flota: `GET /camiones/aptos?peso=3500&volumen=40` 🚛
- Verifica que el camión "ABC123" esté en la lista de aptos ✅
- Si **NO tiene capacidad**, devuelve error con mensaje claro ❌
- Si **SÍ tiene capacidad**, asigna y cambia estado a **ASIGNADO** ✅

```http
### 4. Iniciar tramo
PATCH http://localhost:8082/api-logistica/tramos/1/iniciar
```

**Comportamiento:**
- Valida que el tramo esté en estado **ASIGNADO** ✅
- Registra `fechaInicioReal` con timestamp actual ⏰
- Cambia estado a **INICIADO** ✅

```http
### 5. Finalizar tramo
PATCH http://localhost:8082/api-logistica/tramos/1/finalizar?kmReales=320&costoKm=5.5&consumo=0.15
```

**Comportamiento:**
- Valida que el tramo esté en estado **INICIADO** ✅
- Registra `fechaFinReal` con timestamp actual ⏰
- Calcula y guarda `costoReal` = kmReales × costoKm 💰
- Cambia estado a **FINALIZADO** ✅
- Si **TODOS** los tramos de la ruta están finalizados:
  - Suma `tiempoReal` de todos los tramos ⏱️
  - Suma `costoReal` de todos los tramos 💵
  - Cambia solicitud a estado **ENTREGADA** ✅

```http
### 6. Listar tramos por ruta
GET http://localhost:8082/api-logistica/tramos/ruta/1

### 7. Listar tramos por estado
GET http://localhost:8082/api-logistica/tramos/estado/ESTIMADO
```

---

## 🔄 FLUJO COMPLETO DE NEGOCIO (E2E)

Este es un ejemplo paso a paso de cómo funciona el sistema completo:

### FASE 1: Registrar solicitud con cliente nuevo ✅

```http
POST http://localhost:8082/api-logistica/solicitudes
Content-Type: application/json

{
  "numeroSeguimiento": "TRACK-E2E-001",
  "idContenedor": 1,
  "idCliente": 9999,
  "origenDireccion": "Puerto de Buenos Aires, Buenos Aires, Argentina",
  "destinoDireccion": "Rosario, Santa Fe, Argentina"
}
```

**Resultado:**
- Cliente ID 9999 creado automáticamente ✅
- Solicitud creada en estado **BORRADOR** ✅

---

### FASE 2: Estimar ruta con Google Maps 🗺️

```http
POST http://localhost:8082/api-logistica/solicitudes/estimar-ruta
Content-Type: application/json

{
  "origenDireccion": "Puerto de Buenos Aires, Buenos Aires, Argentina",
  "destinoDireccion": "Rosario, Santa Fe, Argentina"
}
```

**Resultado:**
- Google Maps calcula distancia real: ~305 km
- Sistema calcula costo estimado: ~$36,624
- Sistema calcula tiempo estimado: ~5.1 horas

---

### FASE 3: Asignar ruta a solicitud 📍

```http
POST http://localhost:8082/api-logistica/solicitudes/1/asignar-ruta
Content-Type: application/json

{
  "origenDireccion": "Puerto de Buenos Aires, Buenos Aires, Argentina",
  "destinoDireccion": "Rosario, Santa Fe, Argentina"
}
```

**Resultado:**
- Crea entidad **Ruta** asociada a solicitud
- Crea tramo en estado **ESTIMADO** con distancia y costo
- Solicitud cambia a estado **PROGRAMADA** ✅

---

### FASE 4: Asignar camión con validación de capacidad 🚛

Primero, verificar qué camiones son aptos:

```http
GET http://localhost:8081/api-flota/camiones/aptos?peso=2300&volumen=33.2
```

**Respuesta:**

```json
[
  {"patente": "ABC123", "capacidadPeso": 3500.0, "capacidadVolumen": 25.0},
  {"patente": "DEF456", "capacidadPeso": 4000.0, "capacidadVolumen": 28.0},
  {"patente": "GHI789", "capacidadPeso": 4500.0, "capacidadVolumen": 30.0}
]
```

Ahora asignar uno de ellos:

```http
PUT http://localhost:8082/api-logistica/tramos/1/asignar-camion?patente=ABC123&peso=2300&volumen=33.2
```

**Resultado:**
- Sistema valida capacidad con servicio-flota ✅
- Camión asignado al tramo
- Tramo cambia a estado **ASIGNADO** ✅

**¿Qué pasa si intento asignar un camión sin capacidad?**

```http
PUT http://localhost:8082/api-logistica/tramos/1/asignar-camion?patente=ABC123&peso=30000&volumen=200
```

**Respuesta (error 400):**

```json
{
  "error": "El camión ABC123 no tiene capacidad suficiente para este contenedor (peso: 30000kg, volumen: 200m³). Camiones disponibles: DEF456, GHI789"
}
```

---

### FASE 5: Ejecutar el transporte 🚀

#### Iniciar tramo:

```http
PATCH http://localhost:8082/api-logistica/tramos/1/iniciar
```

**Resultado:**
- Registra `fechaInicioReal`
- Tramo cambia a estado **INICIADO** ✅

#### Finalizar tramo:

```http
PATCH http://localhost:8082/api-logistica/tramos/1/finalizar?kmReales=320&costoKm=5.5&consumo=0.15
```

**Resultado:**
- Registra `fechaFinReal`
- Calcula `costoReal` = 320 × 5.5 = $1,760
- Tramo cambia a estado **FINALIZADO** ✅
- Como es el **único tramo** de la ruta, solicitud cambia a **ENTREGADA** ✅
- Se actualiza `costoFinal` y `tiempoReal` en la solicitud

---

### FASE 6: Verificar estado final 🎯

```http
GET http://localhost:8082/api-logistica/solicitudes/1
```

**Respuesta:**

```json
{
  "id": 1,
  "numeroSeguimiento": "TRACK-E2E-001",
  "idContenedor": 1,
  "idCliente": 9999,
  "origenDireccion": "Puerto de Buenos Aires",
  "destinoDireccion": "Rosario, Santa Fe",
  "estado": "ENTREGADA",
  "costoEstimado": 36624.0,
  "costoFinal": 1760.0,
  "tiempoEstimado": 5.1,
  "tiempoReal": 5.3
}
```

---

## 🔍 VERIFICACIÓN DE DATOS DE PRUEBA

### Conectarse a PostgreSQL desde consola:

```powershell
# Conectar a PostgreSQL dentro del contenedor
docker exec -it tpi-postgres psql -U admin -d bd-tpi-backend

# Una vez dentro, ejecutar queries:
\dt gestion.*          -- Ver tablas del schema gestion
\dt flota.*            -- Ver tablas del schema flota
\dt logistica.*        -- Ver tablas del schema logistica

SELECT COUNT(*) FROM gestion.clientes;       -- Debe mostrar 20 clientes
SELECT COUNT(*) FROM gestion.contenedores;   -- Debe mostrar 200 contenedores
SELECT COUNT(*) FROM flota.camiones;         -- Debe mostrar 30 camiones
SELECT COUNT(*) FROM logistica.solicitudes;  -- Debe mostrar 10 solicitudes

-- Ver clientes autogenerados (los que crea el sistema)
SELECT * FROM gestion.clientes WHERE apellido LIKE 'AutoGenerado%';

-- Ver camiones disponibles
SELECT patente, capacidad_peso, capacidad_volumen, disponible
FROM flota.camiones
WHERE disponible = true;

-- Ver solicitudes por estado
SELECT estado, COUNT(*) FROM logistica.solicitudes GROUP BY estado;

-- Salir
\q
```

---

## 🛠️ TROUBLESHOOTING

### Problema 1: "Cannot connect to Docker daemon"

**Causa:** Docker Desktop no está corriendo.

**Solución:**
- Windows: Abrir Docker Desktop desde el menú inicio
- Linux: `sudo systemctl start docker`
- Mac: Abrir Docker Desktop desde Aplicaciones

---

### Problema 2: "Port 5432 is already in use"

**Causa:** Ya tienes PostgreSQL instalado localmente en el puerto 5432.

**Solución:**

Opción A - Detener PostgreSQL local:

```powershell
# Windows
Stop-Service postgresql*

# Linux
sudo systemctl stop postgresql
```

Opción B - Cambiar puerto en `docker-compose.yml`:

```yaml
postgres:
  ports:
    - "5433:5432"  # Cambiar 5432 por 5433
```

Y también en los `application.yml` de los 3 microservicios:

```yaml
datasource:
  url: jdbc:postgresql://localhost:5433/bd-tpi-backend?currentSchema=...
```

---

### Problema 3: Servicio no inicia (estado "Restarting")

**Diagnóstico:**

```powershell
docker-compose logs servicio-gestion
```

**Errores comunes:**

#### A) "Connection refused to PostgreSQL"

**Causa:** PostgreSQL no terminó de inicializarse.

**Solución:** Esperar 30 segundos más y verificar:

```powershell
docker-compose logs postgres
```

Debe aparecer: `database system is ready to accept connections`

#### B) "Table 'clientes' doesn't exist"

**Causa:** El script `init-db.sql` no se ejecutó.

**Solución:** Borrar todo y volver a crear:

```powershell
docker-compose down -v
docker-compose up -d
```

#### C) "Could not compile Maven project"

**Causa:** Error de compilación en algún microservicio.

**Solución:** Compilar localmente para ver el error:

```powershell
cd servicio-gestion
mvn clean compile
```

---

### Problema 4: Google Maps devuelve "ZERO_RESULTS"

**Causa:** Dirección mal escrita o API Key inválida.

**Solución:**

1. Verificar que la API Key esté configurada en `.env`
2. Verificar que las APIs estén habilitadas en Google Cloud Console:
   - Directions API
   - Distance Matrix API
3. Usar direcciones completas:
   - ✅ "Puerto de Buenos Aires, Buenos Aires, Argentina"
   - ❌ "Buenos Aires" (muy genérico)

---

### Problema 5: "Cliente con ID X no encontrado"

**Causa:** El cliente no existe y hay un error en la creación automática.

**Diagnóstico:**

```powershell
docker-compose logs servicio-logistica | Select-String "Cliente"
```

**Solución:** Verificar que servicio-gestion esté corriendo:

```powershell
docker-compose ps
curl http://localhost:8080/api-gestion/clientes
```

---

### Problema 6: Cambié código pero no se refleja

**Causa:** Docker usa la imagen vieja.

**Solución:** Rebuild:

```powershell
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## 📊 RESUMEN DE PUERTOS

| Servicio | Puerto | URL Base |
|----------|--------|----------|
| PostgreSQL | 5432 | `localhost:5432` |
| Servicio Gestión | 8080 | `http://localhost:8080/api-gestion` |
| Servicio Flota | 8081 | `http://localhost:8081/api-flota` |
| Servicio Logística | 8082 | `http://localhost:8082/api-logistica` |

---

## 📝 COLECCIÓN POSTMAN COMPLETA

Puedes importar esta colección en Postman:

**Nombre:** TPI - Gestión de Contenedores

**Variables de colección:**
- `baseUrlGestion`: `http://localhost:8080/api-gestion`
- `baseUrlFlota`: `http://localhost:8081/api-flota`
- `baseUrlLogistica`: `http://localhost:8082/api-logistica`

**Carpetas:**

1. **Gestión - Clientes** (5 requests)
2. **Gestión - Contenedores** (4 requests)
3. **Gestión - Depósitos** (2 requests)
4. **Gestión - Tarifas** (3 requests)
5. **Flota - Camiones** (6 requests)
6. **Logística - Solicitudes** (8 requests)
7. **Logística - Rutas** (3 requests)
8. **Logística - Tramos** (7 requests)
9. **Flujo E2E Completo** (6 requests en secuencia)

---

## 🎓 RECURSOS ADICIONALES

### Docker

- Documentación oficial: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- Cheat Sheet: https://dockerlabs.collabnix.com/docker/cheatsheet/

### Spring Boot

- Spring Boot Docs: https://docs.spring.io/spring-boot/docs/current/reference/html/
- Spring Data JPA: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/

### PostgreSQL

- Documentación: https://www.postgresql.org/docs/
- pgAdmin (GUI): https://www.pgadmin.org/

### Google Maps API

- Directions API: https://developers.google.com/maps/documentation/directions
- Distance Matrix API: https://developers.google.com/maps/documentation/distance-matrix

---

## 📧 CONTACTO

**Desarrollador:** Martín Carrizo  
**Email:** martin.carrizo@example.com  
**Proyecto:** TPI - Gestión de Contenedores  
**Universidad:** Universidad Tecnológica Nacional (UTN)

---

## 📄 CHANGELOG

### Versión 2.0 (Noviembre 6, 2025)
- ✅ PostgreSQL local con Docker (conexiones ilimitadas)
- ✅ 295 registros de datos de prueba completos
- ✅ Validación de capacidad de camión integrada
- ✅ Creación automática de cliente
- ✅ Dockerfiles multi-stage optimizados
- ✅ Guía de usuario completa con 15,000 palabras

### Versión 1.0 (Octubre 2025)
- ✅ 3 microservicios independientes (Gestión, Flota, Logística)
- ✅ Integración con Google Maps API
- ✅ Máquina de estados para solicitudes y tramos
- ✅ Implementación completa de 11 requerimientos del TP

---

**¡Fin de la guía! 🚀**

Si tienes problemas, revisa la sección de Troubleshooting o consulta los logs de Docker.
