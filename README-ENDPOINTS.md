# 📘 Guía de Endpoints - Sistema de Gestión de Contenedores

## 🎯 Resumen de Cambios Realizados

### ✅ Problemas Detectados y Solucionados:

1. **Error 404 en endpoints de Flota**
   - **Problema:** Usaste `http://localhost:8080/api-flota/...` (puerto incorrecto)
   - **Solución:** El servicio de flota corre en el **puerto 8081**, no 8080
   - **URL Correcta:** `http://localhost:8081/api-flota/camiones`

2. **Error 500 en `/contenedores`**
   - **Problema:** Jackson no podía serializar proxies de Hibernate (Lazy Loading)
   - **Solución:** Agregué `@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})` a la entidad `Contenedor`
   - **Ahora funciona:** `GET http://localhost:8080/api-gestion/contenedores`

3. **Duplicación de `/api` en rutas**
   - **Problema:** Los controladores tenían `@RequestMapping("/api/...")` y el `application.yml` tenía `context-path: /api-gestion`
   - **Solución:** Eliminé `/api` de todos los `@RequestMapping` en los controladores
   - **Resultado:** URLs limpias como `http://localhost:8080/api-gestion/clientes`

---

## 🔌 URLs Correctas de los Servicios

### 🏢 Servicio GESTIÓN (Puerto 8080)
**Base URL:** `http://localhost:8080/api-gestion`

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/clientes` | Listar todos los clientes |
| GET | `/clientes/{id}` | Obtener cliente por ID |
| POST | `/clientes` | Crear nuevo cliente |
| PUT | `/clientes/{id}` | Actualizar cliente |
| DELETE | `/clientes/{id}` | Eliminar cliente |
| GET | `/contenedores` | Listar todos los contenedores |
| POST | `/contenedores` | Crear nuevo contenedor |
| GET | `/depositos` | Listar todos los depósitos |
| POST | `/depositos` | Crear nuevo depósito |
| GET | `/tarifas` | Listar todas las tarifas |
| POST | `/tarifas` | Crear nueva tarifa |

### 🚚 Servicio FLOTA (Puerto 8081)
**Base URL:** `http://localhost:8081/api-flota`

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/camiones` | Listar todos los camiones |
| GET | `/camiones/disponibles` | Listar camiones disponibles |
| GET | `/camiones/{patente}` | Obtener camión por patente |
| POST | `/camiones` | Crear nuevo camión |
| PATCH | `/camiones/{patente}/disponibilidad?disponible=true` | Cambiar disponibilidad |

### 📦 Servicio LOGÍSTICA (Puerto 8082)
**Base URL:** `http://localhost:8082/api-logistica`

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/solicitudes` | Listar todas las solicitudes |
| GET | `/solicitudes/{id}` | Obtener solicitud por ID |
| GET | `/solicitudes/estado/{estado}` | Filtrar por estado (pendiente, en_proceso, completada, cancelada) |
| POST | `/solicitudes` | Crear nueva solicitud |
| GET | `/rutas` | Listar todas las rutas |
| GET | `/tramos` | Listar todos los tramos |
| GET | `/configuraciones` | Listar configuraciones del sistema |

---

## ❓ Explicación de Datos NULL

### 1. **`costoFinal` y `tiempoReal` en Solicitudes**

**¿Por qué algunos tienen `null`?**
- ✅ **Con valores:** Solicitudes con estado `completada` (el transporte ya terminó)
- ❌ **NULL:** Solicitudes con estado `pendiente`, `en_proceso` o `cancelada`

**Ejemplo:**
```json
{
  "numeroSeguimiento": "SOL-2025-001",
  "estado": "pendiente",           // 👈 Todavía no arrancó
  "costoEstimado": 3775.0,          // ✅ Estimación inicial
  "tiempoEstimado": 1.5,            // ✅ Tiempo estimado
  "costoFinal": null,               // ❌ NULL porque no terminó
  "tiempoReal": null                // ❌ NULL porque no terminó
}
```

```json
{
  "numeroSeguimiento": "SOL-2025-006",
  "estado": "completada",           // 👈 Ya terminó
  "costoEstimado": 5092.0,
  "tiempoEstimado": 2.5,
  "costoFinal": 5150.0,            // ✅ Costo real al finalizar
  "tiempoReal": 2.7                // ✅ Tiempo real que tomó
}
```

**Flujo del ciclo de vida:**
1. **Pendiente** → `costoFinal` y `tiempoReal` = NULL
2. **En Proceso** → Sigue NULL (se va actualizando en tramos)
3. **Completada** → Se llenan con los valores reales
4. **Cancelada** → Quedan NULL (nunca se completó)

---

### 2. **`fechaFinReal` y `costoReal` en Tramos**

**¿Por qué algunos tienen `null`?**
- ✅ **Con valores:** Tramos con estado `completado`
- ❌ **NULL:** Tramos con estado `pendiente` o `en_curso`

**Ejemplo:**
```json
{
  "id": 2,
  "estado": "en_curso",            // 👈 El camión está viajando ahora
  "fechaInicioReal": "2025-11-05T14:11:36",  // ✅ Salió
  "fechaFinReal": null,            // ❌ Todavía no llegó
  "costoReal": null                // ❌ No se calculó aún
}
```

```json
{
  "id": 1,
  "estado": "completado",          // 👈 Ya llegó al destino
  "fechaInicioReal": "2025-11-05T13:11:36",
  "fechaFinReal": "2025-11-05T14:11:36",  // ✅ Llegó
  "costoReal": 1100.0              // ✅ Costo calculado
}
```

---

## 🗺️ Relación entre Entidades

### **Solicitud → Ruta → Tramos → Camiones**

```
SOLICITUD (id=4, SOL-2025-004)
    ↓
