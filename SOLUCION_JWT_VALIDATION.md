# Solución: Error de Validación JWT en API Gateway

## 📋 Resumen del Problema

El sistema presentaba errores **401 Unauthorized** al intentar usar tokens JWT obtenidos vía `POST /auth/login` en endpoints protegidos del API Gateway.

### Causa Raíz

La discrepancia se debía a que:

1. **AuthController** obtiene tokens desde Keycloak usando la URL interna de Docker: `http://keycloak:9090`
2. Cuando Keycloak emite tokens desde esta URL interna, el claim `iss` (issuer) del token es: `http://keycloak:9090/realms/tpi-backend`
3. **JwtDecoderConfig** estaba configurado para validar tokens con issuer: `http://localhost:9090/realms/tpi-backend`
4. El validador rechazaba los tokens porque el issuer no coincidía exactamente

### Escenarios Afectados

- ✅ Tokens obtenidos externamente (desde el host): `iss = http://localhost:9090/realms/tpi-backend`
- ❌ Tokens obtenidos internamente (desde AuthController): `iss = http://keycloak:9090/realms/tpi-backend`

## ✅ Solución Implementada: Opción B - Validador Multi-Issuer

Se implementó un **validador JWT personalizado** que acepta múltiples issuers, permitiendo validar tokens obtenidos tanto internamente como externamente.

### Por qué esta solución

1. **Flexibilidad**: Soporta ambos escenarios sin necesidad de cambiar la configuración de Keycloak
2. **Mantenibilidad**: Centraliza la lógica de validación en un solo lugar
3. **Best Practices**: Sigue las prácticas recomendadas de Spring Security OAuth2
4. **Escalabilidad**: Fácil agregar más issuers en el futuro si es necesario

## 🔧 Cambios Realizados

### 1. Nuevo Validador: `MultiIssuerJwtValidator.java`

**Ubicación**: `api-gateway/src/main/java/com/tpi/gateway/config/MultiIssuerJwtValidator.java`

**Funcionalidad**:
- Implementa `OAuth2TokenValidator<Jwt>` de Spring Security
- Acepta una lista de issuers permitidos
- Valida tokens intentando cada issuer hasta encontrar uno válido
- Proporciona logging detallado para debugging

**Características**:
- Verifica que el issuer del token esté en la lista permitida
- Intenta validar con cada validador individual hasta que uno tenga éxito
- Retorna errores descriptivos si todas las validaciones fallan

### 2. Actualización: `JwtDecoderConfig.java`

**Cambios**:
- Lee la configuración `spring.security.oauth2.resourceserver.jwt.allowed-issuers`
- Parsea la lista de issuers (separados por coma)
- Crea y configura el `MultiIssuerJwtValidator` con los issuers permitidos
- Mantiene compatibilidad con el comportamiento anterior si no se especifica `allowed-issuers`

### 3. Actualización: `application.properties`

**Nueva propiedad**:
```properties
# Lista de issuers permitidos (separados por coma)
spring.security.oauth2.resourceserver.jwt.allowed-issuers=${KEYCLOAK_ALLOWED_ISSUERS:http://localhost:9090/realms/tpi-backend,http://keycloak:9090/realms/tpi-backend}
```

**Valores por defecto**:
- `http://localhost:9090/realms/tpi-backend` (tokens externos)
- `http://keycloak:9090/realms/tpi-backend` (tokens internos)

### 4. Actualización: `docker-compose.yml`

**Nueva variable de entorno**:
```yaml
KEYCLOAK_ALLOWED_ISSUERS: http://localhost:9090/realms/tpi-backend,http://keycloak:9090/realms/tpi-backend
```

## 🧪 Cómo Garantiza el Funcionamiento

### Escenario 1: Token obtenido externamente
1. Cliente externo obtiene token desde `http://localhost:8080/auth/login`
2. AuthController llama a Keycloak usando `http://keycloak:9090` (URL interna)
3. Keycloak emite token con `iss = http://keycloak:9090/realms/tpi-backend`
4. Cliente usa token en endpoint protegido
5. **MultiIssuerJwtValidator** valida el token:
   - Verifica que `iss` esté en la lista permitida ✅
   - Intenta validar con validador para `http://keycloak:9090/realms/tpi-backend` ✅
   - Token es aceptado ✅

