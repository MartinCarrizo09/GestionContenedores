# =====================================================
# Script de Inicialización Completa del Sistema TPI
# =====================================================
# Este script:
# 1. Espera a que Keycloak esté disponible
# 2. Configura Keycloak (realm, roles, clientes, usuarios)
# 3. Obtiene tokens para los 3 roles
# =====================================================

param(
    [string]$GatewayUrl = "http://localhost:8080",
    [string]$KeycloakUrl = "http://localhost:9090"
)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "INICIANDO SISTEMA COMPLETO TPI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Variables de configuración
$KEYCLOAK_URL = $KeycloakUrl
$GATEWAY_URL = $GatewayUrl
$ADMIN_USER = "admin"
$ADMIN_PASSWORD = "admin123"
$REALM = "tpi-backend"
$CLIENT_ID = "tpi-client"

# =====================================================
# PASO 1: Esperar a que Keycloak esté disponible
# =====================================================
Write-Host "1. Esperando a que Keycloak esté disponible..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
$keycloakReady = $false

while (-not $keycloakReady -and $attempt -lt $maxAttempts) {
    $attempt++
    Write-Host "   Intento $attempt/$maxAttempts..." -NoNewline
    try {
        $response = Invoke-WebRequest -Uri "$KEYCLOAK_URL/realms/master" -Method GET -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $keycloakReady = $true
            Write-Host " OK"
        }
    } catch {
        Write-Host " esperando..."
        Start-Sleep -Seconds 2
    }
}

if (-not $keycloakReady) {
    Write-Host ""
    Write-Host "ERROR: Keycloak no está disponible en $KEYCLOAK_URL" -ForegroundColor Red
    Write-Host "Verifica que Docker esté corriendo y Keycloak esté disponible" -ForegroundColor Yellow
    exit 1
}

Write-Host "   Keycloak está listo!" -ForegroundColor Green
Write-Host ""

# =====================================================
# PASO 2: Configurar Keycloak
# =====================================================
Write-Host "2. Configurando Keycloak..." -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

# 2.1. Obtener token de admin
Write-Host "2.1. Obteniendo token de administrador..." -ForegroundColor Yellow

try {
    $tokenResponse = Invoke-RestMethod -Uri "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" `
        -Method Post `
        -ContentType "application/x-www-form-urlencoded" `
        -Body "grant_type=password&client_id=admin-cli&username=$ADMIN_USER&password=$ADMIN_PASSWORD" `
        -ErrorAction Stop
} catch {
    Write-Host "ERROR: No se pudo conectar a Keycloak en $KEYCLOAK_URL" -ForegroundColor Red
    Write-Host "Verifica que Docker esté corriendo y Keycloak esté disponible" -ForegroundColor Yellow
    exit 1
}

$ADMIN_TOKEN = $tokenResponse.access_token
Write-Host "   Token obtenido`n" -ForegroundColor Green

# 2.2. Verificar/Crear Realm
Write-Host "2.2. Verificando/Creando realm '$REALM'..." -ForegroundColor Yellow

