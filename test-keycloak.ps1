# Script de Testing - Keycloak + API Gateway
# Uso: powershell -ExecutionPolicy Bypass -File test-keycloak.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Testing Keycloak + API Gateway" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Variables
$KEYCLOAK_URL = "http://localhost:8080"
$REALM = "TPI-Realm"
$CLIENT_ID = "api-gateway-client"
$CLIENT_SECRET = "Txx2xshlS6788zeJFRVpVmhEhlEAnbxg"
$API_GATEWAY_URL = "http://localhost:9090"

# Test 1: Endpoint publico (sin autenticacion)
Write-Host "[Test 1] Probando endpoint publico (sin token)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$API_GATEWAY_URL/api/public/health" -Method Get -ErrorAction Stop
    Write-Host "  Response: $response" -ForegroundColor Green
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 2: Obtener token como Cliente
Write-Host "[Test 2] Obteniendo token para usuario 'cliente'..." -ForegroundColor Yellow
try {
    $tokenResponse = Invoke-RestMethod `
      -Uri "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" `
      -Method Post `
      -ContentType "application/x-www-form-urlencoded" `
      -Body @{
        grant_type = "password"
        client_id = $CLIENT_ID
        client_secret = $CLIENT_SECRET
        username = "cliente"
        password = "Cliente123!"
      } `
      -ErrorAction Stop

    $clienteToken = $tokenResponse.access_token
    Write-Host "  Token obtenido exitosamente" -ForegroundColor Green
    Write-Host "  Expires in: $($tokenResponse.expires_in) segundos" -ForegroundColor White
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 3: Probar endpoint /api/profile (autenticado)
Write-Host "[Test 3] Probando endpoint /api/profile (requiere autenticacion)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod `
      -Uri "$API_GATEWAY_URL/api/profile" `
      -Method Get `
      -Headers @{
        "Authorization" = "Bearer $clienteToken"
      } `
      -ErrorAction Stop

    Write-Host "  Response: $response" -ForegroundColor Green
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 4: Probar endpoint /api/cliente/info (requiere rol cliente)
Write-Host "[Test 4] Probando endpoint /api/cliente/info (requiere rol 'cliente')..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod `
      -Uri "$API_GATEWAY_URL/api/cliente/info" `
      -Method Get `
      -Headers @{
        "Authorization" = "Bearer $clienteToken"
      } `
      -ErrorAction Stop

    Write-Host "  Response: $response" -ForegroundColor Green
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 5: Intentar acceder a endpoint de operador (deberia fallar)
Write-Host "[Test 5] Intentando acceder a /api/operador/dashboard (deberia fallar - 403 Forbidden)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod `
      -Uri "$API_GATEWAY_URL/api/operador/dashboard" `
      -Method Get `
      -Headers @{
        "Authorization" = "Bearer $clienteToken"
      } `
      -ErrorAction Stop

    Write-Host "  Response: $response" -ForegroundColor Red
    Write-Host "  ADVERTENCIA: Deberia haber fallado con 403" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 403) {
        Write-Host "  403 Forbidden - Correcto! El usuario 'cliente' no tiene acceso." -ForegroundColor Green
    } else {
        Write-Host "  Error inesperado: $_" -ForegroundColor Red
    }
}
Write-Host ""

# Test 6: Obtener token como Operador
Write-Host "[Test 6] Obteniendo token para usuario 'operador'..." -ForegroundColor Yellow
try {
    $tokenResponse = Invoke-RestMethod `
      -Uri "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" `
      -Method Post `
      -ContentType "application/x-www-form-urlencoded" `
      -Body @{
        grant_type = "password"
        client_id = $CLIENT_ID
        client_secret = $CLIENT_SECRET
        username = "operador"
        password = "Operador123!"
      } `
      -ErrorAction Stop

    $operadorToken = $tokenResponse.access_token
    Write-Host "  Token obtenido exitosamente" -ForegroundColor Green
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 7: Probar endpoint de operador con token de operador
Write-Host "[Test 7] Probando /api/operador/dashboard con token de operador..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod `
      -Uri "$API_GATEWAY_URL/api/operador/dashboard" `
      -Method Get `
      -Headers @{
        "Authorization" = "Bearer $operadorToken"
      } `
      -ErrorAction Stop

    Write-Host "  Response: $response" -ForegroundColor Green
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 8: Obtener token como Transportista
Write-Host "[Test 8] Obteniendo token para usuario 'transportista'..." -ForegroundColor Yellow
try {
    $tokenResponse = Invoke-RestMethod `
      -Uri "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" `
      -Method Post `
      -ContentType "application/x-www-form-urlencoded" `
      -Body @{
        grant_type = "password"
        client_id = $CLIENT_ID
        client_secret = $CLIENT_SECRET
        username = "transportista"
        password = "Transportista123!"
      } `
      -ErrorAction Stop

    $transportistaToken = $tokenResponse.access_token
    Write-Host "  Token obtenido exitosamente" -ForegroundColor Green
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 9: Probar endpoint de transportista
Write-Host "[Test 9] Probando /api/transportista/rutas con token de transportista..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod `
      -Uri "$API_GATEWAY_URL/api/transportista/rutas" `
      -Method Get `
      -Headers @{
        "Authorization" = "Bearer $transportistaToken"
      } `
      -ErrorAction Stop

    Write-Host "  Response: $response" -ForegroundColor Green
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

# Resumen final
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Resumen de Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si todos los tests pasaron correctamente:" -ForegroundColor Green
Write-Host "  Keycloak esta correctamente configurado" -ForegroundColor White
Write-Host "  API Gateway valida tokens JWT" -ForegroundColor White
Write-Host "  Los roles funcionan correctamente" -ForegroundColor White
Write-Host "  La autorizacion por endpoint funciona" -ForegroundColor White
Write-Host ""
Write-Host "Tokens generados (validos por 5 minutos):" -ForegroundColor Yellow
Write-Host "  Cliente: $clienteToken" -ForegroundColor White
Write-Host "  Operador: $operadorToken" -ForegroundColor White
Write-Host "  Transportista: $transportistaToken" -ForegroundColor White
Write-Host ""

