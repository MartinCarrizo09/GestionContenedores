# =====================================================
# Script para probar TODOS los endpoints del sistema
# =====================================================

$baseUrl = "http://localhost:8080"
$keycloakUrl = "http://localhost:9090"
$realm = "tpi-backend"
$clientId = "tpi-client"

# Colores
function Write-Success { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Error-Custom { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Warning-Custom { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Magenta
Write-Host "   PRUEBA DE TODOS LOS ENDPOINTS DEL SISTEMA" -ForegroundColor Magenta
Write-Host "=========================================================" -ForegroundColor Magenta
Write-Host ""

# =====================================================
# 1. OBTENER TOKENS PARA DIFERENTES ROLES
# =====================================================
Write-Info "Obteniendo tokens para diferentes roles..."

try {
    # Token OPERADOR
    $opTokenResp = Invoke-RestMethod -Uri "$keycloakUrl/realms/$realm/protocol/openid-connect/token" `
        -Method Post -ContentType "application/x-www-form-urlencoded" `
        -Body @{
            client_id = $clientId
            username = "operador@tpi.com"
            password = "operador123"
            grant_type = "password"
        }
    $opToken = $opTokenResp.access_token
    Write-Success "Token OPERADOR obtenido"
} catch {
    Write-Error-Custom "Error al obtener token OPERADOR: $($_.Exception.Message)"
    exit 1
}

try {
    # Token CLIENTE
    $clTokenResp = Invoke-RestMethod -Uri "$keycloakUrl/realms/$realm/protocol/openid-connect/token" `
        -Method Post -ContentType "application/x-www-form-urlencoded" `
        -Body @{
            client_id = $clientId
            username = "cliente@tpi.com"
            password = "cliente123"
            grant_type = "password"
        }
    $clToken = $clTokenResp.access_token
    Write-Success "Token CLIENTE obtenido"
} catch {
    Write-Warning-Custom "No se pudo obtener token CLIENTE (puede que el usuario no exista)"
    $clToken = $null
}

try {
    # Token TRANSPORTISTA
    $trTokenResp = Invoke-RestMethod -Uri "$keycloakUrl/realms/$realm/protocol/openid-connect/token" `
        -Method Post -ContentType "application/x-www-form-urlencoded" `
        -Body @{
            client_id = $clientId
            username = "transportista@tpi.com"
            password = "transportista123"
            grant_type = "password"
        }
    $trToken = $trTokenResp.access_token
    Write-Success "Token TRANSPORTISTA obtenido"
} catch {
    Write-Warning-Custom "No se pudo obtener token TRANSPORTISTA (puede que el usuario no exista)"
    $trToken = $null
}

Write-Host ""

# =====================================================
# FUNCIÓN AUXILIAR PARA PROBAR ENDPOINTS
# =====================================================
function Test-Endpoint {
    param(
        [string]$Method,
        [string]$Url,
        [string]$Token,
        [object]$Body = $null,
        [string]$Description
    )
    
    Write-Info "$Description"
    Write-Host "   $Method $Url" -ForegroundColor Gray
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
    }
    
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers -Body ($Body | ConvertTo-Json) -ErrorAction Stop
        } else {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers -ErrorAction Stop
        }
        
        if ($response -is [Array]) {
            Write-Success "   -> Exito: $($response.Count) elementos encontrados"
        } elseif ($response -is [PSCustomObject]) {
            Write-Success "   -> Exito: Objeto devuelto"
            if ($response.id) { Write-Host "      ID: $($response.id)" -ForegroundColor Gray }
        } else {
            Write-Success "   -> Exito: Respuesta recibida"
        }
        return $true
    } catch {
        $statusCode = $null
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            
            if ($statusCode -eq 404) {
                Write-Warning-Custom "   -> 404 Not Found (endpoint puede no existir o no tener datos)"
            } elseif ($statusCode -eq 403) {
                Write-Error-Custom "   -> 403 Forbidden (rol insuficiente)"
            } elseif ($statusCode -eq 401) {
                Write-Error-Custom "   -> 401 Unauthorized (token invalido o expirado)"
            } elseif ($statusCode -eq 400) {
                Write-Warning-Custom "   -> 400 Bad Request: $responseBody"
            } else {
                Write-Error-Custom "   -> Error $statusCode : $responseBody"
            }
        } else {
            Write-Error-Custom "   -> Error: $($_.Exception.Message)"
        }
        return $false
    }
}

