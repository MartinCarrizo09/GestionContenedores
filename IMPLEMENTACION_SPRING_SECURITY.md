# 🔐 GUÍA DE IMPLEMENTACIÓN: SPRING SECURITY CON ROLES

## 📋 RESUMEN

Este documento proporciona instrucciones paso a paso para implementar control de acceso basado en roles en el sistema de gestión de contenedores, cumpliendo con los requisitos del TPI.

**Roles requeridos:**
- 🟦 **CLIENTE** - Puede registrar solicitudes y consultar estado de sus contenedores
- 🟨 **OPERADOR** - Gestiona rutas, asigna camiones, administra depósitos/tarifas
- 🟩 **TRANSPORTISTA** - Inicia y finaliza tramos de transporte

---

## 🎯 ENDPOINTS POR ROL

### CLIENTE (Requisitos 1, 2)
```
POST   /solicitudes                          - Registrar solicitud
GET    /contenedores/{id}/estado             - Consultar estado contenedor
GET    /solicitudes/cliente/{idCliente}      - Ver sus solicitudes
```

### OPERADOR (Requisitos 3, 4, 5, 6, 10)
```
POST   /solicitudes/estimar-ruta             - Estimar rutas
POST   /solicitudes/{id}/asignar-ruta        - Asignar ruta
GET    /solicitudes/pendientes               - Listar pendientes
PUT    /tramos/{id}/asignar-camion           - Asignar camión
CRUD   /depositos                            - Gestionar depósitos
CRUD   /tarifas                              - Gestionar tarifas
CRUD   /camiones                             - Gestionar camiones
```

### TRANSPORTISTA (Requisitos 7, 9)
```
PATCH  /tramos/{id}/iniciar                  - Iniciar tramo
PATCH  /tramos/{id}/finalizar                - Finalizar tramo
GET    /tramos/camion/{patente}              - Ver sus tramos
```

---

## 🔧 PASO 1: AGREGAR DEPENDENCIAS

### En `pom.xml` de CADA microservicio:

```xml
<!-- Spring Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- JWT para tokens -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.11.5</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.11.5</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.11.5</version>
    <scope>runtime</scope>
</dependency>
```

---

## 🔧 PASO 2: CREAR MODELO DE USUARIO

### `servicio-gestion/src/main/java/com/tpi/gestion/modelo/Usuario.java`

```java
package com.tpi.gestion.modelo;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "usuarios", schema = "gestion")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String password; // Hash BCrypt

    @Column(nullable = false)
    private String email;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private Rol rol;

    @Column(name = "activo")
    private Boolean activo = true;

    // Para CLIENTE: referencia al id del cliente
    @Column(name = "id_cliente")
    private Long idCliente;

    // Para TRANSPORTISTA: referencia a la patente del camión
    @Column(name = "patente_camion")
    private String patenteCamion;

    public enum Rol {
        CLIENTE,
        OPERADOR,
        TRANSPORTISTA
    }
}
```

### Script SQL para crear tabla:

```sql
CREATE TABLE gestion.usuarios (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('CLIENTE', 'OPERADOR', 'TRANSPORTISTA')),
    activo BOOLEAN DEFAULT TRUE,
    id_cliente BIGINT REFERENCES gestion.clientes(id),
    patente_camion VARCHAR(10) REFERENCES flota.camiones(patente)
);

-- Crear índices
CREATE INDEX idx_usuarios_username ON gestion.usuarios(username);
CREATE INDEX idx_usuarios_rol ON gestion.usuarios(rol);

-- Insertar usuarios de prueba (passwords son BCrypt de "password123")
INSERT INTO gestion.usuarios (username, password, email, rol, id_cliente) VALUES
('cliente1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'cliente1@test.com', 'CLIENTE', 1),
('operador1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'operador1@test.com', 'OPERADOR', NULL),
('transportista1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'transportista1@test.com', 'TRANSPORTISTA', NULL);
```

