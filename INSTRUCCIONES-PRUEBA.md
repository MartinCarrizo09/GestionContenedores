# 🧪 INSTRUCCIONES PARA PROBAR EL SISTEMA

## 📋 PASO 1: Cargar los datos en Supabase

1. **Abrir Supabase Dashboard:**
   - Ve a: https://supabase.com/dashboard
   - Selecciona tu proyecto

2. **Abrir SQL Editor:**
   - En el menú lateral, haz clic en "SQL Editor"
   - Clic en "New query"

3. **Ejecutar el script:**
   - Abre el archivo `gestion-contenedores.sql` de este proyecto
   - Copia TODO el contenido (Ctrl+A, Ctrl+C)
   - Pega en el SQL Editor de Supabase
   - Clic en "Run" o presiona Ctrl+Enter

4. **Verificar que se crearon los datos:**
   ```sql
   -- Copia esta query de verificación:
   SELECT 
       'Clientes' as entidad, COUNT(*) as total FROM gestion.clientes
   UNION ALL
   SELECT 'Depósitos', COUNT(*) FROM gestion.depositos
   UNION ALL
   SELECT 'Contenedores', COUNT(*) FROM gestion.contenedores
   UNION ALL
   SELECT 'Tarifas', COUNT(*) FROM gestion.tarifas
   UNION ALL
   SELECT 'Camiones', COUNT(*) FROM flota.camiones
   UNION ALL
   SELECT 'Solicitudes', COUNT(*) FROM logistica.solicitudes
   UNION ALL
   SELECT 'Rutas', COUNT(*) FROM logistica.rutas
   UNION ALL
   SELECT 'Tramos', COUNT(*) FROM logistica.tramos
   ORDER BY entidad;
   ```

   **Resultado esperado:**
   - Camiones: 15
   - Clientes: 15
   - Contenedores: 25
   - Depósitos: 8
   - Rutas: 8
   - Solicitudes: 15
   - Tarifas: 15
   - Tramos: 20

---

## 🚀 PASO 2: Iniciar los microservicios

### Opción A: Usando Maven Wrapper (si existe)

**Terminal 1 - Servicio Gestión:**
```powershell
cd servicio-gestion
.\mvnw.cmd spring-boot:run
```

**Terminal 2 - Servicio Flota:**
```powershell
cd servicio-flota
.\mvnw.cmd spring-boot:run
```

**Terminal 3 - Servicio Logística:**
```powershell
cd servicio-logistica
.\mvnw.cmd spring-boot:run
```

### Opción B: Usando Maven instalado

**Terminal 1 - Servicio Gestión:**
```powershell
cd servicio-gestion
mvn spring-boot:run
```

**Terminal 2 - Servicio Flota:**
```powershell
cd servicio-flota
mvn spring-boot:run
```

**Terminal 3 - Servicio Logística:**
```powershell
cd servicio-logistica
mvn spring-boot:run
```

### ✅ Verificar que iniciaron correctamente

Los servicios deberían estar escuchando en:
- **Servicio Gestión:** http://localhost:8080
- **Servicio Flota:** http://localhost:8081
- **Servicio Logística:** http://localhost:8082

Busca en los logs mensajes como:
```
HikariPool-1 - Start completed.
Started [NombreServicio]Application in X.XXX seconds
```

---

## 🧪 PASO 3: Probar los endpoints

### 1️⃣ **Probar Servicio de Gestión (Puerto 8080)**

#### Listar todos los clientes:
```powershell
curl http://localhost:8080/api/clientes
```

**Resultado esperado:** JSON con 15 clientes

#### Obtener un cliente específico:
```powershell
curl http://localhost:8080/api/clientes/1
```

#### Listar contenedores:
```powershell
curl http://localhost:8080/api/contenedores
```

**Resultado esperado:** JSON con 25 contenedores

#### Listar depósitos:
```powershell
curl http://localhost:8080/api/depositos
```

**Resultado esperado:** JSON con 8 depósitos

#### Listar tarifas:
```powershell
curl http://localhost:8080/api/tarifas
```

**Resultado esperado:** JSON con 15 tarifas

---

### 2️⃣ **Probar Servicio de Flota (Puerto 8081)**

#### Listar todos los camiones:
```powershell
curl http://localhost:8081/api/camiones
```

**Resultado esperado:** JSON con 15 camiones

#### Listar solo camiones disponibles:
```powershell
curl http://localhost:8081/api/camiones/disponibles
```

**Resultado esperado:** JSON con ~13 camiones (los que tienen `disponible: true`)

