# 🔐 GUÍA COMPLETA: SPRING CLOUD GATEWAY + KEYCLOAK

**Autor:** Martín Carrizo  
**Fecha:** Noviembre 6, 2025  
**Versión:** 1.0

---

## 📋 TABLA DE CONTENIDOS

1. [Introducción](#introducción)
2. [¿Qué es Spring Cloud Gateway?](#qué-es-spring-cloud-gateway)
3. [¿Qué es Keycloak?](#qué-es-keycloak)
4. [¿Cómo funciona la integración?](#cómo-funciona-la-integración)
5. [Flujo completo de autenticación](#flujo-completo-de-autenticación)
6. [Configuración de Keycloak](#configuración-de-keycloak)
7. [Obtención de tokens JWT](#obtención-de-tokens-jwt)
8. [Testing con Postman](#testing-con-postman)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 INTRODUCCIÓN

Este sistema utiliza **Spring Cloud Gateway** como punto de entrada único (API Gateway) y **Keycloak** como servidor de autenticación y autorización basado en OAuth2/OpenID Connect.

### ¿Por qué usar un API Gateway?

| Sin API Gateway | Con API Gateway |
|-----------------|-----------------|
| Cliente llama directamente a cada microservicio | Cliente llama solo al Gateway |
| Cada microservicio debe validar tokens | Solo el Gateway valida tokens |
| CORS configurado en cada servicio | CORS configurado centralmente |
| N URLs para el cliente | 1 URL para el cliente |
| Difícil aplicar rate limiting | Fácil aplicar rate limiting |
| Sin Circuit Breaker | Circuit Breaker incluido |

---

## 🌉 ¿QUÉ ES SPRING CLOUD GATEWAY?

**Spring Cloud Gateway** es un API Gateway reactivo construido sobre Spring WebFlux que proporciona enrutamiento, filtrado y resiliencia para microservicios.

### Características principales:

✅ **Enrutamiento dinámico**: Redirige peticiones según patrones de URL  
✅ **Filtros**: Modifica request/response (agregar headers, logging, etc.)  
✅ **Circuit Breaker**: Si un servicio cae, devuelve fallback  
✅ **Rate Limiting**: Limita peticiones por usuario/IP  
✅ **Load Balancing**: Distribuye carga entre instancias  
✅ **Reactivo**: Basado en WebFlux (no bloqueante)

### Arquitectura del Gateway en nuestro sistema:

```
                         CLIENTE (Postman/Frontend)
                                    │
                                    │ Token JWT
                                    ▼
                         ┌──────────────────────┐
                         │   API GATEWAY        │
                         │   (Puerto 8080)      │
                         │                      │
                         │  1. Valida JWT       │
                         │  2. Extrae roles     │
                         │  3. Enruta petición  │
                         └──────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
            ┌──────────┐    ┌──────────┐    ┌──────────┐
            │ Gestión  │    │  Flota   │    │Logística │
            │  :8081   │    │  :8082   │    │  :8083   │
            └──────────┘    └──────────┘    └──────────┘
                    │               │               │
                    └───────────────┼───────────────┘
                                    ▼
                            ┌──────────────┐
                            │  PostgreSQL  │
                            │   :5432      │
                            └──────────────┘
```

### Ejemplo de enrutamiento:

```yaml
# Cuando el cliente hace:
GET http://localhost:8080/api/gestion/clientes

# El Gateway:
# 1. Valida el token JWT
# 2. Extrae roles (CLIENTE, OPERADOR, TRANSPORTISTA)
# 3. Verifica permisos (¿tiene rol OPERADOR?)
# 4. Reescribe la ruta: /api/gestion/clientes → /api-gestion/clientes
# 5. Redirige a: http://servicio-gestion:8081/api-gestion/clientes
# 6. Devuelve respuesta al cliente
```

---

## 🔑 ¿QUÉ ES KEYCLOAK?

**Keycloak** es un servidor de Identity and Access Management (IAM) open-source que implementa OAuth2, OpenID Connect y SAML.

### Características principales:

✅ **Single Sign-On (SSO)**: Un login para múltiples aplicaciones  
✅ **OAuth2/OpenID Connect**: Estándar de la industria  
✅ **Gestión de usuarios y roles**: UI web para administrar  
✅ **Social Login**: Login con Google, Facebook, etc.  
✅ **Two-Factor Authentication**: Autenticación de 2 factores  
✅ **Tokens JWT**: Tokens seguros y verificables  
✅ **Federación de identidades**: Integración con LDAP/Active Directory

### Conceptos clave:

| Concepto | Descripción | Ejemplo en TPI |
|----------|-------------|----------------|
| **Realm** | Espacio aislado de usuarios y aplicaciones | `tpi-backend` |
| **Client** | Aplicación que usa Keycloak | `tpi-client` (Postman) |
| **User** | Usuario del sistema | `operador@tpi.com` |
| **Role** | Rol asignado a usuarios | `CLIENTE`, `OPERADOR`, `TRANSPORTISTA` |
| **Token JWT** | Token firmado con información del usuario | Contiene username, roles, expiración |
| **Realm Roles** | Roles globales del realm | Los 3 roles del sistema |
| **Client Roles** | Roles específicos de un client | No usados en este proyecto |

---

## 🔄 ¿CÓMO FUNCIONA LA INTEGRACIÓN?

### Flujo de autenticación y autorización:

```
┌─────────┐                 ┌──────────┐              ┌─────────┐              ┌──────────────┐
│ Cliente │                 │ Keycloak │              │ Gateway │              │ Microservicio│
└────┬────┘                 └────┬─────┘              └────┬────┘              └──────┬───────┘
     │                           │                         │                          │
     │ 1. POST /auth/realms/     │                         │                          │
     │    tpi-backend/protocol/  │                         │                          │
     │    openid-connect/token   │                         │                          │
     │ (username + password)     │                         │                          │
     ├──────────────────────────>│                         │                          │
     │                           │                         │                          │
     │ 2. Valida credenciales    │                         │                          │
     │                           │                         │                          │
     │ 3. Token JWT (firmado)    │                         │                          │
     │<──────────────────────────┤                         │                          │
     │                           │                         │                          │
     │ 4. GET /api/gestion/clientes                        │                          │
     │    Authorization: Bearer <JWT>                      │                          │
     ├─────────────────────────────────────────────────────>│                          │
     │                           │                         │                          │
     │                           │  5. Obtiene clave       │                          │
     │                           │     pública (JWK)       │                          │
     │                           │<────────────────────────┤                          │
     │                           │                         │                          │
     │                           │  6. Devuelve JWK Set    │                          │
     │                           ├────────────────────────>│                          │
     │                           │                         │                          │
     │                           │    7. Valida firma JWT  │                          │
     │                           │    8. Extrae roles      │                          │
     │                           │    9. Verifica permisos │                          │
     │                           │   10. ¿Tiene rol        │                          │
     │                           │       OPERADOR?         │                          │
     │                           │                         │                          │
     │                           │   11. GET /api-gestion/clientes                    │
     │                           │                         ├─────────────────────────>│
     │                           │                         │                          │
     │                           │                         │   12. Respuesta JSON     │
     │                           │                         │<─────────────────────────┤
     │                           │                         │                          │
     │   13. Respuesta JSON      │                         │                          │
     │<─────────────────────────────────────────────────────┤                          │
     │                           │                         │                          │
```

### Explicación paso a paso:

1. **Cliente solicita token**: Envía username y password a Keycloak
2. **Keycloak valida**: Verifica credenciales en su base de datos
3. **Keycloak devuelve JWT**: Token firmado con información del usuario (username, roles, expiración)
4. **Cliente llama al Gateway**: Incluye el token en el header `Authorization: Bearer <token>`
5-6. **Gateway obtiene clave pública**: Descarga las claves públicas de Keycloak (JWK Set)
7-8. **Gateway valida token**: Verifica firma y extrae claims (username, roles)
9-10. **Gateway verifica permisos**: Comprueba si el usuario tiene el rol necesario para el endpoint
11. **Gateway enruta**: Si está autorizado, redirige la petición al microservicio correspondiente
12-13. **Respuesta**: El microservicio responde y el Gateway devuelve al cliente

---

## 🔐 FLUJO COMPLETO DE AUTENTICACIÓN

### Paso 1: Obtener token de Keycloak

```http
POST http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

grant_type=password
&client_id=tpi-client
&client_secret=tu_client_secret_aqui
&username=operador@tpi.com
&password=operador123
```

**Respuesta:**
```json
{
    "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI...",
    "expires_in": 300,
    "refresh_expires_in": 1800,
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI...",
    "token_type": "Bearer",
    "not-before-policy": 0,
    "session_state": "abc123...",
    "scope": "profile email"
}
```

### Paso 2: Decodificar el JWT

El token JWT tiene 3 partes separadas por puntos (`.`):

```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
│         HEADER         │                    PAYLOAD                    │                SIGNATURE                │
```

**HEADER** (algoritmo de firma):
```json
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "key-id-123"
}
```

**PAYLOAD** (información del usuario):
```json
{
  "exp": 1699999999,
  "iat": 1699999699,
  "jti": "abc-123-def-456",
  "iss": "http://localhost:9090/realms/tpi-backend",
  "aud": "account",
  "sub": "usuario-uuid-123",
  "typ": "Bearer",
  "azp": "tpi-client",
  "session_state": "session-123",
  "acr": "1",
  "realm_access": {
    "roles": [
      "OPERADOR",
      "default-roles-tpi-backend"
    ]
  },
  "scope": "profile email",
  "email_verified": true,
  "name": "Operador TPI",
  "preferred_username": "operador@tpi.com",
  "given_name": "Operador",
  "family_name": "TPI",
  "email": "operador@tpi.com"
}
```

**SIGNATURE** (firma digital):
- Keycloak firma el token con su clave privada (RSA)
- El Gateway verifica la firma con la clave pública de Keycloak
- Si la firma no coincide, el token es inválido

### Paso 3: Usar el token en peticiones

```http
GET http://localhost:8080/api/gestion/clientes
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI...
```

El Gateway:
1. ✅ Verifica la firma del JWT con la clave pública de Keycloak
2. ✅ Comprueba que no haya expirado (`exp` claim)
3. ✅ Extrae los roles de `realm_access.roles`
4. ✅ Verifica que el usuario tenga rol `OPERADOR` (requerido por el endpoint)
5. ✅ Si todo es válido, enruta la petición al microservicio

---

## ⚙️ CONFIGURACIÓN DE KEYCLOAK

### Paso 1: Acceder a Keycloak Admin Console

1. Abrir navegador: `http://localhost:9090`
2. Click en "Administration Console"
3. Login con:
   - **Username**: `admin`
   - **Password**: `admin123` (configurable en `.env`)

### Paso 2: Crear Realm `tpi-backend`

1. En el menú superior izquierdo, click en el dropdown "master"
2. Click en "Create Realm"
3. Configurar:
   - **Realm name**: `tpi-backend`
   - **Enabled**: ON
4. Click en "Create"

### Paso 3: Crear Client `tpi-client`

1. En el menú lateral, ir a **Clients** → **Create client**
2. **General Settings**:
   - **Client type**: `OpenID Connect`
   - **Client ID**: `tpi-client`
   - Click "Next"
3. **Capability config**:
   - **Client authentication**: `ON` (para obtener client_secret)
   - **Authorization**: `OFF`
   - **Authentication flow**:
     - ✅ Standard flow
     - ✅ Direct access grants (para password grant)
     - ✅ Service accounts roles
   - Click "Next"
4. **Login settings**:
   - **Root URL**: `http://localhost:8080`
   - **Valid redirect URIs**: `*` (en producción usar URLs específicas)
   - **Web origins**: `*` (para CORS)
   - Click "Save"

5. **Obtener Client Secret**:
   - Ir a la pestaña "Credentials"
   - Copiar el **Client secret** (necesario para obtener tokens)

### Paso 4: Crear Roles

1. En el menú lateral, ir a **Realm roles** → **Create role**
2. Crear 3 roles:

**Rol 1: CLIENTE**
   - **Role name**: `CLIENTE`
   - **Description**: `Cliente que registra solicitudes y consulta estado`
   - Click "Save"

**Rol 2: OPERADOR**
   - **Role name**: `OPERADOR`
   - **Description**: `Operador que gestiona rutas, asigna camiones y administra maestros`
   - Click "Save"

**Rol 3: TRANSPORTISTA**
   - **Role name**: `TRANSPORTISTA`
   - **Description**: `Transportista que inicia y finaliza tramos`
   - Click "Save"

### Paso 5: Crear Usuarios

**Usuario 1: Cliente**
1. En el menú lateral, ir a **Users** → **Create new user**
2. Configurar:
   - **Username**: `cliente@tpi.com`
   - **Email**: `cliente@tpi.com`
   - **Email verified**: `ON`
   - **First name**: `Cliente`
   - **Last name**: `TPI`
   - **Enabled**: `ON`
3. Click "Create"
4. Ir a la pestaña **Credentials**:
   - Click "Set password"
   - **Password**: `cliente123`
   - **Temporary**: `OFF`
   - Click "Save"
5. Ir a la pestaña **Role mapping**:
   - Click "Assign role"
   - Seleccionar `CLIENTE`
   - Click "Assign"

**Usuario 2: Operador**
1. Crear con:
   - **Username**: `operador@tpi.com`
   - **Password**: `operador123`
   - **Rol**: `OPERADOR`

**Usuario 3: Transportista**
1. Crear con:
   - **Username**: `transportista@tpi.com`
   - **Password**: `transportista123`
   - **Rol**: `TRANSPORTISTA`

---

## 🚀 OBTENCIÓN DE TOKENS JWT

### Método 1: Postman (Recomendado)

1. **Nueva Request**: `POST http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token`
2. **Headers**:
   - `Content-Type`: `application/x-www-form-urlencoded`
3. **Body** (x-www-form-urlencoded):
   - `grant_type`: `password`
   - `client_id`: `tpi-client`
   - `client_secret`: `<tu_client_secret>`
   - `username`: `operador@tpi.com`
   - `password`: `operador123`
4. **Send** → Copiar `access_token` de la respuesta

### Método 2: cURL

```bash
curl -X POST "http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=tpi-client" \
  -d "client_secret=<tu_client_secret>" \
  -d "username=operador@tpi.com" \
  -d "password=operador123"
```

### Método 3: PowerShell

```powershell
$body = @{
    grant_type = "password"
    client_id = "tpi-client"
    client_secret = "<tu_client_secret>"
    username = "operador@tpi.com"
    password = "operador123"
}

$response = Invoke-RestMethod -Uri "http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token" `
                              -Method Post `
                              -ContentType "application/x-www-form-urlencoded" `
                              -Body $body

$response.access_token
```

---

## 📬 TESTING CON POSTMAN

### Configuración inicial:

1. **Crear Collection**: "TPI Backend - Con API Gateway"
2. **Variables de Collection**:
   - `gateway_url`: `http://localhost:8080`
   - `keycloak_url`: `http://localhost:9090`
   - `realm`: `tpi-backend`
   - `client_id`: `tpi-client`
   - `client_secret`: `<tu_client_secret>`
   - `access_token`: (se actualizará dinámicamente)

### Request 1: Obtener Token (Operador)

```
POST {{keycloak_url}}/realms/{{realm}}/protocol/openid-connect/token

Body (x-www-form-urlencoded):
grant_type: password
client_id: {{client_id}}
client_secret: {{client_secret}}
username: operador@tpi.com
password: operador123

Tests (JavaScript):
pm.test("Token obtenido correctamente", function () {
    pm.response.to.have.status(200);
    const jsonData = pm.response.json();
    pm.collectionVariables.set("access_token", jsonData.access_token);
});
```

### Request 2: Listar Clientes (requiere rol OPERADOR)

```
GET {{gateway_url}}/api/gestion/clientes

Headers:
Authorization: Bearer {{access_token}}
```

### Request 3: Crear Solicitud (requiere rol CLIENTE)

```
POST {{gateway_url}}/api/logistica/solicitudes

Headers:
Authorization: Bearer {{access_token}}
Content-Type: application/json

Body (JSON):
{
    "numeroSeguimiento": "TRACK-2025-999",
    "idContenedor": 1,
    "idCliente": 1,
    "origenDireccion": "Buenos Aires",
    "origenLatitud": -34.6037,
    "origenLongitud": -58.3816,
    "destinoDireccion": "Rosario",
    "destinoLatitud": -32.9468,
    "destinoLongitud": -60.6393
}
```

### Errores comunes y sus códigos:

| Código HTTP | Error | Causa |
|-------------|-------|-------|
| `401 Unauthorized` | Token inválido o expirado | Obtener nuevo token |
| `403 Forbidden` | Usuario no tiene el rol necesario | Verificar roles del usuario |
| `404 Not Found` | Endpoint no existe | Verificar URL |
| `500 Internal Server Error` | Error en el microservicio | Ver logs del microservicio |
| `503 Service Unavailable` | Microservicio caído | Circuit Breaker activado |

---

## 🔧 TROUBLESHOOTING

### Problema 1: "Token expired"

**Síntoma**: `401 Unauthorized` con mensaje "Token expired"

**Solución**:
- Los tokens JWT expiran en 5 minutos por defecto
- Obtener un nuevo token con la request "Obtener Token"
- O usar Refresh Token para renovarlo

### Problema 2: "Insufficient permissions" / 403 Forbidden

**Síntoma**: `403 Forbidden`

**Causa**: El usuario no tiene el rol necesario

**Solución**:
1. Verificar qué roles tiene el usuario:
   - Decodificar el JWT en https://jwt.io
   - Ver el claim `realm_access.roles`
2. Asignar el rol faltante en Keycloak Admin Console

### Problema 3: "Invalid token"

**Síntoma**: `401 Unauthorized` con mensaje "Invalid token signature"

**Causas posibles**:
- Token mal copiado (espacios extra, caracteres faltantes)
- Keycloak cambió sus claves (reinicio)
- Gateway no puede contactar a Keycloak

**Solución**:
1. Verificar que Keycloak esté corriendo: `docker ps | grep keycloak`
2. Obtener un token nuevo
3. Copiar el token completo (sin espacios extras)
4. Verificar conectividad: `curl http://localhost:9090/health`

### Problema 4: Gateway no arranca

**Síntoma**: `api-gateway` container termina con error

**Causas posibles**:
- Spring Web (servlet) y Spring WebFlux (reactivo) en conflicto
- Puerto 8080 ocupado
- No puede conectar con Keycloak

**Solución**:
1. Ver logs: `docker logs tpi-gateway`
2. Verificar que no haya `spring-boot-starter-web` en pom.xml
3. Verificar puerto libre: `netstat -an | findstr :8080`
4. Esperar a que Keycloak esté healthy

### Problema 5: CORS error en navegador

**Síntoma**: Error CORS al llamar desde frontend

**Solución**:
- El Gateway ya tiene CORS configurado en `application.yml`
- Si persiste, verificar que `allowedOrigins` incluya tu dominio
- Para desarrollo, usar `allowedOrigins: "*"`

---

## 🎯 RESUMEN

### Flujo simplificado:

1. **Usuario** → Envía credenciales a **Keycloak**
2. **Keycloak** → Valida y devuelve **JWT con roles**
3. **Usuario** → Envía petición a **Gateway** con JWT
4. **Gateway** → Valida JWT, extrae roles, verifica permisos
5. **Gateway** → Enruta a **Microservicio** correspondiente
6. **Microservicio** → Procesa y responde
7. **Gateway** → Devuelve respuesta al usuario

### Beneficios de esta arquitectura:

✅ **Seguridad centralizada**: Un solo punto valida tokens  
✅ **Desacoplamiento**: Microservicios no conocen detalles de autenticación  
✅ **Escalabilidad**: Keycloak puede manejar millones de usuarios  
✅ **Estándar de la industria**: OAuth2/OpenID Connect  
✅ **Gestión de usuarios**: UI web para administrar  
✅ **Resiliencia**: Circuit Breaker si un servicio cae  

---

**¡Fin de la guía!** 🚀

Para más información, consulta:
- [Spring Cloud Gateway Docs](https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
