# Guía Completa: Keycloak con Docker - Configuración e Integración

> **Fecha**: Noviembre 2024  
> **Estado**: Completo para desarrollo y producción básica  
> **Objetivo**: Integrar Keycloak con tu backend (API Gateway + Servicios)

---

## Tabla de Contenidos
1. [Arranque Inicial](#arranque-inicial)
2. [Configuración de Realms](#configuración-de-realms)
3. [Creación de Clientes OAuth2/OIDC](#creación-de-clientes-oauth2oidc)
4. [Gestión de Usuarios y Roles](#gestión-de-usuarios-y-roles)
5. [Integración con API Gateway](#integración-con-api-gateway)
6. [Automatización con Docker Compose](#automatización-con-docker-compose)
7. [Scripts de Administración](#scripts-de-administración)
8. [Testing y Troubleshooting](#testing-y-troubleshooting)
9. [Buenas Prácticas](#buenas-prácticas)

---

## Arranque Inicial

### Opción 1: Modo Desarrollo Rápido (para pruebas)

Ejecuta en `cmd.exe`:

```cmd
docker run --name keycloak-dev -p 8080:8080 ^
  -e KEYCLOAK_ADMIN=admin ^
  -e KEYCLOAK_ADMIN_PASSWORD=admin ^
  quay.io/keycloak/keycloak:latest start-dev
```

**Acceso:**
- URL: http://localhost:8080
- Admin Console: http://localhost:8080/admin
- Usuario: `admin`
- Contraseña: `admin`

**Ver logs en tiempo real:**
```cmd
docker logs -f keycloak-dev
```

**Parar contenedor:**
```cmd
docker stop keycloak-dev
```

---

### Opción 2: Producción Básica con Postgres

Crea archivo `docker-compose.yml` en una carpeta de tu proyecto (ej: `C:\Users\Martin\Desktop\TPI - Backend - G143\keycloak`):

```yaml
version: "3.8"

services:
  postgres:
    image: postgres:14-alpine
    container_name: keycloak-postgres
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: keycloak_secure_password
    volumes:
      - pg_data:/var/lib/postgresql/data
    networks:
      - keycloak-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U keycloak"]
      interval: 10s
      timeout: 5s
      retries: 5
    ports:
      - "5432:5432"  # Opcional: exponer para backup/admin

  keycloak:
    image: quay.io/keycloak/keycloak:22.0.0  # Versión fija (no latest)
    container_name: keycloak-server
    environment:
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin_secure_password
      KC_DB: postgres
      KC_DB_URL_HOST: postgres
      KC_DB_URL_DATABASE: keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: keycloak_secure_password
      KC_HOSTNAME: localhost
      KC_HOSTNAME_PORT: 8080
      KC_HTTP_ENABLED: "true"
      KC_PROXY: reencrypt
    depends_on:
      postgres:
        condition: service_healthy
    command: ["start"]
    ports:
      - "8080:8080"
    networks:
      - keycloak-net
    volumes:
      - keycloak_data:/opt/keycloak/data
    # Descomentar si quieres importar realms al arrancar
    # - ./realms:/opt/keycloak/data/import

volumes:
  pg_data:
  keycloak_data:

networks:
  keycloak-net:
    driver: bridge
```

**Arrancar:**
```cmd
docker compose up -d
```

**Ver estado:**
```cmd
docker compose ps
docker compose logs -f keycloak
```

**Parar todo:**
```cmd
docker compose down
```

**Parar y eliminar datos:**
```cmd
docker compose down -v
```

---

## Configuración de Realms

Un **Realm** es un espacio aislado en Keycloak donde defines usuarios, clientes, roles y políticas.

### Crear Realm vía Admin Console

1. **Entra a Admin Console:**
   - http://localhost:8080/admin
   - Login: admin / admin

2. **Crear Realm:**
   - Hover sobre el selector de Realm (arriba a la izquierda)
   - Click en "Create Realm"
   - Nombre: `TPI-Realm` (o el que prefieras)
   - Click "Create"

3. **Configurar General:**
   - Ve a Settings → General
   - **Realm Name**: TPI-Realm
   - **Enabled**: ✓
   - **Display Name**: "TPI Backend"
   - **HTML Display Name**: "Plataforma de Transporte Integrada"
   - Save

4. **Configurar Tokens:**
   - Ve a Settings → Tokens
   - **Access Token Lifespan**: 5 minutes (o según tu política)
   - **Refresh Token Lifespan**: 30 minutes (o 7 days para mobile)
   - **Session Idle**: 30 minutes
   - Save

### Realm via JSON Export (para reproducibilidad)

Puedes exportar un realm como JSON y reutilizarlo:

```bash
# Desde admin console:
# Master → Master Realm → Export
# (O desde CLI si Keycloak corre en servidor)
```

Guarda el JSON y úsalo para importar en nuevas instancias o compartir con el equipo.

---

## Creación de Clientes OAuth2/OIDC

Los **Clientes** representan tus aplicaciones (API Gateway, Frontend, Mobile, etc.).

### Cliente 1: API Gateway (Backend)

1. **Ir a Clients:**
   - En el menú lateral: Clients
   - Click "Create client"

2. **Configuración Básica:**
   - **Client ID**: `api-gateway-client`
   - **Client Type**: OpenID Connect (por defecto)
   - **Name**: "API Gateway"
   - Click "Next"

3. **Capability Config:**
   - **Client authentication**: ON (usar token en backend)
   - **Authorization**: ON (si usas permisos finos)
   - **Authentication flow**: 
     - ✓ Standard flow
     - ✓ Direct access grants (para testing con usuario/password)
     - ✓ Service account roles (para llamadas backend-to-backend)
   - Click "Next"

4. **Login Settings:**
   - **Valid redirect URIs**: 
     ```
     http://localhost:8080/*
     http://localhost:9000/*
     http://localhost:9001/*
     http://localhost:9002/*
     https://tu-dominio.com/*
     ```
   - **Valid post logout redirect URIs**:
     ```
     http://localhost:8080/*
     https://tu-dominio.com/*
     ```
   - **Web origins**:
     ```
     http://localhost:8080
     http://localhost:9000
     http://localhost:9001
     http://localhost:9002
     https://tu-dominio.com
     ```
   - Click "Save"

5. **Obtener Credenciales:**
   - En la pestaña "Credentials"
   - Copia el **Client Secret** (es sensible, no lo compartas)
   - Ejemplo: `abc123def456...`

### Cliente 2: Frontend/Web App (SPA)

1. **Create client:**
   - **Client ID**: `frontend-app`
   - **Client Type**: OpenID Connect
   - **Name**: "Frontend Web App"
   - Next

2. **Capability Config:**
   - **Client authentication**: OFF (aplicación pública)
   - **Authentication flow**:
     - ✓ Standard flow
     - ✓ Authorization Code Flow with PKCE (recomendado para SPA)
   - Next

3. **Login Settings:**
   - **Valid redirect URIs**: `http://localhost:3000/*`, `https://tu-frontend.com/*`
   - **Valid post logout redirect URIs**: igual que arriba
   - **Web origins**: igual que arriba
   - Save

### Cliente 3: Aplicación Mobile (Opcional)

1. **Create client:**
   - **Client ID**: `mobile-app`
   - **Client Type**: OpenID Connect
   - **Name**: "Mobile App"
   - Next

2. **Capability Config:**
   - **Client authentication**: OFF
   - **Authentication flow**:
     - ✓ Standard flow
     - ✓ Authorization Code Flow with PKCE
   - Next

3. **Login Settings:**
   - **Valid redirect URIs**: `com.example.tpi://callback`
   - **Web origins**: (dejar vacío para mobile)
   - Save

---

## Gestión de Usuarios y Roles

### Crear Usuarios

1. **Ir a Users:**
   - En el menú lateral: Users
   - Click "Create new user"

2. **Datos Básicos (Usuario Administrador):**
   - **Username**: `admin-tpi`
   - **Email**: `admin@tpi.local`
   - **First name**: Admin
   - **Last name**: TPI
   - **Email verified**: ✓
   - **Enabled**: ✓
   - Click "Create"

3. **Asignar Contraseña:**
   - Pestaña "Credentials"
   - Click "Set password"
   - Ingresa contraseña
   - **Temporary**: OFF (si quieres que sea permanente)
   - Click "Set password"

4. **Asignar Roles:**
   - Pestaña "Role mapping"
   - Click "Assign role"
   - Busca y selecciona roles que necesites (ej: `admin`, `realm-admin`)
   - Click "Assign"

### Crear Roles Personalizados

1. **Ir a Roles:**
   - En el menú lateral: Realm roles (o Client roles para roles específicos del cliente)
   - Click "Create role"

2. **Definir Roles para TPI:**
   - `admin-tpi`: Acceso total a funcionalidades
   - `driver`: Conductores (acceso a rutas y estado)
   - `dispatcher`: Despachadores (gestión de rutas)
   - `manager`: Gerentes (reportes y análisis)
   - `customer`: Clientes (consultar estado de envíos)

**Ejemplo de rol Admin TPI:**
```
Role name: admin-tpi
Description: Administrador del sistema TPI
Composite role: OFF
```

### Asignar Múltiples Usuarios de Prueba

Repite el proceso anterior para:
- `driver1`: usuario con rol `driver`
- `dispatcher1`: usuario con rol `dispatcher`
- `manager1`: usuario con rol `manager`
- `customer1`: usuario con rol `customer`

---

## Integración con API Gateway

### Obtener Endpoint de Configuración OpenID Connect

En Keycloak, el endpoint estándar es:

```
http://localhost:8080/realms/TPI-Realm/.well-known/openid-configuration
```

Este JSON contiene:
- `issuer`
- `authorization_endpoint`
- `token_endpoint`
- `userinfo_endpoint`
- `jwks_uri`
- etc.

### Configurar API Gateway (Spring Boot)

En tu proyecto `api-gateway`, edita `application.properties` o `application.yml`:

**application.yml:**
```yaml
spring:
  application:
    name: api-gateway
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8080/realms/TPI-Realm
          jwk-set-uri: http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/certs
      client:
        registration:
          keycloak:
            client-id: api-gateway-client
            client-secret: YOUR_CLIENT_SECRET_HERE
            scope: openid,profile,email,roles
            authorization-grant-type: authorization_code
            redirect-uri: "http://localhost:8080/login/oauth2/code/keycloak"
        provider:
          keycloak:
            issuer-uri: http://localhost:8080/realms/TPI-Realm
            authorization-uri: http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/auth
            token-uri: http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/token
            user-info-uri: http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/userinfo
            jwk-set-uri: http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/certs

server:
  port: 8080
```

### Dependencias Maven

En `pom.xml` del API Gateway, añade:

```xml
<!-- Spring Security + OAuth2 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-client</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-oauth2-jose</artifactId>
</dependency>

<!-- JWT (si necesitas parsear tokens) -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
```

### Configurar Spring Security

Crea una clase `SecurityConfig.java`:

```java
package com.tpi.apigateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authorize -> authorize
                .requestMatchers("/actuator/**", "/health/**").permitAll()
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/driver/**").hasRole("driver")
                .requestMatchers("/api/dispatcher/**").hasRole("dispatcher")
                .requestMatchers("/api/manager/**").hasRole("manager")
                .requestMatchers("/api/**").authenticated()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter()))
            )
            .cors(cors -> cors.disable());
        return http.build();
    }

    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter() {
        JwtGrantedAuthoritiesConverter authoritiesConverter = new JwtGrantedAuthoritiesConverter();
        authoritiesConverter.setAuthoritiesClaimName("roles");
        authoritiesConverter.setAuthorityPrefix("ROLE_");

        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(authoritiesConverter);
        return converter;
    }
}
```

### Ejemplo: Controller Protegido

```java
package com.tpi.apigateway.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class TestController {

    @GetMapping("/public/health")
    public String health() {
        return "Sistema funcionando";
    }

    @GetMapping("/profile")
    @PreAuthorize("isAuthenticated()")
    public String profile(Authentication auth) {
        return "Hola, " + auth.getName() + "! Tus roles: " + auth.getAuthorities();
    }

    @GetMapping("/driver/routes")
    @PreAuthorize("hasRole('driver')")
    public String driverRoutes() {
        return "Rutas del conductor";
    }

    @GetMapping("/dispatcher/assign")
    @PreAuthorize("hasRole('dispatcher')")
    public String dispatcherAssign() {
        return "Asignar rutas";
    }

    @GetMapping("/manager/reports")
    @PreAuthorize("hasRole('manager')")
    public String managerReports() {
        return "Reportes de gerencia";
    }
}
```

---

## Automatización con Docker Compose

### Importar Realm Automáticamente

Si tienes un `realm.json` exportado, puedes importarlo al arrancar Keycloak.

**Pasos:**

1. **Exportar realm desde Admin Console:**
   - Selecciona el realm (ej: TPI-Realm)
   - Arriba a la izquierda, hover sobre el nombre del realm
   - Click en los tres puntos → "Export"
   - Descarga el JSON

2. **Guardar en carpeta:**
   ```
   C:\Users\Martin\Desktop\TPI - Backend - G143\keycloak\
   └── realms/
       └── realm.json
   ```

3. **Actualizar docker-compose.yml:**

```yaml
# ...existing code...
  keycloak:
    image: quay.io/keycloak/keycloak:22.0.0
    container_name: keycloak-server
    # ...existing config...
    volumes:
      - keycloak_data:/opt/keycloak/data
      - ./realms/realm.json:/opt/keycloak/data/import/realm.json
    # ...existing code...
```

4. **Arrancar con importación:**
```cmd
docker compose down -v
docker compose up -d
```

Keycloak detectará el JSON en `/opt/keycloak/data/import` e importará automáticamente.

---

## Scripts de Administración

### Script 1: Obtener Token (Bash/PowerShell)

**PowerShell (`get-token.ps1`):**

```powershell
# Variables
$KEYCLOAK_URL = "http://localhost:8080"
$REALM = "TPI-Realm"
$CLIENT_ID = "api-gateway-client"
$CLIENT_SECRET = "your_client_secret"
$USERNAME = "admin"
$PASSWORD = "admin"

# Obtener token del administrador
$tokenResponse = Invoke-RestMethod `
  -Uri "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" `
  -Method Post `
  -ContentType "application/x-www-form-urlencoded" `
  -Body @{
    grant_type = "password"
    client_id = $CLIENT_ID
    client_secret = $CLIENT_SECRET
    username = $USERNAME
    password = $PASSWORD
  }

$token = $tokenResponse.access_token
Write-Host "Token obtenido:" $token
```

**Usar:**
```powershell
powershell -ExecutionPolicy Bypass -File get-token.ps1
```

### Script 2: Crear Usuario (Bash/PowerShell)

**PowerShell (`create-user.ps1`):**

```powershell
param(
  [string]$Username = "testuser",
  [string]$Email = "testuser@example.com",
  [string]$Password = "Test123!"
)

$KEYCLOAK_URL = "http://localhost:8080"
$REALM = "TPI-Realm"
$CLIENT_ID = "admin-cli"  # Cliente interno de admin
$ADMIN_USER = "admin"
$ADMIN_PASSWORD = "admin"

# Obtener token de admin
$tokenResponse = Invoke-RestMethod `
  -Uri "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" `
  -Method Post `
  -ContentType "application/x-www-form-urlencoded" `
  -Body @{
    grant_type = "password"
    client_id = $CLIENT_ID
    username = $ADMIN_USER
    password = $ADMIN_PASSWORD
  }

$token = $tokenResponse.access_token

# Crear usuario
$newUserData = @{
  username = $Username
  email = $Email
  emailVerified = $true
  enabled = $true
  firstName = $Username
  lastName = "Usuario Test"
  credentials = @(
    @{
      type = "password"
      value = $Password
      temporary = $false
    }
  )
}

$response = Invoke-RestMethod `
  -Uri "$KEYCLOAK_URL/admin/realms/$REALM/users" `
  -Method Post `
  -Headers @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
  } `
  -Body ($newUserData | ConvertTo-Json)

Write-Host "Usuario $Username creado exitosamente"
```

**Usar:**
```powershell
powershell -ExecutionPolicy Bypass -File create-user.ps1 -Username "driver1" -Email "driver1@tpi.local" -Password "Driver123!"
```

### Script 3: Asignar Rol a Usuario

**PowerShell (`assign-role.ps1`):**

```powershell
param(
  [string]$Username = "driver1",
  [string]$RoleName = "driver"
)

$KEYCLOAK_URL = "http://localhost:8080"
$REALM = "TPI-Realm"
$CLIENT_ID = "admin-cli"
$ADMIN_USER = "admin"
$ADMIN_PASSWORD = "admin"

# Obtener token
$tokenResponse = Invoke-RestMethod `
  -Uri "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" `
  -Method Post `
  -ContentType "application/x-www-form-urlencoded" `
  -Body @{
    grant_type = "password"
    client_id = $CLIENT_ID
    username = $ADMIN_USER
    password = $ADMIN_PASSWORD
  }

$token = $tokenResponse.access_token

# Obtener ID del usuario
$user = Invoke-RestMethod `
  -Uri "$KEYCLOAK_URL/admin/realms/$REALM/users?username=$Username" `
  -Headers @{
    "Authorization" = "Bearer $token"
  }

$userId = $user[0].id

# Obtener rol
$role = Invoke-RestMethod `
  -Uri "$KEYCLOAK_URL/admin/realms/$REALM/roles/$RoleName" `
  -Headers @{
    "Authorization" = "Bearer $token"
  }

# Asignar rol
$roleData = @($role)

Invoke-RestMethod `
  -Uri "$KEYCLOAK_URL/admin/realms/$REALM/users/$userId/role-mappings/realm" `
  -Method Post `
  -Headers @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
  } `
  -Body ($roleData | ConvertTo-Json)

Write-Host "Rol $RoleName asignado a $Username"
```

**Usar:**
```powershell
powershell -ExecutionPolicy Bypass -File assign-role.ps1 -Username "driver1" -RoleName "driver"
```

---

## Testing y Troubleshooting

### Test 1: Validar Endpoint OpenID Connect

```cmd
curl -X GET http://localhost:8080/realms/TPI-Realm/.well-known/openid-configuration
```

Debería devolver JSON con endpoints.

### Test 2: Obtener Token con cURL

```cmd
curl -X POST http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/token ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "grant_type=password&client_id=api-gateway-client&client_secret=YOUR_SECRET&username=admin&password=admin"
```

Respuesta esperada:
```json
{
  "access_token": "eyJhbGc...",
  "expires_in": 300,
  "refresh_expires_in": 1800,
  "token_type": "Bearer",
  "not-before-policy": 0,
  "session_state": "...",
  "scope": "profile email"
}
```

### Test 3: Validar Token Obtenido

Copia el `access_token` y decodifica en https://jwt.io/ para ver claims.

### Test 4: Acceder a Recurso Protegido

```cmd
curl -X GET http://localhost:8080/api/profile ^
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

Debería devolver datos del usuario autenticado.

### Troubleshooting Común

**Problema: "Invalid client secret"**
- Solución: Revisa que el `CLIENT_SECRET` en config sea exacto (copiar de Admin Console).

**Problema: "CORS error"**
- Solución: En Keycloak Admin → Settings → Security → CORS, añade tus orígenes autorizados.

**Problema: "Redirect URI mismatch"**
- Solución: Verifica en Clients → Tu cliente → Login Settings → Valid redirect URIs.

**Problema: "Roles no aparecen en token"**
- Solución: En Client → Mappers, crea un "User Realm Role" mapper con:
  - Protocol: openid-connect
  - Mapper Type: User Realm Role
  - Token Claim Name: roles
  - Add to access token: ON

**Problema: Keycloak no inicia con Postgres**
- Solución: Revisa logs con `docker compose logs keycloak`. Asegúrate que Postgres está healthy.

---

## Buenas Prácticas

### Desarrollo Local

1. **Usa Keycloak en modo dev para testing rápido:**
   ```cmd
   docker run --name keycloak-dev -p 8080:8080 ^
     -e KEYCLOAK_ADMIN=admin ^
     -e KEYCLOAK_ADMIN_PASSWORD=admin ^
     quay.io/keycloak/keycloak:latest start-dev
   ```

2. **Guarda realm exportado en Git (sin secretos):**
   ```bash
   git add keycloak/realms/realm.json
   git add docker-compose.yml
   # Pero no commits de secretos
   ```

3. **Usa variables de entorno para secretos:**
   - Crea archivo `.env`:
     ```
     KEYCLOAK_ADMIN=admin
     KEYCLOAK_ADMIN_PASSWORD=secure_password
     KC_DB_PASSWORD=secure_db_password
     CLIENT_SECRET=secure_client_secret
     ```
   - En docker-compose: `env_file: .env`
   - En .gitignore: `.env`

### Pre-Producción / Staging

1. **Usa imagen con versión fija** (no `latest`):
   ```yaml
   image: quay.io/keycloak/keycloak:22.0.0
   ```

2. **Configura DB externa (Postgres/RDS)** con backups.

3. **Habilita HTTPS/TLS** con Nginx o Traefik reverse proxy.

4. **Configura KC_PROXY correctamente:**
   ```yaml
   KC_PROXY: reencrypt  # o edge
   ```

5. **Limita acceso administrativo:**
   - Cambia contraseñas por defecto
   - Usa SSO/LDAP para admin de Keycloak si es posible
   - Documenta accesos en 1Password/Vault

### Monitoreo y Logs

```bash
# Ver logs en tiempo real
docker compose logs -f keycloak

# Ver logs de Postgres
docker compose logs -f postgres

# Exportar logs a archivo
docker compose logs > keycloak.log
```

### Backup y Recuperación

```bash
# Backup de DB
docker exec keycloak-postgres pg_dump -U keycloak keycloak > keycloak_backup.sql

# Restaurar
docker exec -i keycloak-postgres psql -U keycloak keycloak < keycloak_backup.sql

# Backup de volumen (si usas volumes nombrados)
docker run --rm -v pg_data:/data -v C:\backups:/backups ^
  alpine tar czf /backups/pg_data_backup.tar.gz -C /data .
```

### Seguridad

1. **Cambiar credenciales por defecto:**
   - Admin Keycloak: cambiar contraseña en Settings → Sign in
   - Postgres: usar contraseña fuerte en variables

2. **Configurar CORS correctamente:**
   - No usar `*` en producción
   - Listar orígenes específicos

3. **Habilitar auditoria:**
   - En Realm → Security → Audit → Enabled
   - Revisa eventos en Events → Admin events

4. **Rate limiting en Brute Force:**
   - Realm → Security → Brute Force Detection → Enabled

---

## Checklist de Implementación

- [ ] Keycloak corriendo en Docker (dev o docker-compose)
- [ ] Realm TPI-Realm creado
- [ ] Clientes creados:
  - [ ] api-gateway-client
  - [ ] frontend-app
  - [ ] mobile-app
- [ ] Roles creados (admin-tpi, driver, dispatcher, etc.)
- [ ] Usuarios de prueba creados y asignados roles
- [ ] API Gateway configurado con OAuth2 resource server
- [ ] Spring Security configurado en API Gateway
- [ ] Endpoints protegidos por rol testeados
- [ ] Token obtenido y validado
- [ ] Realm exportado y guardado en Git
- [ ] Docker-compose con Postgres testeado
- [ ] Scripts de administración funcionales

---

## Recursos Útiles

- [Keycloak Official Docs](https://www.keycloak.org/documentation)
- [Keycloak Docker Guide](https://www.keycloak.org/getting-started/getting-started-docker)
- [OpenID Connect Spec](https://openid.net/specs/openid-connect-core-1_0.html)
- [Spring Security OAuth2 Docs](https://spring.io/projects/spring-security-oauth2-resource-server)

---

**Última actualización**: Noviembre 2024  
**Autor**: Tu equipo de desarrollo  
**Estado**: Completo y listo para implementación

