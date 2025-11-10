# 📋 VER EN CLASE - Sistema de Logging y Manejo de Excepciones

## 🎯 Propósito de este Documento

Este documento detalla la **implementación del sistema de logging y manejo de excepciones** realizada según el **Apunte 23** del profesor. El objetivo es **corroborar en clase** que la implementación cumple con los requisitos y verificar qué elementos adicionales son necesarios.

---

## ✅ LO QUE YA IMPLEMENTAMOS

### 1️⃣ **Configuración de Logging con Logback**

#### **Archivos Creados:**
```
📁 servicio-gestion/src/main/resources/
   └── logback-spring.xml

📁 servicio-flota/src/main/resources/
   └── logback-spring.xml

📁 servicio-logistica/src/main/resources/
   └── logback-spring.xml
```

#### **Características Implementadas:**
- ✅ **Appender de consola** con formato personalizado
- ✅ **Appender de archivo** con rotación diaria
- ✅ **Retención de logs:** 7 días automáticamente
- ✅ **Niveles diferenciados:**
  - `DEBUG` para nuestro código (`com.tpi.*`)
  - `INFO` para Spring Framework
  - `DEBUG` para SQL de Hibernate

#### **Ejemplo de Configuración:**
```xml
<appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>logs/servicio-gestion.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <fileNamePattern>logs/servicio-gestion-%d{yyyy-MM-dd}.log</fileNamePattern>
        <maxHistory>7</maxHistory>
    </rollingPolicy>
</appender>
```

#### **Resultado:**
Los logs se guardan en:
- `logs/servicio-gestion-2025-11-10.log`
- `logs/servicio-flota-2025-11-10.log`
- `logs/servicio-logistica-2025-11-10.log`

---

### 2️⃣ **Actualización de application.yml**

#### **Archivos Modificados:**
- ✅ `servicio-gestion/src/main/resources/application.yml`
- ✅ `servicio-flota/src/main/resources/application.yml`
- ✅ `servicio-logistica/src/main/resources/application.yml`

#### **Configuración Agregada:**
```yaml
logging:
  level:
    root: INFO
    com.tpi.gestion: DEBUG          # Nuestro código en DEBUG
    org.springframework.web: INFO
    org.springframework.security: INFO
    org.hibernate.SQL: DEBUG        # Ver queries SQL
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} %-5level [%thread] %logger{36} - %msg%n"
  file:
    name: logs/servicio-gestion.log
```

---

### 3️⃣ **Excepciones Personalizadas**

#### **Archivos Creados:**

