# 📋 Resumen: Keycloak en Docker - Estado Actual

## ✅ Estado Actual

**Keycloak está corriendo en Docker en modo desarrollo**

```
URL: http://localhost:8080
Admin Console: http://localhost:8080/admin
Usuario: admin
Contraseña: admin
```

---

## 📂 Archivos Creados en tu Proyecto

1. **KEYCLOAK-CONFIGURACION.md** - Guía completa (80+ líneas)
2. **KEYCLOAK-INICIO-RAPIDO.md** - Guía rápida con pasos manuales
3. **keycloak-setup.ps1** - Script automatizado (configuración completa en 1 comando)

---

## 🚀 Opción 1: Configuración MANUAL (UI Admin Console)

Sigue los pasos en **KEYCLOAK-INICIO-RAPIDO.md**

**Pros:**
- Aprendes cómo funciona Keycloak
- Control total sobre cada elemento

**Contras:**
- Toma ~15-20 minutos

**Pasos:**
1. Abre http://localhost:8080/admin
2. Login con admin/admin
3. Crea realm TPI-Realm
4. Crea clientes (api-gateway-client, frontend-app)
5. Crea roles (admin-tpi, driver, dispatcher, manager, customer)
6. Crea usuarios de prueba y asigna roles

---

## 🤖 Opción 2: Configuración AUTOMATIZADA (Script PowerShell)

Ejecuta en PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\Martin\Desktop\TPI - Backend - G143\keycloak-setup.ps1"
```

**Pros:**
- ⚡ 1 minuto (automático)
- Reproducible
- Sin errores manuales

**Contras:**
- Debes confiar en el script

**Resultado:**
- ✓ Realm TPI-Realm creado
- ✓ 5 roles creados
- ✓ Cliente api-gateway-client configurado
- ✓ 4 usuarios creados (admin-tpi, driver1, dispatcher1, manager1)
- ✓ Client Secret mostrado (GUÁRDALO)

---

## 📝 Próximos Pasos (después de configurar Keycloak)

### 1. Guardar Client Secret

El script mostrará algo como:
```
Client Secret: abc123def456ghi789jkl000
```

**Guárdalo en un lugar seguro** (lo necesitarás para Spring Boot)

### 2. Configurar API Gateway

En `api-gateway/src/main/resources/application.yml`:

```yaml
spring:
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
            client-secret: TU_CLIENT_SECRET_AQUI
            scope: openid,profile,email,roles
        provider:
          keycloak:
            issuer-uri: http://localhost:8080/realms/TPI-Realm
            token-uri: http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/token
```

### 3. Añadir Dependencias Maven

En `pom.xml`:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-oauth2-jose</artifactId>
</dependency>
```

### 4. Crear SecurityConfig.java

En `api-gateway/src/main/java/com/tpi/apigateway/config/SecurityConfig.java`:

```java
@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authorize -> authorize
                .requestMatchers("/actuator/**").permitAll()
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/driver/**").hasRole("driver")
                .requestMatchers("/api/dispatcher/**").hasRole("dispatcher")
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter()))
            );
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

### 5. Testear Autenticación

**Obtener token con PowerShell:**

```powershell
$response = Invoke-RestMethod `
  -Uri "http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/token" `
  -Method Post `
  -ContentType "application/x-www-form-urlencoded" `
  -Body @{
    grant_type = "password"
    client_id = "api-gateway-client"
    client_secret = "TU_CLIENT_SECRET"
    username = "admin-tpi"
    password = "Admin123!"
  }

$token = $response.access_token
Write-Host "Token: $token"
```

**Usar token en API:**

```powershell
curl -H "Authorization: Bearer $token" http://localhost:8080/api/profile
```

---

## 📊 Estructura Final

```
Keycloak (http://localhost:8080)
├── Realm: TPI-Realm
│   ├── Roles:
│   │   ├── admin-tpi
│   │   ├── driver
│   │   ├── dispatcher
│   │   ├── manager
│   │   └── customer
│   ├── Clientes:
│   │   ├── api-gateway-client (con secret)
│   │   └── frontend-app (público)
│   └── Usuarios:
│       ├── admin-tpi (rol: admin-tpi)
│       ├── driver1 (rol: driver)
│       ├── dispatcher1 (rol: dispatcher)
│       └── manager1 (rol: manager)
└── OpenID Connect Configuration
    └── http://localhost:8080/realms/TPI-Realm/.well-known/openid-configuration
```

---

## 🔗 URLs Útiles

| Recurso | URL |
|---------|-----|
| Admin Console | http://localhost:8080/admin |
| Keycloak UI | http://localhost:8080 |
| OpenID Config | http://localhost:8080/realms/TPI-Realm/.well-known/openid-connect |
| Authorization | http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/auth |
| Token | http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/token |
| UserInfo | http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/userinfo |
| JWKS | http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/certs |

---

## 💡 Comandos Docker Útiles

```bash
# Ver logs
docker logs -f practical_roentgen

# Parar
docker stop practical_roentgen

# Reiniciar
docker restart practical_roentgen

# Limpiar (eliminar contenedor)
docker rm practical_roentgen

# Usar docker-compose con Postgres (producción)
docker compose up -d
docker compose logs -f keycloak
docker compose down
```

---

## 🎯 Checklist Rápido

- [ ] Keycloak corriendo (✓ YA HECHO)
- [ ] Configuración completada (manual o automática)
- [ ] Realm TPI-Realm creado
- [ ] Clientes y usuarios creados
- [ ] Client Secret copiado
- [ ] API Gateway configurado con OAuth2
- [ ] SecurityConfig.java creado
- [ ] Dependencias Maven añadidas
- [ ] Token obtenido y testeado
- [ ] Endpoints protegidos por rol

---

## 📚 Documentación

- Ver **KEYCLOAK-CONFIGURACION.md** para guía completa (80+ líneas)
- Ver **KEYCLOAK-INICIO-RAPIDO.md** para pasos manuales
- Ver **keycloak-setup.ps1** para automatización

---

**Generado**: Noviembre 2024  
**Estado**: Keycloak funcionando, listo para configuración  
**Siguiente**: Elige Opción 1 (manual) u Opción 2 (script automatizado)

