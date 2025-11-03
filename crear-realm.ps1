# Script simplificado para crear Realm en Keycloak
Write-Host "Configurando Keycloak..." -ForegroundColor Green

$KEYCLOAK_URL = "http://localhost:8080"
$REALM_NAME = "TPI-Realm"

# Obtener token admin
Write-Host "Obteniendo token de administrador..." -ForegroundColor Yellow
$tokenResponse = Invoke-RestMethod `
  -Uri "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" `
  -Method Post `
  -ContentType "application/x-www-form-urlencoded" `
  -Body @{
    grant_type = "password"
    client_id = "admin-cli"
    username = "admin"
    password = "admin"
  }

$token = $tokenResponse.access_token
Write-Host "Token obtenido" -ForegroundColor Green

# Crear Realm
Write-Host "Creando realm TPI-Realm..." -ForegroundColor Yellow
$realmData = @{
    realm = $REALM_NAME
    enabled = $true
    displayName = "TPI Backend"
} | ConvertTo-Json

try {
    Invoke-RestMethod `
      -Uri "$KEYCLOAK_URL/admin/realms" `
      -Method Post `
      -Headers @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
      } `
      -Body $realmData
    Write-Host "Realm creado exitosamente" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "Realm ya existe" -ForegroundColor Yellow
    } else {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Configuracion completada" -ForegroundColor Green
Write-Host "Ahora crea el cliente y usuarios manualmente en:" -ForegroundColor Yellow
Write-Host "http://localhost:8080/admin" -ForegroundColor Cyan

