#!/bin/bash

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Chatwoot Favicon Generator ===${NC}"

# Verificar se ImageMagick está instalado
if ! command -v convert &> /dev/null; then
    echo -e "${RED}❌ ImageMagick não encontrado!${NC}"
    echo -e "${YELLOW}Instalando via Homebrew...${NC}"
    brew install imagemagick
fi

# Diretório base
BASE_DIR="/Users/rogerhounfourt/Documents/GitHub/chatwoot"
PUBLIC_DIR="$BASE_DIR/public"
ZIP_FILE="$PUBLIC_DIR/favicon.zip"
TEMP_DIR=$(mktemp -d)

cleanup() {
  echo -e "${YELLOW}Limpando arquivos temporários...${NC}"
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Verificar se o zip existe
if [ ! -f "$ZIP_FILE" ]; then
    echo -e "${RED}❌ Arquivo $ZIP_FILE não encontrado!${NC}"
    exit 1
fi

echo -e "${GREEN}📦 Extraindo favicons...${NC}"
unzip -q -o "$ZIP_FILE" -d "$TEMP_DIR"

# Encontrar a imagem base (512x512)
BASE_IMAGE="$TEMP_DIR/web-app-manifest-512x512.png"
if [ ! -f "$BASE_IMAGE" ]; then
    echo -e "${RED}❌ Imagem base 512x512 não encontrada!${NC}"
    exit 1
fi

echo -e "${GREEN}🎨 Gerando favicons em todos os tamanhos...${NC}"

# Função para gerar favicon
generate_favicon() {
    local size=$1
    local output_name=$2
    echo -e "  → Gerando ${output_name} (${size}x${size})"
    convert "$BASE_IMAGE" -resize ${size}x${size} "$PUBLIC_DIR/${output_name}"
}

# Android Icons
echo -e "${YELLOW}📱 Android Icons${NC}"
generate_favicon 36 "android-icon-36x36.png"
generate_favicon 48 "android-icon-48x48.png"
generate_favicon 72 "android-icon-72x72.png"
generate_favicon 96 "android-icon-96x96.png"
generate_favicon 144 "android-icon-144x144.png"
generate_favicon 192 "android-icon-192x192.png"

# Apple Icons
echo -e "${YELLOW}🍎 Apple Icons${NC}"
generate_favicon 57 "apple-icon-57x57.png"
generate_favicon 60 "apple-icon-60x60.png"
generate_favicon 72 "apple-icon-72x72.png"
generate_favicon 76 "apple-icon-76x76.png"
generate_favicon 114 "apple-icon-114x114.png"
generate_favicon 120 "apple-icon-120x120.png"
generate_favicon 144 "apple-icon-144x144.png"
generate_favicon 152 "apple-icon-152x152.png"
generate_favicon 180 "apple-icon-180x180.png"

# Copiar variações do 180x180
cp "$PUBLIC_DIR/apple-icon-180x180.png" "$PUBLIC_DIR/apple-icon.png"
cp "$PUBLIC_DIR/apple-icon-180x180.png" "$PUBLIC_DIR/apple-icon-precomposed.png"
cp "$PUBLIC_DIR/apple-icon-180x180.png" "$PUBLIC_DIR/apple-touch-icon.png"
cp "$PUBLIC_DIR/apple-icon-180x180.png" "$PUBLIC_DIR/apple-touch-icon-precomposed.png"

# Favicons gerais
echo -e "${YELLOW}🌐 Favicons Gerais${NC}"
generate_favicon 16 "favicon-16x16.png"
generate_favicon 32 "favicon-32x32.png"
generate_favicon 96 "favicon-96x96.png"
generate_favicon 512 "favicon-512x512.png"

# Favicon Badge (para notificações)
echo -e "${YELLOW}🔔 Favicon Badges${NC}"
generate_favicon 16 "favicon-badge-16x16.png"
generate_favicon 32 "favicon-badge-32x32.png"
generate_favicon 96 "favicon-badge-96x96.png"

# Microsoft Icons
echo -e "${YELLOW}🪟 Microsoft Icons${NC}"
generate_favicon 70 "ms-icon-70x70.png"
generate_favicon 144 "ms-icon-144x144.png"
generate_favicon 150 "ms-icon-150x150.png"
generate_favicon 310 "ms-icon-310x310.png"

# Copiar arquivos existentes do zip
echo -e "${YELLOW}📋 Copiando arquivos adicionais do zip...${NC}"
if [ -f "$TEMP_DIR/favicon.svg" ]; then
    cp "$TEMP_DIR/favicon.svg" "$PUBLIC_DIR/favicon.svg"
    echo -e "  → favicon.svg"
fi

if [ -f "$TEMP_DIR/favicon.ico" ]; then
    cp "$TEMP_DIR/favicon.ico" "$PUBLIC_DIR/favicon.ico"
    echo -e "  → favicon.ico"
fi

if [ -f "$TEMP_DIR/site.webmanifest" ]; then
    cp "$TEMP_DIR/site.webmanifest" "$PUBLIC_DIR/site.webmanifest"
    echo -e "  → site.webmanifest"
fi

echo -e "${GREEN}✅ Processo completo!${NC}"
echo -e "${GREEN}📁 Favicons gerados em: $PUBLIC_DIR${NC}"
echo ""
echo -e "${YELLOW}📊 Resumo:${NC}"
echo -e "  • 6 ícones Android"
echo -e "  • 13 ícones Apple"
echo -e "  • 4 favicons gerais"
echo -e "  • 3 favicon badges"
echo -e "  • 4 ícones Microsoft"
echo -e "  • Total: 30 arquivos PNG + SVG/ICO/manifest"
echo ""
echo -e "${GREEN}🚀 Próximos passos:${NC}"
echo -e "  1. Revisar os ícones gerados em public/"
echo -e "  2. Commitar as mudanças: git add public/ && git commit -m 'feat: update favicons'"
echo -e "  3. Deploy: docker-compose up -d --force-recreate"