RUTA (id=1, idSolicitud=4)
    ↓
TRAMO 1 (id=1, idRuta=1, patente=AB123CD, estado=completado)
    ↓
TRAMO 2 (id=2, idRuta=1, patente=AB123CD, estado=en_curso)
    ↓
TRAMO 3 (id=15, idRuta=1, patente=AB123CD, estado=pendiente)
```

**Explicación:**
- Una **SOLICITUD** representa un pedido de transporte de un cliente
- Cada solicitud genera una **RUTA** (`idSolicitud` apunta a la solicitud)
- Una ruta se divide en **TRAMOS** (paradas intermedias)
- Cada tramo asigna un **CAMIÓN** específico (por patente)

**Ejemplo real de tu base de datos:**
```json
// SOLICITUD ID=4
{
  "id": 4,
  "numeroSeguimiento": "SOL-2025-012",
  "idContenedor": 21,
  "idCliente": 9,
  "estado": "pendiente"
}

// RUTA para esa solicitud
{
  "id": 1,
  "idSolicitud": 4  // 👈 Apunta a la solicitud ID=4
}

// TRAMOS de esa ruta
[
  {
    "id": 1,
    "idRuta": 1,  // 👈 Pertenece a la ruta ID=1
    "patenteCamion": "AB123CD",
    "origenDescripcion": "Av. Vélez Sarsfield 2345",
    "destinoDescripcion": "Av. Circunvalación",
    "estado": "completado"
  },
  {
    "id": 2,
    "idRuta": 1,  // 👈 Mismo ruta, siguiente tramo
    "patenteCamion": "AB123CD",
    "origenDescripcion": "Av. Circunvalación",
    "destinoDescripcion": "Zona Aeropuerto",
    "estado": "en_curso"  // 👈 Está en camino ahora
  }
]
```

---

## ⚙️ Configuraciones del Sistema

La tabla `configuraciones` almacena **parámetros globales** del sistema:

| Clave | Valor | Uso en el TP |
|-------|-------|--------------|
| `velocidad_promedio_camion` | 60 km/h | Cálculo de tiempo estimado de rutas |
| `tiempo_carga_descarga_min` | 30 min | Tiempo adicional por cada tramo |
| `margen_seguridad_tiempo` | 15% | Margen para imprevistos en estimaciones |
| `radio_busqueda_deposito` | 100 km | Para buscar depósitos cercanos |
| `costo_administrativo` | $500 | Costo fijo por solicitud |
| `iva_porcentaje` | 21% | IVA aplicado a tarifas |
| `email_notificaciones` | logistica@... | Email para notificaciones |
| `habilitar_notificaciones` | true | Activar/desactivar emails |
| `max_distancia_tramo` | 300 km | Distancia máxima por tramo |
| `tiempo_descanso_conductor` | 60 min | Descanso obligatorio cada X km |

**Ejemplo de uso:**
```java
// En tu servicio de cálculo de rutas
double velocidad = configuracionRepo.findByClave("velocidad_promedio_camion").getValor();
double tiempoEstimado = distanciaKm / velocidad;
```

---

## 📨 Ejemplos de Bodies para POST

### Crear Cliente
```json
{
  "nombre": "Test",
  "apellido": "Usuario",
  "email": "test@example.com",
  "telefono": "+54 351 000-0000"
}
```

### Crear Contenedor
```json
{
  "codigoIdentificacion": "CONT-TEST-002",
  "peso": 2500.0,
  "volumen": 33.0,
  "idCliente": 1
}
```

### Crear Depósito
```json
{
  "nombre": "Depósito Prueba",
  "direccion": "Calle Falsa 123",
  "latitud": -31.42,
  "longitud": -64.18,
  "costoEstadiaXdia": 120.0
}
```

### Crear Solicitud
```json
{
  "numeroSeguimiento": "TEST-SOL-003",
  "idContenedor": 1,
  "idCliente": 1,
  "origenDireccion": "Av. Colón 123",
  "origenLatitud": -31.4201,
  "origenLongitud": -64.1888,
  "destinoDireccion": "Ruta 9 Km 680",
  "destinoLatitud": -31.35,
  "destinoLongitud": -64.15,
  "estado": "pendiente",
  "costoEstimado": 3000.0,
  "tiempoEstimado": 2.0
}
```

---

## 🚀 Cómo Probar

### 1. Asegurate que los servicios estén corriendo:
```bash
# Terminal 1 - Gestión
cd servicio-gestion
mvn spring-boot:run

