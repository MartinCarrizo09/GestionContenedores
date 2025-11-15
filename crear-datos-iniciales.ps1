#!/usr/bin/env pwsh
# Script para crear datos iniciales necesarios para los casos de prueba

param(
    [string]$GATEWAY_URL = "http://localhost:8080"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CREANDO DATOS INICIALES PARA PRUEBAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Obtener token de operador
Write-Host "Obteniendo token de operador..." -ForegroundColor Yellow
try {
    $keycloakUrl = "http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token"
    
    $body = @{
        grant_type = "password"
        client_id = "tpi-client"
        username = "operador@tpi.com"
        password = "operador123"
    }
    
    $tokenResponse = Invoke-RestMethod -Uri $keycloakUrl `
        -Method Post `
        -ContentType "application/x-www-form-urlencoded" `
        -Body $body `
        -ErrorAction Stop
    
    $token = $tokenResponse.access_token
    
    if (-not $token) {
        Write-Host "Error: No se pudo obtener el token" -ForegroundColor Red
        exit 1
    }
    Write-Host "Token obtenido correctamente" -ForegroundColor Green
} catch {
    Write-Host "Error al obtener token: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Función auxiliar para hacer requests
function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null
    )
    
    $uri = "$GATEWAY_URL$Endpoint"
    
    try {
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10 -Compress
            $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers -Body $jsonBody -ErrorAction Stop
        } else {
            $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers -ErrorAction Stop
        }
        return @{ Success = $true; Response = $response }
    } catch {
        $statusCode = $null
        $errorBody = $null
        try {
            $statusCode = $_.Exception.Response.StatusCode.value__
        } catch {
            # StatusCode no disponible
        }
        try {
            $errorBody = $_.ErrorDetails.Message
        } catch {
            $errorBody = $_.Exception.Message
        }
        return @{ Success = $false; StatusCode = $statusCode; Error = $errorBody }
    }
}

# Inicializar variables
$solicitudId = $null
$rutaId = $null

# 1. Crear Cliente ID 1 (o obtenerlo si ya existe)
Write-Host "1. Creando/Obtendo Cliente ID 1..." -ForegroundColor Yellow
$cliente1 = @{
    nombre = "Juan"
    apellido = "Perez"
    email = "juan.perez@test.com"
    telefono = "+54-11-1234-5678"
    cuil = "20-12345678-9"
}
$clienteId1 = $null
$result = Invoke-ApiRequest -Method POST -Endpoint "/api/gestion/clientes" -Body $cliente1
if ($result.Success) {
    $clienteId1 = $result.Response.id
    Write-Host "   OK Cliente creado con ID: $clienteId1" -ForegroundColor Green
} elseif ($result.StatusCode -eq 409) {
    Write-Host "   INFO Cliente ya existe (409), buscando..." -ForegroundColor Yellow
    # Buscar el cliente existente por email
    $clientes = Invoke-ApiRequest -Method GET -Endpoint "/api/gestion/clientes"
    if ($clientes.Success) {
        $clienteExistente = $clientes.Response | Where-Object { $_.email -eq "juan.perez@test.com" } | Select-Object -First 1
        if ($clienteExistente) {
            $clienteId1 = $clienteExistente.id
            Write-Host "   OK Cliente encontrado con ID: $clienteId1" -ForegroundColor Green
        }
    }
} else {
    Write-Host "   ERROR: $($result.Error)" -ForegroundColor Red
}

# 2. Crear Contenedor ID 1 con código CONT-001
Write-Host "2. Creando/Obtendo Contenedor ID 1 (CONT-001)..." -ForegroundColor Yellow
$contenedorId1 = $null
if ($clienteId1) {
    $clienteId = $clienteId1
} else {
    $clientes = Invoke-ApiRequest -Method GET -Endpoint "/api/gestion/clientes"
    if ($clientes.Success -and $clientes.Response.Count -gt 0) {
        $clienteId = $clientes.Response[0].id
    }
}
if ($clienteId) {
    
    $contenedor1 = @{
        codigoIdentificacion = "CONT-001"
        peso = 1500.0
        volumen = 2.5
        cliente = @{
            id = $clienteId
        }
    }
    $result = Invoke-ApiRequest -Method POST -Endpoint "/api/gestion/contenedores" -Body $contenedor1
    if ($result.Success) {
        $contenedorId1 = $result.Response.id
        Write-Host "   OK Contenedor creado con ID: $contenedorId1" -ForegroundColor Green
    } elseif ($result.StatusCode -eq 409) {
        Write-Host "   INFO Contenedor ya existe (409), buscando..." -ForegroundColor Yellow
        # Buscar contenedor por código
        $resultCodigo = Invoke-ApiRequest -Method GET -Endpoint "/api/gestion/contenedores/codigo/CONT-001"
        if ($resultCodigo.Success) {
            $contenedorId1 = $resultCodigo.Response.id
            Write-Host "   OK Contenedor encontrado con ID: $contenedorId1" -ForegroundColor Green
        }
    } else {
        Write-Host "   ERROR: $($result.Error)" -ForegroundColor Red
    }
}

