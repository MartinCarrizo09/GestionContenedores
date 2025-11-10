# 📦 Nuevo Endpoint: Crear Solicitud Completa

## 🎯 Objetivo

Este endpoint implementa el requerimiento de **registrar una nueva solicitud de transporte** que incluye:
- ✅ Creación del contenedor con su identificación única
- ✅ Registro del cliente si no existe previamente
- ✅ Estado inicial de la solicitud en "BORRADOR"

## 🔌 Endpoint

```
POST http://localhost:8082/api-logistica/solicitudes/completa
```

## 📝 Casos de Uso

### **Caso 1: Cliente NUEVO + Contenedor NUEVO**
Crea automáticamente tanto el cliente como el contenedor.

```json
{
  "numeroSeguimiento": "TRK-2025-001",
  "origenDireccion": "Av. Corrientes 1234, CABA",
  "origenLatitud": -34.603722,
  "origenLongitud": -58.381592,
  "destinoDireccion": "Av. Santa Fe 5678, CABA",
  "destinoLatitud": -34.594722,
  "destinoLongitud": -58.381592,
  
  "clienteNombre": "Juan",
  "clienteApellido": "Pérez",
  "clienteEmail": "juan.perez@email.com",
  "clienteTelefono": "+54-11-4567-8900",
  "clienteCuil": "20-12345678-9",
  
  "codigoIdentificacion": "CNT-001-2025",
  "peso": 2500.0,
  "volumen": 33.0
}
```

**Respuesta:**
```json
{
  "idSolicitud": 1,
  "numeroSeguimiento": "TRK-2025-001",
  "estado": "BORRADOR",
  "idCliente": 1,
  "clienteCreado": true,
  "idContenedor": 1,
  "codigoIdentificacion": "CNT-001-2025",
  "contenedorCreado": true,
  "origenDireccion": "Av. Corrientes 1234, CABA",
  "destinoDireccion": "Av. Santa Fe 5678, CABA",
  "mensaje": "✅ Solicitud creada exitosamente. Cliente creado automáticamente. Contenedor creado automáticamente."
}
```

---

### **Caso 2: Cliente EXISTENTE + Contenedor NUEVO**
Usa un cliente existente y crea el contenedor automáticamente.

```json
{
  "numeroSeguimiento": "TRK-2025-002",
  "origenDireccion": "Av. Belgrano 3000, CABA",
  "origenLatitud": -34.612722,
  "origenLongitud": -58.371592,
  "destinoDireccion": "Av. Libertador 7000, CABA",
  "destinoLatitud": -34.561722,
  "destinoLongitud": -58.451592,
  
  "idCliente": 1,
  
  "codigoIdentificacion": "CNT-002-2025",
  "peso": 3000.0,
  "volumen": 40.0
}
```

**Respuesta:**
```json
{
  "idSolicitud": 2,
  "numeroSeguimiento": "TRK-2025-002",
  "estado": "BORRADOR",
  "idCliente": 1,
  "clienteCreado": false,
  "idContenedor": 2,
  "codigoIdentificacion": "CNT-002-2025",
  "contenedorCreado": true,
  "origenDireccion": "Av. Belgrano 3000, CABA",
  "destinoDireccion": "Av. Libertador 7000, CABA",
  "mensaje": "✅ Solicitud creada exitosamente. Cliente existente utilizado. Contenedor creado automáticamente."
}
```

---

### **Caso 3: Cliente EXISTENTE + Contenedor EXISTENTE**
Usa tanto cliente como contenedor existentes.

```json
{
  "numeroSeguimiento": "TRK-2025-003",
  "origenDireccion": "Av. Rivadavia 5000, CABA",
  "origenLatitud": -34.615722,
  "origenLongitud": -58.441592,
  "destinoDireccion": "Av. Las Heras 3000, CABA",
  "destinoLatitud": -34.587722,
  "destinoLongitud": -58.401592,
  
  "idCliente": 1,
  "idContenedor": 2
}
```