**📁 servicio-gestion/excepcion/**
- ✅ `RecursoNoEncontradoException.java` - Para recursos no encontrados (404)
- ✅ `DatosInvalidosException.java` - Para datos inválidos (400)

**📁 servicio-flota/excepcion/**
- ✅ `RecursoNoEncontradoException.java`
- ✅ `DatosInvalidosException.java`

**📁 servicio-logistica/excepcion/**
- ✅ `RecursoNoEncontradoException.java`
- ✅ `DatosInvalidosException.java`
- ✅ `EstadoInvalidoException.java` - Para estados inválidos (409)

#### **Ejemplo de Implementación:**
```java
public class RecursoNoEncontradoException extends RuntimeException {
    public RecursoNoEncontradoException(String recurso, Long id) {
        super(String.format("%s con ID %d no encontrado", recurso, id));
    }
}
```

---

### 4️⃣ **DTO de Respuesta de Error Estandarizada**

#### **Archivos Creados:**
- ✅ `servicio-gestion/dto/ErrorResponse.java`
- ✅ `servicio-flota/dto/ErrorResponse.java`
- ✅ `servicio-logistica/dto/ErrorResponse.java`

#### **Estructura del DTO:**
```java
public record ErrorResponse(
    LocalDateTime timestamp,
    int status,
    String error,
    String message,
    String path
)
```

#### **Ejemplo de Respuesta JSON:**
```json
{
  "timestamp": "2025-11-10T15:30:00",
  "status": 404,
  "error": "Recurso no encontrado",
  "message": "Cliente con ID 123 no encontrado",
  "path": "/api-gestion/clientes/123"
}
```

---

### 5️⃣ **Manejadores Globales de Excepciones (@ControllerAdvice)**

#### **Archivos Creados:**
- ✅ `servicio-gestion/config/GlobalExceptionHandler.java`
- ✅ `servicio-flota/config/GlobalExceptionHandler.java`
- ✅ `servicio-logistica/config/GlobalExceptionHandler.java`

#### **Excepciones Manejadas:**

| Excepción | Código HTTP | Descripción |
|-----------|-------------|-------------|
| `RecursoNoEncontradoException` | 404 NOT FOUND | Recurso no existe |
| `DatosInvalidosException` | 400 BAD REQUEST | Datos inválidos |
| `EstadoInvalidoException` | 409 CONFLICT | Estado incorrecto |
| `IllegalArgumentException` | 400 BAD REQUEST | Argumento inválido |
| `Exception` (genérica) | 500 INTERNAL SERVER ERROR | Error inesperado |

#### **Ejemplo de Handler:**
```java
@ControllerAdvice
public class GlobalExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(RecursoNoEncontradoException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(
            RecursoNoEncontradoException ex,
            HttpServletRequest request) {
        log.warn("Recurso no encontrado: {}", ex.getMessage());
        ErrorResponse error = ErrorResponse.of(
            HttpStatus.NOT_FOUND.value(),
            "Recurso no encontrado",
            ex.getMessage(),
            request.getRequestURI()
        );
        return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
    }
}
```

---

### 6️⃣ **Reemplazo de System.out.println por SLF4J**

#### **Anti-Patrón Eliminado:**
❌ **ANTES:**
```java
System.out.println("✅ Solicitud ID " + solicitud.getId() + " marcada como ENTREGADA");
System.out.println("   - Costo final: $" + costoTotal[0]);
```

✅ **DESPUÉS:**
```java
private static final Logger log = LoggerFactory.getLogger(TramoServicio.class);

log.info("Solicitud ID {} marcada como ENTREGADA", solicitud.getId());
log.debug("   - Costo final: ${}", costoTotal[0]);
```

#### **Archivos Modificados:**
- ✅ `servicio-logistica/servicio/TramoServicio.java` (6 System.out eliminados)
- ✅ `servicio-logistica/servicio/SolicitudServicio.java` (4 System.out eliminados)

#### **Ventajas:**
- ✅ Niveles de log configurables (INFO, DEBUG, WARN, ERROR)
- ✅ Mejor rendimiento (usa placeholders `{}`)
- ✅ Los logs van a archivos rotativos
- ✅ Formato consistente con timestamp

---

## 📊 RESUMEN DE ARCHIVOS CREADOS/MODIFICADOS

### **Archivos Creados: 19**
| Tipo | Cantidad | Ubicación |
|------|----------|-----------|
| logback-spring.xml | 3 | `*/src/main/resources/` |
| Excepciones personalizadas | 7 | `*/excepcion/` |
| ErrorResponse DTO | 3 | `*/dto/` |
| GlobalExceptionHandler | 3 | `*/config/` |
| Documentación | 3 | Raíz del proyecto |

### **Archivos Modificados: 5**
| Archivo | Cambio |
|---------|--------|
| application.yml (×3) | Configuración de logging |
| TramoServicio.java | Logger + reemplazo de System.out |
| SolicitudServicio.java | Logger + reemplazo de System.out |

---

## ❓ LO QUE FALTA IMPLEMENTAR (VERIFICAR CON PROFESOR)

### 🔍 **Punto 1: ¿Agregar Loggers a TODOS los Controladores?**

#### **Estado Actual:**
- ❌ Los controladores **NO tienen loggers** implementados

#### **Ejemplo de lo que se podría agregar:**
```java
@RestController
@RequestMapping("/api-gestion/clientes")
public class ClienteControlador {
    private static final Logger log = LoggerFactory.getLogger(ClienteControlador.class);
    
