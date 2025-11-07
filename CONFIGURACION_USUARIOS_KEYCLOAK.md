# Configuración de Usuarios en Keycloak

Este documento detalla cómo configurar los usuarios necesarios para el sistema TPI.

## Usuarios Requeridos

| Username | Password | Rol | Email | Descripción |
|----------|----------|-----|-------|-------------|
| cliente@tpi.com | cliente123 | CLIENTE | cliente@tpi.com | Usuario cliente estándar |
| operador@tpi.com | operador123 | OPERADOR | operador@tpi.com | Usuario operador/admin |
| transportista@tpi.com | transportista123 | TRANSPORTISTA | transportista@tpi.com | Usuario transportista |

---

## Pasos de Configuración

### 1. Acceder a Keycloak Admin Console

1. Abrir navegador: `http://localhost:9090`
2. Click en "Administration Console"
3. Login con:
   - **Username**: `admin`
   - **Password**: `admin123`

### 2. Verificar/Crear Realm `tpi-backend`

1. En el menú superior izquierdo, verificar que el realm `tpi-backend` esté seleccionado
2. Si no existe:
   - Click en el dropdown "master"
   - Click en "Create Realm"
   - **Realm name**: `tpi-backend`
   - **Enabled**: ON
   - Click "Create"

### 3. Verificar/Crear Cliente `tpi-client`

1. En el menú lateral, ir a **Clients** → **Create client** (si no existe)
2. **General Settings**:
   - **Client type**: `OpenID Connect`
   - **Client ID**: `tpi-client`
   - Click "Next"
3. **Capability config**:
   - **Client authentication**: `OFF` (cliente público)
   - **Authorization**: `OFF`
   - **Authentication flow**:
     - ✅ Standard flow
     - ✅ **Direct access grants** (IMPORTANTE: debe estar habilitado)
   - Click "Next"
4. **Login settings**:
   - **Root URL**: `http://localhost:8080`
   - **Valid redirect URIs**: `*` (en producción usar URLs específicas)
   - **Web origins**: `*` (para CORS)
   - Click "Save"

### 4. Crear Roles

1. En el menú lateral, ir a **Realm roles** → **Create role**

**Rol 1: CLIENTE**
- **Role name**: `CLIENTE`
- **Description**: `Cliente que registra solicitudes y consulta estado`
- Click "Save"

**Rol 2: OPERADOR**
- **Role name**: `OPERADOR`
- **Description**: `Operador que gestiona rutas, asigna camiones y administra maestros`
- Click "Save"

**Rol 3: TRANSPORTISTA**
- **Role name**: `TRANSPORTISTA`
- **Description**: `Transportista que inicia y finaliza tramos`
- Click "Save"

### 5. Crear Usuario 1: Cliente

1. En el menú lateral, ir a **Users** → **Create new user**
2. Configurar:
   - **Username**: `cliente@tpi.com`
   - **Email**: `cliente@tpi.com`
   - **Email verified**: `ON` ✅
   - **First name**: `Cliente`
   - **Last name**: `TPI`
   - **Enabled**: `ON` ✅
3. Click "Create"
4. Ir a la pestaña **Credentials**:
   - Click "Set password"
   - **Password**: `cliente123`
   - **Temporary**: `OFF` ✅ (IMPORTANTE: desactivar)
   - Click "Save"
5. Ir a la pestaña **Role mapping**:
   - Click "Assign role"
   - Seleccionar `CLIENTE`
   - Click "Assign"

### 6. Crear Usuario 2: Operador

1. **Users** → **Create new user**
2. Configurar:
   - **Username**: `operador@tpi.com`
   - **Email**: `operador@tpi.com`
   - **Email verified**: `ON` ✅
   - **First name**: `Operador`
   - **Last name**: `TPI`
   - **Enabled**: `ON` ✅
3. Click "Create"
4. **Credentials**:
   - **Password**: `operador123`
   - **Temporary**: `OFF` ✅
5. **Role mapping**:
   - Asignar rol: `OPERADOR`

### 7. Crear Usuario 3: Transportista

1. **Users** → **Create new user**
2. Configurar:
   - **Username**: `transportista@tpi.com`
   - **Email**: `transportista@tpi.com`
   - **Email verified**: `ON` ✅
   - **First name**: `Transportista`
   - **Last name**: `TPI`
   - **Enabled**: `ON` ✅
3. Click "Create"
4. **Credentials**:
   - **Password**: `transportista123`
   - **Temporary**: `OFF` ✅
5. **Role mapping**:
   - Asignar rol: `TRANSPORTISTA`

---

## Verificación

### Probar Login

```bash
# Cliente
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"cliente@tpi.com","password":"cliente123"}'

# Operador
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"operador@tpi.com","password":"operador123"}'

# Transportista
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"transportista@tpi.com","password":"transportista123"}'
```

### Usar Scripts de Automatización

```powershell
# PowerShell
.\get-auth-token.ps1 -Username "cliente@tpi.com" -Password "cliente123"

# Bash
source ./get-auth-token.sh cliente@tpi.com cliente123
```

---

## Troubleshooting

### ❌ Error: "user_not_found"

**Causa**: El usuario no existe en Keycloak

**Solución**: 
1. Verificar que el usuario fue creado en el realm correcto (`tpi-backend`)
2. Verificar que el username es exactamente `cliente@tpi.com` (case-sensitive)

### ❌ Error: "invalid_grant" o "Invalid user credentials"

**Causa**: Contraseña incorrecta o temporal

**Solución**:
1. Verificar la contraseña en Keycloak
2. Ir a **Credentials** del usuario
3. Verificar que "Temporary" esté en `OFF`
4. Si está en `ON`, cambiar contraseña y marcar "Temporary" como `OFF`

### ❌ Error: "Direct access grants disabled"

**Causa**: El cliente `tpi-client` no tiene habilitado "Direct access grants"

**Solución**:
1. Ir a **Clients** → `tpi-client`
2. Ir a la pestaña **Settings**
3. Buscar "Authentication flow"
4. Activar ✅ **Direct access grants enabled**

---

## Notas Importantes

1. **Temporary Password**: Siempre debe estar en `OFF` para que los usuarios puedan autenticarse
2. **Email Verified**: Se recomienda activarlo para evitar problemas de validación
3. **Enabled**: El usuario debe estar habilitado para poder autenticarse
4. **Roles**: Los roles deben estar asignados en "Role mapping", no solo creados

---

**Última actualización**: 2025-01-07

