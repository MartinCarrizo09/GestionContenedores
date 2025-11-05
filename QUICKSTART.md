# ⚡ Inicio Rápido - Supabase

## 🎯 Configuración en 3 pasos

### 1️⃣ Obtener contraseña de Supabase

1. Ve a https://supabase.com/dashboard
2. Selecciona tu proyecto: `jqshojwvwpoovjffscyv`
3. Settings > Database
4. Copia o resetea tu **Database Password**

### 2️⃣ Configurar variable de entorno

**Opción A - Con el script (recomendado):**
```powershell
.\setup-env.ps1
```

**Opción B - Manual (PowerShell):**
```powershell
$env:SUPABASE_DB_PASSWORD="TU_PASSWORD_AQUI"
```

**Opción C - Archivo .env:**
```bash
# Copia el ejemplo
cp .env.example .env

# Edita .env y agrega tu password
SUPABASE_DB_PASSWORD=TU_PASSWORD_AQUI
```

### 3️⃣ Ejecutar los servicios

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

## ✅ Verificar que funciona

### Buscar en los logs:

```
✅ HikariPool-1 - Start completed
✅ Tomcat started on port(s): 8080
✅ Schema-Qualified Table Names: logistica.solicitudes
```

### Probar conexión:

```powershell
# Test endpoints (cuando estén disponibles)
curl http://localhost:8080/api-gestion/health
curl http://localhost:8081/api-flota/health
curl http://localhost:8082/api-logistica/health
```

---

## 🗄️ Estructura de Base de Datos

```
Supabase PostgreSQL
│
├── Schema: gestion (servicio-gestion:8080)
│   ├── clientes
│   ├── contenedores
│   ├── depositos
│   └── tarifas
│
├── Schema: flota (servicio-flota:8081)
│   └── camiones
│
└── Schema: logistica (servicio-logistica:8082)
    ├── solicitudes
    ├── rutas
    ├── tramos
    └── configuracion
```

---

## 🐛 Troubleshooting Rápido

| Error | Solución |
|-------|----------|
| `password authentication failed` | Verifica `SUPABASE_DB_PASSWORD` |
| `relation does not exist` | Asegúrate de que las tablas existan en el schema correcto |
| `Connection timeout` | Verifica tu conexión a internet y firewall |
| `SSL connection required` | La URL debe incluir `?sslmode=require` |

---

## 📚 Documentación Completa

Para más detalles, consulta:
- **[SUPABASE_SETUP.md](./SUPABASE_SETUP.md)** - Guía completa de configuración
- **[.env.example](./.env.example)** - Todas las variables disponibles

---

## 🔐 Credenciales

```yaml
Host:     jqshojwvwpoovjffscyv.supabase.co
Port:     5432
Database: postgres
User:     postgres.jqshojwvwpoovjffscyv
Password: ⚠️ Obtener de Supabase Dashboard
SSL:      Requerido
```

---

## 📊 Puertos de los Servicios

| Servicio | Puerto | Context Path | Schema DB |
|----------|--------|--------------|-----------|
| Gestión  | 8080   | /api-gestion | gestion   |
| Flota    | 8081   | /api-flota   | flota     |
| Logística| 8082   | /api-logistica| logistica |

---

**✨ ¡Listo para producción!**
