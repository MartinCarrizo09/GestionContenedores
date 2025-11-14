# =====================================================
# SCRIPT DE INICIO AUTOMÁTICO - SISTEMA TPI
# =====================================================
# Este script levanta Docker Compose y configura Keycloak
# automáticamente sin necesidad de configuraciones manuales.
# 
# USO:
#   .\iniciar-sistema.ps1
# =====================================================

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  🚀 INICIANDO SISTEMA TPI" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Variables de configuración
$KEYCLOAK_URL = "http://localhost:9090"
$KEYCLOAK_ADMIN_USER = "admin"
$KEYCLOAK_ADMIN_PASSWORD = "admin123"
$REALM_NAME = "tpi-backend"
$CLIENT_ID = "tpi-client"
$GATEWAY_URL = "http://localhost:8080"

# =====================================================
# PASO 1: Verificar Docker
# =====================================================
Write-Host "📦 Verificando Docker..." -ForegroundColor Yellow

try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker no está disponible"
    }
    Write-Host "   ✅ Docker está disponible: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ ERROR: Docker no está instalado o no está corriendo" -ForegroundColor Red
    Write-Host "   Por favor instala Docker Desktop y vuelve a intentar" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# =====================================================
# PASO 2: Detener contenedores existentes (si hay)
# =====================================================
Write-Host "🛑 Deteniendo contenedores existentes (si hay)..." -ForegroundColor Yellow
docker-compose down 2>&1 | Out-Null
Write-Host "   ✅ Limpieza completada" -ForegroundColor Green
Write-Host ""

# =====================================================
# PASO 3: Levantar Docker Compose
# =====================================================
Write-Host "🐳 Levantando servicios Docker..." -ForegroundColor Yellow
Write-Host "   Esto puede tomar varios minutos en la primera ejecución..." -ForegroundColor Gray
Write-Host ""

try {
    docker-compose up -d
    if ($LASTEXITCODE -ne 0) {
        throw "Error al levantar Docker Compose"
    }
    Write-Host "   ✅ Servicios Docker iniciados" -ForegroundColor Green
} catch {
    Write-Host "   ❌ ERROR: No se pudieron levantar los servicios Docker" -ForegroundColor Red
    Write-Host "   Verifica los logs con: docker-compose logs" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# =====================================================
# PASO 4: Esperar a que Keycloak esté listo
# =====================================================
Write-Host "⏳ Esperando a que Keycloak esté listo..." -ForegroundColor Yellow
Write-Host "   (Esto puede tomar hasta 2 minutos)" -ForegroundColor Gray

$maxAttempts = 60
$attempt = 0
$keycloakReady = $false

while ($attempt -lt $maxAttempts -and -not $keycloakReady) {
    $attempt++
    Start-Sleep -Seconds 2
    
    try {
        $response = Invoke-WebRequest -Uri "$KEYCLOAK_URL/health/ready" -Method GET -TimeoutSec 2 -ErrorAction Stop 2>&1
        if ($response.StatusCode -eq 200) {
            $keycloakReady = $true
        }
    } catch {
        # Intentar también el endpoint raíz
        try {
            $response = Invoke-WebRequest -Uri "$KEYCLOAK_URL" -Method GET -TimeoutSec 2 -ErrorAction Stop 2>&1
            if ($response.StatusCode -eq 200) {
                $keycloakReady = $true
            }
        } catch {
            # Continuar esperando
        }
    }
    
    if (-not $keycloakReady) {
        Write-Host "   ⏳ Intento $attempt/$maxAttempts..." -ForegroundColor Gray
    }
}

if (-not $keycloakReady) {
    Write-Host "   ⚠️  Keycloak no respondió en el tiempo esperado" -ForegroundColor Yellow
    Write-Host "   Continuando de todas formas..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
} else {
    Write-Host "   ✅ Keycloak está listo" -ForegroundColor Green
}

Write-Host ""

# =====================================================
# PASO 5: Obtener token de administrador de Keycloak
# =====================================================
Write-Host "🔑 Obteniendo token de administrador de Keycloak..." -ForegroundColor Yellow

$adminToken = $null
$maxTokenAttempts = 10
$tokenAttempt = 0

while ($tokenAttempt -lt $maxTokenAttempts -and -not $adminToken) {
    $tokenAttempt++
    
    try {
        $bodyParams = @{
            username = $KEYCLOAK_ADMIN_USER
            password = $KEYCLOAK_ADMIN_PASSWORD
            grant_type = "password"
            client_id = "admin-cli"
        }
        
        # Codificar URL manualmente (compatible con PowerShell)
        $bodyPairs = @()
        foreach ($key in $bodyParams.Keys) {
            $value = $bodyParams[$key]
            $encodedKey = [System.Uri]::EscapeDataString($key)
            $encodedValue = [System.Uri]::EscapeDataString($value)
            $bodyPairs += "$encodedKey=$encodedValue"
        }
        $bodyString = $bodyPairs -join "&"
        
        $response = Invoke-RestMethod -Uri "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" `
            -Method POST `
            -ContentType "application/x-www-form-urlencoded" `
            -Body $bodyString `
            -ErrorAction Stop
        
        $adminToken = $response.access_token
    } catch {
        if ($tokenAttempt -lt $maxTokenAttempts) {
            Start-Sleep -Seconds 3
        }
    }
}

if (-not $adminToken) {
    Write-Host "   ⚠️  No se pudo obtener token de administrador" -ForegroundColor Yellow
    Write-Host "   La configuración manual será necesaria" -ForegroundColor Yellow
    Write-Host "   Ver guía en: CONFIGURACION_USUARIOS_KEYCLOAK.md" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "✅ Docker está corriendo" -ForegroundColor Green
    Write-Host "⚠️  Necesitas configurar Keycloak manualmente" -ForegroundColor Yellow
    exit 0
}

Write-Host "   ✅ Token de administrador obtenido" -ForegroundColor Green
Write-Host ""

# =====================================================
# PASO 6: Crear Realm
# =====================================================
Write-Host "🏛️  Configurando Realm '$REALM_NAME'..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $adminToken"
    "Content-Type" = "application/json"
}