#### Obtener un camión por patente:
```powershell
curl http://localhost:8081/api/camiones/AB123CD
```

---

### 3️⃣ **Probar Servicio de Logística (Puerto 8082)**

#### Listar todas las solicitudes:
```powershell
curl http://localhost:8082/api/solicitudes
```

**Resultado esperado:** JSON con 15 solicitudes

#### Filtrar solicitudes por estado:
```powershell
# Solicitudes pendientes
curl http://localhost:8082/api/solicitudes/estado/pendiente

# Solicitudes en proceso
curl http://localhost:8082/api/solicitudes/estado/en_proceso

# Solicitudes completadas
curl http://localhost:8082/api/solicitudes/estado/completada
```

#### Listar rutas:
```powershell
curl http://localhost:8082/api/rutas
```

**Resultado esperado:** JSON con 8 rutas

#### Listar tramos:
```powershell
curl http://localhost:8082/api/tramos
```

**Resultado esperado:** JSON con 20 tramos

---

## 🎯 PASO 4: Pruebas de integración

### Buscar contenedores de un cliente específico:
```powershell
# Ver contenedores del cliente 1
curl http://localhost:8080/api/contenedores/cliente/1
```

### Ver solicitudes de un cliente:
```powershell
# Ver solicitudes del cliente 1
curl http://localhost:8082/api/solicitudes/cliente/1
```

### Ver tramos de una ruta:
```powershell
# Ver tramos de la ruta 1
curl http://localhost:8082/api/rutas/1/tramos
```

---

## 🐛 Troubleshooting

### Error: "Connection refused" o "Cannot connect to database"

**Solución:**
1. Verifica que la contraseña en las variables de entorno esté correcta:
   ```powershell
   $env:SUPABASE_DB_PASSWORD = "Salchicha123"
   ```

2. O actualiza `application.yml` con la contraseña directamente (solo para desarrollo):
   ```yaml
   spring:
     datasource:
       password: Salchicha123
   ```

### Error: "Table doesn't exist"

**Solución:**
- Ejecuta nuevamente el script `gestion-contenedores.sql` en Supabase
- Verifica que los schemas `gestion`, `flota`, y `logistica` existan

### Error: "Port already in use"

**Solución:**
- Detén los servicios anteriores con Ctrl+C
- O cambia el puerto en `application.properties`:
   ```properties
   server.port=8083
   ```

---

## ✨ Datos de ejemplo disponibles

### Clientes destacados:
- **ID 1:** Juan Carlos Rodríguez (jrodriguez@logisticadelsur.com)
- **ID 2:** María Elena Martínez (mmartinez@transportesunidos.com)
- **ID 4:** Ana Paula Fernández (afernandez@districentral.com)

### Contenedores interesantes:
- **CONT-20-001:** Contenedor estándar 20 pies (cliente 1)
- **CONT-40-001:** Contenedor estándar 40 pies (cliente 1)
- **REEF-20-001:** Contenedor refrigerado (cliente 4)
- **TANK-20-001:** Contenedor tanque (cliente 5)

### Camiones disponibles:
- **AB123CD:** Carlos Rodríguez - 5000kg/30m³
- **EF456GH:** Laura Martínez - 8000kg/45m³
- **IJ789KL:** Roberto Sánchez - 10000kg/60m³

### Solicitudes activas:
- **SOL-2025-004:** En proceso (Refrigerado)
- **SOL-2025-005:** En proceso (Tanque)
- **SOL-2025-014:** En proceso (Contenedor estándar)

---

## 📊 Query útil para ver el dashboard completo

Ejecuta esto en Supabase para ver un resumen:

```sql
-- Resumen del sistema
SELECT 
    s.numero_seguimiento,
    s.estado,
    c.nombre || ' ' || c.apellido as cliente,
    cont.codigo_identificacion as contenedor,
    s.origen_direccion,
    s.destino_direccion,
    s.costo_estimado,
    s.costo_final
FROM logistica.solicitudes s
JOIN gestion.clientes c ON s.id_cliente = c.id
JOIN gestion.contenedores cont ON s.id_contenedor = cont.id
ORDER BY s.id DESC;
```

---

## 🎉 ¡Listo!

Si todo funcionó correctamente, deberías poder:
- ✅ Ver los 131 registros en la base de datos
- ✅ Los 3 servicios corriendo sin errores
- ✅ Hacer peticiones GET a todos los endpoints
- ✅ Ver las relaciones entre entidades funcionando

**¡Tu sistema de gestión de contenedores está funcionando!** 🚚📦
