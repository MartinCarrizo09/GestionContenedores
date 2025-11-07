# =====================================================
# Script para probar el endpoint /api/gestion/clientes
# =====================================================

$baseUrl = "http://localhost:8080"
$keycloakUrl = "http://localhost:9090"
$realm = "tpi-backend"
$clientId = "tpi-client"
$username = "operador@tpi.com"
$password = "operador123"

Write-Host "🔐 Obteniendo token de Keycloak..." -ForegroundColor Cyan

# Obtener token
try {
    $tokenResponse = Invoke-RestMethod -Uri "$keycloakUrl/realms/$realm/protocol/openid-connect/token" `
        -Method Post `
        -ContentType "application/x-www-form-urlencoded" `
        -Body @{
            client_id = $clientId
            username = $username
            password = $password
            grant_type = "password"
        }
    
    $accessToken = $tokenResponse.access_token
    Write-Host "✅ Token obtenido exitosamente" -ForegroundColor Green
    Write-Host "Token expira en: $($tokenResponse.expires_in) segundos" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Error al obtener token:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Respuesta: $responseBody" -ForegroundColor Yellow
    }
    exit 1
}

Write-Host "`n🔍 Probando endpoint: $baseUrl/api/gestion/clientes" -ForegroundColor Cyan

# Probar endpoint
$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/gestion/clientes" `
        -Method Get `
        -Headers $headers
    
    Write-Host "✅ Éxito! Clientes encontrados:" -ForegroundColor Green
    Write-Host "Total de clientes: $($response.Count)" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "❌ Error al llamar al endpoint:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host "Status Code: $statusCode" -ForegroundColor Yellow
        
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Respuesta del servidor:" -ForegroundColor Yellow
        Write-Host $responseBody
    }
}

