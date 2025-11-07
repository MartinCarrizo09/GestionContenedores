# Script de Pruebas Completo - TPI Backend
# Verifica todos los requerimientos funcionales del TPI

$line = "=" * 80

Write-Host "`n$line" -ForegroundColor Cyan
Write-Host "   PRUEBAS COMPLETAS - REQUERIMIENTOS TPI BACKEND" -ForegroundColor Cyan
Write-Host "$line`n" -ForegroundColor Cyan

$resultados = @()
$testNum = 0

# Helper function para ejecutar tests
function Test-Endpoint {
    param(
        [string]$Nombre,
        [string]$Metodo,
        [string]$Url,
        [string]$Token,
        [object]$Body = $null,
        [int]$ExpectedStatus = 200,
        [string]$Requerimiento = ""
    )
    
    $script:testNum++
    Write-Host "`n[$script:testNum] $Requerimiento" -ForegroundColor Yellow
    Write-Host "Test: $Nombre" -ForegroundColor White
    Write-Host "-> $Metodo $Url" -ForegroundColor Gray
    
    try {
        $headers = @{
            "Authorization" = "Bearer $Token"
            "Content-Type" = "application/json"
        }
        
        $params = @{
            Uri = $Url
            Method = $Metodo
            Headers = $headers
            ErrorAction = "Stop"
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        
        if ($ExpectedStatus -eq 200) {
            Write-Host "PASS - Status 200 OK" -ForegroundColor Green
            
            if ($response -is [Array]) {
                Write-Host "   Registros encontrados: $($response.Count)" -ForegroundColor Cyan
                if ($response.Count -gt 0 -and $response.Count -le 3) {
                    Write-Host "   Datos: $($response | ConvertTo-Json -Compress -Depth 2)" -ForegroundColor Gray
                }
            } else {
                Write-Host "   Respuesta: $($response | ConvertTo-Json -Compress -Depth 2)" -ForegroundColor Gray
            }
            
            $script:resultados += @{Test=$Nombre; Status="PASS"; Response=$response}
            return $response
        }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        
        if ($statusCode -eq $ExpectedStatus) {
            Write-Host "PASS - Status $statusCode (esperado)" -ForegroundColor Green
            $script:resultados += @{Test=$Nombre; Status="PASS"; Code=$statusCode}
        }
        else {
            Write-Host "FAIL - Status $statusCode (esperaba $ExpectedStatus)" -ForegroundColor Red
            Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
            $script:resultados += @{Test=$Nombre; Status="FAIL"; Code=$statusCode; Error=$_.Exception.Message}
        }
    }
}

# REQ 1: Registrar nueva solicitud de transporte
$solicitudBody = @{
    clienteId = 1
    contenedorId = "CONT001"
    origenDireccion = "Av. Corrientes 1234, CABA"
    origenLatitud = -34.6037
    origenLongitud = -58.3816
    destinoDireccion = "Av. Rivadavia 5678, CABA"
    destinoLatitud = -34.6131
    destinoLongitud = -58.4353
}

Test-Endpoint `
    -Nombre "CLIENTE crea solicitud de transporte" `
    -Metodo "POST" `
    -Url "http://localhost:8080/api/logistica/solicitudes" `
    -Token $env:CLIENTE_TOKEN `
    -Body $solicitudBody `
    -Requerimiento "REQ 1: Registrar nueva solicitud de transporte"

# REQ 2: Consultar estado del contenedor
Test-Endpoint `
    -Nombre "CLIENTE consulta estado de contenedor" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/gestion/contenedores/codigo/CONT001/estado" `
    -Token $env:CLIENTE_TOKEN `
    -Requerimiento "REQ 2: Consultar estado del transporte"

# REQ 3: Consultar y estimar rutas
Test-Endpoint `
    -Nombre "OPERADOR consulta solicitudes" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/logistica/solicitudes" `
    -Token $env:OPERADOR_TOKEN `
    -Requerimiento "REQ 3: Consultar rutas tentativas"

$estimarRutaBody = @{
    origenLatitud = -34.6037
    origenLongitud = -58.3816
    destinoLatitud = -34.6131
    destinoLongitud = -58.4353
    pesoKg = 4800
    volumenM3 = 33
}

Test-Endpoint `
    -Nombre "OPERADOR estima ruta" `
    -Metodo "POST" `
    -Url "http://localhost:8080/api/logistica/solicitudes/estimar-ruta" `
    -Token $env:OPERADOR_TOKEN `
    -Body $estimarRutaBody `
    -Requerimiento "REQ 3: Estimar ruta con costos"

# REQ 5: Consultar contenedores pendientes
Test-Endpoint `
    -Nombre "OPERADOR consulta todos los contenedores" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/gestion/contenedores" `
    -Token $env:OPERADOR_TOKEN `
    -Requerimiento "REQ 5: Consultar contenedores pendientes"

Test-Endpoint `
    -Nombre "OPERADOR filtra contenedores en transito" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/gestion/contenedores?estado=EN_TRANSITO" `
    -Token $env:OPERADOR_TOKEN `
    -Requerimiento "REQ 5: Filtrar contenedores por estado"

# REQ 6-8: Consultar camiones y tramos
Test-Endpoint `
    -Nombre "OPERADOR consulta camiones disponibles" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/flota/camiones?disponible=true" `
    -Token $env:OPERADOR_TOKEN `
    -Requerimiento "REQ 6: Consultar camiones para asignacion"

Test-Endpoint `
    -Nombre "OPERADOR consulta tramos" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/logistica/tramos" `
    -Token $env:OPERADOR_TOKEN `
    -Requerimiento "REQ 6: Consultar tramos para asignacion"

# REQ 7-9: Transportista consulta tramos
Test-Endpoint `
    -Nombre "TRANSPORTISTA consulta sus tramos" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/logistica/tramos/camion/ABC123" `
    -Token $env:TRANSPORTISTA_TOKEN `
    -Requerimiento "REQ 7: Transportista ve sus tramos"

# REQ 10: Gestion de depositos
Test-Endpoint `
    -Nombre "OPERADOR consulta depositos" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/gestion/depositos" `
    -Token $env:OPERADOR_TOKEN `
    -Requerimiento "REQ 10: Gestionar depositos"

$depositoBody = @{
    nombre = "Deposito Test"
    direccion = "Av. Test 1234"
    latitud = -34.6037
    longitud = -58.3816
    costoDiario = 1500.0
}

Test-Endpoint `
    -Nombre "OPERADOR crea deposito" `
    -Metodo "POST" `
    -Url "http://localhost:8080/api/gestion/depositos" `
    -Token $env:OPERADOR_TOKEN `
    -Body $depositoBody `
    -Requerimiento "REQ 10: Crear deposito"

# REQ 10: Gestion de camiones
Test-Endpoint `
    -Nombre "OPERADOR consulta todos los camiones" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/flota/camiones" `
    -Token $env:OPERADOR_TOKEN `
    -Requerimiento "REQ 10: Gestionar camiones"

$camionBody = @{
    patente = "TEST123"
    nombreTransportista = "Test Transportista"
    telefono = "1234567890"
    capacidadPesoKg = 10000
    capacidadVolumenM3 = 40
    costoKm = 150.0
    consumoLitrosPorKm = 0.35
    disponible = $true
}

Test-Endpoint `
    -Nombre "OPERADOR crea camion" `
    -Metodo "POST" `
    -Url "http://localhost:8080/api/flota/camiones" `
    -Token $env:OPERADOR_TOKEN `
    -Body $camionBody `
    -Requerimiento "REQ 10: Crear camion"

# REQ 10: Gestion de tarifas
Test-Endpoint `
    -Nombre "OPERADOR consulta tarifas" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/gestion/tarifas" `
    -Token $env:OPERADOR_TOKEN `
    -Requerimiento "REQ 10: Gestionar tarifas"

# VERIFICACION DE SEGURIDAD Y ROLES
Write-Host "`n$line" -ForegroundColor Magenta
Write-Host "   VERIFICACION DE SEGURIDAD Y ROLES" -ForegroundColor Magenta
Write-Host "$line`n" -ForegroundColor Magenta

Test-Endpoint `
    -Nombre "CLIENTE bloqueado de camiones" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/flota/camiones" `
    -Token $env:CLIENTE_TOKEN `
    -ExpectedStatus 403 `
    -Requerimiento "SEGURIDAD: CLIENTE no accede a camiones"

Test-Endpoint `
    -Nombre "TRANSPORTISTA bloqueado de clientes" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/gestion/clientes" `
    -Token $env:TRANSPORTISTA_TOKEN `
    -ExpectedStatus 403 `
    -Requerimiento "SEGURIDAD: TRANSPORTISTA no accede a clientes"

Test-Endpoint `
    -Nombre "CLIENTE bloqueado de lista completa contenedores" `
    -Metodo "GET" `
    -Url "http://localhost:8080/api/gestion/contenedores" `
    -Token $env:CLIENTE_TOKEN `
    -ExpectedStatus 403 `
    -Requerimiento "SEGURIDAD: CLIENTE solo ve sus contenedores"

# RESUMEN FINAL
Write-Host "`n$line" -ForegroundColor Cyan
Write-Host "   RESUMEN DE PRUEBAS" -ForegroundColor Cyan
Write-Host "$line`n" -ForegroundColor Cyan

$total = $resultados.Count
$passed = ($resultados | Where-Object { $_.Status -eq "PASS" }).Count
$failed = ($resultados | Where-Object { $_.Status -eq "FAIL" }).Count

Write-Host "Total de pruebas: $total" -ForegroundColor White
Write-Host "Exitosas: $passed" -ForegroundColor Green
Write-Host "Fallidas: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })

if ($failed -eq 0) {
    Write-Host "`nTODAS LAS PRUEBAS PASARON EXITOSAMENTE`n" -ForegroundColor Green
} else {
    Write-Host "`nALGUNAS PRUEBAS FALLARON - REVISAR LOGS`n" -ForegroundColor Yellow
}

Write-Host "$line" -ForegroundColor Cyan
