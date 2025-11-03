# 🚀 Keycloak - Inicio Rápido (Ejecutando)

**Estado**: ✅ Keycloak está corriendo en Docker

---

## 1. Acceder a Keycloak

### Admin Console
Abre en tu navegador:
```
http://localhost:8080/admin
```

**Credenciales:**
- Usuario: `admin`
- Contraseña: `admin`

### Dashboard Principal
```
http://localhost:8080
```

---

## 2. Crear Realm (Espacio de Trabajo)

1. **En Admin Console**, mira la esquina superior izquierda
2. Verás "Master" con un dropdown
3. Click en el dropdown → **Create Realm**
4. Nombre: `TPI-Realm`
5. Click "Create"

---

## 3. Crear Clientes OAuth2

### Cliente 1: API Gateway

En el menú lateral → **Clients** → **Create client**

**Configuración:**
- **Client ID**: `api-gateway-client`
- **Client Type**: OpenID Connect
- **Name**: API Gateway
- Click "Next"

**Capability Config:**
- ✓ Client authentication (ON)
- ✓ Authorization (ON)
- ✓ Standard flow
- ✓ Direct access grants
- ✓ Service account roles
- Click "Next"

**Login Settings:**
- **Valid redirect URIs**:
  ```
  http://localhost:8080/*
  http://localhost:9000/*
  http://localhost:9001/*
  http://localhost:9002/*
  ```
- **Valid post logout redirect URIs**:
  ```
  http://localhost:8080/*
  ```
- **Web origins**:
  ```
  http://localhost:8080
  http://localhost:9000
  http://localhost:9001
  http://localhost:9002
  ```
- Click "Save"

**Obtener Client Secret:**
- Ve a tab "Credentials"
- Copia el **Client Secret** (guárdalo en lugar seguro)

### Cliente 2: Frontend (Opcional ahora)

- **Client ID**: `frontend-app`
- **Client Type**: OpenID Connect
- **Client authentication**: OFF
- **Standard flow**: ✓
- **Valid redirect URIs**: `http://localhost:3000/*`

---

## 4. Crear Roles

En el menú lateral → **Realm roles** → **Create role**

Crea estos roles:
1. `admin-tpi`
2. `driver`
3. `dispatcher`
4. `manager`
5. `customer`

---

## 5. Crear Usuarios de Prueba

En el menú lateral → **Users** → **Create new user**

### Usuario 1: Admin
- **Username**: `admin-tpi`
- **Email**: `admin@tpi.local`
- **Enabled**: ✓
- Click "Create"

**Asignar Contraseña:**
- Tab "Credentials"
- "Set password"
- Contraseña: `Admin123!`
- **Temporary**: OFF
- Click "Set password"

**Asignar Rol:**
- Tab "Role mapping"
- "Assign role"
- Selecciona `admin-tpi`
- Click "Assign"

### Usuario 2: Driver
- **Username**: `driver1`
- **Email**: `driver1@tpi.local`
- **Enabled**: ✓
- Crear, asignar contraseña `Driver123!`
- Asignar rol `driver`

### Usuario 3: Dispatcher
- **Username**: `dispatcher1`
- **Email**: `dispatcher1@tpi.local`
- **Enabled**: ✓
- Crear, asignar contraseña `Dispatcher123!`
- Asignar rol `dispatcher`

---

## 6. Testear Obtención de Token

Abre PowerShell y ejecuta:

```powershell
$KEYCLOAK_URL = "http://localhost:8080"
$REALM = "TPI-Realm"
$CLIENT_ID = "api-gateway-client"
$CLIENT_SECRET = "PEGA_TU_CLIENT_SECRET_AQUI"
$USERNAME = "admin-tpi"
$PASSWORD = "Admin123!"

$tokenResponse = Invoke-RestMethod `
  -Uri "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" `
  -Method Post `
  -ContentType "application/x-www-form-urlencoded" `
  -Body @{
    grant_type = "password"
    client_id = $CLIENT_ID
    client_secret = $CLIENT_SECRET
    username = $USERNAME
    password = $PASSWORD
  }

$token = $tokenResponse.access_token
Write-Host "✓ Token obtenido:"
Write-Host $token
Write-Host ""
Write-Host "Expires in: $($tokenResponse.expires_in) segundos"
```

---

## 7. Verificar Configuración OpenID Connect

Abre en navegador:
```
http://localhost:8080/realms/TPI-Realm/.well-known/openid-configuration
```

Deberías ver endpoints como:
- `authorization_endpoint`
- `token_endpoint`
- `userinfo_endpoint`
- `jwks_uri`
- etc.

---

## 8. Verificar Estadísticas

En Admin Console → tu realm (TPI-Realm):
- Deberías ver:
  - ✓ 2 clientes configurados
  - ✓ 5 roles creados
  - ✓ 3 usuarios creados

---

## 📝 Checklist de Configuración Inicial

- [ ] Accediste a Admin Console (http://localhost:8080/admin)
- [ ] Creaste realm `TPI-Realm`
- [ ] Creaste cliente `api-gateway-client` y copiaste Client Secret
- [ ] Creaste cliente `frontend-app` (opcional)
- [ ] Creaste 5 roles (admin-tpi, driver, dispatcher, manager, customer)
- [ ] Creaste 3 usuarios de prueba (admin-tpi, driver1, dispatcher1)
- [ ] Asignaste roles a usuarios
- [ ] Obtuviste token de prueba con PowerShell
- [ ] Verificaste endpoint OpenID Connect

---

## 🔧 Comandos Útiles

**Ver logs de Keycloak:**
```cmd
docker logs -f practical_roentgen
```
(Reemplaza `practical_roentgen` por el nombre de tu contenedor)

**Parar Keycloak:**
```cmd
docker stop practical_roentgen
```

**Reiniciar Keycloak:**
```cmd
docker restart practical_roentgen
```

**Ver contenedores activos:**
```cmd
docker ps
```

---

## 📋 Próximos Pasos

Una vez completes el checklist anterior:

1. **Configura tu API Gateway con Spring Security + OAuth2**
2. **Integra autenticación en tus servicios**
3. **Importa el realm exportado a producción con Postgres**
4. **Configura HTTPS para producción**

---

**Generado**: Noviembre 2024
**Estado**: Listo para configuración manual en Admin Console