---

## 🔧 PASO 3: CREAR CONFIGURACIÓN DE SEGURIDAD

### `servicio-logistica/src/main/java/com/tpi/logistica/config/SecurityConfig.java`

```java
package com.tpi.logistica.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // CLIENTE - Registrar solicitud
                .requestMatchers(HttpMethod.POST, "/solicitudes").hasRole("CLIENTE")
                
                // OPERADOR - Gestión de rutas y asignaciones
                .requestMatchers(HttpMethod.POST, "/solicitudes/estimar-ruta").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.POST, "/solicitudes/{id}/asignar-ruta").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.GET, "/solicitudes/pendientes").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.PUT, "/tramos/{id}/asignar-camion").hasRole("OPERADOR")
                
                // TRANSPORTISTA - Ejecución de transporte
                .requestMatchers(HttpMethod.PATCH, "/tramos/{id}/iniciar").hasRole("TRANSPORTISTA")
                .requestMatchers(HttpMethod.PATCH, "/tramos/{id}/finalizar").hasRole("TRANSPORTISTA")
                
                // Consultas permitidas según rol
                .requestMatchers(HttpMethod.GET, "/solicitudes/cliente/**").hasAnyRole("CLIENTE", "OPERADOR")
                .requestMatchers(HttpMethod.GET, "/solicitudes/**").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.GET, "/tramos/**").hasAnyRole("OPERADOR", "TRANSPORTISTA")
                .requestMatchers(HttpMethod.GET, "/rutas/**").hasRole("OPERADOR")
                
                // Endpoints públicos (opcional para testing)
                .requestMatchers("/auth/**").permitAll()
                
                // Cualquier otra petición requiere autenticación
                .anyRequest().authenticated()
            );
        
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

### `servicio-gestion/src/main/java/com/tpi/gestion/config/SecurityConfig.java`

```java
package com.tpi.gestion.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // CLIENTE - Consultar estado de contenedor
                .requestMatchers(HttpMethod.GET, "/contenedores/{id}/estado").hasRole("CLIENTE")
                .requestMatchers(HttpMethod.GET, "/contenedores/cliente/**").hasRole("CLIENTE")
                
                // OPERADOR - CRUD completo de recursos
                .requestMatchers("/depositos/**").hasRole("OPERADOR")
                .requestMatchers("/tarifas/**").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.POST, "/clientes").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.PUT, "/clientes/**").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.DELETE, "/clientes/**").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.POST, "/contenedores").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.PUT, "/contenedores/**").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.DELETE, "/contenedores/**").hasRole("OPERADOR")
                
                // Consultas generales requieren autenticación
                .requestMatchers(HttpMethod.GET, "/clientes/**").authenticated()
                .requestMatchers(HttpMethod.GET, "/contenedores/**").authenticated()
                
                // Autenticación
                .requestMatchers("/auth/**").permitAll()
                
                // Resto requiere autenticación
                .anyRequest().authenticated()
            );
        
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

### `servicio-flota/src/main/java/com/tpi/flota/config/SecurityConfig.java`

```java
package com.tpi.flota.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // OPERADOR - CRUD de camiones
                .requestMatchers(HttpMethod.POST, "/camiones").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.PUT, "/camiones/**").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.PATCH, "/camiones/**").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.DELETE, "/camiones/**").hasRole("OPERADOR")
                
                // TRANSPORTISTA - Ver camiones disponibles
                .requestMatchers(HttpMethod.GET, "/camiones/disponibles").hasAnyRole("OPERADOR", "TRANSPORTISTA")
                .requestMatchers(HttpMethod.GET, "/camiones/aptos").hasRole("OPERADOR")
                .requestMatchers(HttpMethod.GET, "/camiones/**").authenticated()
                
                // Autenticación
                .requestMatchers("/auth/**").permitAll()
                
                // Resto requiere autenticación
                .anyRequest().authenticated()
            );
        
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

---

## 🔧 PASO 4: CREAR SERVICIO DE AUTENTICACIÓN (OPCIONAL - BÁSICO)

### `servicio-gestion/src/main/java/com/tpi/gestion/controlador/AuthControlador.java`

```java
package com.tpi.gestion.controlador;

