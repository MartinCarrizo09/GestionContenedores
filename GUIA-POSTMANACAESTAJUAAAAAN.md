# Guía de Uso de Postman - Sistema TPI Backend

## 📋 Tabla de Contenidos
1. [Introducción](#introducción)
2. [Instalación y Configuración](#instalación-y-configuración)
3. [Importar la Colección](#importar-la-colección)
4. [Secuencia de Ejemplo para Presentación](#secuencia-de-ejemplo-para-presentación)
5. [Endpoints Principales](#endpoints-principales)

---

## Introducción

Esta guía explica cómo usar la colección de Postman para interactuar con el sistema de gestión de contenedores TPI Backend. La colección incluye ejemplos de todos los endpoints principales organizados por funcionalidad.

---

## Instalación y Configuración

### Requisitos Previos

1. **Postman instalado**: Descarga desde [postman.com](https://www.postman.com/downloads/)
2. **Sistema TPI en ejecución**: 
   ```powershell
   # Ejecutar el script de inicio
   .\iniciar-sistema.ps1
   ```
   O manualmente:
   ```powershell
   docker-compose up -d
   ```

### Verificar que los Servicios Estén Activos

- **API Gateway**: http://localhost:8080
- **Keycloak**: http://localhost:9090
- Verifica con: `docker-compose ps`

---

## Importar la Colección

### Paso 1: Importar el Archivo

1. Abre Postman
2. Haz clic en **"Import"** (botón arriba a la izquierda)
3. Selecciona el archivo `TPI-Backend.postman_collection.json`
4. Haz clic en **"Import"**

### Paso 2: Configurar Variables

La colección usa variables para facilitar el mantenimiento:

1. Haz clic en la colección **"TPI Backend - Gestión de Contenedores"**
2. Ve a la pestaña **"Variables"**
3. Configura las siguientes variables (opcional, tienen valores por defecto):
   - `baseUrl`: `http://localhost:8080` (si el gateway corre en otro puerto)
   - `keycloakUrl`: `http://localhost:9090` (si Keycloak corre en otro puerto)

### Paso 3: Verificar la Autenticación

La colección usa **Bearer Token** automáticamente. El token se guarda en la variable `authToken` cuando ejecutas cualquier request de autenticación.

---

## Secuencia de Ejemplo para Presentación

Esta es una secuencia recomendada para demostrar el sistema en clase. **Ejecuta los requests en orden:**

### 📌 **Flujo Completo de Solicitud de Transporte**

#### 1. **Autenticación** (Obligatorio primero)
```
📁 1. Autenticación
   └─ Obtener Token - Operador
```
**¿Qué hace?**
- Obtiene un token JWT de Keycloak para el usuario `operador@tpi.com`
- El token se guarda automáticamente en `authToken`
- Este token se usará en todos los requests siguientes

**Valores esperados:**
- Status: `200 OK`
- Response: JSON con `access_token`

---

#### 2. **Gestión de Clientes** (Crear datos base)

##### 2.1. Listar Clientes
```
📁 2. Gestión de Clientes
   └─ Listar Clientes
```
**¿Qué hace?**
- Muestra todos los clientes existentes (puede estar vacío)

**Valores esperados:**
- Status: `200 OK`
- Response: Array de clientes `[]`

---

##### 2.2. Crear Cliente
```
📁 2. Gestión de Clientes
   └─ Crear Cliente
```
**¿Qué hace?**
- Crea un nuevo cliente en el sistema
- **IMPORTANTE**: Requiere rol OPERADOR (por eso necesitamos el token)

**Body del Request:**
```json
{
    "nombre": "María",
    "apellido": "González",
    "email": "maria.gonzalez@test.com",
    "telefono": "3517890123",
    "cuil": "27345678901"
}
```

**Valores esperados:**
- Status: `200 OK`
- Response: Cliente creado con `id` asignado

**Nota**: Guarda el `id` del cliente para usarlo después.

---

##### 2.3. Obtener Cliente por ID
```
📁 2. Gestión de Clientes
   └─ Obtener Cliente por ID
```
**¿Qué hace?**
- Obtiene los detalles del cliente recién creado (usa el `id` del paso anterior)

**Valores esperados:**
- Status: `200 OK`
- Response: Objeto cliente completo

---

#### 3. **Gestión de Contenedores**

##### 3.1. Crear Contenedor
```
📁 3. Gestión de Contenedores
   └─ Crear Contenedor
```
**¿Qué hace?**
- Crea un nuevo contenedor asociado al cliente creado anteriormente
- **IMPORTANTE**: Requiere rol OPERADOR

**Body del Request:**
```json
{
    "codigoIdentificacion": "CONT-002",
    "peso": 2000.0,
    "volumen": 3.0,
    "cliente": {
        "id": 1  // Usar el ID del cliente creado antes
    }
}
```

**Valores esperados:**
- Status: `200 OK`
- Response: Contenedor creado con `id` asignado

**Nota**: Guarda el `id` del contenedor y el `codigoIdentificacion`.

---

##### 3.2. Obtener Contenedor por Código
```
📁 3. Gestión de Contenedores
   └─ Obtener Contenedor por Código
```
**¿Qué hace?**
- Busca el contenedor por su código único `CONT-002`

**Valores esperados:**
- Status: `200 OK`
- Response: Objeto contenedor completo

---

#### 4. **Gestión de Tarifas** (Validar tarifa)

##### 4.1. Obtener Tarifa Aplicable
```
📁 5. Gestión de Tarifas
   └─ Obtener Tarifa Aplicable
```
**¿Qué hace?**
- Busca una tarifa que aplique para el peso y volumen del contenedor
- Parámetros en la URL: `?peso=2000&volumen=3.0`

**Valores esperados:**
- Status: `200 OK` (si existe tarifa aplicable)
- Status: `404 Not Found` (si no hay tarifa)
- Response: Objeto tarifa con `valor`, `rangoPesoMin/Max`, etc.

**Explicación para la clase:**
- El sistema busca tarifas que contengan el peso y volumen dentro de sus rangos
- Si no encuentra, la solicitud no puede proceder

---

#### 5. **Gestión de Solicitudes** (Flujo principal)

##### 5.1. Estimar Ruta (Opcional pero recomendado)
```
📁 4. Gestión de Solicitudes
   └─ Estimar Ruta
```
**¿Qué hace?**
- Calcula distancia, tiempo estimado y costo usando Google Maps API
- **NO requiere autenticación** (ejemplo de endpoint público)

**Body del Request:**
```json
{
    "origen": "Córdoba, Argentina",
    "destino": "Buenos Aires, Argentina",
    "pesoKg": 2000.0,
    "volumenM3": 3.0
}
```

**Valores esperados:**
- Status: `200 OK`
- Response: 
```json
{
    "distanciaKm": 700.5,
    "tiempoEstimadoHoras": 12.5,
    "costoEstimado": 15000.0,
    "tarifa": { ... }
}
```

**Explicación para la clase:**
- Integración con API externa (Google Maps)
- Validación de tarifa aplicable
- Cálculo automático de costos

---

##### 5.2. Crear Solicitud Básica
```
📁 4. Gestión de Solicitudes
   └─ Crear Solicitud Básica
```
**¿Qué hace?**
- Crea una solicitud de transporte usando cliente y contenedor existentes
- **IMPORTANTE**: Requiere rol OPERADOR

**Body del Request:**
```json
{
    "numeroSeguimiento": "SEG-2024-002",
    "origenDireccion": "Av. Colón 100",
    "origenLatitud": -31.4200,
    "origenLongitud": -64.1888,
    "destinoDireccion": "Bv. San Juan 500",
    "destinoLatitud": -31.4100,
    "destinoLongitud": -64.1700,
    "idCliente": 1,  // ID del cliente creado
    "idContenedor": 1,  // ID del contenedor creado
    "estado": "PENDIENTE"
}
```

**Valores esperados:**
- Status: `200 OK`
- Response: 
```json
{
    "id": 2,
    "numeroSeguimiento": "SEG-2024-002",
    "estado": "PENDIENTE",
    ...
}
```

**Nota**: Guarda el `numeroSeguimiento` para consultas posteriores.

---

##### 5.3. Obtener Solicitud por Número de Seguimiento
```
📁 4. Gestión de Solicitudes
   └─ Obtener Solicitud por Número de Seguimiento
```
**¿Qué hace?**
- Busca una solicitud por su número de seguimiento único
- Útil para clientes que quieren consultar el estado

**Valores esperados:**
- Status: `200 OK`
- Response: Objeto solicitud completo con estado actual

**Explicación para la clase:**
- Este es el endpoint que usan los clientes para rastrear sus envíos
- Similar a un sistema de tracking de paquetería

---

##### 5.4. Crear Solicitud Completa (Flujo Avanzado)
```
📁 4. Gestión de Solicitudes
   └─ Crear Solicitud Completa (con Cliente y Contenedor)
```
**¿Qué hace?**
- Crea cliente, contenedor y solicitud en una sola operación
- **Transacción atómica**: Si falla algo, todo se revierte
- **IMPORTANTE**: Requiere rol OPERADOR

**Body del Request:**
```json
{
    "numeroSeguimiento": "SEG-2024-003",
    "origenDireccion": "Origen A",
    "origenLatitud": -31.42,
    "origenLongitud": -64.19,
    "destinoDireccion": "Destino B",
    "destinoLatitud": -31.40,
    "destinoLongitud": -64.15,
    "clienteNombre": "Roberto",
    "clienteApellido": "Sánchez",
    "clienteEmail": "roberto@test.com",
    "clienteTelefono": "3518765432",
    "clienteCuil": "20678901234",
    "contenedorCodigo": "CONT-003",
    "contenedorPeso": 1800.0,
    "contenedorVolumen": 3.2
}
```

**Valores esperados:**
- Status: `200 OK`
- Response:
```json
{
    "idSolicitud": 3,
    "numeroSeguimiento": "SEG-2024-003",
    "clienteId": 3,
    "clienteCreado": true,
    "idContenedor": 3,
    "contenedorCreado": true,
    ...
}
```

**Explicación para la clase:**
- Ejemplo de **transacción distribuida** entre microservicios
- Si el cliente o contenedor no existen, se crean automáticamente
- Demuestra la coordinación entre `servicio-logistica` y `servicio-gestion`

---

##### 5.5. Listar Solicitudes
```
📁 4. Gestión de Solicitudes
   └─ Listar Solicitudes
```
**¿Qué hace?**
- Obtiene todas las solicitudes del sistema
- Puede incluir filtros (por estado, por cliente, etc.)

**Valores esperados:**
- Status: `200 OK`
- Response: Array de solicitudes `[]`

---

## Endpoints Principales

### 🔐 Autenticación
- **Obtener Token**: `POST /realms/tpi-backend/protocol/openid-connect/token`
  - Requiere: `grant_type=password`, `client_id`, `username`, `password`
  - Retorna: `access_token` (JWT)

### 👥 Clientes
- **Listar**: `GET /api/gestion/clientes`
- **Obtener por ID**: `GET /api/gestion/clientes/{id}`
- **Crear**: `POST /api/gestion/clientes` (Requiere OPERADOR)
- **Actualizar**: `PUT /api/gestion/clientes/{id}` (Requiere OPERADOR)
- **Eliminar**: `DELETE /api/gestion/clientes/{id}` (Requiere OPERADOR)

### 📦 Contenedores
- **Listar**: `GET /api/gestion/contenedores`
- **Por código**: `GET /api/gestion/contenedores/codigo/{codigo}`
- **Crear**: `POST /api/gestion/contenedores` (Requiere OPERADOR)

### 🚚 Solicitudes
- **Listar**: `GET /api/logistica/solicitudes`
- **Por seguimiento**: `GET /api/logistica/solicitudes/seguimiento/{numero}`
- **Crear básica**: `POST /api/logistica/solicitudes` (Requiere OPERADOR)
- **Crear completa**: `POST /api/logistica/solicitudes/completa` (Requiere OPERADOR)
- **Estimar ruta**: `POST /api/logistica/solicitudes/estimar-ruta`

### 💰 Tarifas
- **Listar**: `GET /api/gestion/tarifas`
- **Aplicable**: `GET /api/gestion/tarifas/aplicable?peso={peso}&volumen={volumen}`
- **Crear**: `POST /api/gestion/tarifas` (Requiere OPERADOR)

---

## 💡 Tips para la Presentación

1. **Empieza con autenticación**: Siempre obtén el token primero
2. **Muestra el flujo completo**: Cliente → Contenedor → Solicitud
3. **Destaca la integración**: Usa "Estimar Ruta" para mostrar Google Maps API
4. **Explica la transacción**: Usa "Crear Solicitud Completa" para mostrar coordinación
5. **Muestra manejo de errores**: Intenta crear un cliente duplicado (409 Conflict)
6. **Demuestra autorización**: Cambia el rol del token y muestra que algunos endpoints fallan (403)

---

## 🔧 Solución de Problemas

### Error 401 Unauthorized
- **Causa**: Token expirado o inválido
- **Solución**: Ejecuta de nuevo "Obtener Token"

### Error 403 Forbidden
- **Causa**: El rol del usuario no tiene permisos
- **Solución**: Usa el token del OPERADOR para endpoints de creación/modificación

### Error 404 Not Found
- **Causa**: Recurso no existe
- **Solución**: Verifica que los IDs usados existen en la base de datos

### Error 500 Internal Server Error
- **Causa**: Error en el servidor
- **Solución**: Verifica que todos los servicios estén corriendo con `docker-compose ps`

---

## 📚 Recursos Adicionales

- **Documentación API**: Swagger UI disponible en `http://localhost:8080/swagger-ui.html` (si está habilitado)
- **Health Check**: `GET http://localhost:8080/actuator/health` (si está habilitado)
- **Logs**: `docker-compose logs -f servicio-gestion` (para ver logs en tiempo real)

---

**¡Listo para presentar!** 🎉

Esta colección está diseñada para facilitar la demostración del sistema en clase, mostrando todas las funcionalidades principales de forma ordenada y clara.