# =====================================================
# 2. ENDPOINTS DE GESTIÓN (OPERADOR)
# =====================================================
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host "   ENDPOINTS DE GESTION (Rol: OPERADOR)" -ForegroundColor Yellow
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host ""

Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/clientes" -Token $opToken -Description "1. Listar todos los clientes"
Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/clientes/1" -Token $opToken -Description "2. Obtener cliente por ID"
Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/contenedores" -Token $opToken -Description "3. Listar todos los contenedores"
Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/contenedores/1" -Token $opToken -Description "4. Obtener contenedor por ID"
Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/depositos" -Token $opToken -Description "5. Listar todos los depositos"
Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/depositos/1" -Token $opToken -Description "6. Obtener deposito por ID"
Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/tarifas" -Token $opToken -Description "7. Listar todas las tarifas"
Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/tarifas/1" -Token $opToken -Description "8. Obtener tarifa por ID"

# =====================================================
# 3. ENDPOINTS DE FLOTA (OPERADOR)
# =====================================================
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host "   ENDPOINTS DE FLOTA (Rol: OPERADOR)" -ForegroundColor Yellow
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host ""

Test-Endpoint -Method "GET" -Url "$baseUrl/api/flota/camiones" -Token $opToken -Description "9. Listar todos los camiones"
Test-Endpoint -Method "GET" -Url "$baseUrl/api/flota/camiones/1" -Token $opToken -Description "10. Obtener camion por ID"

# =====================================================
# 4. ENDPOINTS DE LOGÍSTICA (OPERADOR)
# =====================================================
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host "   ENDPOINTS DE LOGISTICA (Rol: OPERADOR)" -ForegroundColor Yellow
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host ""

Test-Endpoint -Method "GET" -Url "$baseUrl/api/logistica/solicitudes/pendientes" -Token $opToken -Description "11. Listar solicitudes pendientes"

# =====================================================
# 5. ENDPOINTS DE CLIENTE
# =====================================================
if ($clToken) {
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Yellow
    Write-Host "   ENDPOINTS DE CLIENTE (Rol: CLIENTE)" -ForegroundColor Yellow
    Write-Host "=========================================================" -ForegroundColor Yellow
    Write-Host ""
    
    Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/contenedores/1/estado" -Token $clToken -Description "12. Consultar estado de contenedor"
    Test-Endpoint -Method "GET" -Url "$baseUrl/api/logistica/solicitudes/cliente/1" -Token $clToken -Description "13. Listar solicitudes del cliente"
} else {
    Write-Warning-Custom "Saltando pruebas de CLIENTE (no hay token disponible)"
}

# =====================================================
# 6. ENDPOINTS DE TRANSPORTISTA
# =====================================================
if ($trToken) {
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Yellow
    Write-Host "   ENDPOINTS DE TRANSPORTISTA (Rol: TRANSPORTISTA)" -ForegroundColor Yellow
    Write-Host "=========================================================" -ForegroundColor Yellow
    Write-Host ""
    
    Test-Endpoint -Method "GET" -Url "$baseUrl/api/logistica/tramos/camion/1" -Token $trToken -Description "14. Listar tramos de un camion"
} else {
    Write-Warning-Custom "Saltando pruebas de TRANSPORTISTA (no hay token disponible)"
}

# =====================================================
# 7. HEALTH CHECKS
# =====================================================
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host "   HEALTH CHECKS (Publicos)" -ForegroundColor Yellow
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host ""

try {
    $health = Invoke-RestMethod -Uri "$baseUrl/actuator/health" -Method Get -ErrorAction Stop
    Write-Success "15. Health check del Gateway: OK"
} catch {
    Write-Error-Custom "15. Health check del Gateway: Error"
}

# =====================================================
# RESUMEN
# =====================================================
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Magenta
Write-Host "   PRUEBAS COMPLETADAS" -ForegroundColor Magenta
Write-Host "=========================================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "[INFO] Nota: Algunos endpoints pueden devolver 404 si no hay datos" -ForegroundColor Gray
Write-Host "       o si los IDs de prueba no existen. Esto es normal." -ForegroundColor Gray
Write-Host ""
