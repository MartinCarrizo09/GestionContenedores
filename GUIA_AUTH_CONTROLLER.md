# 🔐 Guía Completa: Auth Controller para Tokens de Keycloak

## 📋 Índice
1. [Problema Resuelto](#problema-resuelto)
2. [Solución Implementada](#solución-implementada)
3. [Endpoints Disponibles](#endpoints-disponibles)
4. [Ejemplos de Uso](#ejemplos-de-uso)
5. [Uso en Postman](#uso-en-postman)
6. [Scripts de Automatización](#scripts-de-automatización)
7. [Configuración de Keycloak](#configuración-de-keycloak)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Problema Resuelto

### Antes (el problema):
```bash
# Para obtener un token había que hacer esto:
curl -X POST http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=tpi-client" \
  -d "username=cliente@tpi.com" \
  -d "password=cliente123"

# Problemas:
# ❌ URL larga y compleja de recordar
# ❌ Content-Type application/x-www-form-urlencoded difícil de manejar
# ❌ Múltiples parámetros que hay que recordar
# ❌ Tokens expiran cada 5 minutos (tedioso renovar manualmente)
# ❌ Sin manejo de errores claro
```

### Ahora (la solución):
```bash
# Obtener token es tan simple como:
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "cliente@tpi.com", "password": "cliente123"}'

# Ventajas:
# ✅ URL simple y fácil de recordar
# ✅ JSON estándar (mucho más fácil)
# ✅ Endpoint unificado en el Gateway
# ✅ Renovación de tokens simplificada con /auth/refresh
# ✅ Respuestas de error claras
```

---

## 🛠️ Solución Implementada

### Arquitectura:

```
┌─────────────┐                  ┌──────────────┐                  ┌──────────────┐
│   Cliente   │                  │  API Gateway │                  │   Keycloak   │
│  (Postman,  │ ────────────────>│              │ ────────────────>│              │
│   curl,     │  POST /auth/login│ AuthController│  form-encoded   │ Token Endpoint│
│   script)   │  JSON simple     │              │  petición OAuth2 │              │
└─────────────┘ <────────────────└──────────────┘ <────────────────└──────────────┘
                  Token JWT                         Token Response
```

### Componentes:

1. **AuthController** (`api-gateway/src/main/java/com/tpi/gateway/controller/AuthController.java`)
   - Simplifica peticiones a Keycloak
   - Usa WebClient reactivo
   - Maneja errores apropiadamente

2. **DTOs** (Data Transfer Objects):
   - `LoginRequest`: username + password
   - `RefreshTokenRequest`: refresh_token
   - `TokenResponse`: respuesta de Keycloak

3. **Configuración** (`application.properties`):
   - Token URI de Keycloak
   - Client ID configurado
   - Client Secret (opcional)

---

## 🎯 Endpoints Disponibles

### 1. POST /auth/login - Obtener Token

**Descripción**: Autentica un usuario y devuelve access_token + refresh_token.

**Request:**
```json
POST http://localhost:8080/auth/login
Content-Type: application/json

{
  "username": "cliente@tpi.com",
  "password": "cliente123"
}
```

**Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ...",
  "expires_in": 300,
  "refresh_expires_in": 1800,
  "token_type": "Bearer",
  "scope": "profile email"
}
```

**Response (401 Unauthorized):**
```
Credenciales inválidas
```

---

### 2. POST /auth/refresh - Renovar Token

**Descripción**: Obtiene un nuevo access_token usando el refresh_token.

**Request:**
```json
POST http://localhost:8080/auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ..."
}
```

**Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ...",
  "expires_in": 300,
  "refresh_expires_in": 1800,
  "token_type": "Bearer"
}
```

---

### 3. GET /auth/info - Información del Servicio

**Descripción**: Retorna información sobre el servicio de autenticación.

**Request:**
```
GET http://localhost:8080/auth/info
```

**Response:**
```json
{
  "service": "Auth Token Generator",
  "version": "1.0.0",
  "keycloak_token_uri": "http://keycloak:9090/realms/tpi-backend/protocol/openid-connect/token",
  "client_id": "tpi-client",
  "endpoints": {
    "login": "POST /auth/login",
    "refresh": "POST /auth/refresh",
    "info": "GET /auth/info"
  },
  "description": "Simplifica la obtención de tokens JWT desde Keycloak para testing y desarrollo"
}
```

---

## 💡 Ejemplos de Uso

### Flujo Completo: Login → Usar Token → Refresh

#### 1️⃣ Obtener token inicial:

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "cliente@tpi.com",
    "password": "cliente123"
  }'
```

**Respuesta:**
```json
{
  "access_token": "eyJhbG...",
  "refresh_token": "eyJhbG...",
  "expires_in": 300
}
```

#### 2️⃣ Usar el access_token en requests:

```bash
# Guardar token en variable
TOKEN="eyJhbG..."

# Usar en requests protegidos
curl -X POST http://localhost:8080/api/logistica/solicitudes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clienteId": 1,
    "contenedorId": "CONT001",
    "origenDireccion": "Av. Corrientes 1234",
    "origenLatitud": -34.6037,
    "origenLongitud": -58.3816,
    "destinoDireccion": "Av. Rivadavia 5678",
    "destinoLatitud": -34.6131,
    "destinoLongitud": -58.4353
  }'
```

#### 3️⃣ Cuando el token expire (5 minutos), renovarlo:

```bash
REFRESH_TOKEN="eyJhbG..."

curl -X POST http://localhost:8080/auth/refresh \
  -H "Content-Type: application/json" \
  -d "{\"refreshToken\": \"$REFRESH_TOKEN\"}"
```

---

## 🔬 Uso en Postman

### Configuración con Variables de Entorno

#### 1️⃣ Crear Environment "TPI Local":

Variables:
```
base_url = http://localhost:8080
access_token = (vacío inicialmente)
refresh_token = (vacío inicialmente)
```

#### 2️⃣ Request de Login con Script Automático:

**Request:**
```
POST {{base_url}}/auth/login
Content-Type: application/json

{
  "username": "cliente@tpi.com",
  "password": "cliente123"
}
```

**Tests Script (guarda tokens automáticamente):**
```javascript
// Guardar tokens en variables de entorno
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    pm.environment.set("access_token", jsonData.access_token);
    pm.environment.set("refresh_token", jsonData.refresh_token);
    
    console.log("✅ Tokens guardados automáticamente");
    console.log("   Access token expira en: " + jsonData.expires_in + " segundos");
    console.log("   Refresh token expira en: " + jsonData.refresh_expires_in + " segundos");
}
```

#### 3️⃣ Usar en Requests Protegidos:

**Authorization Tab:**
- Type: `Bearer Token`
- Token: `{{access_token}}`

**O en Header:**
```
Authorization: Bearer {{access_token}}
```

#### 4️⃣ Request de Refresh con Script Automático:

**Request:**
```
POST {{base_url}}/auth/refresh
Content-Type: application/json

{
  "refreshToken": "{{refresh_token}}"
}
```

**Tests Script:**
```javascript
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    pm.environment.set("access_token", jsonData.access_token);
    pm.environment.set("refresh_token", jsonData.refresh_token);
    console.log("✅ Tokens renovados automáticamente");
}
```

### Pre-Request Script Global (verificar expiración)

En el **Environment** o **Collection**, agregar Pre-request Script:

```javascript
// Verificar si el token está por expirar
// (requiere guardar timestamp cuando se obtiene el token)

var tokenTimestamp = pm.environment.get("token_timestamp");
var expiresIn = pm.environment.get("expires_in") || 300;

if (tokenTimestamp) {
    var now = Date.now();
    var elapsed = (now - tokenTimestamp) / 1000;
    
    if (elapsed >= expiresIn - 30) {
        console.warn("⚠️ Token está por expirar. Considera renovarlo.");
    }
}
```

---

## 🤖 Scripts de Automatización

### PowerShell - Obtener Token y Guardarlo

```powershell
# get-auth-token.ps1
# Obtiene un token de autenticación y lo guarda en variables de entorno

param(
    [string]$Username = "cliente@tpi.com",
    [string]$Password = "cliente123",
    [string]$GatewayUrl = "http://localhost:8080"
)

Write-Host "🔐 Obteniendo token para: $Username" -ForegroundColor Cyan

$body = @{
    username = $Username
    password = $Password
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$GatewayUrl/auth/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $body
    
    # Guardar en variables de entorno
    $env:ACCESS_TOKEN = $response.access_token
    $env:REFRESH_TOKEN = $response.refresh_token
    
    Write-Host "✅ Token obtenido exitosamente" -ForegroundColor Green
    Write-Host "   Expira en: $($response.expires_in) segundos" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Variables de entorno configuradas:" -ForegroundColor Cyan
    Write-Host "   `$env:ACCESS_TOKEN" -ForegroundColor Gray
    Write-Host "   `$env:REFRESH_TOKEN" -ForegroundColor Gray
    
    # Mostrar los primeros caracteres del token
    $tokenPreview = $response.access_token.Substring(0, [Math]::Min(50, $response.access_token.Length))
    Write-Host ""
    Write-Host "Token preview: $tokenPreview..." -ForegroundColor Gray
}
catch {
    Write-Host "❌ Error al obtener token: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

**Uso:**
```powershell
# Usuario cliente
.\get-auth-token.ps1 -Username "cliente@tpi.com" -Password "cliente123"

# Usuario operador
.\get-auth-token.ps1 -Username "operador@tpi.com" -Password "operador123"

# Usuario transportista
.\get-auth-token.ps1 -Username "transportista@tpi.com" -Password "transportista123"

# Luego usar en requests:
curl -X GET http://localhost:8080/api/gestion/contenedores `
  -H "Authorization: Bearer $env:ACCESS_TOKEN"
```

---

### Bash - Obtener Token y Guardarlo

```bash
#!/bin/bash
# get-auth-token.sh
# Obtiene un token de autenticación y lo guarda en variables de entorno

USERNAME=${1:-cliente@tpi.com}
PASSWORD=${2:-cliente123}
GATEWAY_URL=${3:-http://localhost:8080}

echo "🔐 Obteniendo token para: $USERNAME"

RESPONSE=$(curl -s -X POST "$GATEWAY_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}")

if [ $? -eq 0 ]; then
    export ACCESS_TOKEN=$(echo $RESPONSE | jq -r '.access_token')
    export REFRESH_TOKEN=$(echo $RESPONSE | jq -r '.refresh_token')
    EXPIRES_IN=$(echo $RESPONSE | jq -r '.expires_in')
    
    echo "✅ Token obtenido exitosamente"
    echo "   Expira en: $EXPIRES_IN segundos"
    echo ""
    echo "Variables de entorno configuradas:"
    echo "   \$ACCESS_TOKEN"
    echo "   \$REFRESH_TOKEN"
    echo ""
    echo "Token preview: ${ACCESS_TOKEN:0:50}..."
else
    echo "❌ Error al obtener token"
    exit 1
fi
```

**Uso:**
```bash
# Dar permisos de ejecución
chmod +x get-auth-token.sh

# Obtener token
source ./get-auth-token.sh cliente@tpi.com cliente123

# Usar en requests
curl -X GET http://localhost:8080/api/gestion/contenedores \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

---

## ⚙️ Configuración de Keycloak

### Aumentar Tiempo de Expiración de Tokens

Por defecto, los tokens expiran en 5 minutos. Para testing, puedes aumentar este tiempo:

#### 1️⃣ Acceder a Keycloak Admin Console:
```
http://localhost:9090/admin/
Usuario: admin
Password: admin123
```

#### 2️⃣ Seleccionar el Realm `tpi-backend`

#### 3️⃣ Ir a: Realm Settings → Tokens

#### 4️⃣ Ajustar valores:

| Setting | Valor Default | Recomendado Testing | Producción |
|---------|---------------|---------------------|------------|
| Access Token Lifespan | 5 minutes | 30 minutes | 5-15 minutes |
| Refresh Token Lifespan | 30 minutes | 2 hours | 30 minutes |
| Access Token Lifespan For Implicit Flow | 15 minutes | 1 hour | 15 minutes |

#### 5️⃣ Guardar cambios

**Ahora los tokens durarán más tiempo y no será necesario renovarlos tan frecuentemente durante el desarrollo.**

---

### Crear Usuarios de Testing

Si aún no existen, crear estos usuarios en Keycloak:

| Username | Password | Rol | Email |
|----------|----------|-----|-------|
| cliente@tpi.com | cliente123 | CLIENTE | cliente@tpi.com |
| operador@tpi.com | operador123 | OPERADOR | operador@tpi.com |
| transportista@tpi.com | transportista123 | TRANSPORTISTA | transportista@tpi.com |

**Pasos:**
1. Ir a: Users → Create new user
2. Username: `cliente@tpi.com`
3. Email: `cliente@tpi.com`
4. Guardar
5. Ir a pestaña **Credentials**:
   - Set Password: `cliente123`
   - Temporary: **OFF** ✅
6. Ir a pestaña **Role Mappings**:
   - Asignar rol: `CLIENTE`

---

### Verificar Configuración del Cliente

Asegurarse de que el cliente `tpi-client` tenga:

1. **Settings:**
   - Client ID: `tpi-client`
   - Client authentication: **OFF** (cliente público)
   - Direct access grants: **ON** ✅ (permite password grant)
   - Standard flow: **ON** ✅
   - Valid redirect URIs: `http://localhost:8080/*`

2. **Capability config:**
   - Client authentication: **OFF**
   - Authorization: **OFF**
   - Authentication flow:
     - ✅ Standard flow
     - ✅ Direct access grants
     - ❌ Implicit flow (no recomendado)
     - ❌ Service accounts roles

---

## 🔧 Troubleshooting

### ❌ Error: "401 Unauthorized" al hacer login

**Posibles causas:**

1. **Credenciales incorrectas**
   - Verificar username/password
   - Verificar que el usuario existe en Keycloak
   - Verificar que la password no es temporal

2. **Cliente mal configurado en Keycloak**
   ```bash
   # Verificar que Direct Access Grants esté habilitado
   # En Keycloak: Clients → tpi-client → Settings
   # Direct access grants enabled: ON
   ```

3. **Client ID incorrecto**
   ```properties
   # Verificar en application.properties:
   keycloak.auth.client-id=tpi-client
   ```

---

### ❌ Error: "Connection refused" o "timeout"

**Posibles causas:**

1. **Keycloak no está corriendo**
   ```bash
   # Verificar contenedores
   docker ps | grep keycloak
   
   # Debería mostrar:
   # tpi-keycloak   Up   0.0.0.0:9090->9090/tcp
   ```

2. **URL incorrecta en configuración**
   ```properties
   # Verificar en application.properties:
   # Desde el Gateway (Docker) debe usar nombre del servicio:
   keycloak.auth.token-uri=http://keycloak:9090/realms/tpi-backend/protocol/openid-connect/token
   ```

---

### ❌ Error: "Refresh token inválido o expirado"

**Solución:**
```bash
# El refresh_token también expira (default 30 min)
# Si expiró, obtener nuevo login:
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "cliente@tpi.com", "password": "cliente123"}'
```

---

### ❌ Error: "Token inválido" al usar en endpoints protegidos

**Diagnóstico:**

1. **Verificar que el token no haya expirado**
   ```bash
   # Copiar el access_token y pegarlo en: https://jwt.io
   # Verificar campo "exp" (expiration timestamp)
   ```

2. **Verificar issuer en el token**
   ```bash
   # En jwt.io, verificar campo "iss"
   # Debe coincidir con spring.security.oauth2.resourceserver.jwt.issuer-uri
   
   # Si el token dice: "iss": "http://localhost:9090/realms/tpi-backend"
   # Entonces application.properties debe tener:
   spring.security.oauth2.resourceserver.jwt.issuer-uri=http://localhost:9090/realms/tpi-backend
   ```

3. **Verificar que el usuario tenga el rol necesario**
   ```bash
   # En jwt.io, buscar:
   "realm_access": {
     "roles": ["CLIENTE", "offline_access", ...]
   }
   ```

---

### 🐛 Habilitar Logs de Debug

Para ver más detalles sobre autenticación:

```properties
# application.properties
logging.level.org.springframework.security=DEBUG
logging.level.com.tpi.gateway=DEBUG
```

Luego revisar logs:
```bash
docker logs tpi-gateway -f
```

---

## 🚀 Próximos Pasos

1. **Importar la colección de Postman** (ver `postman-collection-auth.json`)
2. **Crear usuarios de testing en Keycloak** (si no existen)
3. **Aumentar tiempo de expiración** para testing (opcional)
4. **Probar los 3 endpoints**: `/auth/login`, `/auth/refresh`, `/auth/info`
5. **Usar tokens en requests protegidos** del TPI

---

## 📚 Referencias

- [Keycloak - Resource Owner Password Credentials Flow](https://www.keycloak.org/docs/latest/securing_apps/#_resource_owner_password_credentials_flow)
- [Spring Cloud Gateway - Security](https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/#gateway-security)
- [JWT.io - Debug JWT tokens](https://jwt.io)
- [OAuth2 RFC 6749 - Password Grant](https://datatracker.ietf.org/doc/html/rfc6749#section-4.3)

---

**¿Problemas o dudas?** Consultar la sección de [Troubleshooting](#troubleshooting) o revisar los logs del Gateway.
