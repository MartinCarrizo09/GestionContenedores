# Script para decodificar un token JWT y ver el issuer
param(
    [string]$Token
)

if ([string]::IsNullOrEmpty($Token)) {
    Write-Host "❌ Error: Debes proporcionar un token JWT" -ForegroundColor Red
    Write-Host ""
    Write-Host "Uso: .\decode-token.ps1 -Token 'eyJhbGci...'" -ForegroundColor Yellow
    exit 1
}

try {
    # Extraer el payload (segunda parte del JWT)
    $parts = $Token.Split('.')
    if ($parts.Count -ne 3) {
        Write-Host "❌ Error: El token JWT no tiene el formato correcto" -ForegroundColor Red
        exit 1
    }
    
    $payload = $parts[1]
    
    # Agregar padding si es necesario
    $padding = 4 - ($payload.Length % 4)
    if ($padding -ne 4) {
        $payload += "=" * $padding
    }
    
    # Decodificar de Base64
    $decodedBytes = [System.Convert]::FromBase64String($payload)
    $decodedJson = [System.Text.Encoding]::UTF8.GetString($decodedBytes)
    
    # Parsear JSON
    $tokenData = $decodedJson | ConvertFrom-Json
    
    # Mostrar información relevante
    Write-Host ""
    Write-Host "🔍 TOKEN JWT DECODIFICADO" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📍 ISSUER (iss):" -ForegroundColor Yellow
    Write-Host "   $($tokenData.iss)" -ForegroundColor White
    Write-Host ""
    Write-Host "👤 USUARIO:" -ForegroundColor Yellow
    Write-Host "   Username: $($tokenData.preferred_username)" -ForegroundColor White
    Write-Host "   Email: $($tokenData.email)" -ForegroundColor White
    Write-Host ""
    Write-Host "🔐 ROLES:" -ForegroundColor Yellow
    if ($tokenData.realm_access -and $tokenData.realm_access.roles) {
        $tokenData.realm_access.roles | ForEach-Object {
            Write-Host "   - $_" -ForegroundColor White
        }
    }
    Write-Host ""
    Write-Host "⏰ VALIDEZ:" -ForegroundColor Yellow
    $iatDate = [DateTimeOffset]::FromUnixTimeSeconds($tokenData.iat).LocalDateTime
    $expDate = [DateTimeOffset]::FromUnixTimeSeconds($tokenData.exp).LocalDateTime
    Write-Host "   Emitido: $iatDate" -ForegroundColor White
    Write-Host "   Expira:  $expDate" -ForegroundColor White
    
    $now = Get-Date
    if ($expDate -lt $now) {
        Write-Host "   ⚠️  TOKEN EXPIRADO" -ForegroundColor Red
    } else {
        Write-Host "   ✅ TOKEN VÁLIDO" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host "❌ Error al decodificar el token: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
