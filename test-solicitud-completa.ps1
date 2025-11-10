# Script de Prueba - Endpoint Solicitud Completa
# Este script prueba los 3 casos de uso del nuevo endpoint

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PRUEBA: Endpoint Solicitud Completa" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8082/api-logistica"

# =================================================================
Write-Host "CASO 1: Cliente NUEVO + Contenedor NUEVO" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow

$caso1 = @{
    numeroSeguimiento = "TRK-2025-001"
    origenDireccion = "Av. Corrientes 1234, CABA"
    origenLatitud = -34.603722
    origenLongitud = -58.381592
    destinoDireccion = "Av. Santa Fe 5678, CABA"
    destinoLatitud = -34.594722
    destinoLongitud = -58.381592
    clienteNombre = "Juan"
    clienteApellido = "Pérez"
    clienteEmail = "juan.perez@email.com"
    clienteTelefono = "+54-11-4567-8900"
    clienteCuil = "20-12345678-9"
    codigoIdentificacion = "CNT-001-2025"
    peso = 2500.0
    volumen = 33.0
} | ConvertTo-Json

Write-Host "Request:" -ForegroundColor Green
Write-Host $caso1
Write-Host ""

try {
    $response1 = Invoke-RestMethod -Uri "$baseUrl/solicitudes/completa" `
        -Method Post `
        -ContentType "application/json" `
        -Body $caso1
    
    Write-Host "✅ ÉXITO - Respuesta:" -ForegroundColor Green
    $response1 | ConvertTo-Json -Depth 5
    Write-Host ""
    
    # Guardar IDs para casos siguientes
    $idCliente = $response1.idCliente
    $idContenedor = $response1.idContenedor
    
} catch {
    Write-Host "❌ ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Start-Sleep -Seconds 2

# =================================================================
Write-Host ""
Write-Host "CASO 2: Cliente EXISTENTE + Contenedor NUEVO" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Yellow

$caso2 = @{
    numeroSeguimiento = "TRK-2025-002"
    origenDireccion = "Av. Belgrano 3000, CABA"
    origenLatitud = -34.612722
    origenLongitud = -58.371592
    destinoDireccion = "Av. Libertador 7000, CABA"
    destinoLatitud = -34.561722
    destinoLongitud = -58.451592
    idCliente = $idCliente
    codigoIdentificacion = "CNT-002-2025"
    peso = 3000.0
    volumen = 40.0
} | ConvertTo-Json

Write-Host "Request:" -ForegroundColor Green
Write-Host $caso2
Write-Host ""

try {
    $response2 = Invoke-RestMethod -Uri "$baseUrl/solicitudes/completa" `
        -Method Post `
        -ContentType "application/json" `
        -Body $caso2
    
    Write-Host "✅ ÉXITO - Respuesta:" -ForegroundColor Green
    $response2 | ConvertTo-Json -Depth 5
    Write-Host ""
    
} catch {
    Write-Host "❌ ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Start-Sleep -Seconds 2

# =================================================================
Write-Host ""
Write-Host "CASO 3: Cliente EXISTENTE + Contenedor EXISTENTE" -ForegroundColor Yellow
Write-Host "=================================================" -ForegroundColor Yellow

$caso3 = @{
    numeroSeguimiento = "TRK-2025-003"
    origenDireccion = "Av. Rivadavia 5000, CABA"
    origenLatitud = -34.615722
    origenLongitud = -58.441592
    destinoDireccion = "Av. Las Heras 3000, CABA"
    destinoLatitud = -34.587722
    destinoLongitud = -58.401592
    idCliente = $idCliente
    idContenedor = $idContenedor
} | ConvertTo-Json

Write-Host "Request:" -ForegroundColor Green
Write-Host $caso3
Write-Host ""

try {
    $response3 = Invoke-RestMethod -Uri "$baseUrl/solicitudes/completa" `
        -Method Post `
        -ContentType "application/json" `
        -Body $caso3
    
    Write-Host "✅ ÉXITO - Respuesta:" -ForegroundColor Green
    $response3 | ConvertTo-Json -Depth 5
    Write-Host ""
    
} catch {
    Write-Host "❌ ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# =================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RESUMEN DE PRUEBAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Listar todas las solicitudes creadas
try {
    Write-Host "Listando todas las solicitudes..." -ForegroundColor Green
    $todasSolicitudes = Invoke-RestMethod -Uri "$baseUrl/solicitudes" -Method Get
    
    Write-Host "Total de solicitudes: $($todasSolicitudes.Count)" -ForegroundColor Cyan
    foreach ($sol in $todasSolicitudes) {
        Write-Host "  - ID: $($sol.id) | Número: $($sol.numeroSeguimiento) | Estado: $($sol.estado)" -ForegroundColor White
    }
    
} catch {
    Write-Host "Error al listar solicitudes: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PRUEBAS COMPLETADAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
