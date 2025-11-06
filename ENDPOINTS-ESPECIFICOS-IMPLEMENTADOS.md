# 🚀 Implementación de Endpoints Específicos del Enunciado

**Fecha**: 6 de noviembre de 2025  
**Implementado por**: GitHub Copilot

---

## 📋 Resumen de Cambios

Se implementaron dos endpoints críticos faltantes según los requerimientos del enunciado:

1. **Requerimiento 5**: Consultar contenedores pendientes de entrega
2. **Requerimiento 2**: Consultar estado del transporte de un contenedor (con comunicación entre microservicios)

---

## ✅ 1. Requerimiento 5: GET /solicitudes/pendientes

### **Endpoint Implementado**
```
GET /api-logistica/solicitudes/pendientes
```

### **Parámetros Query (opcionales)**
- `estado`: Filtra por estado específico (ej: `EN_TRANSITO`, `PROGRAMADA`, `BORRADOR`)
- `idContenedor`: Filtra por un contenedor específico

### **Ejemplos de Uso**
```bash
# Obtener todos los contenedores pendientes
GET http://localhost:8082/api-logistica/solicitudes/pendientes

# Filtrar por estado
GET http://localhost:8082/api-logistica/solicitudes/pendientes?estado=EN_TRANSITO

# Buscar por contenedor específico
GET http://localhost:8082/api-logistica/solicitudes/pendientes?idContenedor=2
```

### **Respuesta (JSON)**
```json
[
  {
    "idSolicitud": 501,
    "numeroSeguimiento": "XYZ-789",
    "idContenedor": 2,
    "idCliente": 1,
    "estado": "EN_TRANSITO",
    "ubicacionActual": "EN_TRANSITO",
    "descripcionUbicacion": "En viaje de Buenos Aires hacia Depósito Central",
    "costoEstimado": 98524.0,
    "costoFinal": null,
    "tramoActual": {
      "idTramo": 20,
      "origen": "Buenos Aires",
      "destino": "Depósito Central",
      "estadoTramo": "INICIADO",
      "patenteCamion": "ABC123"
    }
  }
]
```

### **Archivos Creados/Modificados**

#### 📄 **Nuevo**: `ContenedorPendienteResponse.java`
**Ubicación**: `servicio-logistica/src/main/java/com/tpi/logistica/dto/`

DTO para la respuesta que combina información de Solicitud, Tramo y ubicación actual.

```java
public class ContenedorPendienteResponse {
    private Long idSolicitud;
    private String numeroSeguimiento;
    private Long idContenedor;
    private Long idCliente;
    private String estado;
    private String ubicacionActual;
    private String descripcionUbicacion;
    private TramoActual tramoActual;
    private Double costoEstimado;
    private Double costoFinal;
}
```

#### 📝 **Modificado**: `SolicitudServicio.java`
**Ubicación**: `servicio-logistica/src/main/java/com/tpi/logistica/servicio/`

**Métodos agregados**:
- `listarPendientes(String estadoFiltro, Long idContenedor)`: **Líneas 207-225**
  - Filtra solicitudes que no están entregadas
  - Permite filtrar por estado o ID de contenedor
  
- `convertirAContenedorPendiente(Solicitud solicitud)`: **Líneas 230-285**
  - Convierte Solicitud a DTO con información de ubicación
  - Determina ubicación actual basándose en tramos activos
  - Busca tramo iniciado o último finalizado

#### 📝 **Modificado**: `SolicitudControlador.java`
**Ubicación**: `servicio-logistica/src/main/java/com/tpi/logistica/controlador/`

**Endpoint agregado**: **Líneas 93-99**
```java
@GetMapping("/pendientes")
public ResponseEntity<List<ContenedorPendienteResponse>> listarPendientes(
        @RequestParam(required = false) String estado,
        @RequestParam(required = false) Long idContenedor) {
    List<ContenedorPendienteResponse> pendientes = 
        servicio.listarPendientes(estado, idContenedor);
    return ResponseEntity.ok(pendientes);
}
```