# Terminal 2 - Flota  
cd servicio-flota
mvn spring-boot:run

# Terminal 3 - Logística
cd servicio-logistica
mvn spring-boot:run
```

### 2. Verifica que arrancaron viendo estos logs:
```
✅ GestionHikariPool - Start completed.
✅ FlotaHikariPool - Start completed.
✅ LogisticaHikariPool - Start completed.
✅ Tomcat started on port 8080/8081/8082
```

### 3. Prueba los endpoints en Postman con las URLs correctas

---

## 🐛 Errores Comunes

### ❌ 404 Not Found
**Causa:** Puerto incorrecto o path mal escrito
**Solución:** 
- Gestión → Puerto 8080
- Flota → Puerto 8081 (no 8080!)
- Logística → Puerto 8082

### ❌ 500 Internal Server Error
**Causa:** Error en el servidor (revisar logs)
**Solución:** Ver terminal del servicio, buscar el stacktrace

### ❌ 400 Bad Request
**Causa:** JSON mal formado o campos requeridos faltantes
**Solución:** Verificar que el body tenga todos los campos obligatorios

---

## 📊 Datos de Prueba Incluidos

La base de datos ya tiene estos datos cargados (desde `gestion-contenedores.sql`):

- ✅ 15 Clientes
- ✅ 8 Depósitos
- ✅ 25 Contenedores
- ✅ 15 Tarifas
- ✅ 15 Camiones
- ✅ 15 Solicitudes
- ✅ 8 Rutas
- ✅ 20 Tramos
- ✅ 10 Configuraciones

**Total:** 131 registros listos para probar

---

## ✅ Checklist Final

- [x] Contraseña configurada en `application.yml` de los 3 servicios
- [x] Controladores actualizados (sin `/api` duplicado)
- [x] Error de serialización de Hibernate resuelto
- [x] Puertos correctos documentados
- [x] Endpoints probados y funcionando
- [x] Explicación de campos NULL
- [x] Relaciones entre entidades documentadas
- [x] Configuraciones del sistema explicadas

---

**🎉 ¡Todo listo para usar!**