### Escenario 2: Token obtenido directamente desde Keycloak
1. Cliente externo obtiene token directamente desde `http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token`
2. Keycloak emite token con `iss = http://localhost:9090/realms/tpi-backend`
3. Cliente usa token en endpoint protegido
4. **MultiIssuerJwtValidator** valida el token:
   - Verifica que `iss` esté en la lista permitida ✅
   - Intenta validar con validador para `http://localhost:9090/realms/tpi-backend` ✅
   - Token es aceptado ✅

### Escenario 3: Token con issuer no permitido
1. Token tiene `iss = http://malicious-server.com/realms/tpi-backend`
2. **MultiIssuerJwtValidator** valida el token:
   - Verifica que `iss` esté en la lista permitida ❌
   - Rechaza el token inmediatamente ❌
   - Retorna error 401 Unauthorized ✅

## 📝 Configuración

### Variables de Entorno (docker-compose.yml)

```yaml
KEYCLOAK_ISSUER_URI: http://localhost:9090/realms/tpi-backend  # Issuer por defecto (fallback)
KEYCLOAK_ALLOWED_ISSUERS: http://localhost:9090/realms/tpi-backend,http://keycloak:9090/realms/tpi-backend
KEYCLOAK_JWK_SET_URI: http://keycloak:9090/realms/tpi-backend/protocol/openid-connect/certs
```

### Propiedades (application.properties)

```properties
spring.security.oauth2.resourceserver.jwt.issuer-uri=${KEYCLOAK_ISSUER_URI:http://localhost:9090/realms/tpi-backend}
spring.security.oauth2.resourceserver.jwt.allowed-issuers=${KEYCLOAK_ALLOWED_ISSUERS:http://localhost:9090/realms/tpi-backend,http://keycloak:9090/realms/tpi-backend}
spring.security.oauth2.resourceserver.jwt.jwk-set-uri=${KEYCLOAK_JWK_SET_URI:http://keycloak:9090/realms/tpi-backend/protocol/openid-connect/certs}
```

## 🚀 Pruebas

### 1. Obtener token vía AuthController

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"cliente@tpi.com","password":"cliente123"}'
```

### 2. Usar token en endpoint protegido

```bash
TOKEN="<access_token_obtenido>"

curl -X GET http://localhost:8080/api/gestion/endpoint \
  -H "Authorization: Bearer $TOKEN"
```

### 3. Verificar logs del Gateway

Buscar en los logs:
```
🔐 MultiIssuerJwtValidator inicializado con 2 issuers permitidos:
   ✓ http://localhost:9090/realms/tpi-backend
   ✓ http://keycloak:9090/realms/tpi-backend
🔍 Validando token con issuer: http://keycloak:9090/realms/tpi-backend
✅ Token validado exitosamente con issuer: http://keycloak:9090/realms/tpi-backend
```

## 🔍 Logging y Debugging

El validador proporciona logging detallado:

- **INFO**: Inicialización con lista de issuers permitidos
- **DEBUG**: Validación de cada token (issuer detectado)
- **WARN**: Tokens rechazados (issuer no permitido o validación fallida)

Para habilitar logs de seguridad:
```properties
logging.level.org.springframework.security=${SECURITY_LOG_LEVEL:DEBUG}
```

## 📚 Referencias

- [Spring Security OAuth2 Resource Server](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/index.html)
- [JWT Validation](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/jwt.html)
- [OAuth2TokenValidator API](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/oauth2/core/OAuth2TokenValidator.html)

## ✅ Resultado Final

El sistema ahora permite:
- ✅ Obtener tokens vía `/auth/login` sin errores
- ✅ Usar tokens obtenidos internamente en endpoints protegidos
- ✅ Usar tokens obtenidos externamente en endpoints protegidos
- ✅ Validación segura con múltiples issuers
- ✅ Logging detallado para debugging
- ✅ Mantenibilidad y escalabilidad

---

**Fecha de implementación**: 2024
**Versión**: 1.0.0
**Autor**: Sistema de Gestión de Contenedores TPI