import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Controlador de autenticación básico.
 * Para producción, implementar JWT completo.
 */
@RestController
@RequestMapping("/auth")
public class AuthControlador {

    private final PasswordEncoder passwordEncoder;

    public AuthControlador(PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Endpoint de login básico para testing.
     * En producción, implementar JWT con refresh tokens.
     */
    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody LoginRequest request) {
        // TODO: Validar usuario y password con UsuarioRepositorio
        // TODO: Generar JWT token con rol del usuario
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Login endpoint - implementar JWT");
        response.put("username", request.getUsername());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Generar hash BCrypt para passwords de prueba.
     */
    @PostMapping("/hash-password")
    public ResponseEntity<String> hashPassword(@RequestParam String password) {
        String hash = passwordEncoder.encode(password);
        return ResponseEntity.ok(hash);
    }

    // DTO para request de login
    public static class LoginRequest {
        private String username;
        private String password;

        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
    }
}
```

---

## 🔧 PASO 5: CONFIGURACIÓN TEMPORAL PARA TESTING

### application.yml (todos los servicios)

```yaml
spring:
  security:
    user:
      # Usuario por defecto para testing inicial
      name: admin
      password: admin123
      roles: OPERADOR
```

### Deshabilitar seguridad temporalmente (NO USAR EN PRODUCCIÓN):

```java
// Agregar en SecurityConfig.java
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
        .csrf(csrf -> csrf.disable())
        .authorizeHttpRequests(auth -> auth
            .anyRequest().permitAll() // ⚠️ Deshabilitado para testing
        );
    return http.build();
}
```

---

## 🧪 TESTING CON POSTMAN

### Autenticación básica (sin JWT implementado)

```http
# Header para todas las peticiones
Authorization: Basic YWRtaW46YWRtaW4xMjM=
# Base64 de "admin:admin123"
```

### Ejemplo: Registrar solicitud como CLIENTE

```http
POST http://localhost:8082/solicitudes
Authorization: Basic Y2xpZW50ZTE6cGFzc3dvcmQxMjM=
Content-Type: application/json

{
  "numeroSeguimiento": "TRACK-001",
  "idContenedor": 1,
  "idCliente": 1,
  "origenDireccion": "Puerto de Buenos Aires",
  "destinoDireccion": "Rosario, Santa Fe",
  "estado": "BORRADOR"
}
```

### Ejemplo: Estimar ruta como OPERADOR

```http
POST http://localhost:8082/solicitudes/estimar-ruta
Authorization: Basic b3BlcmFkb3IxOnBhc3N3b3JkMTIz
Content-Type: application/json

{
  "origenDireccion": "Puerto de Buenos Aires",
  "destinoDireccion": "Rosario, Santa Fe"
}
```

### Ejemplo: Iniciar tramo como TRANSPORTISTA

```http
PATCH http://localhost:8082/tramos/1/iniciar
Authorization: Basic dHJhbnNwb3J0aXN0YTE6cGFzc3dvcmQxMjM=
```

---

## 📝 VALIDACIÓN DE ROLES EN CÓDIGO

### Opción 1: Anotaciones en métodos de servicio

```java
import org.springframework.security.access.prepost.PreAuthorize;

@Service
public class SolicitudServicio {

    @PreAuthorize("hasRole('CLIENTE')")
    public Solicitud guardar(Solicitud solicitud) {
        // Solo usuarios con rol CLIENTE pueden ejecutar esto
        return repositorio.save(solicitud);
    }