#### 📝 **Modificado**: `SolicitudRepositorio.java`
**Ubicación**: `servicio-logistica/src/main/java/com/tpi/logistica/repositorio/`

**Método agregado**: **Línea 20**
```java
List<Solicitud> findByIdContenedor(Long idContenedor);
```

---

## ✅ 2. Requerimiento 2: GET /contenedores/{id}/estado

### **Endpoint Implementado**
```
GET /api-gestion/contenedores/{id}/estado
```

### **Características**
- ✅ Comunicación entre microservicios (Gestión → Logística)
- ✅ Combina datos del contenedor con su solicitud de transporte activa
- ✅ Muestra ubicación actual y tramo en curso
- ✅ Información completa del cliente

### **Ejemplo de Uso**
```bash
GET http://localhost:8080/api-gestion/contenedores/2/estado
```

### **Respuesta (JSON)**
```json
{
  "idContenedor": 2,
  "codigoIdentificacion": "CONT-002",
  "peso": 4800.0,
  "volumen": 35.0,
  "cliente": {
    "id": 1,
    "nombre": "Juan",
    "apellido": "Pérez",
    "email": "juan@email.com"
  },
  "solicitud": {
    "id": 501,
    "numeroSeguimiento": "XYZ-789",
    "estado": "EN_TRANSITO",
    "costoEstimado": 98524.0,
    "costoFinal": null
  },
  "ubicacionActual": "EN_TRANSITO",
  "descripcionUbicacion": "En viaje de Buenos Aires hacia Depósito Central",
  "tramoActual": {
    "origen": "Buenos Aires",
    "destino": "Depósito Central",
    "estadoTramo": "INICIADO",
    "patenteCamion": "ABC123"
  }
}
```

### **Archivos Creados/Modificados**

#### 📄 **Nuevo**: `EstadoContenedorResponse.java`
**Ubicación**: `servicio-gestion/src/main/java/com/tpi/gestion/dto/`

DTO principal para la respuesta del estado del contenedor.

```java
public class EstadoContenedorResponse {
    private Long idContenedor;
    private String codigoIdentificacion;
    private Double peso;
    private Double volumen;
    private ClienteInfo cliente;
    private SolicitudInfo solicitud;
    private String ubicacionActual;
    private String descripcionUbicacion;
    private TramoInfo tramoActual;
}
```

#### 📄 **Nuevo**: `SolicitudLogisticaDTO.java`
**Ubicación**: `servicio-gestion/src/main/java/com/tpi/gestion/dto/`

DTO auxiliar para recibir información desde servicio-logistica.

#### 📄 **Nuevo**: `RestTemplateConfig.java`
**Ubicación**: `servicio-gestion/src/main/java/com/tpi/gestion/config/`

Configuración del bean RestTemplate para comunicación entre servicios.

```java
@Configuration
public class RestTemplateConfig {
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```

#### 📄 **Nuevo**: `LogisticaClienteServicio.java`
**Ubicación**: `servicio-gestion/src/main/java/com/tpi/gestion/servicio/`

Servicio cliente para la comunicación con servicio-logistica.

**Métodos**:
- `buscarSolicitudesPorContenedor(Long idContenedor)`: **Líneas 24-41**
  - Llama a `/api-logistica/solicitudes/pendientes?idContenedor={id}`
  - Maneja errores devolviendo lista vacía
  
- `obtenerSolicitudActiva(Long idContenedor)`: **Líneas 47-54**
  - Obtiene la primera solicitud no entregada del contenedor

#### 📝 **Modificado**: `ContenedorServicio.java`
**Ubicación**: `servicio-gestion/src/main/java/com/tpi/gestion/servicio/`

**Método agregado**: `obtenerEstado(Long id)` - **Líneas 75-136**

Lógica:
1. Busca contenedor en base de datos local
2. Construye información básica del contenedor y cliente
3. **Llama a servicio-logistica** para obtener solicitud activa
4. Combina toda la información en EstadoContenedorResponse
5. Maneja caso cuando no hay solicitud activa

