# 🐳 CHEAT SHEET - COMANDOS DOCKER

**Referencia rápida de comandos para gestionar el sistema TPI**

---

## 🚀 INICIAR / DETENER

```powershell
# Iniciar TODO (primera vez puede tardar 5-10 min)
docker-compose up -d

# Iniciar TODO y ver logs en tiempo real
docker-compose up

# Iniciar solo la base de datos
docker-compose up -d postgres

# Detener TODO (sin borrar datos)
docker-compose stop

# Detener TODO y borrar contenedores (datos persisten)
docker-compose down

# Detener TODO y BORRAR DATOS (¡cuidado!)
docker-compose down -v
```

---

## 📋 VER ESTADO

```powershell
# Ver estado de todos los contenedores
docker-compose ps

# Ver uso de CPU y RAM en tiempo real
docker stats

# Ver qué puertos están en uso
docker-compose ps
```

---

## 📖 VER LOGS

```powershell
# Ver logs de TODOS los servicios (Ctrl+C para salir)
docker-compose logs -f

# Ver logs de UN servicio específico
docker-compose logs -f servicio-gestion
docker-compose logs -f servicio-flota
docker-compose logs -f servicio-logistica
docker-compose logs -f postgres

# Ver últimas 100 líneas de logs
docker-compose logs --tail=100 servicio-logistica

# Ver logs desde hace 10 minutos
docker-compose logs --since=10m

# Buscar texto en logs
docker-compose logs | Select-String "ERROR"
```

---

## 🔄 REINICIAR

```powershell
# Reiniciar TODOS los servicios
docker-compose restart

# Reiniciar UN servicio específico
docker-compose restart servicio-gestion

# Rebuild y reiniciar (después de cambios en código)
docker-compose build --no-cache
docker-compose up -d --build
```

---

## 🗄️ POSTGRESQL

```powershell
# Conectar a PostgreSQL (CLI)
docker exec -it tpi-postgres psql -U admin -d bd-tpi-backend

# Ver tablas
\dt gestion.*
\dt flota.*
\dt logistica.*

# Contar registros
SELECT COUNT(*) FROM gestion.clientes;
SELECT COUNT(*) FROM gestion.contenedores;
SELECT COUNT(*) FROM flota.camiones;
SELECT COUNT(*) FROM logistica.solicitudes;

# Ver clientes
SELECT id, nombre, apellido, email FROM gestion.clientes LIMIT 10;

# Ver camiones disponibles
SELECT patente, capacidad_peso, capacidad_volumen, disponible 
FROM flota.camiones 
WHERE disponible = true;

# Ver solicitudes por estado
SELECT estado, COUNT(*) FROM logistica.solicitudes GROUP BY estado;

# Salir de PostgreSQL
\q

# Backup de la base de datos
docker exec tpi-postgres pg_dump -U admin bd-tpi-backend > backup.sql

# Restaurar backup
docker exec -i tpi-postgres psql -U admin -d bd-tpi-backend < backup.sql
```

---

## 🔍 DEBUGGING

```powershell
# Entrar a un contenedor (shell interactivo)
docker exec -it tpi-postgres sh
docker exec -it tpi-gestion sh
docker exec -it tpi-flota sh
docker exec -it tpi-logistica sh

# Ver archivos dentro de un contenedor
docker exec tpi-gestion ls -la /app

# Ver variables de entorno de un contenedor
docker exec tpi-gestion env

# Inspeccionar configuración de un contenedor
docker inspect tpi-postgres

# Ver redes de Docker
docker network ls
docker network inspect tpi-network
```

---

## 🧹 LIMPIAR

```powershell
# Limpiar contenedores detenidos
docker container prune

# Limpiar imágenes no usadas
docker image prune

# Limpiar volúmenes no usados
docker volume prune

# Limpiar TODO (contenedores, imágenes, volúmenes, redes)
docker system prune -a --volumes

# Ver espacio usado por Docker
docker system df
```

---

## 🔧 AVANZADO

```powershell
# Ver todas las imágenes Docker
docker images

# Borrar una imagen específica
docker rmi nombre-imagen:tag

# Ver todos los contenedores (incluso detenidos)
docker ps -a

# Borrar un contenedor específico
docker rm nombre-contenedor

# Ver volúmenes de Docker
docker volume ls

# Inspeccionar un volumen
docker volume inspect tpi-postgres-data

# Copiar archivo DESDE contenedor
docker cp tpi-postgres:/var/lib/postgresql/data/postgresql.conf ./

# Copiar archivo HACIA contenedor
docker cp ./archivo.txt tpi-postgres:/tmp/

# Ver eventos de Docker en tiempo real
docker events

# Ver procesos corriendo en un contenedor
docker top tpi-postgres
```

