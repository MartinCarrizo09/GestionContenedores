#!/bin/bash
# =====================================================
# get-auth-token.sh
# Obtiene un token de autenticación desde el API Gateway
# y lo guarda en variables de entorno
# =====================================================

USERNAME=${1:-cliente@tpi.com}
PASSWORD=${2:-cliente123}
GATEWAY_URL=${3:-http://localhost:8080}

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}  🔐 OBTENER TOKEN DE AUTENTICACIÓN${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

echo -e "Usuario: ${USERNAME}"
echo -e "Gateway: ${GATEWAY_URL}"
echo ""

echo -e "${YELLOW}🔄 Solicitando token...${NC}"

# Hacer request al Gateway
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${GATEWAY_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"${USERNAME}\", \"password\": \"${PASSWORD}\"}")

# Separar body y status code
HTTP_BODY=$(echo "$RESPONSE" | head -n -1)
HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

if [ "$HTTP_STATUS" -eq 200 ]; then
    # Extraer tokens usando jq (o python si jq no está disponible)
    if command -v jq &> /dev/null; then
        export ACCESS_TOKEN=$(echo "$HTTP_BODY" | jq -r '.access_token')
        export REFRESH_TOKEN=$(echo "$HTTP_BODY" | jq -r '.refresh_token')
        export TOKEN_TYPE=$(echo "$HTTP_BODY" | jq -r '.token_type')
        EXPIRES_IN=$(echo "$HTTP_BODY" | jq -r '.expires_in')
        REFRESH_EXPIRES_IN=$(echo "$HTTP_BODY" | jq -r '.refresh_expires_in')
    else
        # Fallback sin jq (usando python)
        export ACCESS_TOKEN=$(echo "$HTTP_BODY" | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")
        export REFRESH_TOKEN=$(echo "$HTTP_BODY" | python3 -c "import sys, json; print(json.load(sys.stdin)['refresh_token'])")
        export TOKEN_TYPE=$(echo "$HTTP_BODY" | python3 -c "import sys, json; print(json.load(sys.stdin)['token_type'])")
        EXPIRES_IN=$(echo "$HTTP_BODY" | python3 -c "import sys, json; print(json.load(sys.stdin)['expires_in'])")
        REFRESH_EXPIRES_IN=$(echo "$HTTP_BODY" | python3 -c "import sys, json; print(json.load(sys.stdin)['refresh_expires_in'])")
    fi
    
    # Calcular minutos
    EXPIRES_MIN=$(echo "scale=1; $EXPIRES_IN / 60" | bc)
    REFRESH_EXPIRES_MIN=$(echo "scale=1; $REFRESH_EXPIRES_IN / 60" | bc)
    
    echo ""
    echo -e "${GREEN}✅ TOKEN OBTENIDO EXITOSAMENTE${NC}"
    echo ""
    echo -e "${CYAN}📊 Información del Token:${NC}"
    echo -e "   Token Type: ${TOKEN_TYPE}"
    echo -e "   Expira en: ${EXPIRES_IN} segundos (${EXPIRES_MIN} minutos)"
    echo -e "   Refresh expira en: ${REFRESH_EXPIRES_IN} segundos (${REFRESH_EXPIRES_MIN} minutos)"
    echo ""
    
    echo -e "${CYAN}💾 Variables de Entorno Configuradas:${NC}"
    echo -e "   \$ACCESS_TOKEN"
    echo -e "   \$REFRESH_TOKEN"
    echo -e "   \$TOKEN_TYPE"
    echo ""
    
    # Mostrar preview del token
    TOKEN_PREVIEW="${ACCESS_TOKEN:0:60}"
    echo -e "${CYAN}🔍 Token Preview:${NC}"
    echo -e "${GRAY}   ${TOKEN_PREVIEW}...${NC}"
    echo ""
    
    echo -e "${CYAN}📝 Uso en curl:${NC}"
    echo -e "${GRAY}   curl -X GET http://localhost:8080/api/gestion/contenedores \\${NC}"
    echo -e "${GRAY}     -H \"Authorization: Bearer \$ACCESS_TOKEN\"${NC}"
    echo ""
    
    echo -e "${GREEN}✅ Listo para usar!${NC}"
    echo -e "${YELLOW}💡 Recuerda: ejecuta este script con 'source' para exportar las variables:${NC}"
    echo -e "${GRAY}   source ./get-auth-token.sh $USERNAME $PASSWORD${NC}"
    echo ""
    
else
    echo ""
    echo -e "${RED}❌ ERROR AL OBTENER TOKEN${NC}"
    echo ""
    echo -e "   Status Code: ${HTTP_STATUS}"
    
    if [ "$HTTP_STATUS" -eq 401 ]; then
        echo -e "${YELLOW}   Causa probable: Credenciales inválidas${NC}"
        echo -e "${YELLOW}   Verificar:${NC}"
        echo -e "${GRAY}     - Username: ${USERNAME}${NC}"
        echo -e "${GRAY}     - Password: *** (oculto)${NC}"
        echo -e "${GRAY}     - El usuario existe en Keycloak?${NC}"
    elif [ "$HTTP_STATUS" -eq 404 ]; then
        echo -e "${YELLOW}   Causa probable: Endpoint no encontrado${NC}"
        echo -e "${YELLOW}   Verificar que el Gateway esté corriendo:${NC}"
        echo -e "${GRAY}     docker ps | grep gateway${NC}"
    elif [ "$HTTP_STATUS" -eq 000 ]; then
        echo -e "${YELLOW}   Causa probable: Gateway no está corriendo${NC}"
        echo -e "${YELLOW}   Verificar:${NC}"
        echo -e "${GRAY}     docker ps${NC}"
        echo -e "${GRAY}     docker logs tpi-gateway --tail 20${NC}"
    fi
    
    echo ""
    exit 1
fi