# 3. Crear Depósito ID 1
Write-Host "3. Creando Depósito ID 1..." -ForegroundColor Yellow
$deposito1 = @{
    nombre = "Deposito Central"
    direccion = "Av. Principal 123"
    capacidad = 10000
    latitud = -31.4200
    longitud = -64.1888
}
$result = Invoke-ApiRequest -Method POST -Endpoint "/api/gestion/depositos" -Body $deposito1
if ($result.Success) {
    Write-Host "   OK Deposito creado con ID: $($result.Response.id)" -ForegroundColor Green
} else {
    Write-Host "   ERROR: $($result.Error)" -ForegroundColor Red
}

# 4. Crear Tarifa ID 1 (si no existe)
Write-Host "4. Verificando/Creando Tarifa ID 1..." -ForegroundColor Yellow
$tarifas = Invoke-ApiRequest -Method GET -Endpoint "/api/gestion/tarifas"
if ($tarifas.Success) {
    if ($tarifas.Response.Count -eq 0) {
        $tarifa1 = @{
            descripcion = "Tarifa Estandar"
            rangoPesoMin = 0.0
            rangoPesoMax = 5000.0
            rangoVolumenMin = 0.0
            rangoVolumenMax = 10.0
            valor = 5000.0
        }
        $result = Invoke-ApiRequest -Method POST -Endpoint "/api/gestion/tarifas" -Body $tarifa1
        if ($result.Success) {
            Write-Host "   OK Tarifa creada con ID: $($result.Response.id)" -ForegroundColor Green
        } else {
            Write-Host "   ERROR: $($result.Error)" -ForegroundColor Red
        }
    } else {
        Write-Host "   INFO Ya existen tarifas en el sistema" -ForegroundColor Yellow
    }
}

# 5. Crear Solicitud ID 1 con número de seguimiento SEG-2024-001
Write-Host "5. Creando Solicitud ID 1 (SEG-2024-001)..." -ForegroundColor Yellow
$contenedores = Invoke-ApiRequest -Method GET -Endpoint "/api/gestion/contenedores"
if ($contenedores.Success -and $contenedores.Response.Count -gt 0) {
    $contenedorId = $contenedores.Response[0].id
    $clienteId = $contenedores.Response[0].cliente.id
    
    $solicitud1 = @{
        numeroSeguimiento = "SEG-2024-001"
        origenDireccion = "Av. Colon 100"
        origenLatitud = -31.4200
        origenLongitud = -64.1888
        destinoDireccion = "Bv. San Juan 500"
        destinoLatitud = -31.4100
        destinoLongitud = -64.1700
        idCliente = $clienteId
        idContenedor = $contenedorId
        estado = "PENDIENTE"
    }
    $result = Invoke-ApiRequest -Method POST -Endpoint "/api/logistica/solicitudes" -Body $solicitud1
    if ($result.Success) {
        $solicitudId = $result.Response.id
        Write-Host "   OK Solicitud creada con ID: $solicitudId" -ForegroundColor Green
    } elseif ($result.StatusCode -eq 409) {
        Write-Host "   INFO Solicitud ya existe (409), buscando..." -ForegroundColor Yellow
        $solicitudes = Invoke-ApiRequest -Method GET -Endpoint "/api/logistica/solicitudes"
        if ($solicitudes.Success) {
            $solicitudExistente = $solicitudes.Response | Where-Object { $_.numeroSeguimiento -eq "SEG-2024-001" } | Select-Object -First 1
            if ($solicitudExistente) {
                $solicitudId = $solicitudExistente.id
                Write-Host "   OK Solicitud encontrada con ID: $solicitudId" -ForegroundColor Green
            }
        }
    } else {
        $errorMsg = if ($result.Error) { $result.Error } else { "Error desconocido" }
        Write-Host "   ERROR: $errorMsg" -ForegroundColor Red
    }
}

# 6. Crear Ruta ID 1 asociada a Solicitud ID 1
Write-Host "6. Creando Ruta ID 1..." -ForegroundColor Yellow
if ($solicitudId) {
    $ruta1 = @{
        idSolicitud = $solicitudId
    }
    $result = Invoke-ApiRequest -Method POST -Endpoint "/api/logistica/rutas" -Body $ruta1
    if ($result.Success) {
        Write-Host "   OK Ruta creada con ID: $($result.Response.id)" -ForegroundColor Green
        $rutaId = $result.Response.id
    } elseif ($result.StatusCode -eq 404) {
        Write-Host "   INFO Error: El recurso referenciado no existe" -ForegroundColor Yellow
    } else {
        Write-Host "   ERROR: $($result.Error)" -ForegroundColor Red
    }
}

# 7. Crear Tramo ID 1 asociado a Ruta ID 1
Write-Host "7. Creando Tramo ID 1..." -ForegroundColor Yellow
if ($rutaId) {
    $tramo1 = @{
        idRuta = $rutaId
        origenDescripcion = "Origen"
        destinoDescripcion = "Destino"
        distanciaKm = 10.0
        estado = "ESTIMADO"
    }
    $result = Invoke-ApiRequest -Method POST -Endpoint "/api/logistica/tramos" -Body $tramo1
    if ($result.Success) {
        Write-Host "   OK Tramo creado con ID: $($result.Response.id)" -ForegroundColor Green
    } else {
        Write-Host "   ERROR: $($result.Error)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DATOS INICIALES CREADOS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
