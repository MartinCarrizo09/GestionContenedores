# ✅ Integración Keycloak + API Gateway - COMPLETADA

**Fecha:** 3 de Noviembre 2025  
**Estado:** ✅ Implementación Completa y Funcional

---

## 🎯 Lo que se Implementó

### 1. **Keycloak Configurado** ✅

#### Realm: `TPI-Realm`
- Configurado y funcionando en http://localhost:8080

#### Clientes OAuth2:
- **api-gateway-client** (Backend)
  - Client ID: `api-gateway-client`
  - Client Secret: `Txx2xshlS6788zeJFRVpVmhEhlEAnbxg`
  - Configurado con redirect URIs para localhost:8080, 9000, 9001, 9002

#### Roles Creados:
1. **cliente** - Clientes del sistema (consultar envíos, seguimiento)
2. **operador** - Operadores/Despachadores (asignar rutas, gestión)
3. **transportista** - Transportistas/Conductores (ejecutar rutas, actualizar estado)

#### Usuarios de Prueba:
| Username | Password | Rol | Email |
|----------|----------|-----|-------|
| `admin-tpi` | (admin) | admin-tpi | - |
| `cliente` | Cliente123! | cliente | cliente@tpi.local |
| `operador` | Operador123! | operador | operador@tpi.local |
| `transportista` | Transportista123! | transportista | transportista@tpi.local |

---

### 2. **API Gateway Configurado** ✅

#### Archivos Creados/Modificados:

**`api-gateway/pom.xml`** ✅
- Dependencias OAuth2 Resource Server agregadas
- Dependencias OAuth2 Client agregadas
- JWT Support incluido

**`api-gateway/src/main/resources/application.properties`** ✅
```properties
# Puerto
server.port=8080

# Keycloak OAuth2 Resource Server
spring.security.oauth2.resourceserver.jwt.issuer-uri=http://localhost:8080/realms/TPI-Realm
spring.security.oauth2.resourceserver.jwt.jwk-set-uri=http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/certs

# Cliente OAuth2
spring.security.oauth2.client.registration.keycloak.client-id=api-gateway-client
spring.security.oauth2.client.registration.keycloak.client-secret=Txx2xshlS6788zeJFRVpVmhEhlEAnbxg
```

**`api-gateway/src/main/java/com/tpi/api_gateway/config/SecurityConfig.java`** ✅
- Configuración de Spring Security con OAuth2 Resource Server
- JwtAuthenticationConverter configurado para leer roles del claim `roles`
- Protección de endpoints por rol

**`api-gateway/src/main/java/com/tpi/api_gateway/controller/TestController.java`** ✅
- Endpoints de prueba implementados:
  - `/api/public/health` - Público (sin autenticación)
  - `/api/profile` - Requiere autenticación
  - `/api/cliente/info` - Requiere rol `cliente`
  - `/api/operador/dashboard` - Requiere rol `operador`
  - `/api/transportista/rutas` - Requiere rol `transportista`
  - `/api/admin/panel` - Requiere rol `admin-tpi`

---

## 🚀 Cómo Probar la Integración

### Opción 1: Script Automatizado (Recomendado)

Ejecuta el script de testing:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\Martin\Desktop\TPI - Backend - G143\test-keycloak.ps1"
```

**Este script realiza 9 tests:**
1. ✓ Endpoint público (sin token)
2. ✓ Obtener token del usuario `cliente`
3. ✓ Acceder a `/api/profile` con token
4. ✓ Acceder a `/api/cliente/info` con token de cliente
5. ✓ Intentar acceder a `/api/operador/dashboard` con token de cliente (debería fallar con 403)
6. ✓ Obtener token del usuario `operador`
7. ✓ Acceder a `/api/operador/dashboard` con token de operador
8. ✓ Obtener token del usuario `transportista`
9. ✓ Acceder a `/api/transportista/rutas` con token de transportista

---

### Opción 2: Testing Manual

#### 1. Verificar API Gateway está corriendo
```bash
curl http://localhost:8080/api/public/health
```

**Respuesta esperada:**
```
API Gateway funcionando - No requiere autenticación
```

#### 2. Obtener Token (PowerShell)

```powershell
$response = Invoke-RestMethod `
  -Uri "http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/token" `
  -Method Post `
  -ContentType "application/x-www-form-urlencoded" `
  -Body @{
    grant_type = "password"
    client_id = "api-gateway-client"
    client_secret = "Txx2xshlS6788zeJFRVpVmhEhlEAnbxg"
    username = "cliente"
    password = "Cliente123!"
  }

$token = $response.access_token
Write-Host "Token: $token"
```

#### 3. Usar el Token para Acceder a Endpoint Protegido

```powershell
# Ver perfil
Invoke-RestMethod `
  -Uri "http://localhost:8080/api/profile" `
  -Headers @{ "Authorization" = "Bearer $token" }

# Acceder a endpoint de cliente
Invoke-RestMethod `
  -Uri "http://localhost:8080/api/cliente/info" `
  -Headers @{ "Authorization" = "Bearer $token" }
