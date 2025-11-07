# 🎯 Resumen Ejecutivo: Solución de Autenticación Simplificada

## El Problema

Obtener tokens JWT de Keycloak para testing era complicado y tedioso:

❌ **Antes:**
- URL larga: `http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token`
- Content-Type difícil: `application/x-www-form-urlencoded`
- Múltiples parámetros: grant_type, client_id, username, password
- Tokens expiran cada 5 minutos
- Renovación manual tediosa

## La Solución

✅ **Ahora:**
Sistema centralizado de autenticación en el API Gateway con 3 endpoints simples:

| Endpoint | Método | Propósito |
|----------|--------|-----------|
| `/auth/login` | POST | Obtener token con username/password |
| `/auth/refresh` | POST | Renovar token con refresh_token |
| `/auth/info` | GET | Información del servicio |

---

## Comparación Directa

### Obtener Token

**ANTES:**
```bash
curl -X POST 'http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=password' \
  -d 'client_id=tpi-client' \
  -d 'username=cliente@tpi.com' \
  -d 'password=cliente123'
```

**AHORA:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "cliente@tpi.com", "password": "cliente123"}'
```

### Renovar Token

**ANTES:**
```bash
curl -X POST 'http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=refresh_token' \
  -d 'client_id=tpi-client' \
  -d 'refresh_token=eyJhbG...'
```

**AHORA:**
```bash
curl -X POST http://localhost:8080/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken": "eyJhbG..."}'
```

---

## Ejemplos Rápidos con curl

### 1. Login como CLIENTE
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "cliente@tpi.com", "password": "cliente123"}'
```

**Respuesta:**
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 300,
  "refresh_expires_in": 1800,
  "token_type": "Bearer"
}
```

### 2. Usar el Token
```bash
# Guardar token en variable
TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."

# Usar en requests protegidos
curl -X GET http://localhost:8080/api/gestion/contenedores/codigo/CONT001/estado \
  -H "Authorization: Bearer $TOKEN"
```

### 3. Renovar cuando Expira
```bash
REFRESH_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X POST http://localhost:8080/auth/refresh \
  -H "Content-Type: application/json" \
  -d "{\"refreshToken\": \"$REFRESH_TOKEN\"}"
```

---

## Beneficios Clave

### Para Desarrolladores
- ✅ **JSON simple** en lugar de form-urlencoded
- ✅ **URL corta** fácil de recordar
- ✅ **Endpoint unificado** en el Gateway
- ✅ **Renovación simplificada** de tokens
- ✅ **Mensajes de error claros** (401 si credenciales inválidas)

### Para Testing
- ✅ **Postman scripts automáticos** para guardar tokens
- ✅ **Variables de entorno** auto-configuradas
- ✅ **Pre-request scripts** que verifican expiración
- ✅ **Colección completa** lista para importar

### Para CI/CD
- ✅ **Scripts PowerShell/Bash** para automatizar obtención de tokens
- ✅ **Fácil integración** en pipelines de testing
- ✅ **Logs claros** con emojis para debugging

---

## Usuarios de Testing Recomendados

Crear estos usuarios en Keycloak para testing:

| Username | Password | Rol | Descripción |
|----------|----------|-----|-------------|
| cliente@tpi.com | cliente123 | CLIENTE | Usuario cliente estándar |
| operador@tpi.com | operador123 | OPERADOR | Usuario operador/admin |
| transportista@tpi.com | transportista123 | TRANSPORTISTA | Usuario transportista |

---

## Archivos Creados

### Código Java
- ✅ `api-gateway/src/main/java/com/tpi/gateway/controller/AuthController.java` - Controlador principal
- ✅ `api-gateway/src/main/java/com/tpi/gateway/dto/LoginRequest.java` - DTO para login
- ✅ `api-gateway/src/main/java/com/tpi/gateway/dto/RefreshTokenRequest.java` - DTO para refresh
- ✅ `api-gateway/src/main/java/com/tpi/gateway/dto/TokenResponse.java` - DTO de respuesta

### Configuración
- ✅ `api-gateway/src/main/resources/application.properties` - Configuración actualizada

### Documentación
- ✅ `GUIA_AUTH_CONTROLLER.md` - Guía completa con ejemplos
- ✅ `RESUMEN_AUTH_SOLUTION.md` - Este resumen ejecutivo
- ✅ `postman-collection-auth.json` - Colección de Postman completa

---

## Próximos Pasos

### 1. Rebuilding del Gateway
```bash
# Reconstruir y levantar el Gateway con los nuevos cambios
docker compose up -d --build api-gateway
```

### 2. Verificar que Funciona
```bash
# Test rápido del endpoint /auth/info
curl http://localhost:8080/auth/info

