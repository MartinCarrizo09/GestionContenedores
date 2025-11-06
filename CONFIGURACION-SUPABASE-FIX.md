# 🔧 Solución de Problemas de Conexión a Supabase

## 📋 Resumen del Problema

Los tres microservicios (Gestión, Flota y Logística) fallaban al intentar conectarse simultáneamente a Supabase PostgreSQL con el error:

```
FATAL: MaxClientsInSessionMode: max clients reached - in Session mode max clients are limited to pool_size
```

### Causa Raíz

Supabase **Session Mode** (puerto 5432) tiene un límite muy bajo de conexiones simultáneas (~15 conexiones totales en el plan free tier). Cada microservicio estaba configurado con un pool de **10 conexiones**, lo que excedía el límite cuando los tres servicios intentaban iniciar simultáneamente.

---

## ✅ Solución Implementada

Se realizaron cambios en los archivos `application.yml` de los tres microservicios para:

1. **Cambiar de Session Mode a Transaction Mode** (puerto 5432 → 6543)
2. **Reducir el pool de conexiones HikariCP** (10 → 2 conexiones)
3. **Agregar configuración específica para PGBouncer**

---

## 🔄 Cambios Realizados

### 1. Servicio Gestión

**Archivo:** `servicio-gestion/src/main/resources/application.yml`

#### Cambio 1: URL de conexión y puerto (Línea 11)

**ANTES:**
```yaml
url: jdbc:postgresql://${SUPABASE_DB_HOST:aws-1-sa-east-1.pooler.supabase.com}:${SUPABASE_DB_PORT:5432}/${SUPABASE_DB_NAME:postgres}?sslmode=require
```

**DESPUÉS:**
```yaml
url: jdbc:postgresql://${SUPABASE_DB_HOST:aws-1-sa-east-1.pooler.supabase.com}:${SUPABASE_DB_PORT:6543}/${SUPABASE_DB_NAME:postgres}?sslmode=require&pgbouncer=true
```

**Cambios:**
- Puerto: `5432` → `6543`
- Agregado parámetro: `&pgbouncer=true`

#### Cambio 2: Configuración del pool HikariCP (Líneas 17-23)

**ANTES:**
```yaml
hikari:
  maximum-pool-size: 10
  minimum-idle: 5
  connection-timeout: 30000
  idle-timeout: 600000
  max-lifetime: 1800000
  pool-name: GestionHikariPool
```

**DESPUÉS:**
```yaml
hikari:
  maximum-pool-size: 2
  minimum-idle: 1
  connection-timeout: 30000
  idle-timeout: 60000
  max-lifetime: 300000
  pool-name: GestionHikariPool
```

**Cambios:**
- `maximum-pool-size`: `10` → `2`
- `minimum-idle`: `5` → `1`
- `idle-timeout`: `600000` (10 min) → `60000` (1 min)
- `max-lifetime`: `1800000` (30 min) → `300000` (5 min)

#### Cambio 3: Configuración Hibernate para PGBouncer (Líneas 38-40)

**AGREGADO:**
```yaml
# Configuración para PGBouncer en Transaction Mode
temp:
  use_jdbc_metadata_defaults: false
```

**Ubicación:** Dentro de `spring.jpa.properties.hibernate`

---

### 2. Servicio Flota

**Archivo:** `servicio-flota/src/main/resources/application.yml`

#### Cambio 1: URL de conexión y puerto (Línea 11)

**ANTES:**
```yaml
url: jdbc:postgresql://${SUPABASE_DB_HOST:aws-1-sa-east-1.pooler.supabase.com}:${SUPABASE_DB_PORT:5432}/${SUPABASE_DB_NAME:postgres}?sslmode=require
```

**DESPUÉS:**
```yaml
url: jdbc:postgresql://${SUPABASE_DB_HOST:aws-1-sa-east-1.pooler.supabase.com}:${SUPABASE_DB_PORT:6543}/${SUPABASE_DB_NAME:postgres}?sslmode=require&pgbouncer=true
```

#### Cambio 2: Configuración del pool HikariCP (Líneas 17-23)

**ANTES:**
```yaml
hikari:
  maximum-pool-size: 10
  minimum-idle: 5
  connection-timeout: 30000
  idle-timeout: 600000
  max-lifetime: 1800000
  pool-name: FlotaHikariPool
```

**DESPUÉS:**
```yaml
hikari:
  maximum-pool-size: 2
  minimum-idle: 1
  connection-timeout: 30000
  idle-timeout: 60000
  max-lifetime: 300000
  pool-name: FlotaHikariPool
```

#### Cambio 3: Configuración Hibernate para PGBouncer (Líneas 38-40)

**AGREGADO:**
```yaml
# Configuración para PGBouncer en Transaction Mode
temp:
  use_jdbc_metadata_defaults: false
```

---

### 3. Servicio Logística

**Archivo:** `servicio-logistica/src/main/resources/application.yml`

#### Cambio 1: URL de conexión y puerto (Línea 11)