    @GetMapping("/{id}")
    public ResponseEntity<Cliente> obtener(@PathVariable Long id) {
        log.info("[GET] /api-gestion/clientes/{} - Iniciando búsqueda", id);
        Cliente cliente = servicio.obtener(id);
        log.info("[GET] /api-gestion/clientes/{} - Finalizado correctamente", id);
        return ResponseEntity.ok(cliente);
    }
}
```

#### **Archivos Afectados (~15 controladores):**

**servicio-gestion:**
- `ClienteControlador.java`
- `ContenedorControlador.java`
- `DepositoControlador.java`
- `TarifaControlador.java`

**servicio-flota:**
- `CamionControlador.java`

**servicio-logistica:**
- `SolicitudControlador.java`
- `RutaControlador.java`
- `TramoControlador.java`
- `ConfiguracionControlador.java`
- `GoogleMapsControlador.java`

#### **Beneficio:**
- Trazabilidad de **todas las peticiones HTTP**
- Tiempo de respuesta visible
- Fácil debugging de endpoints

#### **Pregunta para el Profesor:**
> ❓ **¿Es necesario agregar loggers en todos los controladores o con los GlobalExceptionHandler es suficiente?**

---

### 🔍 **Punto 2: ¿Agregar Loggers a TODOS los Servicios?**

#### **Estado Actual:**
- ✅ `TramoServicio.java` - Ya tiene logger
- ✅ `SolicitudServicio.java` - Ya tiene logger
- ❌ El resto de servicios **NO tienen loggers**

#### **Ejemplo de lo que se podría agregar:**
```java
@Service
public class ClienteServicio {
    private static final Logger log = LoggerFactory.getLogger(ClienteServicio.class);
    
