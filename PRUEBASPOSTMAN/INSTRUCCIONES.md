# 🚀 Guía para Poblar la Base de Datos con Postman Runner

## 📁 Archivos Incluidos

- `clientes.csv` - 50 clientes listos para importar
- `contenedores.csv` - 200 contenedores con diferentes tipos
- `GestionContenedores-Seed.postman_collection.json` - Colección de Postman

## 🎯 Pasos para Usar

### 1️⃣ Importar la Colección en Postman

1. Abre Postman
2. Click en **Import** (arriba a la izquierda)
3. Arrastra el archivo `GestionContenedores-Seed.postman_collection.json`
4. Click en **Import**

### 2️⃣ Crear un Environment (Opcional pero Recomendado)

1. Click en **Environments** en la barra lateral
2. Click en **+** para crear nuevo environment
3. Nombre: `GestionContenedores-Local`
4. Agrega estas variables:
   - `base_gestion` = `http://localhost:8080/api-gestion`
   - `base_flota` = `http://localhost:8081/api-flota`
   - `base_logistica` = `http://localhost:8082/api-logistica`
5. Click en **Save**
6. Selecciona el environment en el dropdown (arriba a la derecha)

### 3️⃣ Crear 50 Clientes

1. En Postman, selecciona la colección **GestionContenedores - Seed Database**
2. Click derecho en **"1 - Crear Clientes (50)"**
3. Selecciona **Run**
4. En el Runner:
   - **Select File** → Selecciona `clientes.csv`
   - **Iterations:** 50 (automático según filas del CSV)
   - Click en **Run GestionContenedores - Seed Database**
5. Espera a que termine (verás 50/50 passed si todo está bien)

**Resultado esperado:**
```
✅ 50 clientes creados
✅ IDs guardados en variable de entorno 'clientIds'
```

### 4️⃣ Obtener IDs de Clientes (Opcional)

Si por alguna razón necesitás recargar los IDs:

1. Click en **"2 - Obtener IDs de Clientes"**
2. Click en **Send**
3. Verás en la consola: `✅ Total clientes obtenidos: XX`

### 5️⃣ Crear 200 Contenedores

1. Click derecho en **"3 - Crear Contenedores (200)"**
2. Selecciona **Run**
3. En el Runner:
   - **Select File** → Selecciona `contenedores.csv`
   - **Iterations:** 200
   - Click en **Run**
4. Espera (puede tardar 1-2 minutos)

**Nota Importante:** 
- El script asigna automáticamente un cliente aleatorio a cada contenedor
- Los IDs de clientes se toman de la variable `clientIds` guardada en el paso 3

**Resultado esperado:**
```
✅ 200 contenedores creados
✅ IDs guardados en variable de entorno 'contenedorIds'
```

### 6️⃣ Verificar Totales

1. Click en **"5 - Verificar Totales"**
2. Click en **Send**
3. Revisa la consola de Postman:

```
📊 RESUMEN:
   Clientes creados: 65 (15 originales + 50 nuevos)
   IDs de clientes guardados: 65
   IDs de contenedores guardados: 225 (25 originales + 200 nuevos)
```

---

## 🔍 Verificar en Supabase

Abre el SQL Editor de Supabase y ejecuta:

```sql
-- Ver totales por tabla
SELECT 
    'Clientes' as tabla, COUNT(*) as total FROM gestion.clientes
UNION ALL
SELECT 'Contenedores', COUNT(*) FROM gestion.contenedores
UNION ALL
SELECT 'Depósitos', COUNT(*) FROM gestion.depositos
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
ORDER BY tabla;
```

**Resultado esperado después de correr todo:**
```
Camiones:      15
Clientes:      65  ← 15 originales + 50 nuevos
Contenedores:  225 ← 25 originales + 200 nuevos
Depósitos:     8
Rutas:         8
Solicitudes:   15
Tarifas:       15
Tramos:        20
```

---

## 🎨 Tipos de Contenedores en el CSV

El archivo `contenedores.csv` incluye diferentes tipos:

- **CONT-STD-20-XXX:** Contenedores estándar de 20 pies (~2200kg, ~33m³)
- **CONT-STD-40-XXX:** Contenedores estándar de 40 pies (~3900kg, ~68m³)
- **CONT-HC-40-XXX:** Contenedores High Cube de 40 pies (~4100kg, ~76m³)
- **REEF-20-XXX:** Contenedores refrigerados de 20 pies (~2850kg, ~29m³)
- **REEF-40-XXX:** Contenedores refrigerados de 40 pies (~4550kg, ~60m³)
- **TANK-20-XXX:** Contenedores tanque de 20 pies (~3200kg, ~26m³)
- **TANK-40-XXX:** Contenedores tanque de 40 pies (~5150kg, ~54m³)

---

## 🚨 Solución de Problemas

### Error: "No hay clientes disponibles"
**Causa:** No se ejecutó el paso "Crear Clientes" o "Obtener IDs de Clientes"
**Solución:** Ejecuta primero el paso 3 (Crear Clientes) y luego el paso 2 (Obtener IDs)

### Error: 500 Internal Server Error
**Causa:** Puede ser problema de serialización de Hibernate
**Solución:** Verifica que `Contenedor.java` tenga `@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})`

### Error: Timeout / Connection refused
**Causa:** Los servicios no están corriendo
**Solución:** 
```powershell
# Terminal 1
cd servicio-gestion
mvn spring-boot:run

# Terminal 2
cd servicio-flota
mvn spring-boot:run

# Terminal 3
cd servicio-logistica
mvn spring-boot:run
```

### Los contenedores no se crean
**Causa:** El `idCliente` aleatorio no existe
**Solución:** Ejecuta "Obtener IDs de Clientes" antes de crear contenedores

---

## 📊 Variables de Entorno Guardadas

Después de ejecutar todo, tendrás estas variables en el environment:

- `clientIds` - Array JSON con IDs de todos los clientes: `[1,2,3,...,65]`
- `contenedorIds` - Array JSON con IDs de todos los contenedores: `[1,2,3,...,225]`

Estas variables se usan automáticamente para crear solicitudes, rutas y tramos.

---

## 🎯 Siguiente Paso: Crear Solicitudes Masivas

Una vez que tengas clientes y contenedores, podés crear solicitudes masivas:

**Script Pre-request para crear solicitudes:**
```javascript
const clientIds = JSON.parse(pm.environment.get('clientIds') || '[]');
const contIds = JSON.parse(pm.environment.get('contenedorIds') || '[]');

pm.variables.set('randomClientId', clientIds[Math.floor(Math.random() * clientIds.length)]);
pm.variables.set('randomContenedorId', contIds[Math.floor(Math.random() * contIds.length)]);
pm.variables.set('numSeguimiento', 'SOL-' + Date.now() + '-' + Math.floor(Math.random()*10000));
pm.variables.set('costo', (3000 + Math.floor(Math.random() * 10000)).toFixed(2));
pm.variables.set('tiempo', (1 + Math.random() * 5).toFixed(1));
```

**Body de la request:**
```json
{
  "numeroSeguimiento": "{{numSeguimiento}}",
  "idContenedor": {{randomContenedorId}},
  "idCliente": {{randomClientId}},
  "origenDireccion": "Av. Colón 1234, Córdoba",
  "origenLatitud": -31.4201,
  "origenLongitud": -64.1888,
  "destinoDireccion": "Ruta 9 Km 680",
  "destinoLatitud": -31.35,
  "destinoLongitud": -64.15,
  "estado": "pendiente",
  "costoEstimado": {{costo}},
  "tiempoEstimado": {{tiempo}}
}
```

Ejecuta esto 100 veces con el Runner (sin CSV, solo iterations: 100)

---

## ✅ Checklist Final

- [ ] Servicios corriendo (8080, 8081, 8082)
- [ ] Colección importada en Postman
- [ ] Environment creado y seleccionado
- [ ] 50 clientes creados ✓
- [ ] IDs de clientes obtenidos ✓
- [ ] 200 contenedores creados ✓
- [ ] IDs de contenedores obtenidos ✓
- [ ] Verificación en Supabase ✓

**🎉 ¡Listo para hacer pruebas de carga!**
