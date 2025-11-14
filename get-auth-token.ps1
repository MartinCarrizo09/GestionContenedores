# =====================================================
# get-auth-token.ps1
# Obtiene un token de autenticación desde el API Gateway
# y lo guarda en variables de entorno
# =====================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$Username = "cliente@tpi.com",
    
    [Parameter(Mandatory=$false)]
    [string]$Password = "cliente123",
    
    [Parameter(Mandatory=$false)]
    [string]$GatewayUrl = "http://localhost:8080"
)

$ErrorActionPreference = "Stop"

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  🔐 OBTENER TOKEN DE AUTENTICACIÓN" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

Write-Host "Usuario: $Username" -ForegroundColor White
Write-Host "Gateway: $GatewayUrl" -ForegroundColor White
Write-Host ""

# Preparar body JSON
$body = @{
    username = $Username
    password = $Password
} | ConvertTo-Json

Write-Host "🔄 Solicitando token..." -ForegroundColor Yellow

try {
    # Hacer request al Gateway
    $response = Invoke-RestMethod -Uri "$GatewayUrl/auth/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $body `
        -ErrorAction Stop
    
    # Guardar tokens en variables de entorno
    $env:ACCESS_TOKEN = $response.access_token
    $env:REFRESH_TOKEN = $response.refresh_token
    $env:TOKEN_TYPE = $response.token_type
    
    # Calcular tiempo de expiración
    $expiresAt = (Get-Date).AddSeconds($response.expires_in)
    $refreshExpiresAt = (Get-Date).AddSeconds($response.refresh_expires_in)
    
    Write-Host ""
    Write-Host "✅ TOKEN OBTENIDO EXITOSAMENTE" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Información del Token:" -ForegroundColor Cyan
    Write-Host "   Token Type: $($response.token_type)" -ForegroundColor Gray
    $minutos = [Math]::Round($response.expires_in / 60, 1)
    $refreshMinutos = [Math]::Round($response.refresh_expires_in / 60, 1)
    Write-Host "   Expira en: $($response.expires_in) segundos ($minutos minutos)" -ForegroundColor Gray
    Write-Host "   Expira a las: $($expiresAt.ToString('HH:mm:ss'))" -ForegroundColor Gray
    Write-Host "   Refresh expira en: $($response.refresh_expires_in) segundos ($refreshMinutos minutos)" -ForegroundColor Gray
    Write-Host "   Refresh expira a las: $($refreshExpiresAt.ToString('HH:mm:ss'))" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "💾 Variables de Entorno Configuradas:" -ForegroundColor Cyan
    Write-Host "   `$env:ACCESS_TOKEN" -ForegroundColor White
    Write-Host "   `$env:REFRESH_TOKEN" -ForegroundColor White
    Write-Host "   `$env:TOKEN_TYPE" -ForegroundColor White
    Write-Host ""
    
    # Mostrar preview del token
    $tokenPreview = $response.access_token.Substring(0, [Math]::Min(60, $response.access_token.Length))
    Write-Host "🔍 Token Preview:" -ForegroundColor Cyan
    Write-Host "   $tokenPreview..." -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "📝 Uso en curl:" -ForegroundColor Cyan
    Write-Host '   curl -X GET http://localhost:8080/api/gestion/contenedores `' -ForegroundColor Gray
    Write-Host '     -H "Authorization: Bearer $env:ACCESS_TOKEN"' -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "📝 Uso en Invoke-RestMethod:" -ForegroundColor Cyan
    Write-Host '   $headers = @{ Authorization = "Bearer $env:ACCESS_TOKEN" }' -ForegroundColor Gray
    Write-Host '   Invoke-RestMethod -Uri "http://localhost:8080/api/..." -Headers $headers' -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "✅ Listo para usar!" -ForegroundColor Green
    Write-Host ""
    
    # Retornar el token (opcional, para scripts que lo capturen)
    return $response.access_token
}
catch {
    Write-Host ""
    Write-Host "❌ ERROR AL OBTENER TOKEN" -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   Status Code: $statusCode" -ForegroundColor Red
        
        if ($statusCode -eq 401) {
            Write-Host "   Causa probable: Credenciales inválidas" -ForegroundColor Yellow
            Write-Host "   Verificar:" -ForegroundColor Yellow
            Write-Host "     - Username: $Username" -ForegroundColor Gray
            Write-Host "     - Password: *** (oculto)" -ForegroundColor Gray
            Write-Host "     - El usuario existe en Keycloak?" -ForegroundColor Gray
        }
        elseif ($statusCode -eq 404) {
            Write-Host "   Causa probable: Endpoint no encontrado" -ForegroundColor Yellow
            Write-Host "   Verificar que el Gateway esté corriendo:" -ForegroundColor Yellow
            Write-Host "     docker ps | findstr gateway" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Causa probable: Gateway no está corriendo" -ForegroundColor Yellow
        Write-Host "   Verificar:" -ForegroundColor Yellow
        Write-Host "     docker ps" -ForegroundColor Gray
        Write-Host "     docker logs tpi-gateway --tail 20" -ForegroundColor Gray
    }
    
    Write-Host ""
    exit 1
}
