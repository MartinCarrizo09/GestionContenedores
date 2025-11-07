# =====================================================
# setup-tokens.ps1
# Configura tokens para los 3 roles y los exporta
# =====================================================

param([string]$GatewayUrl = "http://localhost:8080")

Write-Host "`n CONFIGURAR TOKENS PARA TESTING`n" -ForegroundColor Cyan

$usuarios = @(
    @{ Rol = "CLIENTE"; Username = "cliente@tpi.com"; Password = "cliente123"; VarPrefix = "CLIENTE" }
    @{ Rol = "OPERADOR"; Username = "operador@tpi.com"; Password = "operador123"; VarPrefix = "OPERADOR" }
    @{ Rol = "TRANSPORTISTA"; Username = "transportista@tpi.com"; Password = "transportista123"; VarPrefix = "TRANSPORTISTA" }
)

$exitosos = 0

foreach ($usuario in $usuarios) {
    Write-Host " $($usuario.Rol)..." -ForegroundColor Yellow
    $body = @{ username = $usuario.Username; password = $usuario.Password } | ConvertTo-Json
    try {
        $r = Invoke-RestMethod -Uri "$GatewayUrl/auth/login" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        Set-Item -Path "Env:$($usuario.VarPrefix)_TOKEN" -Value $r.access_token
        Set-Item -Path "Env:$($usuario.VarPrefix)_REFRESH" -Value $r.refresh_token
        Write-Host "    OK - Expira en: $($r.expires_in)s`n" -ForegroundColor Green
        $exitosos++
    } catch {
        Write-Host "    Error`n" -ForegroundColor Red
    }
}

Write-Host " $exitosos/3 tokens configurados`n" -ForegroundColor Green
