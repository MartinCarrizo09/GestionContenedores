# =====================================================
# Script de Setup Completo del Sistema TPI
# =====================================================
# Este script:
# 1. Elimina contenedores y volúmenes existentes
# 2. Rebuildea todas las imágenes desde cero (10 minutos)
# 3. Reinicia la BD a 0 con init-db.sql
# 4. Configura Keycloak automáticamente
# 5. Obtiene tokens para testing
# =====================================================

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SETUP COMPLETO DEL SISTEMA TPI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# =====================================================
# PASO 1: Eliminar contenedores y volúmenes existentes
# =====================================================
Write-Host "1. Eliminando contenedores y volúmenes existentes..." -ForegroundColor Yellow

try {
    docker-compose down -v 2>&1 | Out-Null
    Write-Host "   Contenedores y volúmenes eliminados" -ForegroundColor Green
} catch {
    Write-Host "   No había contenedores para eliminar" -ForegroundColor Gray
}

Write-Host ""

# =====================================================
# PASO 2: Rebuildear todas las imágenes desde cero
# =====================================================
Write-Host "2. Rebuildando imágenes Docker desde cero..." -ForegroundColor Yellow
Write-Host "   Esto puede tomar aproximadamente 10 minutos..." -ForegroundColor Gray
Write-Host ""

$buildStartTime = Get-Date

try {
    # Rebuildear sin cache
    docker-compose build --no-cache
    
    if ($LASTEXITCODE -ne 0) {
        throw "Error al rebuildear las imágenes"
    }
    
    $buildEndTime = Get-Date
    $buildDuration = $buildEndTime - $buildStartTime
    $buildMinutes = [Math]::Round($buildDuration.TotalMinutes, 1)
    
    Write-Host ""
    Write-Host "   Build completado en $buildMinutes minutos" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "ERROR: No se pudieron rebuildear las imágenes Docker" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""

# =====================================================
# PASO 3: Iniciar servicios (esto ejecuta init-db.sql)
# =====================================================
Write-Host "3. Iniciando servicios y reiniciando BD a 0..." -ForegroundColor Yellow
Write-Host "   La BD se reiniciará automáticamente con init-db.sql..." -ForegroundColor Gray

try {
    docker-compose up -d
    
    if ($LASTEXITCODE -ne 0) {
        throw "Error al iniciar los servicios"
    }
    
    Write-Host "   Servicios iniciados" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "ERROR: No se pudieron iniciar los servicios" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""

# =====================================================
# PASO 4: Esperar a que los servicios estén listos
# =====================================================
Write-Host "4. Esperando a que los servicios estén listos..." -ForegroundColor Yellow

# Esperar a que PostgreSQL esté listo
Write-Host "   Esperando PostgreSQL..." -NoNewline
$postgresReady = $false
$maxAttempts = 30
$attempt = 0

while (-not $postgresReady -and $attempt -lt $maxAttempts) {
    $attempt++
    try {
        $health = docker inspect --format='{{.State.Health.Status}}' tpi-postgres 2>&1
        if ($health -eq "healthy") {
            $postgresReady = $true
            Write-Host " OK" -ForegroundColor Green
        } else {
            Start-Sleep -Seconds 2
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}

if (-not $postgresReady) {
    Write-Host " Warning: PostgreSQL puede no estar completamente listo" -ForegroundColor Yellow
}

# Esperar a que Keycloak esté listo
Write-Host "   Esperando Keycloak..." -NoNewline
$keycloakReady = $false
$maxAttempts = 60
$attempt = 0

while (-not $keycloakReady -and $attempt -lt $maxAttempts) {
    $attempt++
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:9090/realms/master" -Method GET -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $keycloakReady = $true
            Write-Host " OK" -ForegroundColor Green
        }
    } catch {
        if ($attempt -lt $maxAttempts) {
            Start-Sleep -Seconds 3
        }
    }
}

if (-not $keycloakReady) {
    Write-Host " Warning: Keycloak puede no estar completamente listo" -ForegroundColor Yellow
    Write-Host "   Continuando de todas formas..." -ForegroundColor Yellow
}

Write-Host ""

# Esperar un poco más para que todos los servicios estén completamente listos
Write-Host "   Esperando que todos los servicios terminen de inicializar..." -ForegroundColor Gray
Write-Host "   (Keycloak puede tardar hasta 2 minutos en inicializar completamente)..." -ForegroundColor Gray
Start-Sleep -Seconds 30

# Verificar nuevamente Keycloak antes de continuar
Write-Host "   Verificando Keycloak nuevamente..." -NoNewline
$keycloakReady = $false
$maxAttempts = 40
$attempt = 0

while (-not $keycloakReady -and $attempt -lt $maxAttempts) {
    $attempt++
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:9090/realms/master" -Method GET -TimeoutSec 3 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $keycloakReady = $true
            Write-Host " OK" -ForegroundColor Green
        }
    } catch {
        if ($attempt -lt $maxAttempts) {
            Start-Sleep -Seconds 3
        }
    }
}

if (-not $keycloakReady) {
    Write-Host " Warning: Keycloak aún no está listo, pero continuaremos..." -ForegroundColor Yellow
    Write-Host "   Puedes ejecutar manualmente: .\iniciar-sistema.ps1" -ForegroundColor Yellow
}

Write-Host ""

# =====================================================
# PASO 5: Ejecutar configuración de Keycloak y tokens
# =====================================================
Write-Host "5. Configurando Keycloak y obteniendo tokens..." -ForegroundColor Yellow
Write-Host ""

try {
    & .\iniciar-sistema.ps1
    
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
        Write-Host ""
        Write-Host "Warning: El script de configuración puede no haber completado correctamente" -ForegroundColor Yellow
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: No se pudo ejecutar el script de configuración" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Puedes ejecutar manualmente: .\iniciar-sistema.ps1" -ForegroundColor Yellow
}

Write-Host ""

# =====================================================
# RESUMEN FINAL
# =====================================================
Write-Host "========================================" -ForegroundColor Green
Write-Host "SISTEMA LISTO PARA USAR CON POSTMAN" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Servicios disponibles:" -ForegroundColor Cyan
Write-Host "  * PostgreSQL: localhost:5432" -ForegroundColor White
Write-Host "  * Keycloak Admin: http://localhost:9090/admin" -ForegroundColor White
Write-Host "  * API Gateway: http://localhost:8080" -ForegroundColor White
Write-Host "  * Servicio Gestión: http://localhost:8081/api/gestion" -ForegroundColor White
Write-Host "  * Servicio Flota: http://localhost:8082/api/flota" -ForegroundColor White
Write-Host "  * Servicio Logística: http://localhost:8083/api/logistica" -ForegroundColor White
Write-Host ""

Write-Host "Usuarios de prueba:" -ForegroundColor Cyan
Write-Host "  * cliente@tpi.com / cliente123 (CLIENTE)" -ForegroundColor White
Write-Host "  * operador@tpi.com / operador123 (OPERADOR)" -ForegroundColor White
Write-Host "  * transportista@tpi.com / transportista123 (TRANSPORTISTA)" -ForegroundColor White
Write-Host ""

Write-Host "Comandos útiles:" -ForegroundColor Cyan
Write-Host "  * Ver logs: docker-compose logs -f" -ForegroundColor Gray
Write-Host "  * Detener: docker-compose down" -ForegroundColor Gray
Write-Host "  * Reiniciar: docker-compose restart" -ForegroundColor Gray
Write-Host ""

Write-Host "¡Sistema listo para usar con Postman!" -ForegroundColor Green
Write-Host ""

