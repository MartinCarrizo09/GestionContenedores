# 🚀 Inicio Rápido - Sistema TPI

Este documento explica cómo iniciar todo el sistema TPI con un solo comando, sin necesidad de configuraciones manuales.

## 📋 Requisitos Previos

1. **Docker Desktop** instalado y corriendo
   - Windows: Descargar desde [docker.com](https://www.docker.com/products/docker-desktop)
   - Verificar instalación: `docker --version`

2. **PowerShell** (incluido en Windows 10/11)
   - Verificar: Abrir PowerShell y escribir `$PSVersionTable`

## 🎯 Inicio Automático

### Opción 1: Script Automático (Recomendado)

Simplemente ejecuta:

```powershell
.\iniciar-sistema.ps1
```

Este script hará todo automáticamente:
- ✅ Levantará Docker Compose
- ✅ Esperará a que Keycloak esté listo
- ✅ Creará el realm `tpi-backend`
- ✅ Creará el cliente `tpi-client`
- ✅ Creará los roles: CLIENTE, OPERADOR, TRANSPORTISTA
- ✅ Creará los usuarios de prueba
- ✅ Configurará contraseñas y roles

**Tiempo estimado**: 2-5 minutos (la primera vez puede tardar más)

### Opción 2: Inicio Manual

Si prefieres hacerlo manualmente:

```powershell
# 1. Levantar Docker
docker-compose up -d

# 2. Esperar 2-3 minutos a que Keycloak esté listo

# 3. Configurar Keycloak manualmente
# Ver guía en: CONFIGURACION_USUARIOS_KEYCLOAK.md
```

## ✅ Verificación

Una vez que el script termine, verifica que todo esté funcionando:

```powershell
# Verificar contenedores
docker ps

# Ver logs
docker-compose logs -f

# Obtener token de prueba
.\get-auth-token.ps1 -Username "cliente@tpi.com" -Password "cliente123"
```

## 🌐 URLs del Sistema

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| **Keycloak Admin** | http://localhost:9090 | admin / admin123 |
| **API Gateway** | http://localhost:8080 | - |
| **Swagger UI** | http://localhost:8080/swagger-ui.html | - |
| **PostgreSQL** | localhost:5432 | admin / admin123 |

## 👤 Usuarios de Prueba

| Usuario | Contraseña | Rol | Descripción |
|---------|------------|-----|-------------|
| `cliente@tpi.com` | `cliente123` | CLIENTE | Usuario cliente estándar |
| `operador@tpi.com` | `operador123` | OPERADOR | Usuario operador/admin |
| `transportista@tpi.com` | `transportista123` | TRANSPORTISTA | Usuario transportista |

## 🔧 Comandos Útiles

### Ver Logs
```powershell
# Todos los servicios
docker-compose logs -f

# Servicio específico
docker logs tpi-gateway -f
docker logs tpi-keycloak -f
```

### Detener Servicios
```powershell
# Detener (mantiene datos)
docker-compose down

# Detener y eliminar datos
docker-compose down -v
```

### Reiniciar Servicios
```powershell
# Reiniciar todos
docker-compose restart

# Reiniciar uno específico
docker-compose restart servicio-logistica
```

### Obtener Token de Autenticación
```powershell
# Cliente
.\get-auth-token.ps1 -Username "cliente@tpi.com" -Password "cliente123"

# Operador
.\get-auth-token.ps1 -Username "operador@tpi.com" -Password "operador123"

# Transportista
.\get-auth-token.ps1 -Username "transportista@tpi.com" -Password "transportista123"
```

## ❌ Solución de Problemas

### Error: "Docker no está disponible"
- **Solución**: Asegúrate de que Docker Desktop esté instalado y corriendo
- Verificar: Abrir Docker Desktop y verificar que el estado sea "Running"

### Error: "Keycloak no responde"
- **Solución**: Espera más tiempo (Keycloak puede tardar 2-3 minutos en iniciar)
- Verificar: `docker logs tpi-keycloak`
- Si persiste: Reiniciar Keycloak: `docker-compose restart keycloak`

### Error: "No se pudo obtener token de administrador"
- **Solución**: Espera 1-2 minutos más y verifica que Keycloak esté corriendo
- Verificar: Abrir http://localhost:9090 en el navegador
- Si no responde: Ver logs: `docker logs tpi-keycloak`

### Los usuarios no funcionan
- **Solución**: Ejecuta el script nuevamente (es idempotente, no duplica configuraciones)
- O configura manualmente siguiendo: `CONFIGURACION_USUARIOS_KEYCLOAK.md`

### Puerto ya en uso
- **Solución**: Detener servicios que usan los puertos 8080, 8081, 8082, 8083, 9090, 5432
- Verificar: `netstat -ano | findstr :8080`
- Detener proceso específico (si es necesario)

## 📚 Documentación Adicional

- **Configuración Manual de Keycloak**: `CONFIGURACION_USUARIOS_KEYCLOAK.md`
- **Guía de Endpoints**: `README-ENDPOINTS.md`
- **Documentación Docker**: `DOCKER_CHEATSHEET.md`
- **Ejecutar Casos de Prueba**: `ejecutar-casos-prueba.ps1`

## 🎓 Para Desarrolladores

### Estructura del Proyecto

```
GestionContenedores/
├── iniciar-sistema.ps1       # Script de inicio automático ⭐
├── docker-compose.yml        # Configuración Docker
├── keycloak/                 # Configuración Keycloak
├── api-gateway/              # API Gateway
├── servicio-gestion/         # Microservicio Gestión
├── servicio-flota/           # Microservicio Flota
└── servicio-logistica/       # Microservicio Logística
```

### Próximos Pasos

1. ✅ Ejecutar `.\iniciar-sistema.ps1`
2. ✅ Verificar que todos los servicios estén corriendo
3. ✅ Obtener un token de prueba
4. ✅ Probar los endpoints desde Swagger UI o Postman
5. ✅ Ejecutar casos de prueba: `.\ejecutar-casos-prueba.ps1`

---

**¿Necesitas ayuda?** Revisa la documentación adicional o consulta con el equipo de desarrollo.

