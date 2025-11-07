# Script de Pruebas de Endpoints - Sistema TPI
# Usa los usuarios correctos: cliente@tpi.com, operador@tpi.com, transportista@tpi.com

$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost:8080"
$results = @()

function Test-Endpoint {
    param(
        [string]$Method,
        [string]$Url,
        [string]$Description,
        [object]$Body = $null,
        [string]$Token = $null,
        [int]$ExpectedStatus = 200
    )
    
    $headers = @{
        "Content-Type" = "application/json"
    }
    
    if ($Token) {
        $headers["Authorization"] = "Bearer $Token"
    }
    
    try {
        Write-Host ""
        Write-Host "Probando: $Description" -ForegroundColor Cyan
        Write-Host "   $Method $Url" -ForegroundColor Gray
        
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $headers
            ErrorAction = "Stop"
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        $statusCode = 200
        
        $result = @{
            Endpoint = "$Method $Url"
            Description = $Description
            Status = "OK"
            StatusCode = $statusCode
            Response = $response
            Error = $null
        }
        
        Write-Host "   OK (Status: $statusCode)" -ForegroundColor Green
        return $result
        
    } catch {
        $statusCode = 0
        try {
            $statusCode = $_.Exception.Response.StatusCode.value__
        } catch {
            $statusCode = 500
        }
        $errorMessage = $_.Exception.Message
        
        $result = @{
            Endpoint = "$Method $Url"
            Description = $Description
            Status = if ($statusCode -eq $ExpectedStatus) { "OK (Expected)" } else { "ERROR" }
            StatusCode = $statusCode
            Response = $null
            Error = $errorMessage
        }
        
        if ($statusCode -eq $ExpectedStatus) {
            Write-Host "   OK (Status esperado: $statusCode)" -ForegroundColor Green
        } else {
            Write-Host "   ERROR: $statusCode - $errorMessage" -ForegroundColor Red
        }
        
        return $result
    }
}

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "PRUEBAS DE ENDPOINTS - SISTEMA TPI" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# 1. Obtener token para CLIENTE
Write-Host ""
Write-Host "PASO 1: Obtener token de autenticacion (CLIENTE)" -ForegroundColor Magenta
$loginBody = @{
    username = "cliente@tpi.com"
    password = "cliente123"
}

try {
    $tokenResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -ContentType "application/json" -Body ($loginBody | ConvertTo-Json)
    $tokenCliente = $tokenResponse.access_token
    Write-Host "Token CLIENTE obtenido exitosamente" -ForegroundColor Green
} catch {
    Write-Host "Error al obtener token CLIENTE: $_" -ForegroundColor Red
    Write-Host "Continuando sin token" -ForegroundColor Yellow
    $tokenCliente = $null
}

# 2. Obtener token para OPERADOR
Write-Host ""
Write-Host "PASO 2: Obtener token de autenticacion (OPERADOR)" -ForegroundColor Magenta
$loginBodyOperador = @{
    username = "operador@tpi.com"
    password = "operador123"
}

try {
    $tokenResponseOperador = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -ContentType "application/json" -Body ($loginBodyOperador | ConvertTo-Json)
    $tokenOperador = $tokenResponseOperador.access_token
    Write-Host "Token OPERADOR obtenido exitosamente" -ForegroundColor Green
} catch {
    Write-Host "Error al obtener token OPERADOR: $_" -ForegroundColor Red
    $tokenOperador = $null
}

# 3. Servicio de Gestion - Clientes (OPERADOR puede gestionar)
Write-Host ""
Write-Host "PASO 3: Servicio de Gestion - Clientes" -ForegroundColor Magenta
$results += Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/clientes" -Description "Listar clientes" -Token $tokenOperador
$results += Test-Endpoint -Method "POST" -Url "$baseUrl/api/gestion/clientes" -Description "Crear cliente" -Token $tokenOperador -Body @{
    nombre = "Cliente"
    apellido = "Test"
    email = "test$(Get-Random)@test.com"
    telefono = "123456789"
}

# 4. Servicio de Gestion - Contenedores
Write-Host ""
Write-Host "PASO 4: Servicio de Gestion - Contenedores" -ForegroundColor Magenta
$results += Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/contenedores" -Description "Listar contenedores" -Token $tokenOperador
# CLIENTE puede consultar estado de su contenedor
$results += Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/contenedores/1/estado" -Description "Consultar estado contenedor (CLIENTE)" -Token $tokenCliente -ExpectedStatus 200

# 5. Servicio de Gestion - Depositos (OPERADOR)
Write-Host ""
Write-Host "PASO 5: Servicio de Gestion - Depositos" -ForegroundColor Magenta
$results += Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/depositos" -Description "Listar depositos" -Token $tokenOperador
$results += Test-Endpoint -Method "POST" -Url "$baseUrl/api/gestion/depositos" -Description "Crear deposito" -Token $tokenOperador -Body @{
    nombre = "Deposito Test"
    direccion = "Calle Deposito 456"
    latitud = -34.603722
    longitud = -58.381592
    costoEstadiaDiario = 5000.0
}

