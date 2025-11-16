# Setup automatico de Keycloak para TPI Backend

$KEYCLOAK_URL = "http://localhost:9090"
$ADMIN_USER = "admin"
$ADMIN_PASSWORD = "admin123"
$REALM = "tpi-backend"
$CLIENT_ID = "tpi-client"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "CONFIGURANDO KEYCLOAK" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Obtener token de admin
Write-Host "1. Obteniendo token de administrador..." -ForegroundColor Yellow

try {
    $tokenResponse = Invoke-RestMethod -Uri "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" `
        -Method Post `
        -ContentType "application/x-www-form-urlencoded" `
        -Body "grant_type=password&client_id=admin-cli&username=$ADMIN_USER&password=$ADMIN_PASSWORD" `
        -ErrorAction Stop
} catch {
    Write-Host "ERROR: No se pudo conectar a Keycloak en $KEYCLOAK_URL" -ForegroundColor Red
    Write-Host "Verifica que Docker este corriendo y Keycloak este disponible" -ForegroundColor Yellow
    exit 1
}

$ADMIN_TOKEN = $tokenResponse.access_token
Write-Host "   Token obtenido`n" -ForegroundColor Green

# 2. Crear Realm
Write-Host "2. Creando realm '$REALM'..." -ForegroundColor Yellow

$realmBody = @{
    realm = $REALM
    enabled = $true
    displayName = "TPI Backend"
    accessTokenLifespan = 1800
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms" `
        -Method Post `
        -ContentType "application/json" `
        -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
        -Body $realmBody `
        -ErrorAction Stop
    
    Write-Host "   Realm '$REALM' creado`n" -ForegroundColor Green
} catch {
    Write-Host "   Realm ya existe, continuando...`n" -ForegroundColor Yellow
}

# 2.1. Configurar duración del token (30 minutos)
Write-Host "2.1. Configurando duración del token a 30 minutos..." -ForegroundColor Yellow

$tokenSettings = @{
    accessTokenLifespan = 1800
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM" `
        -Method Put `
        -ContentType "application/json" `
        -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
        -Body $tokenSettings `
        -ErrorAction Stop
    
    Write-Host "   Token configurado para 30 minutos (1800 segundos)`n" -ForegroundColor Green
} catch {
    Write-Host "   Error configurando duración del token`n" -ForegroundColor Red
}

# 3. Crear Roles
Write-Host "3. Creando roles..." -ForegroundColor Yellow

$roles = @("CLIENTE", "OPERADOR", "TRANSPORTISTA")