    @PreAuthorize("hasRole('OPERADOR')")
    public EstimacionRutaResponse estimarRuta(EstimacionRutaRequest request) {
        // Solo usuarios con rol OPERADOR
        return calcularRuta(request);
    }
}
```

### Opción 2: Verificación programática

```java
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

@Service
public class TramoServicio {

    public Tramo iniciarTramo(Long idTramo) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        if (!auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_TRANSPORTISTA"))) {
            throw new RuntimeException("Solo transportistas pueden iniciar tramos");
        }
        
        // Lógica del servicio
        return ...;
    }
}
```

### Opción 3: Validar que CLIENTE solo vea sus propias solicitudes

```java
@PreAuthorize("hasRole('CLIENTE')")
public List<Solicitud> listarPorCliente(Long idCliente) {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    String username = auth.getName();
    
    // Buscar usuario en BD
    Usuario usuario = usuarioRepo.findByUsername(username)
        .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
    
    // Validar que el cliente solo pueda ver sus propias solicitudes
    if (!usuario.getIdCliente().equals(idCliente)) {
        throw new RuntimeException("No tiene permisos para ver solicitudes de otro cliente");
    }
    
    return repositorio.findByIdCliente(idCliente);
}
```

---

## 🚀 ROADMAP DE IMPLEMENTACIÓN

### Fase 1: Setup básico (1-2 horas)
1. ✅ Agregar dependencias Spring Security en los 3 servicios
2. ✅ Crear modelo Usuario con tabla en BD
3. ✅ Insertar usuarios de prueba con roles
4. ✅ Crear SecurityConfig con autorización por endpoint

### Fase 2: Testing (30 min)
5. ✅ Probar endpoints con Postman usando Basic Auth
6. ✅ Verificar que solo roles correctos pueden acceder a cada endpoint
7. ✅ Validar errores 403 Forbidden para roles incorrectos

### Fase 3: Mejoras (opcional - 2-3 horas)
8. ⚪ Implementar JWT completo con tokens
9. ⚪ Crear endpoint de login que devuelva JWT
10. ⚪ Agregar refresh tokens
11. ⚪ Validar que clientes solo vean sus propios datos

---

## ⚠️ NOTAS IMPORTANTES

### Para entrega del TPI:

1. **Mínimo requerido:** SecurityConfig con autorización por endpoint
2. **Suficiente:** Basic Auth con usuarios hardcodeados en BD
3. **Ideal:** JWT completo con login/logout

### Comandos útiles:

```bash
# Generar hash BCrypt para password "password123"
# Usar en AuthControlador.hashPassword o https://bcrypt-generator.com/

# Base64 para Basic Auth
echo -n "username:password" | base64

# Cliente: cliente1:password123
echo -n "cliente1:password123" | base64
# Resultado: Y2xpZW50ZTE6cGFzc3dvcmQxMjM=

# Operador: operador1:password123
echo -n "operador1:password123" | base64
# Resultado: b3BlcmFkb3IxOnBhc3N3b3JkMTIz

# Transportista: transportista1:password123
echo -n "transportista1:password123" | base64
# Resultado: dHJhbnNwb3J0aXN0YTE6cGFzc3dvcmQxMjM=
```

### Testing rápido sin seguridad:

```java
// Comentar @EnableWebSecurity temporalmente
// @EnableWebSecurity
public class SecurityConfig {
    // ...
}
```

---

## 📚 RECURSOS ADICIONALES

- [Spring Security Reference](https://docs.spring.io/spring-security/reference/index.html)
- [JWT.io](https://jwt.io/) - Debugger de tokens JWT
- [BCrypt Generator](https://bcrypt-generator.com/) - Generar hashes de passwords
- [Base64 Encode](https://www.base64encode.org/) - Para Basic Auth headers

---

**Documento creado para facilitar la implementación de seguridad en el TPI.**  
**Tiempo estimado de implementación básica:** 2-3 horas  
**Prioridad:** ALTA (requisito funcional del profesor)