**Respuesta:**
```json
{
  "idSolicitud": 3,
  "numeroSeguimiento": "TRK-2025-003",
  "estado": "BORRADOR",
  "idCliente": 1,
  "clienteCreado": false,
  "idContenedor": 2,
  "codigoIdentificacion": null,
  "contenedorCreado": false,
  "origenDireccion": "Av. Rivadavia 5000, CABA",
  "destinoDireccion": "Av. Las Heras 3000, CABA",
  "mensaje": "✅ Solicitud creada exitosamente. Cliente existente utilizado. Contenedor existente utilizado."
}
```

---

## ✅ Validaciones

### **Campos Obligatorios:**
- `numeroSeguimiento` (único en el sistema)
- `origenDireccion`
- `origenLatitud`
- `origenLongitud`
- `destinoDireccion`
- `destinoLatitud`
- `destinoLongitud`

### **Validaciones de Cliente:**
- Si no se proporciona `idCliente`, debe proporcionar:
  - `clienteNombre`
  - `clienteApellido`
  - `clienteEmail` (debe ser válido)
  
### **Validaciones de Contenedor:**
- Si no se proporciona `idContenedor`, debe proporcionar:
  - `codigoIdentificacion` (único en el sistema)
  - `peso` (> 0)
  - `volumen` (> 0)

---

## 🔄 Flujo de Creación

```
┌─────────────────────────────────────────────────────────┐
│  POST /solicitudes/completa                            │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────┐
        │  ¿Se proporciona         │
        │  idCliente?              │
        └───────────────────────────┘
                │           │
             SÍ │           │ NO
                │           │
                ▼           ▼
        ┌──────────┐  ┌──────────────────┐
        │ Validar  │  │ Crear Cliente    │
        │ Cliente  │  │ en servicio-     │
        │          │  │ gestion          │
        └──────────┘  └──────────────────┘
                │           │
                └─────┬─────┘
                      ▼
        ┌───────────────────────────┐
        │  ¿Se proporciona         │
        │  idContenedor?           │
        └───────────────────────────┘
                │           │
             SÍ │           │ NO
                │           │
                ▼           ▼
        ┌──────────┐  ┌──────────────────┐
        │ Validar  │  │ Crear Contenedor │
        │ Contene- │  │ en servicio-     │
        │ dor      │  │ gestion          │
        └──────────┘  └──────────────────┘
                │           │
                └─────┬─────┘
                      ▼
        ┌───────────────────────────┐
        │  Crear Solicitud con     │
        │  estado = "BORRADOR"     │
        └───────────────────────────┘
                      │
                      ▼
        ┌───────────────────────────┐
        │  Retornar Response con   │
        │  IDs generados           │
        └───────────────────────────┘
```

---

## 🚦 Estados de la Solicitud

| Estado | Descripción | ¿Cuándo se establece? |
|--------|-------------|----------------------|
| **BORRADOR** | Solicitud creada pero sin ruta asignada | Al crear la solicitud (inicial) |
| **PROGRAMADA** | Ruta y tramos asignados | Al asignar ruta con `POST /solicitudes/{id}/asignar-ruta` |
| **EN_TRANSITO** | Transporte en curso | Durante la ejecución de tramos |
| **ENTREGADA** | Entrega completada | Al finalizar el último tramo |

---

## 🧪 Prueba con cURL

### Cliente + Contenedor nuevos:
```bash
curl -X POST http://localhost:8082/api-logistica/solicitudes/completa \
  -H "Content-Type: application/json" \
  -d '{
    "numeroSeguimiento": "TRK-2025-001",
    "origenDireccion": "Av. Corrientes 1234, CABA",
    "origenLatitud": -34.603722,
    "origenLongitud": -58.381592,
    "destinoDireccion": "Av. Santa Fe 5678, CABA",
    "destinoLatitud": -34.594722,
    "destinoLongitud": -58.381592,
    "clienteNombre": "Juan",
    "clienteApellido": "Pérez",
    "clienteEmail": "juan.perez@email.com",
    "clienteTelefono": "+54-11-4567-8900",
    "codigoIdentificacion": "CNT-001-2025",
    "peso": 2500.0,
    "volumen": 33.0
  }'
```

