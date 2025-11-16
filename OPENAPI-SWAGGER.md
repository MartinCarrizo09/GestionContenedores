# 📚 Documentación OpenAPI/Swagger

Este documento describe cómo acceder a la documentación interactiva de las APIs de los microservicios.

---

## 🌐 URLs de Acceso

### **Servicio de Gestión** (Puerto 8081)
- **Swagger UI:** http://localhost:8081/api/gestion/swagger-ui.html
- **OpenAPI JSON:** http://localhost:8081/api/gestion/api-docs
- **A través del Gateway:** http://localhost:8080/api/gestion/swagger-ui.html

### **Servicio de Flota** (Puerto 8082)
- **Swagger UI:** http://localhost:8082/api/flota/swagger-ui.html
- **OpenAPI JSON:** http://localhost:8082/api/flota/api-docs
- **A través del Gateway:** http://localhost:8080/api/flota/swagger-ui.html

### **Servicio de Logística** (Puerto 8083)
- **Swagger UI:** http://localhost:8083/api/logistica/swagger-ui.html
- **OpenAPI JSON:** http://localhost:8083/api/logistica/api-docs
- **A través del Gateway:** http://localhost:8080/api/logistica/swagger-ui.html

---

## 🔐 Autenticación en Swagger

Todos los endpoints requieren autenticación JWT de Keycloak.

### **Pasos para autenticarte en Swagger:**

#### 1. Obtén un JWT Token de Keycloak

**Endpoint:**
```
POST http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token
```

**Headers:**
```
Content-Type: application/x-www-form-urlencoded
```

**Body (x-www-form-urlencoded):**
```
grant_type: password
client_id: tpi-client
username: operador1
password: password123
```

**Respuesta:**
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 300,
  "refresh_expires_in": 1800,
  "token_type": "Bearer"
}
```

#### 2. Configura el Token en Swagger UI

1. Abre cualquier Swagger UI (por ejemplo: http://localhost:8083/api/logistica/swagger-ui.html)
2. Click en el botón **"Authorize"** (candado verde arriba a la derecha)
3. En el campo **"Value"**, pega el `access_token` completo
4. Click en **"Authorize"**
5. Click en **"Close"**

¡Ahora puedes probar todos los endpoints desde Swagger! 🎉

---

## 👥 Usuarios de Prueba

### **CLIENTE**
```
Username: cliente1
Password: password123
Rol: CLIENTE
```

**Permisos:**
- Crear solicitudes completas
- Consultar estado de sus contenedores
- Ver seguimiento de sus solicitudes

---

### **OPERADOR**
```
Username: operador1
Password: password123
Rol: OPERADOR
```

**Permisos:**
- Acceso completo a todos los endpoints
- Gestión de clientes, contenedores, depósitos, tarifas
- Gestión de camiones
- Estimación y asignación de rutas
- Asignación de camiones a tramos

---

### **TRANSPORTISTA**
```
Username: transportista1
Password: password123
Rol: TRANSPORTISTA
```

**Permisos:**
- Ver tramos asignados a su camión
- Iniciar tramo
- Finalizar tramo
- Consultar información de su camión

---

## 📊 Estructura de los Microservicios

### **Servicio de Gestión** (8081)
- **Clientes:** CRUD de clientes
- **Contenedores:** CRUD de contenedores y consulta de estados
- **Depósitos:** CRUD de depósitos
- **Tarifas:** CRUD de tarifas y búsqueda de tarifas aplicables

### **Servicio de Flota** (8082)
- **Camiones:** CRUD de camiones
- **Disponibilidad:** Consulta de camiones disponibles y aptos
- **Capacidad:** Validación de peso y volumen

### **Servicio de Logística** (8083)
- **Solicitudes:** CRUD y gestión completa de solicitudes
- **Rutas:** CRUD de rutas y asignación a solicitudes
- **Tramos:** CRUD de tramos, asignación de camiones, inicio y finalización
- **Google Maps:** Cálculo de distancias y duraciones
- **Seguimiento:** Consulta de estado y seguimiento detallado

---

## 🚀 Ejemplos de Uso

### **Ejemplo 1: Crear Solicitud Completa (CLIENTE)**

**Endpoint:** `POST /api/logistica/solicitudes/completa`

**Request:**
```json
{
  "numeroSeguimiento": "CLI-2025-001",
  "origenDireccion": "Córdoba, Argentina",
  "origenLatitud": -31.4201,
  "origenLongitud": -64.1888,
  "destinoDireccion": "Buenos Aires, Argentina",
  "destinoLatitud": -34.6037,
  "destinoLongitud": -58.3816,
  "clienteNombre": "Carlos",
  "clienteApellido": "Cliente",
  "clienteEmail": "carlos@test.com",
  "clienteTelefono": "+54 341 5555555",
  "clienteCuil": "20-11111111-1",
  "codigoIdentificacion": "CONT-CLI-001",
  "peso": 3000.0,
  "volumen": 35.0
}
```

---

### **Ejemplo 2: Estimar Ruta (OPERADOR)**

**Endpoint:** `POST /api/logistica/solicitudes/estimar-ruta`

**Request:**
```json
{
  "origenLatitud": -31.4201,
  "origenLongitud": -64.1888,
  "destinoLatitud": -34.6037,
  "destinoLongitud": -58.3816,
  "pesoKg": 3000.0,
  "volumenM3": 35.0
}
```

---

### **Ejemplo 3: Iniciar Tramo (TRANSPORTISTA)**

**Endpoint:** `PATCH /api/logistica/tramos/{id}/iniciar`

**Sin body**. Registra la fecha/hora actual como inicio del tramo.

---

## 🔍 Características de OpenAPI

### ✅ **Implementado:**

- **Configuración de seguridad JWT** en los 3 microservicios
- **Descripción detallada** de cada servicio
- **Servidores múltiples** (directo + a través del Gateway)
- **Información de contacto** y versión
- **Esquema de autenticación Bearer** configurado
- **Acceso público** a la documentación (sin requerir autenticación)
- **Rutas relativas** correctamente configuradas con context-path

### 📝 **Endpoints Documentados:**

**Total: 50+ endpoints** distribuidos en:
- Gestión: Clientes, Contenedores, Depósitos, Tarifas
- Flota: Camiones
- Logística: Solicitudes, Rutas, Tramos, Google Maps, Configuraciones

---

## 🛠️ Verificación

Para verificar que Swagger está funcionando correctamente:

```bash
# Verifica que los servicios estén UP
docker ps