# Verificar si el realm existe
$realmExists = $false
try {
    $realmCheck = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM" `
        -Method Get `
        -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
        -ErrorAction Stop
    $realmExists = $true
    Write-Host "   Realm '$REALM' ya existe" -ForegroundColor Green
} catch {
    # Realm no existe, hay que crearlo
    $realmExists = $false
}

# Crear realm si no existe
if (-not $realmExists) {
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
        
        Write-Host "   Realm '$REALM' creado" -ForegroundColor Green
        
        # Esperar a que Keycloak propague el realm (importante!)
        Write-Host "   Esperando que Keycloak propague el realm..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
        
        # Verificar que el realm esté disponible
        $realmAvailable = $false
        $verificationAttempts = 0
        $maxVerificationAttempts = 10
        
        while (-not $realmAvailable -and $verificationAttempts -lt $maxVerificationAttempts) {
            $verificationAttempts++
            try {
                $realmVerify = Invoke-WebRequest -Uri "$KEYCLOAK_URL/realms/$REALM" `
                    -Method Get `
                    -TimeoutSec 3 `
                    -ErrorAction Stop
                if ($realmVerify.StatusCode -eq 200) {
                    $realmAvailable = $true
                    Write-Host "   Realm '$REALM' verificado y disponible" -ForegroundColor Green
                }
            } catch {
                if ($verificationAttempts -lt $maxVerificationAttempts) {
                    Start-Sleep -Seconds 2
                }
            }
        }
        
        if (-not $realmAvailable) {
            Write-Host "   Warning: El realm puede no estar completamente disponible aún" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "   ERROR al crear el realm: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   Detalle: $($_.ErrorDetails.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

# 2.3. Configurar duración del token (30 minutos)
Write-Host "2.3. Configurando duración del token a 30 minutos..." -ForegroundColor Yellow

try {
    # Primero obtener la configuración actual del realm
    $realmConfig = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM" `
        -Method Get `
        -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
        -ErrorAction Stop
    
    # Actualizar solo la duración del token
    $realmConfig.accessTokenLifespan = 1800
    
    $tokenSettings = $realmConfig | ConvertTo-Json -Depth 10
    
    Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM" `
        -Method Put `
        -ContentType "application/json" `
        -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
        -Body $tokenSettings `
        -ErrorAction Stop
    
    Write-Host "   Token configurado para 30 minutos (1800 segundos)" -ForegroundColor Green
} catch {
    Write-Host "   Error configurando duración del token: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 2.4. Crear Roles
Write-Host "2.4. Creando roles..." -ForegroundColor Yellow

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

# 2.5. Configurar Cliente
Write-Host "2.5. Configurando cliente '$CLIENT_ID'..." -ForegroundColor Yellow

try {
    $clients = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/clients?clientId=$CLIENT_ID" `
        -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
        -ErrorAction Stop

    # Si existe, eliminarlo primero
    if ($clients.Count -gt 0) {
        Write-Host "   Cliente existe, eliminando..." -ForegroundColor Yellow
        $clientInternalId = $clients[0].id
        
        try {
            Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/clients/$clientInternalId" `
                -Method Delete `
                -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
                -ErrorAction Stop
            
            Write-Host "   Cliente eliminado" -ForegroundColor Green
            Start-Sleep -Seconds 2
        } catch {
            Write-Host "   Warning: No se pudo eliminar el cliente existente" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   No se encontró cliente existente" -ForegroundColor Gray
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

try {
    Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/clients" `
        -Method Post `
        -ContentType "application/json" `
        -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
        -Body $clientBody `
        -ErrorAction Stop

    Write-Host "   Cliente '$CLIENT_ID' creado como PUBLICO" -ForegroundColor Green
    
    # Esperar un poco para que Keycloak propague el cliente
    Start-Sleep -Seconds 2
    
} catch {
    Write-Host "   ERROR al crear el cliente: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "   Detalle: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

Write-Host ""

# 2.6. Crear Usuarios
Write-Host "2.6. Creando usuarios de prueba..." -ForegroundColor Yellow

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
                $rolesToAssign = @(
                    @{
                        id = $roleMapping.id
                        name = $roleMapping.name
                    }
                )
                
                $rolesJson = $rolesToAssign | ConvertTo-Json
                
                try {
                    Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM/users/$userId/role-mappings/realm" `
                        -Method Post `
                        -ContentType "application/json" `
                        -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
                        -Body $rolesJson `
                        -ErrorAction Stop
                    
                    Write-Host "      Rol '$($usuario.rol)' asignado" -ForegroundColor Green
                } catch {
                    Write-Host "      Error al asignar rol '$($usuario.rol)': $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "      Rol '$($usuario.rol)' ya estaba asignado" -ForegroundColor Cyan
            }
        }
    }
}

Write-Host ""

# =====================================================
# PASO 2.7: Verificar que el realm esté completamente configurado
# =====================================================
Write-Host "2.7. Verificando configuración final del realm..." -ForegroundColor Yellow

# Verificar que el realm esté disponible para obtener tokens
$realmReady = $false
$readyAttempts = 0
$maxReadyAttempts = 15

while (-not $realmReady -and $readyAttempts -lt $maxReadyAttempts) {
    $readyAttempts++
    try {
        # Intentar obtener la configuración del realm
        $realmTest = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM" `
            -Method Get `
            -Headers @{Authorization = "Bearer $ADMIN_TOKEN"} `
            -ErrorAction Stop
        
        # Intentar acceder al endpoint público del realm
        $realmPublic = Invoke-WebRequest -Uri "$KEYCLOAK_URL/realms/$REALM/.well-known/openid-configuration" `
            -Method Get `
            -TimeoutSec 3 `
            -ErrorAction Stop
        
        if ($realmPublic.StatusCode -eq 200) {
            $realmReady = $true
            Write-Host "   Realm '$REALM' completamente configurado y disponible" -ForegroundColor Green
        }
    } catch {
        if ($readyAttempts -lt $maxReadyAttempts) {
            Write-Host "   Intento $readyAttempts/$maxReadyAttempts..." -ForegroundColor Gray
            Start-Sleep -Seconds 2
        }
    }
}

if (-not $realmReady) {
    Write-Host "   Warning: El realm puede no estar completamente listo" -ForegroundColor Yellow
    Write-Host "   Continuando de todas formas..." -ForegroundColor Yellow
}

Write-Host ""

# =====================================================
# PASO 3: Obtener Tokens para Testing
# =====================================================
Write-Host "3. Obteniendo tokens para los 3 roles..." -ForegroundColor Yellow
Write-Host ""

$usuariosTokens = @(
    @{ Rol = "CLIENTE"; Username = "cliente@tpi.com"; Password = "cliente123"; VarPrefix = "CLIENTE" },
    @{ Rol = "OPERADOR"; Username = "operador@tpi.com"; Password = "operador123"; VarPrefix = "OPERADOR" },
    @{ Rol = "TRANSPORTISTA"; Username = "transportista@tpi.com"; Password = "transportista123"; VarPrefix = "TRANSPORTISTA" }
)

$exitosos = 0

foreach ($usuario in $usuariosTokens) {
    Write-Host "   $($usuario.Rol)..." -ForegroundColor Yellow
    $body = @{ username = $usuario.Username; password = $usuario.Password } | ConvertTo-Json
    try {
        $r = Invoke-RestMethod -Uri "$GATEWAY_URL/auth/login" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        Set-Item -Path "Env:$($usuario.VarPrefix)_TOKEN" -Value $r.access_token
        Set-Item -Path "Env:$($usuario.VarPrefix)_REFRESH" -Value $r.refresh_token
        Write-Host "      OK - Expira en: $($r.expires_in)s" -ForegroundColor Green
        $exitosos++
    } catch {
        Write-Host "      Error al obtener token" -ForegroundColor Red
    }
}

Write-Host ""
if ($exitosos -eq 3) {
    Write-Host "   $exitosos/3 tokens configurados correctamente" -ForegroundColor Green
} else {
    Write-Host "   $exitosos/3 tokens configurados (algunos pueden haber fallado)" -ForegroundColor Yellow
}
Write-Host ""

# =====================================================
# RESUMEN FINAL
# =====================================================
Write-Host "========================================" -ForegroundColor Green
Write-Host "CONFIGURACION COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Usuarios creados:" -ForegroundColor Cyan
Write-Host "  * cliente@tpi.com / cliente123 (CLIENTE)" -ForegroundColor White
Write-Host "  * operador@tpi.com / operador123 (OPERADOR)" -ForegroundColor White
Write-Host "  * transportista@tpi.com / transportista123 (TRANSPORTISTA)" -ForegroundColor White
Write-Host ""

Write-Host "Variables de entorno configuradas:" -ForegroundColor Cyan
Write-Host "  * `$env:CLIENTE_TOKEN" -ForegroundColor White
Write-Host "  * `$env:CLIENTE_REFRESH" -ForegroundColor White
Write-Host "  * `$env:OPERADOR_TOKEN" -ForegroundColor White
Write-Host "  * `$env:OPERADOR_REFRESH" -ForegroundColor White
Write-Host "  * `$env:TRANSPORTISTA_TOKEN" -ForegroundColor White
Write-Host "  * `$env:TRANSPORTISTA_REFRESH" -ForegroundColor White
Write-Host ""

Write-Host "URLs del sistema:" -ForegroundColor Cyan
Write-Host "  * Keycloak Admin: http://localhost:9090/admin" -ForegroundColor White
Write-Host "    Usuario: admin / Contraseña: admin123" -ForegroundColor Gray
Write-Host "  * API Gateway: http://localhost:8080" -ForegroundColor White
Write-Host ""

Write-Host "Sistema listo para usar!" -ForegroundColor Green
Write-Host "Ejecuta 'Obtener Token' en las colecciones de Postman" -ForegroundColor Yellow
Write-Host ""

