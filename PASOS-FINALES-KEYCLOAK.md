# ✅ Keycloak + API Gateway - Pasos Finales

**Fecha:** 3 de Noviembre 2025  
**Estado:** Realm creado, API Gateway arrancando

---

## ✅ Lo que ya está hecho:

1. ✓ Keycloak corriendo en puerto 8080
2. ✓ Realm `TPI-Realm` creado y funcionando
3. ✓ API Gateway configurado en puerto 9090
4. ✓ SecurityConfig.java creado
5. ✓ TestController.java creado
6. ✓ application.properties configurado con Client Secret

---

## 🔴 Lo que FALTA hacer MANUALMENTE en Keycloak Admin:

### Paso 1: Crear Cliente `api-gateway-client`

1. Abre: **http://localhost:8080/admin**
2. Login: `admin` / `admin`
3. Selecciona realm: **TPI-Realm** (dropdown arriba a la izquierda)
4. Ve a: **Clients** → **Create client**
5. Configura:
   ```
   Client ID: api-gateway-client
   Client Type: OpenID Connect
   Name: API Gateway
   ```
6. Click "Next"
7. **Capability Config:**
   ```
   Client authentication: ON
   Authorization: ON
   Standard flow: ON
   Direct access grants: ON
   Service account roles: ON
   ```
8. Click "Next"
9. **Login Settings:**
   ```
   Valid redirect URIs:
   - http://localhost:9090/*
   - http://localhost:9000/*
   - http://localhost:9001/*
   - http://localhost:9002/*
   
   Valid post logout redirect URIs:
   - http://localhost:9090/*
   
   Web origins:
   - http://localhost:9090
   - http://localhost:9000
   - http://localhost:9001
   - http://localhost:9002
   ```
10. Click "Save"
11. **MUY IMPORTANTE:** Ve a pestaña "Credentials"
12. Copia el **Client Secret**
13. Verifica que sea: `Txx2xshlS6788zeJFRVpVmhEhlEAnbxg`
14. Si es diferente, actualiza `application.properties` del API Gateway

---

### Paso 2: Crear Roles

Ve a: **Realm roles** → **Create role**

Crear estos 3 roles:

1. **cliente**
   ```
   Role name: cliente
   Description: Clientes del sistema - Consultar envios y seguimiento
   ```

2. **operador**
   ```
   Role name: operador
   Description: Operadores - Asignar rutas y gestionar operaciones
   ```

3. **transportista**
   ```
   Role name: transportista
   Description: Transportistas - Ejecutar rutas y actualizar estado
   ```

---

### Paso 3: Crear Usuarios

Ve a: **Users** → **Create new user**

#### Usuario 1: Cliente
```
Username: cliente
Email: cliente@tpi.local
First name: Gonzalo
Last name: Maurino
Email verified: ✓
Enabled: ✓
```
- Click "Create"
- Pestaña "Credentials" → Set password: `Cliente123!`
- Temporary: OFF
- Pestaña "Role mapping" → Assign role: `cliente`

#### Usuario 2: Operador
```
Username: operador
Email: operador@tpi.local
First name: Martin
Last name: Carrizo
Email verified: ✓
Enabled: ✓
```
- Click "Create"
- Credentials: `Operador123!` (Temporary: OFF)
- Role mapping: `operador`

#### Usuario 3: Transportista
```
Username: transportista
Email: transportista@tpi.local
First name: Juan
Last name: Martinez
Email verified: ✓
Enabled: ✓
```
- Click "Create"
- Credentials: `Transportista123!` (Temporary: OFF)
- Role mapping: `transportista`

#### Usuario 4: Admin (ya existe)
- Ya tienes `admin-tpi` creado
- Asegúrate que tenga todos los roles de admin

---

### Paso 4: Configurar Mapper de Roles (MUY IMPORTANTE)

1. Ve a: **Clients** → `api-gateway-client` → **Client scopes**
2. Click en `api-gateway-client-dedicated`
3. Click en **"Add mapper"** → **"By configuration"**
4. Selecciona: **"User Realm Role"**
5. Configura:
   ```
   Name: roles-mapper
   Token Claim Name: roles
   Claim JSON Type: String
   Add to access token: ON
   Add to ID token: ON
   Add to userinfo: ON
   ```
6. Click "Save"

**¿Por qué es importante?**  
Sin este mapper, los roles NO aparecerán en el token JWT y Spring Security no podrá validar permisos.

---

## 🧪 Probar la Integración

Una vez completados los 4 pasos anteriores:

### Opción 1: Script Automatizado

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\Martin\Desktop\TPI - Backend - G143\test-keycloak.ps1"
```

### Opción 2: Manual con PowerShell

```powershell
# 1. Obtener token
$response = Invoke-RestMethod `
  -Uri "http://localhost:8080/realms/TPI-Realm/protocol/openid-connect/token" `
  -Method Post `
  -ContentType "application/x-www-form-urlencoded" `
  -Body @{
    grant_type = "password"
    client_id = "api-gateway-client"
    client_secret = "Txx2xshlS6788zeJFRVpVmhEhlEAnbxg"
    username = "cliente"
    password = "Cliente123!"
  }

$token = $response.access_token
Write-Host "Token: $token"

# 2. Probar endpoint público (sin token)
Invoke-RestMethod -Uri "http://localhost:9090/api/public/health"

# 3. Probar endpoint protegido (con token)
Invoke-RestMethod `
  -Uri "http://localhost:9090/api/profile" `
  -Headers @{ "Authorization" = "Bearer $token" }

# 4. Probar endpoint de cliente
Invoke-RestMethod `
  -Uri "http://localhost:9090/api/cliente/info" `
  -Headers @{ "Authorization" = "Bearer $token" }
```

---

## 📋 Checklist Final

- [ ] Cliente `api-gateway-client` creado
- [ ] Client Secret verificado/actualizado
- [ ] 3 Roles creados (cliente, operador, transportista)
- [ ] 3 Usuarios creados con roles asignados
- [ ] Mapper de roles configurado
- [ ] API Gateway arrancado sin errores
- [ ] Endpoint público accesible: http://localhost:9090/api/public/health
- [ ] Token obtenido exitosamente
- [ ] Endpoint protegido accesible con token
- [ ] Roles validados correctamente

---

## 🚨 Troubleshooting

### Error: "403 Forbidden" al acceder a endpoints
- Verifica que el mapper de roles esté configurado
- Decodifica el token en https://jwt.io/ y verifica que tenga el claim `roles`

### Error: "401 Unauthorized"
- Verifica que el token no haya expirado (5 minutos)
- Obtén un nuevo token

### Error: API Gateway no inicia
- Verifica que Keycloak esté corriendo
- Verifica que el realm TPI-Realm exista
- Verifica que el Client Secret sea correcto

---

## 📚 Archivos de Referencia

- **KEYCLOAK-CONFIGURACION.md** - Guía completa
- **KEYCLOAK-INICIO-RAPIDO.md** - Pasos manuales detallados
- **INTEGRACION-KEYCLOAK-COMPLETADA.md** - Documentación técnica
- **test-keycloak.ps1** - Script de testing automatizado

---

**Próximo Paso:** Completa los 4 pasos manuales en Keycloak Admin Console y luego ejecuta el script de testing.