# Verificar si el realm ya existe
try {
    $response = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop
    Write-Host "   ℹ️  Realm '$REALM_NAME' ya existe" -ForegroundColor Gray
} catch {
    # Crear el realm
    $realmConfig = @{
        realm = $REALM_NAME
        enabled = $true
        displayName = "TPI Backend"
        displayNameHtml = "<div class='kc-logo-text'><span>TPI Backend</span></div>"
    } | ConvertTo-Json -Depth 10
    
    try {
        Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms" `
            -Method POST `
            -Headers $headers `
            -Body $realmConfig `
            -ErrorAction Stop | Out-Null
        Write-Host "   ✅ Realm '$REALM_NAME' creado" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  No se pudo crear el realm (puede que ya exista)" -ForegroundColor Yellow
    }
}

# =====================================================
# PASO 7: Crear Cliente
# =====================================================
Write-Host "🔐 Configurando Cliente '$CLIENT_ID'..." -ForegroundColor Yellow

# Verificar si el cliente ya existe
try {
    $response = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/clients?clientId=$CLIENT_ID" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop
    
    if ($response.Count -gt 0) {
        Write-Host "   ℹ️  Cliente '$CLIENT_ID' ya existe" -ForegroundColor Gray
        $clientId = $response[0].id
    } else {
        throw "Cliente no encontrado"
    }
} catch {
    # Crear el cliente
    $clientConfig = @{
        clientId = $CLIENT_ID
        enabled = $true
        protocol = "openid-connect"
        publicClient = $true
        standardFlowEnabled = $true
        directAccessGrantsEnabled = $true
        rootUrl = $GATEWAY_URL
        redirectUris = @("*")
        webOrigins = @("*")
    } | ConvertTo-Json -Depth 10
    
    try {
        Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/clients" `
            -Method POST `
            -Headers $headers `
            -Body $clientConfig `
            -ErrorAction Stop | Out-Null
        Write-Host "   ✅ Cliente '$CLIENT_ID' creado" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  No se pudo crear el cliente: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Obtener el ID del cliente
try {
    $response = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/clients?clientId=$CLIENT_ID" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop
    $clientId = $response[0].id
} catch {
    Write-Host "   ⚠️  No se pudo obtener el ID del cliente" -ForegroundColor Yellow
}

# =====================================================
# PASO 8: Crear Roles
# =====================================================
Write-Host "👥 Configurando Roles..." -ForegroundColor Yellow

$roles = @(
    @{ name = "CLIENTE"; description = "Cliente que registra solicitudes y consulta estado" },
    @{ name = "OPERADOR"; description = "Operador que gestiona rutas, asigna camiones y administra maestros" },
    @{ name = "TRANSPORTISTA"; description = "Transportista que inicia y finaliza tramos" }
)

foreach ($role in $roles) {
    try {
        # Verificar si el rol ya existe
        Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles/$($role.name)" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop | Out-Null
        Write-Host "   ℹ️  Rol '$($role.name)' ya existe" -ForegroundColor Gray
    } catch {
        # Crear el rol
        $roleConfig = @{
            name = $role.name
            description = $role.description
        } | ConvertTo-Json
        
        try {
            Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles" `
                -Method POST `
                -Headers $headers `
                -Body $roleConfig `
                -ErrorAction Stop | Out-Null
            Write-Host "   ✅ Rol '$($role.name)' creado" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️  No se pudo crear el rol '$($role.name)'" -ForegroundColor Yellow
        }
    }
}

# =====================================================
# PASO 9: Crear Usuarios
# =====================================================
Write-Host "👤 Configurando Usuarios..." -ForegroundColor Yellow

$users = @(
    @{ username = "cliente@tpi.com"; password = "cliente123"; email = "cliente@tpi.com"; firstName = "Cliente"; lastName = "TPI"; role = "CLIENTE" },
    @{ username = "operador@tpi.com"; password = "operador123"; email = "operador@tpi.com"; firstName = "Operador"; lastName = "TPI"; role = "OPERADOR" },
    @{ username = "transportista@tpi.com"; password = "transportista123"; email = "transportista@tpi.com"; firstName = "Transportista"; lastName = "TPI"; role = "TRANSPORTISTA" }
)

foreach ($user in $users) {
    try {
        # Verificar si el usuario ya existe
        $response = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users?username=$($user.username)" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop
        
        if ($response.Count -gt 0) {
            Write-Host "   ℹ️  Usuario '$($user.username)' ya existe" -ForegroundColor Gray
            $userId = $response[0].id
        } else {
            throw "Usuario no encontrado"
        }
    } catch {
        # Crear el usuario
        $userConfig = @{
            username = $user.username
            email = $user.email
            emailVerified = $true
            enabled = $true
            firstName = $user.firstName
            lastName = $user.lastName
        } | ConvertTo-Json
        
        try {
            $response = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users" `
                -Method POST `
                -Headers $headers `
                -Body $userConfig `
                -ErrorAction Stop
            
            # Obtener el ID del usuario creado
            $response = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users?username=$($user.username)" `
                -Method GET `
                -Headers $headers `
                -ErrorAction Stop
            $userId = $response[0].id
            
            Write-Host "   ✅ Usuario '$($user.username)' creado" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️  No se pudo crear el usuario '$($user.username)'" -ForegroundColor Yellow
            continue
        }
    }
    
    # Configurar contraseña
    try {
        $passwordConfig = @{
            type = "password"
            value = $user.password
            temporary = $false
        } | ConvertTo-Json
        
        Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users/$userId/reset-password" `
            -Method PUT `
            -Headers $headers `
            -Body $passwordConfig `
            -ErrorAction Stop | Out-Null
        Write-Host "      ✅ Contraseña configurada para '$($user.username)'" -ForegroundColor Green
    } catch {
        Write-Host "      ⚠️  No se pudo configurar la contraseña para '$($user.username)'" -ForegroundColor Yellow
    }
    
    # Asignar rol
    try {
        $roleResponse = Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles/$($user.role)" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop
        
        $roleAssign = @($roleResponse) | ConvertTo-Json
        
        Invoke-RestMethod -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users/$userId/role-mappings/realm" `
            -Method POST `
            -Headers $headers `
            -Body $roleAssign `
            -ErrorAction Stop | Out-Null
        Write-Host "      ✅ Rol '$($user.role)' asignado a '$($user.username)'" -ForegroundColor Green
    } catch {
        Write-Host "      ⚠️  No se pudo asignar el rol '$($user.role)' a '$($user.username)'" -ForegroundColor Yellow
    }
}

Write-Host ""

# =====================================================
# PASO 10: Verificar servicios
# =====================================================
Write-Host "🔍 Verificando servicios..." -ForegroundColor Yellow

Start-Sleep -Seconds 5

$services = @(
    @{ name = "PostgreSQL"; container = "tpi-postgres"; port = "5432" },
    @{ name = "Keycloak"; container = "tpi-keycloak"; port = "9090" },
    @{ name = "API Gateway"; container = "tpi-gateway"; port = "8080" },
    @{ name = "Servicio Gestión"; container = "tpi-gestion"; port = "8081" },
    @{ name = "Servicio Flota"; container = "tpi-flota"; port = "8082" },
    @{ name = "Servicio Logística"; container = "tpi-logistica"; port = "8083" }
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$($service.port)/actuator/health" -Method GET -TimeoutSec 2 -ErrorAction Stop 2>&1
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ $($service.name) - http://localhost:$($service.port)" -ForegroundColor Green
        }
    } catch {
        # Intentar también con el gateway
        if ($service.port -eq "8081" -or $service.port -eq "8082" -or $service.port -eq "8083") {
            Write-Host "   ⚠️  $($service.name) - Verificar logs: docker logs $($service.container)" -ForegroundColor Yellow
        } else {
            Write-Host "   ⚠️  $($service.name) - Verificar logs: docker logs $($service.container)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

# =====================================================
# RESUMEN FINAL
# =====================================================
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ✅ SISTEMA INICIADO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 URLs del Sistema:" -ForegroundColor Cyan
Write-Host "   Keycloak Admin: http://localhost:9090" -ForegroundColor White
Write-Host "      Usuario: admin / Password: admin123" -ForegroundColor Gray
Write-Host ""
Write-Host "   API Gateway: http://localhost:8080" -ForegroundColor White
Write-Host "   Swagger UI: http://localhost:8080/swagger-ui.html" -ForegroundColor White
Write-Host ""
Write-Host "👤 Usuarios de Prueba:" -ForegroundColor Cyan
Write-Host "   Cliente: cliente@tpi.com / cliente123" -ForegroundColor White
Write-Host "   Operador: operador@tpi.com / operador123" -ForegroundColor White
Write-Host "   Transportista: transportista@tpi.com / transportista123" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Comandos Útiles:" -ForegroundColor Cyan
Write-Host "   Ver logs: docker-compose logs -f" -ForegroundColor Gray
Write-Host "   Detener: docker-compose down" -ForegroundColor Gray
Write-Host "   Reiniciar: docker-compose restart" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ ¡Listo para usar!" -ForegroundColor Green
Write-Host ""

