# =====================================================
# Script de Ejecución de Casos de Prueba - Sistema TPI
# Ejecuta todos los casos de prueba del CSV
# =====================================================

$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost:8080"
$csvFile = "casos_prueba_tpi_backend.csv"
$results = @()
$tokens = @{}

# Función para obtener token de un usuario
function Get-AuthToken {
    param(
        [string]$Username,
        [string]$Password
    )
    
    if ($tokens.ContainsKey($Username)) {
        return $tokens[$Username]
    }
    
    try {
        $loginBody = @{
            username = $Username
            password = $Password
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" `
            -Method POST `
            -ContentType "application/json" `
            -Body $loginBody `
            -ErrorAction Stop
        
        $token = $response.access_token
        $tokens[$Username] = $token
        Write-Host "   Token obtenido para $Username" -ForegroundColor Gray
        return $token
    } catch {
        Write-Host "   ERROR: No se pudo obtener token para $Username" -ForegroundColor Red
        return $null
    }
}

# Función para obtener token según rol
function Get-TokenByRole {
    param([string]$Rol)
    
    switch ($Rol.ToUpper()) {
        "CLIENTE" {
            return Get-AuthToken -Username "cliente@tpi.com" -Password "cliente123"
        }
        "OPERADOR" {
            return Get-AuthToken -Username "operador@tpi.com" -Password "operador123"
        }
        "TRANSPORTISTA" {
            return Get-AuthToken -Username "transportista@tpi.com" -Password "transportista123"
        }
        "ANY" {
            # Para casos de prueba sin autenticación o con token inválido
            return $null
        }
        default {
            # Por defecto, intentar con operador
            return Get-AuthToken -Username "operador@tpi.com" -Password "operador123"
        }
    }
}

# Función para ejecutar un caso de prueba
function Test-CasoPrueba {
    param(
        [PSCustomObject]$Caso
    )
    
    $id = $Caso.ID
    $rol = $Caso.ROL
    
    # Leer método - la propiedad está en el índice 3 (después de ID, ROL, MICROSERVICIO)
    $metodo = $null
    $props = $Caso.PSObject.Properties
    if ($props.Count -gt 3) {
        $metodo = $props[3].Value
    }
    
    # Si aún no se encontró, buscar por nombre
    if (-not $metodo) {
        foreach ($prop in $props) {
            if ($prop.Name -like '*TODO*' -or $prop.Name -match 'M[EÉ]TODO') {
                $metodo = $prop.Value
                break
            }
        }
    }
    
    # Si aún no se encontró, intentar acceso directo
    if (-not $metodo) {
        try {
            $metodo = $Caso.'MÉTODO'
        } catch {
            # Intentar sin acento
            try {
                $metodo = $Caso.METODO
            } catch {
                # Usar índice directamente
                $metodo = $props[3].Value
            }
        }
    }
    
    $endpoint = $Caso.ENDPOINT
    $descripcion = $Caso.'DESCRIPCIÓN'
    $entrada = $Caso.'ENTRADA(JSON)'
    $tokenRequerido = $Caso.'TOKEN/ROL REQUERIDO'
    $statusEsperado = [int]$Caso.'HTTP STATUS'
    
    # Validar que el método no sea null
    if (-not $metodo -or $metodo -eq "") {
        Write-Host "   ⚠️  ERROR: Método no encontrado para caso $id" -ForegroundColor Red
        Write-Host "   Propiedades: $($Caso.PSObject.Properties.Name -join ', ')" -ForegroundColor Yellow
        return $null
    }
    
    # Convertir rutas del CSV al formato que espera el Gateway
    # El Gateway espera /api/gestion, /api/flota, /api/logistica
    # Pero el CSV usa /api-gestion, /api-flota, /api-logistica
    $endpointConvertido = $endpoint
    if ($endpoint -match '^/api-gestion') {
        $endpointConvertido = $endpoint -replace '^/api-gestion', '/api/gestion'
    } elseif ($endpoint -match '^/api-flota') {
        $endpointConvertido = $endpoint -replace '^/api-flota', '/api/flota'
    } elseif ($endpoint -match '^/api-logistica') {
        $endpointConvertido = $endpoint -replace '^/api-logistica', '/api/logistica'
    }
    
    # Construir URL completa
    $url = "$baseUrl$endpointConvertido"
    
    # Manejar query parameters si existen
    if ($endpoint -match '\?') {
        # Ya tiene query params
    }
    
    Write-Host ""
    Write-Host "[$id] $descripcion" -ForegroundColor Cyan
    Write-Host "   $metodo $endpoint" -ForegroundColor Gray
    
    # Obtener token según el rol
    # Primero intentar usar el rol especificado en TOKEN/ROL REQUERIDO si está disponible
    # Si no, usar el rol de la columna ROL
    $token = $null
    if ($tokenRequerido -and $tokenRequerido -notmatch "Sin token|EXPIRADO|inválido" -and $rol -ne "ANY") {
        # Intentar extraer el rol del campo TOKEN/ROL REQUERIDO (ej: "Bearer token JWT (rol transportista)")
        $rolParaToken = $rol
        if ($tokenRequerido -match "rol\s+(\w+)") {
            $rolParaToken = $matches[1]
        }
        $token = Get-TokenByRole -Rol $rolParaToken
    }
    
    # Preparar headers
    $headers = @{
        "Content-Type" = "application/json"
    }
    
    if ($token) {
        $headers["Authorization"] = "Bearer $token"
    }
    
    # Preparar body si existe
    $body = $null
    if ($entrada -and $entrada -ne "N/A" -and $entrada.Trim() -ne "") {
        try {
            # Normalizar la codificación del string primero
            $entradaNormalizada = $entrada
            try {
                # Intentar convertir desde diferentes codificaciones
                $bytes = [System.Text.Encoding]::Default.GetBytes($entrada)
                $entradaNormalizada = [System.Text.Encoding]::UTF8.GetString($bytes)
            } catch {
                # Si falla, usar la entrada original
                $entradaNormalizada = $entrada
            }
            
            # Intentar parsear como JSON
            $jsonObj = $null
            try {
                $jsonObj = $entradaNormalizada | ConvertFrom-Json -ErrorAction Stop
            } catch {
                # Si falla, intentar reemplazar caracteres problemáticos
                $entradaLimpia = $entradaNormalizada -replace '[^\x00-\x7F]', { 
                    $_.Value | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes($_.ToString())) }
                }
                try {
                    $jsonObj = $entradaLimpia | ConvertFrom-Json -ErrorAction Stop
                } catch {
                    throw $_
                }
            }
            
            # Si es una solicitud y no tiene estado, agregarlo automáticamente
            if ($endpoint -match "/solicitudes" -and $metodo -eq "POST" -and -not $jsonObj.estado) {
                $jsonObj | Add-Member -MemberType NoteProperty -Name "estado" -Value "PENDIENTE" -Force
            }
            
            # Si es una solicitud PUT y no tiene estado, agregarlo automáticamente
            if ($endpoint -match "/solicitudes" -and $metodo -eq "PUT" -and -not $jsonObj.estado) {
                $jsonObj | Add-Member -MemberType NoteProperty -Name "estado" -Value "PENDIENTE" -Force
            }
            
            # Si es una tarifa y tiene "nombre" en vez de "descripcion", mapearlo
            if ($endpoint -match "/tarifas" -and $jsonObj.nombre -and -not $jsonObj.descripcion) {
                $jsonObj | Add-Member -MemberType NoteProperty -Name "descripcion" -Value $jsonObj.nombre -Force
                $jsonObj.PSObject.Properties.Remove('nombre')
            }
            
            # Si es una tarifa y tiene "precioBase" en vez de "valor", mapearlo
            if ($endpoint -match "/tarifas" -and $jsonObj.precioBase -and -not $jsonObj.valor) {
                $jsonObj | Add-Member -MemberType NoteProperty -Name "valor" -Value $jsonObj.precioBase -Force
                $jsonObj.PSObject.Properties.Remove('precioBase')
            }
            
            # Si es una tarifa y tiene "pesoMinimo" en vez de "rangoPesoMin", mapearlo
            if ($endpoint -match "/tarifas" -and $jsonObj.pesoMinimo -and -not $jsonObj.rangoPesoMin) {
                $jsonObj | Add-Member -MemberType NoteProperty -Name "rangoPesoMin" -Value $jsonObj.pesoMinimo -Force
                $jsonObj.PSObject.Properties.Remove('pesoMinimo')
            }
            
            # Si es una tarifa y tiene "pesoMaximo" en vez de "rangoPesoMax", mapearlo
            if ($endpoint -match "/tarifas" -and $jsonObj.pesoMaximo -and -not $jsonObj.rangoPesoMax) {
                $jsonObj | Add-Member -MemberType NoteProperty -Name "rangoPesoMax" -Value $jsonObj.pesoMaximo -Force
                $jsonObj.PSObject.Properties.Remove('pesoMaximo')
            }
            
            # Si es una tarifa y tiene "volumenMinimo" en vez de "rangoVolumenMin", mapearlo
            if ($endpoint -match "/tarifas" -and $jsonObj.volumenMinimo -and -not $jsonObj.rangoVolumenMin) {
                $jsonObj | Add-Member -MemberType NoteProperty -Name "rangoVolumenMin" -Value $jsonObj.volumenMinimo -Force
                $jsonObj.PSObject.Properties.Remove('volumenMinimo')
            }
            
            # Si es una tarifa y tiene "volumenMaximo" en vez de "rangoVolumenMax", mapearlo
            if ($endpoint -match "/tarifas" -and $jsonObj.volumenMaximo -and -not $jsonObj.rangoVolumenMax) {
                $jsonObj | Add-Member -MemberType NoteProperty -Name "rangoVolumenMax" -Value $jsonObj.volumenMaximo -Force
                $jsonObj.PSObject.Properties.Remove('volumenMaximo')
            }
            
            # Convertir a JSON con codificación UTF-8
            $body = $jsonObj | ConvertTo-Json -Depth 10 -Compress -ErrorAction Stop
            # Asegurar codificación UTF-8
            $utf8 = New-Object System.Text.UTF8Encoding $false
            $bytes = $utf8.GetBytes($body)
            $body = $utf8.GetString($bytes)
        } catch {
            # Si no es JSON válido, intentar usar directamente con codificación UTF-8
            Write-Host "   ⚠️  Advertencia: No se pudo parsear como JSON, intentando como string UTF-8" -ForegroundColor Yellow
            try {
                $utf8 = New-Object System.Text.UTF8Encoding $false
                $bytes = $utf8.GetBytes($entrada)
                $body = $utf8.GetString($bytes)
            } catch {
                $body = $entrada
            }
        }
    }
    
    # Ejecutar petición
    try {
        # Para DELETE, usar Invoke-WebRequest para capturar el código de estado
        if ($metodo -eq "DELETE") {
            $params = @{
                Uri = $url
                Method = $metodo
                Headers = $headers
                ErrorAction = "Stop"
            }
            $response = Invoke-WebRequest @params
            $statusCode = $response.StatusCode
            $responseBody = $null
        } else {
            $params = @{
                Uri = $url
                Method = $metodo
                Headers = $headers
                ErrorAction = "Stop"
            }
            
            if ($body -and ($metodo -eq "POST" -or $metodo -eq "PUT" -or $metodo -eq "PATCH")) {
                $params.Body = $body
            }
            
            # Para métodos que retornan contenido, usar Invoke-RestMethod
            $response = Invoke-RestMethod @params
            $statusCode = 200
            $responseBody = $response
        }
        
        # Validar status code
        $resultado = if ($statusCode -eq $statusEsperado) { "OK" } else { "FAIL" }
        
        $result = [PSCustomObject]@{
            ID = $id
            Descripcion = $descripcion
            Endpoint = "$metodo $endpoint"
            StatusEsperado = $statusEsperado
            StatusObtenido = $statusCode
            Resultado = $resultado
            Error = $null
            Response = if ($responseBody) { $responseBody } else { $response }
        }
        
        if ($resultado -eq "OK") {
            Write-Host "   ✅ OK (Status: $statusCode)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Status incorrecto: esperado $statusEsperado, obtenido $statusCode" -ForegroundColor Yellow
        }
        
        return $result
        
    } catch {
        $statusCode = 0
        $errorMessage = $_.Exception.Message
        
        try {
            if ($_.Exception.Response) {
                $statusCode = $_.Exception.Response.StatusCode.value__
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $responseBody = $reader.ReadToEnd()
                try {
                    $errorObj = $responseBody | ConvertFrom-Json
                    $errorMessage = $errorObj.message
                } catch {
                    $errorMessage = $responseBody
                }
            }
        } catch {
            $statusCode = 500
        }
        
        # Validar si el error es el esperado
        $resultado = if ($statusCode -eq $statusEsperado) { "OK" } else { "FAIL" }
        
        $result = [PSCustomObject]@{
            ID = $id
            Descripcion = $descripcion
            Endpoint = "$metodo $endpoint"
            StatusEsperado = $statusEsperado
            StatusObtenido = $statusCode
            Resultado = $resultado
            Error = $errorMessage
            Response = $null
        }
        
        if ($resultado -eq "OK") {
            Write-Host "   ✅ OK (Status esperado: $statusCode)" -ForegroundColor Green
        } else {
            Write-Host "   ❌ FAIL: Status $statusCode - $errorMessage" -ForegroundColor Red
        }
        
        return $result
    }
}

# =====================================================
# INICIO DEL SCRIPT
# =====================================================

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "EJECUTANDO CASOS DE PRUEBA - SISTEMA TPI" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# Verificar que el CSV existe
if (-not (Test-Path $csvFile)) {
    Write-Host "ERROR: No se encontró el archivo $csvFile" -ForegroundColor Red
    exit 1
}

# Verificar que los servicios estén corriendo
Write-Host "Verificando servicios..." -ForegroundColor Cyan
try {
    $healthCheck = Invoke-RestMethod -Uri "$baseUrl/actuator/health" -Method GET -ErrorAction Stop
    Write-Host "✅ Gateway está disponible" -ForegroundColor Green
} catch {
    Write-Host "⚠️  No se pudo conectar al Gateway. Verificando si está corriendo..." -ForegroundColor Yellow
    Write-Host "   Ejecuta: docker-compose up -d" -ForegroundColor Gray
}

# Leer CSV
Write-Host ""
Write-Host "Leyendo casos de prueba desde $csvFile..." -ForegroundColor Cyan

# Leer CSV con codificación UTF-8 explícita
# Intentar múltiples codificaciones si falla
try {
    $casos = Import-Csv -Path $csvFile -Delimiter ";" -Encoding UTF8 -ErrorAction Stop
} catch {
    try {
        # Intentar con codificación por defecto
        $casos = Import-Csv -Path $csvFile -Delimiter ";" -ErrorAction Stop
    } catch {
        # Intentar con UTF-8 sin BOM
        $content = Get-Content -Path $csvFile -Raw -Encoding UTF8
        $casos = $content | ConvertFrom-Csv -Delimiter ";"
    }
}

# Filtrar casos vacíos o sin ID
$casos = $casos | Where-Object { $_.ID -and $_.ID -ne "" -and $_.ID -ne "ID" }

Write-Host "Se encontraron $($casos.Count) casos de prueba" -ForegroundColor Cyan
Write-Host ""

# Obtener tokens iniciales para todos los roles
Write-Host "Obteniendo tokens de autenticación..." -ForegroundColor Cyan
Get-TokenByRole -Rol "CLIENTE" | Out-Null
Get-TokenByRole -Rol "OPERADOR" | Out-Null
Get-TokenByRole -Rol "TRANSPORTISTA" | Out-Null
Write-Host ""

# Ejecutar cada caso de prueba
$contador = 0
foreach ($caso in $casos) {
    $contador++
    Write-Host "[$contador/$($casos.Count)]" -ForegroundColor DarkGray
    
    $result = Test-CasoPrueba -Caso $caso
    $results += $result
    
    # Pequeña pausa para no sobrecargar el sistema
    Start-Sleep -Milliseconds 100
}

# =====================================================
# GENERAR REPORTE
# =====================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "RESUMEN DE RESULTADOS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

$total = $results.Count
$exitosos = ($results | Where-Object { $_.Resultado -eq "OK" }).Count
$fallidos = ($results | Where-Object { $_.Resultado -eq "FAIL" }).Count

Write-Host "Total de casos: $total" -ForegroundColor Cyan
Write-Host "✅ Exitosos: $exitosos" -ForegroundColor Green
Write-Host "❌ Fallidos: $fallidos" -ForegroundColor Red
Write-Host ""

if ($fallidos -gt 0) {
    Write-Host "CASOS FALLIDOS:" -ForegroundColor Red
    Write-Host ""
    $results | Where-Object { $_.Resultado -eq "FAIL" } | ForEach-Object {
        Write-Host "  [$($_.ID)] $($_.Descripcion)" -ForegroundColor Red
        Write-Host "     Endpoint: $($_.Endpoint)" -ForegroundColor Gray
        Write-Host "     Status esperado: $($_.StatusEsperado)" -ForegroundColor Gray
        Write-Host "     Status obtenido: $($_.StatusObtenido)" -ForegroundColor Gray
        if ($_.Error) {
            Write-Host "     Error: $($_.Error)" -ForegroundColor Yellow
        }
        Write-Host ""
    }
}

# Guardar reporte en archivo
$fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$reportePath = "REPORTE_CASOS_PRUEBA_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"

$reporte = "# Reporte de Ejecución de Casos de Prueba - Sistema TPI`n"
$reporte += "Fecha: $fecha`n`n"
$reporte += "## Resumen`n"
$reporte += "- Total de casos: $total`n"
$reporte += "- Exitosos: $exitosos`n"
$reporte += "- Fallidos: $fallidos`n"
$reporte += "- Tasa de éxito: $([Math]::Round(($exitosos / $total) * 100, 2))%`n`n"

$reporte += "## Detalle de Casos`n`n"

foreach ($result in $results) {
    $icono = if ($result.Resultado -eq "OK") { "✅" } else { "❌" }
    $reporte += "### $icono [$($result.ID)] $($result.Descripcion)`n"
    $reporte += "- **Endpoint**: $($result.Endpoint)`n"
    $reporte += "- **Status esperado**: $($result.StatusEsperado)`n"
    $reporte += "- **Status obtenido**: $($result.StatusObtenido)`n"
    $reporte += "- **Resultado**: $($result.Resultado)`n"
    
    if ($result.Error) {
        $reporte += "- **Error**: $($result.Error)`n"
    }
    
    if ($result.Response) {
        $responseJson = $result.Response | ConvertTo-Json -Depth 3 -Compress
        if ($responseJson.Length -gt 500) {
            $responseJson = $responseJson.Substring(0, 500) + "..."
        }
        $reporte += "- **Respuesta**: ``$responseJson`` `n"
    }
    
    $reporte += "`n"
}

$reporte | Out-File -FilePath $reportePath -Encoding UTF8
Write-Host "Reporte guardado en: $reportePath" -ForegroundColor Green
Write-Host ""

# Retornar código de salida
if ($fallidos -gt 0) {
    exit 1
} else {
    exit 0
}