---

## 🚦 HEALTHCHECK

```powershell
# Ver estado de salud de los contenedores
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Ejecutar healthcheck manualmente en PostgreSQL
docker exec tpi-postgres pg_isready -U admin -d bd-tpi-backend
```

---

## 📊 PERFORMANCE

```powershell
# Ver uso de recursos en tiempo real
docker stats

# Limitar CPU y RAM de un servicio (en docker-compose.yml)
# deploy:
#   resources:
#     limits:
#       cpus: '0.50'
#       memory: 512M
```

---

## 🌐 REDES

```powershell
# Ver redes
docker network ls

# Inspeccionar red de TPI
docker network inspect tpi-network

# Ver qué contenedores están en la red
docker network inspect tpi-network | Select-String "Name"

# Probar conectividad entre servicios
docker exec tpi-logistica ping tpi-postgres
docker exec tpi-logistica curl http://tpi-gestion:8080/api-gestion/clientes
```

---

## 🔐 SEGURIDAD

```powershell
# Ver qué puertos están expuestos
docker port tpi-postgres
docker port tpi-gestion

# Cambiar contraseña de PostgreSQL
docker exec -it tpi-postgres psql -U admin -d bd-tpi-backend
ALTER USER admin WITH PASSWORD 'nueva-contraseña';
\q

# Luego actualizar .env y reiniciar:
docker-compose down
# Editar .env
docker-compose up -d
```

---

## 📦 EXPORTAR / IMPORTAR

```powershell
# Exportar contenedor como imagen
docker commit tpi-postgres mi-postgres-backup

# Guardar imagen en archivo .tar
docker save -o postgres-backup.tar mi-postgres-backup

# Cargar imagen desde archivo .tar
docker load -i postgres-backup.tar

# Exportar volumen (backup de datos)
docker run --rm -v tpi-postgres-data:/data -v ${PWD}:/backup alpine tar czf /backup/postgres-data-backup.tar.gz -C /data .

# Importar volumen (restaurar datos)
docker run --rm -v tpi-postgres-data:/data -v ${PWD}:/backup alpine sh -c "cd /data && tar xzf /backup/postgres-data-backup.tar.gz"
```

---

## 🆘 TROUBLESHOOTING

```powershell
# Problema: Puerto ocupado
netstat -ano | findstr :5432
Stop-Service postgresql*

# Problema: Servicio no inicia
docker-compose logs -f servicio-que-falla

# Problema: Contenedor en loop (reiniciando constantemente)
docker logs --tail=100 nombre-contenedor

# Problema: Sin espacio en disco
docker system prune -a --volumes
docker system df

# Problema: Cambios no se reflejan
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Problema: Necesito resetear TODO
docker-compose down -v
docker system prune -a
docker-compose up -d
```

---

## 📌 ALIAS ÚTILES (POWERSHELL)

Agregar a tu `$PROFILE`:

```powershell
# Ver/editar perfil
notepad $PROFILE

# Agregar estos alias:
function dcu { docker-compose up -d }
function dcd { docker-compose down }
function dcl { docker-compose logs -f $args }
function dcp { docker-compose ps }
function dcr { docker-compose restart $args }
function dcb { docker-compose build --no-cache; docker-compose up -d }
function dps { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function dstats { docker stats --no-stream }
```

Luego reiniciar PowerShell y usar:

```powershell
dcu      # En vez de docker-compose up -d
dcd      # En vez de docker-compose down
dcl      # En vez de docker-compose logs -f
```

---

## 🎯 COMANDOS MÁS USADOS (TOP 10)

```powershell
1.  docker-compose up -d              # Iniciar
2.  docker-compose down               # Detener
3.  docker-compose logs -f            # Ver logs
4.  docker-compose ps                 # Ver estado
5.  docker-compose restart            # Reiniciar
6.  docker exec -it tpi-postgres psql -U admin -d bd-tpi-backend  # BD
7.  docker-compose build              # Rebuild
8.  docker stats                      # Ver recursos
9.  docker system prune -a            # Limpiar
10. docker-compose logs --tail=100    # Últimos logs
```

---

**¡Guarda este archivo para referencia rápida! 📚**