# Accede a cualquier Swagger UI
# Ejemplo: http://localhost:8083/api/logistica/swagger-ui.html

# Debería mostrar:
# ✅ Lista de endpoints organizados por categorías
# ✅ Botón "Authorize" para configurar JWT
# ✅ Posibilidad de probar cada endpoint directamente
```

---

## 📌 Notas Importantes

1. **Autenticación obligatoria:** Todos los endpoints (excepto la documentación) requieren JWT válido
2. **Tokens expiran:** Por defecto, los tokens de Keycloak expiran en 5 minutos (300 segundos)
3. **Gateway centralizado:** Puedes acceder a todos los servicios a través de `http://localhost:8080`
4. **Roles estrictos:** Los endpoints validan roles específicos (CLIENTE, OPERADOR, TRANSPORTISTA)
5. **CORS configurado:** Swagger UI funciona correctamente desde el navegador

---

## 🆘 Troubleshooting

### **Problema: Swagger UI no carga**
**Solución:** Verifica que el servicio esté corriendo (`docker ps`) y accede directamente al puerto del servicio.

### **Problema: "401 Unauthorized" al probar endpoint**
**Solución:** Asegúrate de haber configurado el token JWT en el botón "Authorize".

### **Problema: "403 Forbidden"**
**Solución:** El usuario no tiene el rol necesario. Usa un token con el rol correcto (CLIENTE, OPERADOR o TRANSPORTISTA).

### **Problema: Token expirado**
**Solución:** Obtén un nuevo token desde Keycloak y vuelve a configurarlo en Swagger.

---

## 📖 Referencias

- **OpenAPI Specification:** https://swagger.io/specification/
- **Springdoc OpenAPI:** https://springdoc.org/
- **Keycloak Documentation:** https://www.keycloak.org/documentation