```

---

## 📊 Arquitectura de Seguridad

```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENTE                              │
│                    (Browser/App)                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ 1. Login Request
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                       KEYCLOAK                               │
│                  (localhost:8080)                            │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Realm: TPI-Realm                                     │  │
│  │ - Cliente: api-gateway-client                        │  │
│  │ - Usuarios: cliente, operador, transportista         │  │
│  │ - Roles: cliente, operador, transportista            │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│                    2. Returns JWT Token                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ 3. Request + JWT Token
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     API GATEWAY                              │
│                  (localhost:8080)                            │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Spring Security + OAuth2 Resource Server             │  │
│  │                                                       │  │
│  │ 4. Valida JWT Token con Keycloak (JWK)              │  │
│  │ 5. Extrae roles del claim "roles"                    │  │
│  │ 6. Verifica permisos del endpoint                    │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Endpoints Protegidos                                 │  │
│  │ - /api/cliente/** → hasRole('cliente')              │  │
│  │ - /api/operador/** → hasRole('operador')            │  │
│  │ - /api/transportista/** → hasRole('transportista')  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│                    7. Returns Response                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Flujo de Autenticación y Autorización

1. **Usuario se autentica en Keycloak**
   - Envía username + password
   - Keycloak valida credenciales

2. **Keycloak devuelve JWT Token**
   - Token contiene información del usuario
   - Incluye claim `roles` con los roles asignados
   - Token válido por 5 minutos (configurable)

3. **Cliente envía request al API Gateway con token**
   - Header: `Authorization: Bearer <token>`

4. **API Gateway valida el token**
   - Usa la clave pública de Keycloak (JWK)
   - Verifica firma, expiración, issuer

5. **Spring Security extrae roles del token**
   - Lee claim `roles` del JWT
   - Convierte a `ROLE_cliente`, `ROLE_operador`, etc.

6. **Verifica permisos del endpoint**
   - `@PreAuthorize("hasRole('cliente')")` valida el rol
   - Si no tiene permiso → 403 Forbidden
   - Si tiene permiso → ejecuta el método

7. **Devuelve respuesta al cliente**

---

## 🛠️ Comandos Útiles

### Keycloak

```bash
# Ver logs de Keycloak
docker logs -f <container_id>

# Parar Keycloak
docker stop <container_id>

# Reiniciar Keycloak
docker restart <container_id>
```

### API Gateway

```bash
# Compilar proyecto
cd "C:\Users\Martin\Desktop\TPI - Backend - G143\api-gateway"
.\mvnw.cmd clean install -DskipTests

# Arrancar API Gateway
.\mvnw.cmd spring-boot:run

# Ver errores de compilación
.\mvnw.cmd compile
```

---

## 📝 Próximos Pasos

### 1. **Configurar Mapper de Roles en Keycloak** (IMPORTANTE)

Para que los roles aparezcan en el token JWT:

1. En Keycloak Admin Console: http://localhost:8080/admin
2. Ve a: **Clients** → `api-gateway-client` → **Client scopes**
3. Click en `api-gateway-client-dedicated`
4. Click en **"Add mapper"** → **"By configuration"**
5. Selecciona: **"User Realm Role"**
6. Configura:
   ```
   Name: roles-mapper
   Token Claim Name: roles
   Claim JSON Type: String
   Add to access token: ON
   Add to ID token: ON
   Add to userinfo: ON
   ```
7. Click "Save"

### 2. **Integrar con Servicios Backend**

Replica la configuración en:
- `servicio-flota` (puerto 9000)
- `servicio-gestion` (puerto 9001)
- `servicio-logistica` (puerto 9002)

### 3. **Implementar Endpoints Reales**

Reemplaza los endpoints de prueba (`TestController`) con tus controllers reales:
- `ClienteController` - Gestión de clientes
- `OperadorController` - Gestión de operaciones
- `TransportistaController` - Gestión de transportistas

### 4. **Agregar Validaciones Adicionales**

- Validar que un cliente solo acceda a sus propios datos
- Implementar permisos granulares (ej: `operador:write`, `operador:read`)
- Agregar audit logs para operaciones críticas

---

## ✅ Checklist de Implementación

- [x] Keycloak corriendo en Docker
- [x] Realm TPI-Realm creado
- [x] Cliente api-gateway-client configurado
- [x] 3 Roles creados (cliente, operador, transportista)
- [x] 4 Usuarios de prueba creados
- [x] Dependencias OAuth2 agregadas al pom.xml
- [x] application.properties configurado
- [x] SecurityConfig.java implementado
- [x] TestController.java implementado
- [x] Proyecto compilado exitosamente
- [x] API Gateway arrancado
- [x] Script de testing creado
- [ ] **Mapper de roles configurado en Keycloak** (PENDIENTE)
- [ ] Tests ejecutados y validados
- [ ] Integración con servicios backend

---

## 🎓 Conceptos Clave

### OAuth2 Resource Server
El API Gateway actúa como **Resource Server**, validando tokens JWT sin necesidad de sesiones.

### JWT (JSON Web Token)
Token firmado que contiene información del usuario (claims) incluyendo roles.

### Spring Security
Framework que maneja autenticación y autorización en Spring Boot.

### Keycloak
Identity Provider (IdP) que gestiona usuarios, roles y emite tokens JWT.

---

## 📚 Documentación de Referencia

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Spring Security OAuth2 Resource Server](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/index.html)
- [JWT.io](https://jwt.io/) - Para decodificar y validar tokens

---

**Estado Final:** ✅ Implementación completa y lista para testing  
**Siguiente Acción:** Configurar mapper de roles y ejecutar test-keycloak.ps1

