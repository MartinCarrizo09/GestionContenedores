# Script completo de inicializacion
Write-Host ""
Write-Host "========================================"
Write-Host "INICIANDO SISTEMA COMPLETO"
Write-Host "========================================"
Write-Host ""

$KEYCLOAK_URL = "http://localhost:9090"
$REALM = "tpi-backend"
$ADMIN_USER = "admin"
$ADMIN_PASS = "admin123"
$CLIENT_ID = "tpi-client"

# Esperar a que Keycloak este listo
Write-Host "1. Esperando a que Keycloak este disponible..."
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
    Write-Host "ERROR: Keycloak no esta disponible"
    exit 1
}

Write-Host "   Keycloak esta listo!"
Write-Host ""

# Ejecutar setup de Keycloak
Write-Host "2. Configurando Keycloak..."
& .\setup-keycloak.ps1

# Ejecutar setup de tokens
Write-Host ""
Write-Host "3. Configurando tokens..."
& .\setup-tokens.ps1

Write-Host ""
Write-Host "========================================"
Write-Host "CONFIGURACION COMPLETADA"
Write-Host "========================================"
Write-Host ""
Write-Host "Sistema listo para usar!"
Write-Host "Ejecuta Obtener Token en las colecciones de Postman"
Write-Host ""