```java
public EstadoContenedorResponse obtenerEstado(Long id) {
    // Buscar contenedor local
    Contenedor contenedor = contenedorRepo.findById(id)
        .orElseThrow(() -> new RuntimeException("Contenedor no encontrado"));
    
    // Consultar servicio de logística
    Optional<SolicitudLogisticaDTO> solicitudOpt = 
        logisticaCliente.obtenerSolicitudActiva(id);
    
    // Combinar información...
}
```

#### 📝 **Modificado**: `ContenedorControlador.java`
**Ubicación**: `servicio-gestion/src/main/java/com/tpi/gestion/controlador/`

**Endpoint agregado**: **Líneas 56-60**
```java
@GetMapping("/{id}/estado")
public ResponseEntity<EstadoContenedorResponse> obtenerEstado(@PathVariable Long id) {
    EstadoContenedorResponse estado = servicio.obtenerEstado(id);
    return ResponseEntity.ok(estado);
}
```

#### 📝 **Modificado**: `application.yml` (servicio-gestion)
**Ubicación**: `servicio-gestion/src/main/resources/`

**Configuración agregada**: **Líneas 51-54**
```yaml
# ========== Configuración de Microservicios ==========
servicio:
  logistica:
    url: ${SERVICIO_LOGISTICA_URL:http://localhost:8082/api-logistica}
```

---

## 🔄 Flujo de Comunicación entre Microservicios

### **Diagrama de Secuencia**

```
Cliente/Operador
    |
    | 1. GET /api-gestion/contenedores/2/estado
    v
ContenedorControlador
    |
    | 2. obtenerEstado(2)
    v
ContenedorServicio
    |
    | 3. buscarPorId(2)
    v
ContenedorRepositorio (DB Gestión)
    |
    | 4. Contenedor encontrado
    |
    v
LogisticaClienteServicio
    |
    | 5. HTTP GET http://localhost:8082/api-logistica/solicitudes/pendientes?idContenedor=2
    v
SolicitudControlador (Servicio Logística)
    |
    | 6. listarPendientes(null, 2)
    v
SolicitudServicio
    |
    | 7. findByIdContenedor(2)
    v
SolicitudRepositorio (DB Logística)
    |
    | 8. Solicitudes encontradas
    |
    v
ContenedorServicio
    |
    | 9. Combinar Contenedor + Solicitud + Tramo
    v
EstadoContenedorResponse
    |
    | 10. JSON Response
    v
Cliente/Operador
```

---

## 📊 Estructura de Directorios Modificada

### **Servicio Gestión**
```
servicio-gestion/src/main/java/com/tpi/gestion/
├── config/
│   └── RestTemplateConfig.java                    ← NUEVO
├── controlador/
│   └── ContenedorControlador.java                 ← MODIFICADO
├── dto/
│   ├── EstadoContenedorResponse.java              ← NUEVO
│   └── SolicitudLogisticaDTO.java                 ← NUEVO
└── servicio/
    ├── ContenedorServicio.java                    ← MODIFICADO
    └── LogisticaClienteServicio.java              ← NUEVO
```

### **Servicio Logística**
```
servicio-logistica/src/main/java/com/tpi/logistica/
├── controlador/
│   └── SolicitudControlador.java                  ← MODIFICADO
├── dto/
│   └── ContenedorPendienteResponse.java           ← NUEVO
├── repositorio/
│   └── SolicitudRepositorio.java                  ← MODIFICADO
└── servicio/
    └── SolicitudServicio.java                     ← MODIFICADO
```

---

## ✅ Checklist de Implementación

### Requerimiento 5: Contenedores Pendientes
- [x] DTO `ContenedorPendienteResponse` creado
- [x] Método `listarPendientes()` en SolicitudServicio
- [x] Método `convertirAContenedorPendiente()` con lógica de ubicación
- [x] Endpoint GET `/solicitudes/pendientes` en SolicitudControlador
- [x] Método repositorio `findByIdContenedor()`
- [x] Soporte para filtros por estado e idContenedor
- [x] Determinación de ubicación actual basada en tramos