**ANTES:**
```yaml
url: jdbc:postgresql://${SUPABASE_DB_HOST:aws-1-sa-east-1.pooler.supabase.com}:${SUPABASE_DB_PORT:5432}/${SUPABASE_DB_NAME:postgres}?sslmode=require
```

**DESPUÉS:**
```yaml
url: jdbc:postgresql://${SUPABASE_DB_HOST:aws-1-sa-east-1.pooler.supabase.com}:${SUPABASE_DB_PORT:6543}/${SUPABASE_DB_NAME:postgres}?sslmode=require&pgbouncer=true
```

#### Cambio 2: Configuración del pool HikariCP (Líneas 17-23)

**ANTES:**
```yaml
hikari:
  maximum-pool-size: 10
  minimum-idle: 5
  connection-timeout: 30000
  idle-timeout: 600000
  max-lifetime: 1800000
  pool-name: LogisticaHikariPool
```

**DESPUÉS:**
```yaml
hikari:
  maximum-pool-size: 2
  minimum-idle: 1
  connection-timeout: 30000
  idle-timeout: 60000
  max-lifetime: 300000
  pool-name: LogisticaHikariPool
```

#### Cambio 3: Configuración Hibernate para PGBouncer (Líneas 38-40)

**AGREGADO:**
```yaml
# Configuración para PGBouncer en Transaction Mode
temp:
  use_jdbc_metadata_defaults: false
```

---

## 📊 Comparación de Configuraciones

| Parámetro | Antes | Después | Motivo |
|-----------|-------|---------|--------|
| **Puerto** | 5432 (Session Mode) | 6543 (Transaction Mode) | Mayor límite de conexiones (~200 vs ~15) |
| **maximum-pool-size** | 10 | 2 | Reducir consumo de conexiones |
| **minimum-idle** | 5 | 1 | Minimizar conexiones idle |
| **idle-timeout** | 600000 ms (10 min) | 60000 ms (1 min) | Liberar conexiones inactivas más rápido |
| **max-lifetime** | 1800000 ms (30 min) | 300000 ms (5 min) | Reciclar conexiones más frecuentemente |
| **pgbouncer param** | No incluido | `&pgbouncer=true` | Indicar uso de PGBouncer |
| **use_jdbc_metadata_defaults** | No configurado | `false` | Compatibilidad con Transaction Mode |

---

## 🎯 Resultados

### ✅ Estado Final

Los tres microservicios ahora pueden ejecutarse simultáneamente:

- **Servicio Gestión**: Puerto 8080, context-path `/api-gestion` ✅
- **Servicio Flota**: Puerto 8081, context-path `/api-flota` ✅
- **Servicio Logística**: Puerto 8082, context-path `/api-logistica` ✅

### 📈 Consumo de Conexiones

- **Antes**: 3 servicios × 10 conexiones = 30 conexiones (excede límite de 15)
- **Después**: 3 servicios × 2 conexiones = **6 conexiones máximo** (muy por debajo del límite de 200)

---

## 📝 Notas Adicionales

### Sobre Transaction Mode vs Session Mode

- **Session Mode (puerto 5432)**: 
  - Mantiene sesiones persistentes
  - Límite: ~15 conexiones (plan free tier)
  - Uso: Operaciones que requieren state de sesión (prepared statements, cursors, temp tables)

- **Transaction Mode (puerto 6543)**:
  - Mantiene solo transacciones cortas
  - Límite: ~200 conexiones (plan free tier)
  - Uso: Operaciones CRUD estándar (ideal para microservicios REST)
  - **Recomendado para aplicaciones Spring Boot**

### Advertencias de Hibernate

Los logs muestran estas advertencias que pueden ser ignoradas:

```
HHH90000021: Encountered deprecated setting [hibernate.temp.use_jdbc_metadata_defaults], 
use [hibernate.boot.allow_jdbc_metadata_access] instead
```

**Acción recomendada**: En versiones futuras de Hibernate, reemplazar:
```yaml
temp:
  use_jdbc_metadata_defaults: false
```

Por:
```yaml
boot:
  allow_jdbc_metadata_access: false
```

---

## 🚀 Cómo Iniciar los Servicios

Ejecutar en terminales separadas:

```powershell
# Terminal 1 - Servicio Gestión
cd servicio-gestion
mvn spring-boot:run

# Terminal 2 - Servicio Flota
cd servicio-flota
mvn spring-boot:run

# Terminal 3 - Servicio Logística
cd servicio-logistica
mvn spring-boot:run
```

---

## 📚 Referencias

- [Supabase Connection Pooling](https://supabase.com/docs/guides/database/connecting-to-postgres#connection-pool)
- [PGBouncer Transaction Mode](https://www.pgbouncer.org/features.html)
- [HikariCP Configuration](https://github.com/brettwooldridge/HikariCP#configuration-knobs-baby)
- [Spring Boot + PGBouncer Best Practices](https://spring.io/guides/gs/accessing-data-jpa/)

---

**Fecha de implementación**: 6 de noviembre de 2025  
**Autor**: GitHub Copilot  
**Estado**: ✅ RESUELTO - Todos los microservicios funcionando correctamente