# Debería retornar información del servicio
```

### 3. Crear Usuarios en Keycloak
Si no existen, crear los usuarios de testing:
- http://localhost:9090/admin/
- Usuario: admin / Password: admin123
- Crear: cliente@tpi.com, operador@tpi.com, transportista@tpi.com

### 4. Importar Colección de Postman
- Abrir Postman
- Import → File → `postman-collection-auth.json`
- Configurar variables si es necesario

### 5. Probar el Flujo Completo
1. Ejecutar "Login - Cliente" en Postman
2. Ver que los tokens se guardan automáticamente
3. Ejecutar cualquier request protegido
4. Cuando expire (5 min), ejecutar "Refresh Token"

---

## Configuración Opcional: Aumentar Tiempo de Expiración

Para testing, aumentar tiempo de vida de tokens en Keycloak:

1. Ir a: http://localhost:9090/admin/
2. Realm Settings → Tokens
3. Cambiar:
   - **Access Token Lifespan**: 5 min → **30 min**
   - **Refresh Token Lifespan**: 30 min → **2 hours**
4. Guardar

**Esto evitará renovaciones constantes durante desarrollo.**

---

## Scripts de Automatización Incluidos

### PowerShell
```powershell
# Obtener token y guardarlo en $env:ACCESS_TOKEN
.\get-auth-token.ps1 -Username "cliente@tpi.com" -Password "cliente123"

# Usar en requests
curl -X GET http://localhost:8080/api/gestion/contenedores `
  -H "Authorization: Bearer $env:ACCESS_TOKEN"
```

### Bash
```bash
# Obtener token y guardarlo en $ACCESS_TOKEN
source ./get-auth-token.sh cliente@tpi.com cliente123

# Usar en requests
curl -X GET http://localhost:8080/api/gestion/contenedores \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

---

## Troubleshooting Rápido

### Error: "401 Unauthorized" en /auth/login
- ✅ Verificar que el usuario existe en Keycloak
- ✅ Verificar username/password correctos
- ✅ Verificar que "Direct access grants" está habilitado en el cliente

### Error: "Connection refused"
- ✅ Verificar que Keycloak está corriendo: `docker ps | grep keycloak`
- ✅ Verificar URL en `application.properties`

### Error: "Token inválido" al usar en endpoints
- ✅ Copiar token en https://jwt.io y verificar:
  - Campo `exp` (no expirado)
  - Campo `iss` (debe coincidir con issuer-uri)
  - Campo `realm_access.roles` (contiene rol necesario)

---

## Resumen de URLs

| Servicio | URL |
|----------|-----|
| API Gateway | http://localhost:8080 |
| Auth Login | http://localhost:8080/auth/login |
| Auth Refresh | http://localhost:8080/auth/refresh |
| Auth Info | http://localhost:8080/auth/info |
| Keycloak Admin | http://localhost:9090/admin/ |
| JWT Debugger | https://jwt.io |

---

## Comandos Útiles

```bash
# Ver logs del Gateway
docker logs tpi-gateway -f

# Verificar contenedores corriendo
docker ps

# Rebuild del Gateway
docker compose up -d --build api-gateway

# Reiniciar todo
docker compose restart
```

---

## Recursos Adicionales

- 📖 **Guía Completa**: `GUIA_AUTH_CONTROLLER.md`
- 🔧 **Colección Postman**: `postman-collection-auth.json`
- 🐳 **Docker Compose**: `docker-compose.yml`
- 📝 **Application Properties**: `api-gateway/src/main/resources/application.properties`

---

## Soporte

**¿Problemas?**
1. Revisar la sección de Troubleshooting en `GUIA_AUTH_CONTROLLER.md`
2. Verificar logs del Gateway: `docker logs tpi-gateway -f`
3. Habilitar debug en `application.properties`:
   ```properties
   logging.level.org.springframework.security=DEBUG
   logging.level.com.tpi.gateway=DEBUG
   ```

---

**¡Sistema listo para usar! 🚀**

Ahora puedes obtener tokens de Keycloak de manera simple y rápida para testing y desarrollo.
