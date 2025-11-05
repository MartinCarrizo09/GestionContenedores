# ============================================================
# Script de Configuración de Variables de Entorno - Supabase
# ============================================================
# 
# Este script configura las variables de entorno necesarias
# para conectar los microservicios a Supabase.
#
# USO:
#   .\setup-env.ps1
#
# ============================================================

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Configuración de Variables de Entorno - Supabase" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ========== Solicitar Password de Supabase ==========
Write-Host "Por favor, ingresa la contraseña de tu base de datos Supabase:" -ForegroundColor Yellow
Write-Host "(Puedes obtenerla en: Supabase > Project Settings > Database)" -ForegroundColor Gray
Write-Host ""

$supabasePassword = Read-Host "Password" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($supabasePassword)
$passwordPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# ========== Configurar Variables de Entorno ==========
Write-Host ""
Write-Host "Configurando variables de entorno..." -ForegroundColor Green

# Supabase Database Configuration
$env:SUPABASE_DB_HOST = "jqshojwvwpoovjffscyv.supabase.co"
$env:SUPABASE_DB_PORT = "5432"
$env:SUPABASE_DB_NAME = "postgres"
$env:SUPABASE_DB_USER = "postgres.jqshojwvwpoovjffscyv"
$env:SUPABASE_DB_PASSWORD = $passwordPlainText

# Supabase API
$env:SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impxc2hvand2d3Bvb3ZqZmZzY3l2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzNTU0MjMsImV4cCI6MjA3NzkzMTQyM30.mp3b1BIsk9GFMJgPtuwwX7gQPwdRyKDp029DbOaXQHM"

# Google Maps API
$env:GOOGLE_MAPS_API_KEY = "AIzaSyAUp0j1WFgacoQYTKhtPI-CF6Ld7a7jHSg"

# Logging Configuration
$env:LOG_LEVEL = "INFO"
$env:SQL_LOG_LEVEL = "DEBUG"
$env:SQL_PARAMS_LOG_LEVEL = "TRACE"
$env:SHOW_SQL = "true"

# Server Ports
$env:GESTION_SERVER_PORT = "8080"
$env:FLOTA_SERVER_PORT = "8081"
$env:LOGISTICA_SERVER_PORT = "8082"

Write-Host "✅ Variables de entorno configuradas correctamente!" -ForegroundColor Green
Write-Host ""

# ========== Verificar Configuración ==========
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Verificación de Variables de Entorno" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 Configuración actual:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Database Host:     " -NoNewline; Write-Host $env:SUPABASE_DB_HOST -ForegroundColor Green
Write-Host "  Database Port:     " -NoNewline; Write-Host $env:SUPABASE_DB_PORT -ForegroundColor Green
Write-Host "  Database Name:     " -NoNewline; Write-Host $env:SUPABASE_DB_NAME -ForegroundColor Green
Write-Host "  Database User:     " -NoNewline; Write-Host $env:SUPABASE_DB_USER -ForegroundColor Green
Write-Host "  Password Set:      " -NoNewline; Write-Host "✅ Configurada (oculta)" -ForegroundColor Green
Write-Host ""
Write-Host "  Servicio Gestión:  " -NoNewline; Write-Host "http://localhost:$env:GESTION_SERVER_PORT" -ForegroundColor Cyan
Write-Host "  Servicio Flota:    " -NoNewline; Write-Host "http://localhost:$env:FLOTA_SERVER_PORT" -ForegroundColor Cyan
Write-Host "  Servicio Logística:" -NoNewline; Write-Host "http://localhost:$env:LOGISTICA_SERVER_PORT" -ForegroundColor Cyan
Write-Host ""

# ========== Crear archivo .env para referencia ==========
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Creando archivo .env" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$envContent = @"
# Archivo .env generado automáticamente
# Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# ========== SUPABASE DATABASE CONFIGURATION ==========
SUPABASE_DB_HOST=jqshojwvwpoovjffscyv.supabase.co
SUPABASE_DB_PORT=5432
SUPABASE_DB_NAME=postgres
SUPABASE_DB_USER=postgres.jqshojwvwpoovjffscyv
SUPABASE_DB_PASSWORD=$passwordPlainText

# ========== SUPABASE API ==========
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impxc2hvand2d3Bvb3ZqZmZzY3l2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzNTU0MjMsImV4cCI6MjA3NzkzMTQyM30.mp3b1BIsk9GFMJgPtuwwX7gQPwdRyKDp029DbOaXQHM

# ========== GOOGLE MAPS API ==========
GOOGLE_MAPS_API_KEY=AIzaSyAUp0j1WFgacoQYTKhtPI-CF6Ld7a7jHSg

# ========== CONFIGURACIÓN DE LOGS ==========
LOG_LEVEL=INFO
SQL_LOG_LEVEL=DEBUG
SQL_PARAMS_LOG_LEVEL=TRACE
SHOW_SQL=true

# ========== PUERTOS DE LOS SERVICIOS ==========
GESTION_SERVER_PORT=8080
FLOTA_SERVER_PORT=8081
LOGISTICA_SERVER_PORT=8082
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Host "✅ Archivo .env creado correctamente" -ForegroundColor Green
Write-Host "⚠️  IMPORTANTE: NO subas este archivo a Git (ya está en .gitignore)" -ForegroundColor Red
Write-Host ""

# ========== Instrucciones finales ==========
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Próximos Pasos" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. ✅ Variables de entorno configuradas en esta sesión de PowerShell" -ForegroundColor Green
Write-Host "2. 📝 Archivo .env creado para futuras sesiones" -ForegroundColor Green
Write-Host ""
Write-Host "Para iniciar los servicios:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  cd servicio-gestion" -ForegroundColor Cyan
Write-Host "  mvn spring-boot:run" -ForegroundColor Cyan
Write-Host ""
Write-Host "  cd servicio-flota" -ForegroundColor Cyan
Write-Host "  mvn spring-boot:run" -ForegroundColor Cyan
Write-Host ""
Write-Host "  cd servicio-logistica" -ForegroundColor Cyan
Write-Host "  mvn spring-boot:run" -ForegroundColor Cyan
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Limpiar variable sensible de la memoria
Remove-Variable -Name passwordPlainText
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