    public Cliente crear(Cliente cliente) {
        log.info("Creando nuevo cliente: {}", cliente.getNombre());
        try {
            Cliente guardado = repositorio.save(cliente);
            log.debug("Cliente guardado con ID: {}", guardado.getId());
            return guardado;
        } catch (Exception e) {
            log.error("Error al crear cliente: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    public Cliente obtener(Long id) {
        log.debug("Buscando cliente con ID: {}", id);
        return repositorio.findById(id)
            .orElseThrow(() -> {
                log.warn("Cliente con ID {} no encontrado", id);
                return new RecursoNoEncontradoException("Cliente", id);
            });
    }
}
```

#### **Archivos Afectados (~10 servicios):**

**servicio-gestion:**
- `ClienteServicio.java`
- `ContenedorServicio.java`
- `DepositoServicio.java`
- `TarifaServicio.java`

**servicio-flota:**
- `CamionServicio.java`

**servicio-logistica:**
- `RutaServicio.java`
- `ConfiguracionServicio.java`
- `CalculoTarifaServicio.java`

#### **Beneficio:**
- Trazabilidad de la **lógica de negocio**
- Debugging de operaciones complejas
- Registro de decisiones tomadas

#### **Pregunta para el Profesor:**
> ❓ **¿Es necesario agregar loggers en todos los servicios o solo en los críticos como Tramo y Solicitud?**

---

### 🔍 **Punto 3: ¿Implementar Correlation IDs?**

#### **Estado Actual:**
- ❌ **NO implementado**

#### **¿Qué es un Correlation ID?**
Es un identificador único que se propaga a través de **múltiples microservicios** para rastrear una petición completa.

#### **Ejemplo de Implementación:**
```java
// En un filtro
@Component
public class CorrelationIdFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
        String correlationId = UUID.randomUUID().toString();
        MDC.put("correlationId", correlationId);
        try {
            chain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}

// En logback-spring.xml
<pattern>%d{yyyy-MM-dd HH:mm:ss} [%X{correlationId}] %-5level %logger{36} - %msg%n</pattern>
```

#### **Resultado en Logs:**
```
2025-11-10 15:30:00 [abc-123-def] INFO  c.t.l.SolicitudServicio - Creando solicitud
2025-11-10 15:30:01 [abc-123-def] INFO  c.t.g.ClienteServicio - Obteniendo cliente
2025-11-10 15:30:02 [abc-123-def] INFO  c.t.f.CamionServicio - Buscando camión disponible
```

#### **Beneficio:**
- Seguir una petición a través de **todos los microservicios**
- Debugging de flujos distribuidos

#### **Pregunta para el Profesor:**
> ❓ **¿Es necesario implementar Correlation IDs o es un concepto avanzado para otro momento?**

---

### 🔍 **Punto 4: ¿Usar Excepciones en lugar de RuntimeException genérica?**

#### **Estado Actual:**
En algunos lugares del código se usa:
```java
throw new RuntimeException("Error al crear cliente: " + ex.getMessage());
```

#### **¿Debería ser así?**
```java
throw new DatosInvalidosException("Error al crear cliente: " + ex.getMessage(), ex);
```

#### **Archivos a Revisar:**
- `SolicitudServicio.java` - Tiene varios `throw new RuntimeException(...)`
- Otros servicios con manejo de errores

#### **Beneficio:**
- Respuestas HTTP más específicas (400 en vez de 500)
- Mejor semántica del error

#### **Pregunta para el Profesor:**
> ❓ **¿Deberíamos reemplazar todos los RuntimeException genéricos por nuestras excepciones personalizadas?**

---

### 🔍 **Punto 5: ¿Logs en Repositorios (Capa de Datos)?**

#### **Estado Actual:**
- ❌ Los repositorios **NO tienen loggers**

#### **Ejemplo de lo que se podría agregar:**
```java
@Repository
public interface ClienteRepositorio extends JpaRepository<Cliente, Long> {
    // Los repositorios son interfaces, pero podemos habilitar logs de JPA
}
```

#### **Configuración en application.yml:**
```yaml
logging:
  level:
    org.hibernate.SQL: DEBUG                    # Ya lo tenemos ✅
    org.hibernate.type.descriptor.sql: TRACE    # Parámetros de queries
```

#### **Resultado:**
```
2025-11-10 15:30:00 DEBUG o.h.SQL - select cliente0_.id, cliente0_.nombre from clientes cliente0_ where cliente0_.id=?
2025-11-10 15:30:00 TRACE o.h.type.descriptor.sql.BasicBinder - binding parameter [1] as [BIGINT] - [123]
```

#### **Pregunta para el Profesor:**
> ❓ **¿Es suficiente con los logs de Hibernate o deberíamos agregar logs personalizados en los repositorios?**

---

## 🎯 CHECKLIST PARA REVISAR EN CLASE

### ✅ **Implementado y Funcionando:**
- [x] Configuración de Logback con rotación de archivos
- [x] Niveles de log configurados en application.yml
- [x] Excepciones personalizadas (RecursoNoEncontrado, DatosInvalidos, EstadoInvalido)
- [x] ErrorResponse DTO estandarizado
- [x] GlobalExceptionHandler con @ControllerAdvice
- [x] System.out.println eliminados de TramoServicio y SolicitudServicio
- [x] Loggers SLF4J en servicios críticos

### ❓ **Por Validar con el Profesor:**
- [ ] ¿Agregar loggers en TODOS los controladores? (~15 clases)
- [ ] ¿Agregar loggers en TODOS los servicios? (~10 clases)
- [ ] ¿Implementar Correlation IDs para trazabilidad distribuida?
- [ ] ¿Reemplazar RuntimeException genéricos por excepciones personalizadas?
- [ ] ¿Habilitar logs TRACE de Hibernate para ver parámetros SQL?

---

## 📝 PREGUNTAS ESPECÍFICAS PARA EL PROFESOR

### **Pregunta 1: Alcance del Logging**
> Según el Apunte 23, ¿qué nivel de cobertura de logs se espera?
> - ¿Solo en servicios críticos? ✅ (Ya hecho)
> - ¿En todos los controladores?
> - ¿En todos los servicios?

### **Pregunta 2: Nivel de Detalle**
> ¿Qué nivel de log debería estar activo en producción?
> - `INFO` para operaciones normales
> - `DEBUG` para desarrollo
> - ¿Cuándo usar `TRACE`?

### **Pregunta 3: Excepciones**
> ¿Está bien usar `RuntimeException` genérica o deberíamos usar siempre nuestras excepciones personalizadas?

### **Pregunta 4: Correlation IDs**
> ¿Es parte del TP o es un concepto avanzado que veremos más adelante?

### **Pregunta 5: Logs en Repositorios**
> ¿Es suficiente con los logs de Hibernate o necesitamos algo más?

---

## 🎓 REFERENCIA AL APUNTE

**Basado en:** Apunte 23 - Manejo de Excepciones y Logging Local

**Secciones Implementadas:**
- ✅ Conceptos básicos de Excepciones (páginas 1-3)
- ✅ Manejo global de excepciones con Spring (páginas 4-5)
- ✅ Logging en aplicaciones Spring Boot (páginas 6-8)
- ✅ Uso de SLF4J (páginas 9-10)
- ✅ Configuración avanzada con Logback (páginas 11-13)
- ⏳ Logging por capa de aplicación (páginas 14-15) - **PARCIALMENTE**

**Secciones por Validar:**
- ❓ Alcance completo de "Logging por capa" (¿todas las capas o solo críticas?)
- ❓ Anti-patrones (revisamos System.out, ¿falta algo más?)

---

## 📊 MÉTRICAS DE CUMPLIMIENTO

| Categoría | Implementado | Total Posible | % |
|-----------|--------------|---------------|---|
| **Configuración de Logging** | 3/3 servicios | 3 | 100% |
| **Excepciones Personalizadas** | 7 excepciones | 7+ | 100% |
| **GlobalExceptionHandler** | 3/3 servicios | 3 | 100% |
| **System.out Eliminados** | 2 servicios críticos | 2+ | 100% |
| **Loggers en Servicios** | 2/10 servicios | 10 | 20% |
| **Loggers en Controladores** | 0/15 controladores | 15 | 0% |
| **Correlation IDs** | 0/1 | 1 | 0% |

---

## 🚀 CONCLUSIÓN

### **Estado Actual:**
- ✅ **Infraestructura completa** de logging y manejo de excepciones
- ✅ **Funciona correctamente** con logs rotativos y errores estandarizados
- ✅ **Anti-patrón eliminado** (System.out.println)
- ⏳ **Cobertura parcial** de loggers en servicios y controladores

### **Decisión Pendiente:**
Necesitamos validar con el profesor **cuál es el alcance esperado** para el TP:
1. ¿Solo la infraestructura? (Ya está ✅)
2. ¿Infraestructura + loggers en servicios críticos? (Ya está ✅)
3. ¿Infraestructura + loggers en TODOS los servicios y controladores? (Falta)

---

## 📅 PLAN PARA LA CLASE

1. **Mostrar la implementación actual** (infraestructura completa)
2. **Demostrar funcionamiento:**
   - Logs en archivos rotativos
   - Respuestas de error estandarizadas
   - Logs con niveles apropiados
3. **Consultar las 5 preguntas** sobre alcance y nivel de detalle
4. **Implementar lo faltante** según indicaciones del profesor (si es necesario)

---

**Documento preparado para revisión en clase - Noviembre 2025**