### Requerimiento 2: Estado de Contenedor
- [x] DTOs de respuesta creados (EstadoContenedorResponse, SolicitudLogisticaDTO)
- [x] Configuración RestTemplate para comunicación HTTP
- [x] Servicio cliente LogisticaClienteServicio
- [x] Método `obtenerEstado()` en ContenedorServicio
- [x] Endpoint GET `/contenedores/{id}/estado` en ContenedorControlador
- [x] Configuración URL servicio-logistica en application.yml
- [x] Manejo de errores de comunicación
- [x] Lógica para caso sin solicitud activa

---

## 🧪 Casos de Prueba Sugeridos

### **Test 1: Contenedor con Solicitud Activa**
```bash
# 1. Crear contenedor
POST http://localhost:8080/api-gestion/contenedores

# 2. Crear solicitud
POST http://localhost:8082/api-logistica/solicitudes

# 3. Consultar estado
GET http://localhost:8080/api-gestion/contenedores/2/estado

# Resultado esperado: Estado completo con solicitud y ubicación
```

### **Test 2: Contenedor sin Solicitud**
```bash
GET http://localhost:8080/api-gestion/contenedores/999/estado

# Resultado esperado: 
# - Datos del contenedor ✓
# - ubicacionActual: "SIN_SOLICITUD"
# - solicitud: null
```

### **Test 3: Listar Pendientes con Filtros**
```bash
# Todos los pendientes
GET http://localhost:8082/api-logistica/solicitudes/pendientes

# Filtrar por estado
GET http://localhost:8082/api-logistica/solicitudes/pendientes?estado=EN_TRANSITO

# Filtrar por contenedor
GET http://localhost:8082/api-logistica/solicitudes/pendientes?idContenedor=2
```

### **Test 4: Servicio Logística Caído**
```bash
# Detener servicio-logistica
# Consultar estado de contenedor
GET http://localhost:8080/api-gestion/contenedores/2/estado

# Resultado esperado: 
# - No debe lanzar error 500
# - Debe devolver datos del contenedor
# - ubicacionActual: "SIN_SOLICITUD"
```

---

## 🔧 Configuración Adicional Necesaria

### **Variables de Entorno (Opcional)**

```bash
# En servicio-gestion
SERVICIO_LOGISTICA_URL=http://localhost:8082/api-logistica
```

### **application.yml - Producción**

Si los servicios están en hosts diferentes:

```yaml
# servicio-gestion/src/main/resources/application.yml
servicio:
  logistica:
    url: http://servicio-logistica:8082/api-logistica
```

---

## 📝 Notas Técnicas

### **Manejo de Errores**
- Si servicio-logistica no responde, `LogisticaClienteServicio` retorna lista vacía
- No lanza excepciones que rompan la respuesta
- Log de errores en consola para debugging

### **Performance**
- RestTemplate hace llamadas síncronas (blocking)
- Para alta concurrencia, considerar WebClient (asíncrono)
- Posible implementación de caché para reducir llamadas

### **Ubicación Actual - Lógica**
```java
if (tramo.estado == "INICIADO") → "EN_TRANSITO"
else if (tramo.estado == "ASIGNADO") → "EN_DEPOSITO"
else if (existe tramo finalizado) → "EN_DEPOSITO"
else → "PENDIENTE_ASIGNACION"
```

---

## 🚀 Próximos Pasos Sugeridos

1. **Pruebas de Integración**: Verificar endpoints con Postman/Bruno
2. **Manejo de Errores**: Agregar excepciones personalizadas
3. **Documentación Swagger**: Documentar nuevos endpoints
4. **Tests Unitarios**: Crear tests para servicios y controladores
5. **Logs Estructurados**: Mejorar logging con información de trazabilidad

---

**Estado**: ✅ **IMPLEMENTACIÓN COMPLETA**  
**Compilación**: ✅ **SIN ERRORES CRÍTICOS** (solo warnings menores de imports)  
**Listo para probar**: ✅ **SÍ**
