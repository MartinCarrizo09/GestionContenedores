# =====================================================
# Script para Corregir Asignacion de Roles en Keycloak
# =====================================================

$ErrorActionPreference = "Continue"

$KEYCLOAK_URL = "http://localhost:9090"
$REALM = "tpi-backend"
$ADMIN_USER = "admin"
$ADMIN_PASS = "admin123"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CORRIGIENDO ROLES DE USUARIOS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Obtener token de admin
Write-Host "1. Obteniendo token de administrador..." -ForegroundColor Yellow

$adminTokenBody = @{
    grant_type = "password"
    client_id = "admin-cli"
    username = $ADMIN_USER
    password = $ADMIN_PASS
}

try {
    $adminTokenResponse = Invoke-RestMethod -Uri "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" `
        -Method Post `
        -ContentType "application/x-www-form-urlencoded" `
        -Body $adminTokenBody `
        -ErrorAction Stop
    
    $ADMIN_TOKEN = $adminTokenResponse.access_token
    Write-Host "   Token obtenido" -ForegroundColor Green
} catch {
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Funcion para obtener ID de usuario
function Get-UserId {
    param([string]$Username, [string]$Token)
    
    try {
        $users = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/users?username=$Username" `
            -Method Get `
            -Headers @{Authorization = "Bearer $Token"} `
            -ErrorAction Stop
        
        if ($users.Count -gt 0) {
            return $users[0].id
        }
        return $null
    } catch {
        Write-Host "      Error buscando usuario: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Funcion para obtener ID de rol
function Get-RoleId {
    param([string]$RoleName, [string]$Token)
    
    try {
        $role = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/roles/$RoleName" `
            -Method Get `
            -Headers @{Authorization = "Bearer $Token"} `
            -ErrorAction Stop
        
        return $role
    } catch {
        Write-Host "      Error buscando rol: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Funcion para asignar rol a usuario
function Assign-Role {
    param(
        [string]$UserId,
        [string]$RoleName,
        [string]$Token
    )
    
    $role = Get-RoleId -RoleName $RoleName -Token $Token
    
    if ($null -eq $role) {
        Write-Host "      Rol '$RoleName' no encontrado" -ForegroundColor Red
        return $false
    }
    
    $roleBody = @(
        @{
            id = $role.id
            name = $role.name
        }
    ) | ConvertTo-Json
    
    # Asegurar que es un array JSON
    if (-not $roleBody.StartsWith('[')) {
        $roleBody = "[$roleBody]"
    }
    
    try {
        Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/users/$UserId/role-mappings/realm" `
            -Method Post `
            -Headers @{
                Authorization = "Bearer $Token"
                "Content-Type" = "application/json"
            } `
            -Body $roleBody `
            -ErrorAction Stop | Out-Null
        
        return $true
    } catch {
        Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Red
        
        # Intentar metodo alternativo
        Write-Host "      Intentando metodo alternativo..." -ForegroundColor Yellow
        
        try {
            # Obtener roles disponibles del usuario
            $availableRoles = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/users/$UserId/role-mappings/realm/available" `
                -Method Get `
                -Headers @{Authorization = "Bearer $Token"} `
                -ErrorAction Stop
            
            $targetRole = $availableRoles | Where-Object { $_.name -eq $RoleName }
            
            if ($null -ne $targetRole) {
                $alternativeBody = @(
                    @{
                        id = $targetRole.id
                        name = $targetRole.name
                    }
                ) | ConvertTo-Json -AsArray
                
                Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/users/$UserId/role-mappings/realm" `
                    -Method Post `
                    -Headers @{
                        Authorization = "Bearer $Token"
                        "Content-Type" = "application/json"
                    } `
                    -Body $alternativeBody `
                    -ErrorAction Stop | Out-Null
                
                return $true
            }
        } catch {
            Write-Host "      Metodo alternativo fallo: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        return $false
    }
}

# Asignar roles
Write-Host "2. Asignando roles a usuarios..." -ForegroundColor Yellow
Write-Host ""

$usuarios = @(
    @{Username = "cliente@tpi.com"; Role = "CLIENTE"},
    @{Username = "operador@tpi.com"; Role = "OPERADOR"},
    @{Username = "transportista@tpi.com"; Role = "TRANSPORTISTA"}
)

$exitosos = 0
$fallidos = 0

foreach ($usuario in $usuarios) {
    Write-Host "   Procesando $($usuario.Username)..." -ForegroundColor Cyan
    
    $userId = Get-UserId -Username $usuario.Username -Token $ADMIN_TOKEN
    
    if ($null -eq $userId) {
        Write-Host "      Usuario no encontrado" -ForegroundColor Red
        $fallidos++
        continue
    }
    
    Write-Host "      Usuario ID: $userId" -ForegroundColor Gray
    
    $success = Assign-Role -UserId $userId -RoleName $usuario.Role -Token $ADMIN_TOKEN
    
    if ($success) {
        Write-Host "      Rol '$($usuario.Role)' asignado correctamente" -ForegroundColor Green
        $exitosos++
    } else {
        Write-Host "      Fallo al asignar rol '$($usuario.Role)'" -ForegroundColor Red
        $fallidos++
    }
    
    Write-Host ""
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RESULTADO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Roles asignados exitosamente: $exitosos/3" -ForegroundColor $(if ($exitosos -eq 3) { "Green" } else { "Yellow" })
Write-Host "Fallos: $fallidos/3" -ForegroundColor $(if ($fallidos -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($exitosos -eq 3) {
    Write-Host "Todos los roles fueron asignados correctamente" -ForegroundColor Green
    Write-Host "Ya puedes ejecutar el script de testing" -ForegroundColor Green
} else {
    Write-Host "Algunos roles no pudieron ser asignados" -ForegroundColor Yellow
    Write-Host "Verifica manualmente en Keycloak Admin Console" -ForegroundColor Yellow
}

Write-Host ""