foreach ($role in $roles) {
    $roleBody = @{
        name = $role
        description = "Rol $role"
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/roles" `
            -Method Post `
            -ContentType "application/json" `
            -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
            -Body $roleBody `
            -ErrorAction Stop
        
        Write-Host "   Rol '$role' creado" -ForegroundColor Green
    } catch {
        Write-Host "   Rol '$role' ya existe" -ForegroundColor Yellow
    }
}

Write-Host ""

# 4. Verificar si el cliente ya existe
Write-Host "4. Configurando cliente '$CLIENT_ID'..." -ForegroundColor Yellow

$clients = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/clients?clientId=$CLIENT_ID" `
    -Headers @{Authorization = "Bearer $ADMIN_TOKEN"}

# Si existe, eliminarlo primero
if ($clients.Count -gt 0) {
    Write-Host "   Cliente existe, eliminando..." -ForegroundColor Yellow
    $clientInternalId = $clients[0].id
    
    Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/clients/$clientInternalId" `
        -Method Delete `
        -Headers @{Authorization = "Bearer $ADMIN_TOKEN"}
    
    Write-Host "   Cliente eliminado" -ForegroundColor Green
}

# Crear el cliente PÚBLICO
$clientBody = @{
    clientId = $CLIENT_ID
    name = "TPI Backend Client"
    publicClient = $true
    directAccessGrantsEnabled = $true
    standardFlowEnabled = $true
    enabled = $true
    redirectUris = @("*")
    webOrigins = @("*")
    rootUrl = "http://localhost:8080"
    protocol = "openid-connect"
    fullScopeAllowed = $true
} | ConvertTo-Json

Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/clients" `
    -Method Post `
    -ContentType "application/json" `
    -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
    -Body $clientBody

Write-Host "   Cliente '$CLIENT_ID' creado como PUBLICO`n" -ForegroundColor Green

# 5. Crear Usuarios
Write-Host "5. Creando usuarios de prueba..." -ForegroundColor Yellow

$usuarios = @(
    @{username = "cliente@tpi.com"; password = "cliente123"; email = "cliente@tpi.com"; rol = "CLIENTE"; nombre = "Cliente"; apellido = "TPI"},
    @{username = "operador@tpi.com"; password = "operador123"; email = "operador@tpi.com"; rol = "OPERADOR"; nombre = "Operador"; apellido = "TPI"},
    @{username = "transportista@tpi.com"; password = "transportista123"; email = "transportista@tpi.com"; rol = "TRANSPORTISTA"; nombre = "Transportista"; apellido = "TPI"}
)

foreach ($usuario in $usuarios) {
    # Crear usuario
    $userBody = @{
        username = $usuario.username
        email = $usuario.email
        emailVerified = $true
        enabled = $true
        firstName = $usuario.nombre
        lastName = $usuario.apellido
        credentials = @(
            @{
                type = "password"
                value = $usuario.password
                temporary = $false
            }
        )
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/users" `
            -Method Post `
            -ContentType "application/json" `
            -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
            -Body $userBody `
            -ErrorAction Stop
        
        Write-Host "   Usuario '$($usuario.username)' creado" -ForegroundColor Green
    } catch {
        Write-Host "   Usuario '$($usuario.username)' ya existe" -ForegroundColor Yellow
    }
    
    # Obtener ID del usuario (ya sea recién creado o existente)
    $users = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/users?username=$($usuario.username)" `
        -Headers @{Authorization = "Bearer $ADMIN_TOKEN"}
    
    if ($users.Count -gt 0) {
        $userId = $users[0].id
        
        # Obtener el rol a asignar
        $roleMapping = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/roles/$($usuario.rol)" `
            -Headers @{Authorization = "Bearer $ADMIN_TOKEN"}
        
        if ($roleMapping) {
            # Verificar si el usuario ya tiene el rol
            $existingRoles = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/users/$userId/role-mappings/realm" `
                -Headers @{Authorization = "Bearer $ADMIN_TOKEN"}
            
            $hasRole = $false
            foreach ($existingRole in $existingRoles) {
                if ($existingRole.name -eq $usuario.rol) {
                    $hasRole = $true
                    break
                }
            }
            
            if (-not $hasRole) {
                # Asignar rol al usuario
                $rolesToAssign = @(@{
                    id = $roleMapping.id
                    name = $roleMapping.name
                }) | ConvertTo-Json -AsArray
                
                try {
                    Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/users/$userId/role-mappings/realm" `
                        -Method Post `
                        -ContentType "application/json" `
                        -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
                        -Body $rolesToAssign `
                        -ErrorAction Stop
                    
                    Write-Host "      Rol '$($usuario.rol)' asignado" -ForegroundColor Green
                } catch {
                    Write-Host "      Error al asignar rol '$($usuario.rol)'" -ForegroundColor Red
                }
            } else {
                Write-Host "      Rol '$($usuario.rol)' ya estaba asignado" -ForegroundColor Cyan
            }
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "CONFIGURACION COMPLETADA" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Usuarios creados:" -ForegroundColor Cyan
Write-Host "  * cliente@tpi.com / cliente123 (CLIENTE)" -ForegroundColor White
Write-Host "  * operador@tpi.com / operador123 (OPERADOR)" -ForegroundColor White
Write-Host "  * transportista@tpi.com / transportista123 (TRANSPORTISTA)" -ForegroundColor White

Write-Host "`nPrueba el login en:" -ForegroundColor Cyan
Write-Host "  http://localhost:9090/admin" -ForegroundColor White
Write-Host "  Usuario: admin / Contraseña: admin123`n" -ForegroundColor Gray
