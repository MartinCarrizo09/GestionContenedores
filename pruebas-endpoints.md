El error 404 significa que el endpoint no existe. El problema es que el `context-path` está configurado como `/api-gestion` pero necesitamos verificar cómo están definidos los controladores. Déjame revisar: 

Searched text for `@RestController|@RequestMapping` (`**/servicio-gestion/src/main/java/**/*.java`), 8 results

Searched text for `@RestController|@RequestMapping` (`**/servicio-flota/src/main/java/**/*.java`), 2 results

Searched text for `@RestController|@RequestMapping` (`**/servicio-logistica/src/main/java/**/*.java`), 10 results

¡Perfecto! Ya veo el problema. Los controladores tienen `@RequestMapping("/api/...")` pero el application.yml tiene `context-path: /api-gestion`, entonces la URL completa queda duplicada.

**Las URLs correctas son:**

**Servicio Gestión (Puerto 8080):**
- `http://localhost:8080/api-gestion/api/clientes` ❌ (duplicado)
  
**Debería ser:**
- `http://localhost:8080/api-gestion/clientes` (sin el `/api`)

Tengo que quitar el `/api` de los `@RequestMapping` de los controladores. Voy a arreglarlo: 

Read [](file:///c%3A/Users/Martin/Desktop/GestionContenedores/servicio-gestion/src/main/java/com/tpi/gestion/controlador/ClienteControlador.java)

Read [](file:///c%3A/Users/Martin/Desktop/GestionContenedores/servicio-flota/src/main/java/com/tpi/flota/controlador/CamionControlador.java)

Read [](file:///c%3A/Users/Martin/Desktop/GestionContenedores/servicio-logistica/src/main/java/com/tpi/logistica/controlador/SolicitudControlador.java)

Ahora veo el problema. Los controladores tienen `/api/...` pero el context-path ya tiene `/api-gestion`, `/api-flota`, `/api-logistica`. Entonces hay dos opciones:

**Opción 1:** Quitar el `/api` de los `@RequestMapping`
**Opción 2:** Quitar el `context-path` del application.yml

Voy a elegir la **Opción 1** (quitar `/api` de los controladores) porque es más limpio tener el context-path separado por microservicio. 

Using "Replace String in File"


```

```


Using "Replace String in File"


```

```


Using "Replace String in File"


```

```


Using "Replace String in File"


```

```


Using "Replace String in File"


```

```


Using "Replace String in File"


```

```


Using "Replace String in File"


```

```


Using "Replace String in File"


```

```


Using "Replace String in File"


```

```
✅ Perfecto! Ahora reiniciá los servicios y probá con estas URLs correctas:

## 📋 URLs CORRECTAS para Postman:

### **Servicio Gestión (Puerto 8080):**
```
GET  http://localhost:8080/api-gestion/clientes
GET  http://localhost:8080/api-gestion/clientes/1
POST http://localhost:8080/api-gestion/clientes
GET  http://localhost:8080/api-gestion/contenedores
GET  http://localhost:8080/api-gestion/depositos
GET  http://localhost:8080/api-gestion/tarifas
```

### **Servicio Flota (Puerto 8081):**
```
GET  http://localhost:8080/api-flota/camiones
GET  http://localhost:8080/api-flota/camiones/disponibles
GET  http://localhost:8080/api-flota/camiones/AB123CD
POST http://localhost:8080/api-flota/camiones
```

### **Servicio Logística (Puerto 8082):**
```
GET  http://localhost:8082/api-logistica/solicitudes
GET  http://localhost:8082/api-logistica/solicitudes/1
GET  http://localhost:8082/api-logistica/rutas
GET  http://localhost:8082/api-logistica/tramos
GET  http://localhost:8082/api-logistica/configuraciones
```

**Reiniciá los 3 servicios** (Ctrl+C en cada terminal y volvé a correr `mvn spring-boot:run`) y probá de nuevo! 🚀

Made changes.