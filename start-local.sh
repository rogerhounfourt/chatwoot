#!/bin/bash

set -e

echo "🚀 Iniciando Chatwoot Conecta localmente..."

# Gerar SECRET_KEY_BASE se não existir
if ! grep -q "SECRET_KEY_BASE=" docker-compose.local.yaml 2>/dev/null; then
    echo "🔑 Gerando SECRET_KEY_BASE..."
    SECRET_KEY=$(openssl rand -hex 64)
    sed -i '' "s/replace_with_your_secret_key_base/$SECRET_KEY/g" docker-compose.local.yaml
    echo "✅ SECRET_KEY_BASE configurado"
fi

echo "📥 Baixando imagens Docker..."
docker-compose -f docker-compose.local.yaml pull

echo "🏗️  Iniciando containers..."
docker-compose -f docker-compose.local.yaml up -d

echo "⏳ Aguardando banco de dados inicializar (30s)..."
sleep 30

echo "🗄️  Executando migrações..."
docker-compose -f docker-compose.local.yaml exec -T rails bundle exec rails db:chatwoot_prepare

echo "✅ Chatwoot Conecta iniciado!"
echo ""
echo "📍 Acesse: http://localhost:3000"
echo ""
echo "📊 Ver logs:"
echo "   docker-compose -f docker-compose.local.yaml logs -f"
echo ""
echo "🛑 Parar:"
echo "   docker-compose -f docker-compose.local.yaml down"
echo ""
echo "🗑️  Limpar tudo (dados também):"
echo "   docker-compose -f docker-compose.local.yaml down -v"