# 6. Servicio de Gestion - Tarifas (OPERADOR)
Write-Host ""
Write-Host "PASO 6: Servicio de Gestion - Tarifas" -ForegroundColor Magenta
$results += Test-Endpoint -Method "GET" -Url "$baseUrl/api/gestion/tarifas" -Description "Listar tarifas" -Token $tokenOperador
$results += Test-Endpoint -Method "POST" -Url "$baseUrl/api/gestion/tarifas" -Description "Crear tarifa" -Token $tokenOperador -Body @{
    descripcion = "Tarifa Test"
    rangoPesoMin = 0.0
    rangoPesoMax = 5000.0
    rangoVolumenMin = 0.0
    rangoVolumenMax = 100.0
    valor = 100.0
}

# 7. Servicio de Flota - Camiones (OPERADOR)
Write-Host ""
Write-Host "PASO 7: Servicio de Flota - Camiones" -ForegroundColor Magenta
$results += Test-Endpoint -Method "GET" -Url "$baseUrl/api/flota/camiones" -Description "Listar camiones" -Token $tokenOperador
$results += Test-Endpoint -Method "GET" -Url "$baseUrl/api/flota/camiones/disponibles" -Description "Listar camiones disponibles" -Token $tokenOperador

# 8. Servicio de Logistica - Solicitudes (CLIENTE)
Write-Host ""
Write-Host "PASO 8: Servicio de Logistica - Solicitudes" -ForegroundColor Magenta
$results += Test-Endpoint -Method "GET" -Url "$baseUrl/api/logistica/solicitudes" -Description "Listar solicitudes" -Token $tokenCliente
$results += Test-Endpoint -Method "GET" -Url "$baseUrl/api/logistica/solicitudes/pendientes" -Description "Listar contenedores pendientes" -Token $tokenOperador

# 9. Servicio de Logistica - Estimar Ruta (OPERADOR)
Write-Host ""
Write-Host "PASO 9: Servicio de Logistica - Estimar Ruta" -ForegroundColor Magenta
$results += Test-Endpoint -Method "POST" -Url "$baseUrl/api/logistica/solicitudes/estimar-ruta" -Description "Estimar ruta" -Token $tokenOperador -Body @{
    origenLatitud = -34.603722
    origenLongitud = -58.381592
    destinoLatitud = -34.611791
    destinoLongitud = -58.396030
    pesoKg = 1000.0
    volumenM3 = 50.0
}

# Generar reporte
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "RESUMEN DE PRUEBAS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

$total = $results.Count
$exitosos = ($results | Where-Object { $_.Status -like "OK*" }).Count
$fallidos = ($results | Where-Object { $_.Status -like "ERROR*" }).Count

Write-Host "Total de pruebas: $total" -ForegroundColor Cyan
Write-Host "Exitosas: $exitosos" -ForegroundColor Green
Write-Host "Fallidas: $fallidos" -ForegroundColor Red

if ($fallidos -gt 0) {
    Write-Host ""
    Write-Host "ENDPOINTS CON ERRORES:" -ForegroundColor Red
    $results | Where-Object { $_.Status -like "ERROR*" } | ForEach-Object {
        Write-Host "   - $($_.Endpoint): $($_.Error)" -ForegroundColor Red
    }
}

# Guardar resultados en archivo
$fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$reporte = "# Reporte de Pruebas de Endpoints - Sistema TPI`n"
$reporte += "Fecha: $fecha`n`n"
$reporte += "## Resumen`n"
$reporte += "- Total de pruebas: $total`n"
$reporte += "- Exitosas: $exitosos`n"
$reporte += "- Fallidas: $fallidos`n`n"
$reporte += "## Usuarios Utilizados`n"
$reporte += "- CLIENTE: cliente@tpi.com / cliente123`n"
$reporte += "- OPERADOR: operador@tpi.com / operador123`n`n"
$reporte += "## Detalle de Pruebas`n`n"

foreach ($result in $results) {
    $reporte += "### $($result.Description)`n"
    $reporte += "- **Endpoint**: $($result.Endpoint)`n"
    $reporte += "- **Estado**: $($result.Status)`n"
    $reporte += "- **Codigo HTTP**: $($result.StatusCode)`n"
    
    if ($result.Error) {
        $reporte += "- **Error**: $($result.Error)`n"
    }
    
    if ($result.Response) {
        $responseJson = $result.Response | ConvertTo-Json -Depth 3 -Compress
        $reporte += "- **Respuesta**: ``$responseJson`` `n"
    }
    
    $reporte += "`n"
}

$reporte | Out-File -FilePath "REPORTE_PRUEBAS_ENDPOINTS.md" -Encoding UTF8
Write-Host ""
Write-Host "Reporte guardado en: REPORTE_PRUEBAS_ENDPOINTS.md" -ForegroundColor Green

return $results

