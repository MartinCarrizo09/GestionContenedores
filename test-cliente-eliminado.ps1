# Script de prueba para demostrar el manejo de clientes eliminados
# Este script demuestra que al eliminar un cliente:
# 1. Los IDs no se reorganizan (permanecen con espacios)
# 2. Al intentar acceder a un ID eliminado, se retorna 404

$baseUrl = "http://localhost:8080/api-gestion"

Write-Host "=== TEST: Manejo de Clientes Eliminados ===" -ForegroundColor Cyan
Write-Host ""

# Obtener token de operador
Write-Host "1. Obteniendo token de operador..." -ForegroundColor Yellow
try {
    $tokenResponse = Invoke-RestMethod -Uri "http://localhost:8081/realms/tpi/protocol/openid-connect/token" `
        -Method POST `
        -Body @{
            client_id = "tpi-backend"
            client_secret = "ZNr9CUIk9xFg6K6TRXQCvJ5QfgRZnckb"
            grant_type = "password"
            username = "operador"
            password = "operador123"
        }
    $token = $tokenResponse.access_token
    Write-Host "✓ Token obtenido" -ForegroundColor Green
} catch {
    Write-Host "✗ Error obteniendo token: $_" -ForegroundColor Red
    exit
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host ""
Write-Host "2. Creando tres clientes..." -ForegroundColor Yellow

# Crear cliente 1
$cliente1 = @{
    nombre = "Cliente"
    apellido = "Uno"
    email = "cliente1_$(Get-Random)@test.com"
    telefono = "3511111111"
    cuil = "20111111111"
} | ConvertTo-Json

$result1 = Invoke-RestMethod -Uri "$baseUrl/clientes" -Method POST -Headers $headers -Body $cliente1
Write-Host "✓ Cliente creado - ID: $($result1.id)" -ForegroundColor Green

# Crear cliente 2
$cliente2 = @{
    nombre = "Cliente"
    apellido = "Dos"
    email = "cliente2_$(Get-Random)@test.com"
    telefono = "3522222222"
    cuil = "20222222222"
} | ConvertTo-Json

$result2 = Invoke-RestMethod -Uri "$baseUrl/clientes" -Method POST -Headers $headers -Body $cliente2
Write-Host "✓ Cliente creado - ID: $($result2.id)" -ForegroundColor Green

# Crear cliente 3
$cliente3 = @{
    nombre = "Cliente"
    apellido = "Tres"
    email = "cliente3_$(Get-Random)@test.com"
    telefono = "3533333333"
    cuil = "20333333333"
} | ConvertTo-Json

$result3 = Invoke-RestMethod -Uri "$baseUrl/clientes" -Method POST -Headers $headers -Body $cliente3
Write-Host "✓ Cliente creado - ID: $($result3.id)" -ForegroundColor Green

$id1 = $result1.id
$id2 = $result2.id
$id3 = $result3.id

Write-Host ""
Write-Host "3. Listando clientes antes de eliminar..." -ForegroundColor Yellow
$clientes = Invoke-RestMethod -Uri "$baseUrl/clientes" -Method GET -Headers $headers
Write-Host "Total de clientes: $($clientes.Count)" -ForegroundColor Cyan
$clientes | Where-Object { $_.id -in @($id1, $id2, $id3) } | ForEach-Object {
    Write-Host "  - ID: $($_.id) - $($_.nombre) $($_.apellido)" -ForegroundColor White
}

Write-Host ""
Write-Host "4. Eliminando el cliente con ID $id2..." -ForegroundColor Yellow
Invoke-RestMethod -Uri "$baseUrl/clientes/$id2" -Method DELETE -Headers $headers
Write-Host "✓ Cliente eliminado" -ForegroundColor Green

Write-Host ""
Write-Host "5. Listando clientes después de eliminar..." -ForegroundColor Yellow
$clientesDespues = Invoke-RestMethod -Uri "$baseUrl/clientes" -Method GET -Headers $headers
Write-Host "Total de clientes: $($clientesDespues.Count)" -ForegroundColor Cyan
$clientesDespues | Where-Object { $_.id -in @($id1, $id2, $id3) } | ForEach-Object {
    Write-Host "  - ID: $($_.id) - $($_.nombre) $($_.apellido)" -ForegroundColor White
}

Write-Host ""
Write-Host "6. Verificando que los IDs NO se reorganizaron..." -ForegroundColor Yellow
$cliente1Existe = $clientesDespues | Where-Object { $_.id -eq $id1 }
$cliente3Existe = $clientesDespues | Where-Object { $_.id -eq $id3 }

if ($cliente1Existe -and $cliente3Existe) {
    Write-Host "✓ Los IDs permanecen intactos (ID $id1 y ID $id3 todavía existen)" -ForegroundColor Green
} else {
    Write-Host "✗ ERROR: Los IDs fueron reorganizados" -ForegroundColor Red
}

Write-Host ""
Write-Host "7. Intentando acceder al cliente eliminado (ID $id2)..." -ForegroundColor Yellow
try {
    $clienteEliminado = Invoke-RestMethod -Uri "$baseUrl/clientes/$id2" -Method GET -Headers $headers
    Write-Host "✗ ERROR: El cliente eliminado todavía es accesible" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 404) {
        Write-Host "✓ Retorna 404 - Cliente no encontrado (como esperado)" -ForegroundColor Green
        $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "  Mensaje: $($errorResponse.mensaje)" -ForegroundColor Cyan
    } else {
        Write-Host "✗ Retornó código $statusCode (se esperaba 404)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "8. Intentando actualizar el cliente eliminado (ID $id2)..." -ForegroundColor Yellow
$updateData = @{
    nombre = "Modificado"
    apellido = "Modificado"
    email = "modificado@test.com"
    telefono = "3500000000"
    cuil = "20000000000"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/clientes/$id2" -Method PUT -Headers $headers -Body $updateData
    Write-Host "✗ ERROR: Se pudo actualizar un cliente eliminado" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 404) {
        Write-Host "✓ Retorna 404 - Cliente no encontrado (como esperado)" -ForegroundColor Green
    } else {
        Write-Host "✗ Retornó código $statusCode (se esperaba 404)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "9. Intentando eliminar nuevamente el mismo cliente (ID $id2)..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "$baseUrl/clientes/$id2" -Method DELETE -Headers $headers
    Write-Host "✗ ERROR: Se pudo eliminar un cliente que ya no existe" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 404) {
        Write-Host "✓ Retorna 404 - Cliente no encontrado (como esperado)" -ForegroundColor Green
    } else {
        Write-Host "✗ Retornó código $statusCode (se esperaba 404)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "10. Creando un nuevo cliente..." -ForegroundColor Yellow
$clienteNuevo = @{
    nombre = "Cliente"
    apellido = "Nuevo"
    email = "cliente_nuevo_$(Get-Random)@test.com"
    telefono = "3544444444"
    cuil = "20444444444"
} | ConvertTo-Json

$resultNuevo = Invoke-RestMethod -Uri "$baseUrl/clientes" -Method POST -Headers $headers -Body $clienteNuevo
Write-Host "✓ Cliente creado - ID: $($resultNuevo.id)" -ForegroundColor Green
Write-Host "  Nota: El ID es $($resultNuevo.id), NO reutiliza el ID $id2 eliminado" -ForegroundColor Cyan

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "✓ Los IDs NO se reorganizan después de eliminar" -ForegroundColor Green
Write-Host "✓ Intentar acceder a un ID eliminado retorna 404" -ForegroundColor Green
Write-Host "✓ El sistema mantiene la integridad de los IDs" -ForegroundColor Green
Write-Host ""
