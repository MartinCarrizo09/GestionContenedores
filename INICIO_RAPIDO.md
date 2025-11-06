# ⚡ INICIO RÁPIDO - 3 PASOS

## 🎯 Para poner en marcha TODO el sistema:

### 1️⃣ Configurar contraseña (solo primera vez)

```powershell
# Copiar archivo de ejemplo
Copy-Item .env.example .env
```

Abrir `.env` y verificar/cambiar la contraseña:

```env
POSTGRES_PASSWORD=admin123
```

---

### 2️⃣ Levantar TODO con Docker

```powershell
docker-compose up -d
```

**Esperar 5-10 minutos en el primer inicio** (descarga imágenes y compila código).

---

### 3️⃣ Verificar que esté funcionando

```powershell
# Ver estado
docker-compose ps

# Deberías ver algo como:
# tpi-postgres     Up 2 minutes  0.0.0.0:5432->5432/tcp
# tpi-gestion      Up 1 minute   0.0.0.0:8080->8080/tcp
# tpi-flota        Up 1 minute   0.0.0.0:8081->8081/tcp
# tpi-logistica    Up 1 minute   0.0.0.0:8082->8082/tcp
```

Abrir navegador en: http://localhost:8080/api-gestion/clientes

Si ves JSON con clientes, ¡funciona! ✅

---

## 🧪 PRUEBA RÁPIDA EN POSTMAN

### Crear solicitud con cliente nuevo:

```http
POST http://localhost:8082/api-logistica/solicitudes
Content-Type: application/json

{
  "numeroSeguimiento": "TRACK-TEST-001",
  "idContenedor": 1,
  "idCliente": 9999,
  "origenDireccion": "Puerto de Buenos Aires, Buenos Aires, Argentina",
  "destinoDireccion": "Rosario, Santa Fe, Argentina"
}
```

**Resultado:** Cliente 9999 se crea automáticamente ✅

---

## 🛑 DETENER TODO

```powershell
docker-compose down
```

---

## 🔄 REINICIAR TODO

```powershell
docker-compose restart
```

---

## 📖 DOCUMENTACIÓN COMPLETA

Ver [GUIA_USUARIO_POSTMAN.md](GUIA_USUARIO_POSTMAN.md) para:
- Todos los endpoints disponibles
- Ejemplos completos de Postman
- Flujo E2E paso a paso
- Troubleshooting

---

## 🆘 PROBLEMAS COMUNES

### Docker no arranca

```powershell
# Verificar que Docker Desktop esté corriendo
docker --version
```

### Puerto 5432 ocupado

```powershell
# Detener PostgreSQL local
Stop-Service postgresql*
```

### Ver logs de errores

```powershell
docker-compose logs -f servicio-logistica
```

---

## 📊 PUERTOS

- PostgreSQL: **5432**
- Servicio Gestión: **8080**
- Servicio Flota: **8081**
- Servicio Logística: **8082**

---

**¡Listo para usar! 🚀**
