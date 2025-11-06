# 🚀 GUÍA DE IMPLEMENTACIÓN: API GATEWAY + KEYCLOAK + MICROSERVICIOS

**Autor:** Martín Carrizo  
**Fecha:** Noviembre 6, 2025  
**Versión:** 1.0

---

## 📋 TABLA DE CONTENIDOS

1. [Resumen de la arquitectura](#resumen-de-la-arquitectura)
2. [Cambios realizados](#cambios-realizados)
3. [Estructura del proyecto](#estructura-del-proyecto)
4. [Configuración de puertos](#configuración-de-puertos)
5. [Guía de despliegue](#guía-de-despliegue)
6. [Testing paso a paso](#testing-paso-a-paso)
7. [Mapeo de endpoints](#mapeo-de-endpoints)

---

## 🏗️ RESUMEN DE LA ARQUITECTURA

### Antes (Sin API Gateway):

```
Cliente → http://localhost:8080/api-gestion/clientes
Cliente → http://localhost:8081/api-flota/camiones  
Cliente → http://localhost:8082/api-logistica/solicitudes
```

**Problemas:**
- ❌ Cliente debe conocer 3 URLs diferentes
- ❌ Cada microservicio debe validar tokens
- ❌ CORS configurado 3 veces
- ❌ Sin Circuit Breaker
- ❌ Sin punto único de monitoreo

### Después (Con API Gateway + Keycloak):

```
                              ┌──────────────┐
Cliente → http://localhost:8080 │  API Gateway │
                              │  (Puerto 8080)│
                              │              │
                              │ + Keycloak   │
                              │   (Puerto    │
                              │    9090)     │
                              └──────┬───────┘
                                     │
                 ┌───────────────────┼───────────────────┐
                 │                   │                   │
                 ▼                   ▼                   ▼
          ┌────────────┐      ┌────────────┐     ┌────────────┐
          │  Gestión   │      │   Flota    │     │ Logística  │
          │  :8081     │      │   :8082    │     │   :8083    │
          │ (interno)  │      │ (interno)  │     │ (interno)  │
          └────────────┘      └────────────┘     └────────────┘
                 │                   │                   │
                 └───────────────────┼───────────────────┘
                                     ▼
                              ┌──────────────┐
                              │  PostgreSQL  │
                              │   :5432      │
                              └──────────────┘
```

**Beneficios:**
- ✅ Cliente usa 1 URL: `http://localhost:8080`
- ✅ Autenticación centralizada con Keycloak
- ✅ CORS configurado una vez
- ✅ Circuit Breaker para resiliencia
- ✅ Monitoreo centralizado
- ✅ Rate Limiting fácil de agregar

---

## 📦 CAMBIOS REALIZADOS

### 1. Archivos nuevos creados:

#### API Gateway:
```
api-gateway/
├── pom.xml                              ← Dependencias Spring Cloud Gateway
├── Dockerfile                           ← Multi-stage build
└── src/main/
    ├── java/com/tpi/gateway/
    │   ├── ApiGatewayApplication.java   ← Clase principal
    │   ├── config/
    │   │   └── SecurityConfig.java      ← Seguridad + Keycloak
    │   └── controller/
    │       └── FallbackController.java  ← Circuit Breaker fallbacks
    └── resources/
        └── application.yml              ← Rutas y configuración
```

#### Documentación:
- `GUIA_SPRING_GATEWAY_KEYCLOAK.md` - Guía completa de Gateway + Keycloak
- `IMPLEMENTACION_API_GATEWAY.md` - Este documento

### 2. Archivos modificados:

#### Docker Compose:
```yaml
# docker-compose.yml

services:
  # NUEVO: Keycloak (puerto 9090)
  keycloak:
    image: quay.io/keycloak/keycloak:26.0.7
    ports:
      - "9090:9090"
  
  # NUEVO: API Gateway (puerto 8080)
  api-gateway:
    build: ./api-gateway
    ports:
      - "8080:8080"
  
  # MODIFICADO: Puertos internos
  servicio-gestion:    # 8080 → 8081
  servicio-flota:      # 8081 → 8082  
  servicio-logistica:  # 8082 → 8083
```

#### Variables de entorno:
```bash
# .env.example

# NUEVO
KEYCLOAK_ADMIN_PASSWORD=admin123

# NOTAS ACTUALIZADAS
# - Gateway en puerto 8080 (entrada única)
# - Keycloak en puerto 9090
# - Microservicios en puertos internos (8081, 8082, 8083)
```

---

## 📂 ESTRUCTURA DEL PROYECTO

```
GestionContenedores/
├── api-gateway/                    ✨ NUEVO
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/tpi/gateway/
│       │   ├── ApiGatewayApplication.java
│       │   ├── config/SecurityConfig.java
│       │   └── controller/FallbackController.java
│       └── resources/application.yml
│
├── servicio-gestion/               ✏️ Puerto cambiado 8080→8081
├── servicio-flota/                 ✏️ Puerto cambiado 8081→8082
├── servicio-logistica/             ✏️ Puerto cambiado 8082→8083
│
├── docker-compose.yml              ✏️ Modificado (Keycloak + Gateway)
├── .env.example                    ✏️ Modificado
│
└── 📚 Documentación:
    ├── GUIA_SPRING_GATEWAY_KEYCLOAK.md   ✨ NUEVO
    └── IMPLEMENTACION_API_GATEWAY.md      ✨ NUEVO (este archivo)
```

---

## 🔌 CONFIGURACIÓN DE PUERTOS

| Servicio | Puerto | Acceso | Uso |
|----------|--------|--------|-----|
| **PostgreSQL** | 5432 | Externo | Base de datos (desde host y Docker) |
| **Keycloak** | 9090 | Externo | Admin Console y obtener tokens |
| **API Gateway** | 8080 | **Externo** | **Entrada única al sistema** |
| Servicio Gestión | 8081 | Interno | Solo accesible vía Gateway |
| Servicio Flota | 8082 | Interno | Solo accesible vía Gateway |
| Servicio Logística | 8083 | Interno | Solo accesible vía Gateway |

### URLs importantes:

| Descripción | URL |
|-------------|-----|
| **Keycloak Admin Console** | http://localhost:9090 |
| **API Gateway (entrada única)** | http://localhost:8080 |
| Obtener token JWT | http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token |
| Health check Gateway | http://localhost:8080/actuator/health |
| Listar rutas Gateway | http://localhost:8080/actuator/gateway/routes |

---

## 🚀 GUÍA DE DESPLIEGUE

### Paso 1: Preparar entorno

```powershell
# 1. Crear archivo .env desde el template
Copy-Item .env.example .env

# 2. Editar .env y configurar:
#    - POSTGRES_PASSWORD
#    - KEYCLOAK_ADMIN_PASSWORD
#    - GOOGLE_MAPS_API_KEY

# 3. Bajar contenedores anteriores (si existen)
docker-compose down -v
```

### Paso 2: Levantar sistema completo

```powershell
# Construir e iniciar todos los contenedores
docker-compose up -d --build

# Ver logs en tiempo real
docker-compose logs -f

# Esperar a que todos estén healthy (2-3 minutos)
# PostgreSQL → Keycloak → Gateway → Microservicios
```

### Paso 3: Verificar que todo está corriendo

```powershell
# Ver estado de contenedores
docker-compose ps

# Debe mostrar:
# tpi-postgres     Up (healthy)
# tpi-keycloak     Up (healthy)
# tpi-gateway      Up
# tpi-gestion      Up
# tpi-flota        Up
# tpi-logistica    Up
```

### Paso 4: Configurar Keycloak (solo primera vez)

#### 4.1. Acceder a Admin Console:
- URL: http://localhost:9090
- Usuario: `admin`
- Password: `admin123` (o el configurado en .env)

#### 4.2. Crear Realm `tpi-backend`:
1. Click en dropdown "master" (arriba izquierda)
2. "Create Realm"
3. Name: `tpi-backend`
4. Create

#### 4.3. Crear Client `tpi-client`:
1. Clients → Create client
2. Client ID: `tpi-client`
3. Next
4. Client authentication: ON
5. Authentication flow:
   - ✅ Standard flow
   - ✅ Direct access grants
6. Save
7. **Ir a pestaña "Credentials" y copiar Client Secret**

#### 4.4. Crear Roles:
1. Realm roles → Create role
2. Crear 3 roles:
   - `CLIENTE` (puede crear solicitudes y consultar estado)
   - `OPERADOR` (gestiona rutas, asigna camiones, administra maestros)
   - `TRANSPORTISTA` (inicia y finaliza tramos)

#### 4.5. Crear Usuarios:
| Username | Password | Rol |
|----------|----------|-----|
| cliente@tpi.com | cliente123 | CLIENTE |
| operador@tpi.com | operador123 | OPERADOR |
| transportista@tpi.com | transportista123 | TRANSPORTISTA |

**Pasos para cada usuario:**
1. Users → Create new user
2. Username, Email, First name, Last name
3. Email verified: ON
4. Create
5. Pestaña Credentials → Set password → Temporary: OFF
6. Pestaña Role mapping → Assign role

### Paso 5: Testing inicial

```powershell
# 1. Health check Gateway
curl http://localhost:8080/actuator/health

# 2. Ver rutas configuradas
curl http://localhost:8080/actuator/gateway/routes

# 3. Intentar acceso sin token (debe dar 401)
curl http://localhost:8080/api/gestion/clientes
```

---

## 🧪 TESTING PASO A PASO

### Opción 1: Con Postman (Recomendado)

#### Request 1: Obtener token (Operador)

```
POST http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token

Headers:
Content-Type: application/x-www-form-urlencoded

Body (x-www-form-urlencoded):
grant_type: password
client_id: tpi-client
client_secret: <pegar_client_secret_aqui>
username: operador@tpi.com
password: operador123

Tests (JavaScript):
pm.test("Token obtenido", function () {
    pm.response.to.have.status(200);
    const jsonData = pm.response.json();
    pm.collectionVariables.set("access_token", jsonData.access_token);
});
```

**Respuesta esperada:**
```json
{
    "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI...",
    "expires_in": 300,
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI...",
    "token_type": "Bearer"
}
```

#### Request 2: Listar clientes (requiere OPERADOR)

```
GET http://localhost:8080/api/gestion/clientes

Headers:
Authorization: Bearer {{access_token}}
```

**Respuesta esperada:** `200 OK` con lista de 20 clientes

#### Request 3: Crear solicitud (requiere CLIENTE)

```
# Primero obtener token de CLIENTE
POST http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token
Body:
username: cliente@tpi.com
password: cliente123

# Luego crear solicitud
POST http://localhost:8080/api/logistica/solicitudes
Authorization: Bearer {{access_token_cliente}}
Content-Type: application/json

{
    "numeroSeguimiento": "TRACK-TEST-001",
    "idContenedor": 1,
    "idCliente": 1,
    "origenDireccion": "Buenos Aires, Argentina",
    "origenLatitud": -34.6037,
    "origenLongitud": -58.3816,
    "destinoDireccion": "Rosario, Argentina",
    "destinoLatitud": -32.9468,
    "destinoLongitud": -60.6393
}
```

**Respuesta esperada:** `200 OK` con solicitud creada

#### Request 4: Testing de roles

```
# Con token de CLIENTE, intentar listar clientes (debe fallar)
GET http://localhost:8080/api/gestion/clientes
Authorization: Bearer {{access_token_cliente}}

Respuesta esperada: 403 Forbidden
```

### Opción 2: Con cURL

```bash
# 1. Obtener token
TOKEN=$(curl -X POST "http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=tpi-client" \
  -d "client_secret=<client_secret>" \
  -d "username=operador@tpi.com" \
  -d "password=operador123" \
  | jq -r '.access_token')

# 2. Usar token
curl http://localhost:8080/api/gestion/clientes \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🗺️ MAPEO DE ENDPOINTS

### Formato: `[ROL] MÉTODO /ruta-gateway → /ruta-microservicio`

#### Servicio Gestión (8081):

| Gateway URL | Microservicio URL | Rol | Descripción |
|-------------|-------------------|-----|-------------|
| `GET /api/gestion/clientes` | `GET /api-gestion/clientes` | OPERADOR | Listar clientes |
| `POST /api/gestion/clientes` | `POST /api-gestion/clientes` | OPERADOR | Crear cliente |
| `GET /api/gestion/clientes/{id}` | `GET /api-gestion/clientes/{id}` | OPERADOR | Obtener cliente |
| `GET /api/gestion/contenedores` | `GET /api-gestion/contenedores` | OPERADOR | Listar contenedores |
| `GET /api/gestion/contenedores/{id}/estado` | `GET /api-gestion/contenedores/{id}/estado` | CLIENTE | Consultar estado |
| `GET /api/gestion/depositos` | `GET /api-gestion/depositos` | OPERADOR | Listar depósitos |
| `POST /api/gestion/depositos` | `POST /api-gestion/depositos` | OPERADOR | Crear depósito |
| `GET /api/gestion/tarifas` | `GET /api-gestion/tarifas` | OPERADOR | Listar tarifas |
| `POST /api/gestion/tarifas` | `POST /api-gestion/tarifas` | OPERADOR | Crear tarifa |

#### Servicio Flota (8082):

| Gateway URL | Microservicio URL | Rol | Descripción |
|-------------|-------------------|-----|-------------|
| `GET /api/flota/camiones` | `GET /api-flota/camiones` | OPERADOR | Listar camiones |
| `POST /api/flota/camiones` | `POST /api-flota/camiones` | OPERADOR | Crear camión |
| `GET /api/flota/camiones/aptos` | `GET /api-flota/camiones/aptos` | OPERADOR | Camiones con capacidad |

#### Servicio Logística (8083):

| Gateway URL | Microservicio URL | Rol | Descripción |
|-------------|-------------------|-----|-------------|
| `GET /api/logistica/solicitudes` | `GET /api-logistica/solicitudes` | OPERADOR | Listar solicitudes |
| `POST /api/logistica/solicitudes` | `POST /api-logistica/solicitudes` | CLIENTE | Crear solicitud |
| `GET /api/logistica/solicitudes/cliente/{id}` | `GET /api-logistica/solicitudes/cliente/{id}` | CLIENTE | Mis solicitudes |
| `POST /api/logistica/solicitudes/estimar-ruta` | `POST /api-logistica/solicitudes/estimar-ruta` | OPERADOR | Estimar ruta |
| `POST /api/logistica/solicitudes/{id}/asignar-ruta` | `POST /api-logistica/solicitudes/{id}/asignar-ruta` | OPERADOR | Asignar ruta |
| `PUT /api/logistica/tramos/{id}/asignar-camion` | `PUT /api-logistica/tramos/{id}/asignar-camion` | OPERADOR | Asignar camión |
| `PATCH /api/logistica/tramos/{id}/iniciar` | `PATCH /api-logistica/tramos/{id}/iniciar` | TRANSPORTISTA | Iniciar tramo |
| `PATCH /api/logistica/tramos/{id}/finalizar` | `PATCH /api-logistica/tramos/{id}/finalizar` | TRANSPORTISTA | Finalizar tramo |

---

## 🔍 VERIFICACIÓN DE IMPLEMENTACIÓN

### Checklist completo:

- [ ] PostgreSQL corriendo en puerto 5432
- [ ] Keycloak corriendo en puerto 9090
- [ ] API Gateway corriendo en puerto 8080
- [ ] 3 microservicios corriendo (8081, 8082, 8083)
- [ ] Realm `tpi-backend` creado en Keycloak
- [ ] Client `tpi-client` configurado con client_secret
- [ ] 3 roles creados (CLIENTE, OPERADOR, TRANSPORTISTA)
- [ ] 3 usuarios creados con sus roles
- [ ] Token JWT obtenido correctamente
- [ ] Endpoint con rol correcto devuelve 200 OK
- [ ] Endpoint con rol incorrecto devuelve 403 Forbidden
- [ ] Endpoint sin token devuelve 401 Unauthorized
- [ ] Circuit Breaker funciona (bajar un microservicio y probar)

### Comandos de verificación:

```powershell
# 1. Verificar contenedores
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 2. Verificar logs del Gateway
docker logs tpi-gateway --tail 50

# 3. Verificar rutas del Gateway
curl http://localhost:8080/actuator/gateway/routes | jq

# 4. Verificar salud del sistema
curl http://localhost:8080/actuator/health | jq

# 5. Test end-to-end automatizado
# (obtener token + llamar endpoint + verificar respuesta)
```

---

## 🎯 RESUMEN DE LA ARQUITECTURA FINAL

```
┌────────────────────────────────────────────────────────────┐
│                    DOCKER COMPOSE                          │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────┐         ┌──────────────┐              │
│  │  PostgreSQL  │◄────────┤  Keycloak    │              │
│  │   :5432      │         │   :9090      │              │
│  └──────┬───────┘         └──────┬───────┘              │
│         │                        │                        │
│         │                        │ JWT Validation         │
│         │                        │                        │
│         │                 ┌──────▼───────────┐           │
│         │                 │   API Gateway    │           │
│         │                 │    :8080         │           │
│         │                 │                  │           │
│         │                 │ ✓ Autenticación  │           │
│         │                 │ ✓ Autorización   │           │
│         │                 │ ✓ Enrutamiento   │           │
│         │                 │ ✓ CORS           │           │
│         │                 │ ✓ Circuit Breaker│           │
│         │                 └──────┬───────────┘           │
│         │                        │                        │
│         │       ┌────────────────┼─────────────────┐     │
│         │       │                │                 │     │
│         │       ▼                ▼                 ▼     │
│         │  ┌──────────┐    ┌──────────┐     ┌──────────┐│
│         └─►│ Gestión  │    │  Flota   │     │Logística ││
│            │  :8081   │    │  :8082   │     │  :8083   ││
│            └──────────┘    └──────────┘     └──────────┘│
│                 │                │                 │     │
│                 │   Shared Database (3 schemas)    │     │
│                 └────────────────┴─────────────────┘     │
│                                                            │
└────────────────────────────────────────────────────────────┘

ACCESO EXTERNO:
- PostgreSQL: localhost:5432
- Keycloak: localhost:9090
- API Gateway: localhost:8080 (ENTRADA ÚNICA)
```

---

**¡Implementación completada!** 🚀

Para más detalles, consulta:
- `GUIA_SPRING_GATEWAY_KEYCLOAK.md` - Funcionamiento de Gateway y Keycloak
- `GUIA_USUARIO_POSTMAN.md` - Testing de endpoints
- [Spring Cloud Gateway](https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