### Con cliente existente:
```bash
curl -X POST http://localhost:8082/api-logistica/solicitudes/completa \
  -H "Content-Type: application/json" \
  -d '{
    "numeroSeguimiento": "TRK-2025-002",
    "origenDireccion": "Av. Belgrano 3000, CABA",
    "origenLatitud": -34.612722,
    "origenLongitud": -58.371592,
    "destinoDireccion": "Av. Libertador 7000, CABA",
    "destinoLatitud": -34.561722,
    "destinoLongitud": -58.451592,
    "idCliente": 1,
    "codigoIdentificacion": "CNT-002-2025",
    "peso": 3000.0,
    "volumen": 40.0
  }'
```

---

## ❌ Errores Comunes

### Error 400: Número de seguimiento duplicado
```json
{
  "error": "Ya existe una solicitud con ese número de seguimiento"
}
```
**Solución:** Use un número de seguimiento único.

### Error 400: Código de contenedor duplicado
```json
{
  "error": "Ya existe un contenedor con ese código de identificación"
}
```
**Solución:** Use un código de identificación único para el contenedor.

### Error 400: Cliente no existe
```json
{
  "error": "El cliente con ID X no existe"
}
```
**Solución:** Verifique el ID del cliente o proporcione datos para crear uno nuevo.

### Error 400: Datos incompletos
```json
{
  "error": "Debe proporcionar el ID del cliente o los datos completos (nombre, apellido, email) para crear uno nuevo"
}
```
**Solución:** Proporcione `idCliente` o los datos completos del cliente.

---

## 📊 Diferencias con el Endpoint Original

| Característica | `POST /solicitudes` | `POST /solicitudes/completa` |
|----------------|---------------------|------------------------------|
| **Cliente** | Debe existir previamente o se auto-genera con datos básicos | Se crea con datos completos o se usa existente |
| **Contenedor** | Debe existir previamente | Se crea automáticamente con los datos proporcionados |
| **Request** | Objeto `Solicitud` con IDs | Objeto `SolicitudCompletaRequest` con datos completos |
| **Response** | Objeto `Solicitud` | Objeto `SolicitudCompletaResponse` con información de creación |
| **Validaciones** | Valida que existan cliente y contenedor | Crea automáticamente si no existen |

---

## 🎓 Uso Recomendado

**Use `POST /solicitudes/completa` cuando:**
- Es la primera vez que el cliente hace una solicitud
- Necesita crear un nuevo contenedor para la solicitud
- Quiere un flujo simplificado en una sola llamada
- Necesita información detallada sobre qué se creó

**Use `POST /solicitudes` cuando:**
- Tanto cliente como contenedor ya existen
- Prefiere un control más granular del proceso
- Ya tiene los IDs de cliente y contenedor

---

## ✅ Checklist de Implementación

- [x] DTO `SolicitudCompletaRequest` creado
- [x] DTO `SolicitudCompletaResponse` creado
- [x] Método `crearSolicitudCompleta()` en `SolicitudServicio`
- [x] Método `crearCliente()` privado
- [x] Método `crearContenedor()` privado
- [x] Endpoint `POST /solicitudes/completa` en controlador
- [x] Validaciones de datos obligatorios
- [x] Manejo de errores
- [x] Documentación completa

---

## 🔗 Endpoints Relacionados

- `GET /solicitudes/{id}` - Consultar solicitud por ID
- `GET /solicitudes/seguimiento/{numeroSeguimiento}` - Buscar por número de seguimiento
- `POST /solicitudes/{id}/asignar-ruta` - Asignar ruta (cambia estado a PROGRAMADA)
- `GET /contenedores/{id}/estado` - Consultar estado del contenedor
- `GET /solicitudes/pendientes` - Listar solicitudes no entregadas

---

**Última actualización:** 10 de noviembre de 2025
