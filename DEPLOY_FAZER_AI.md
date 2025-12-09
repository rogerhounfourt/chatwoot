# Deploy Chatwoot Fazer.ai via Docker

Este guia mostra como personalizar e deployar o Chatwoot customizado da Fazer.ai usando Docker.

---

## 1️⃣ Personalização de Branding

### Opção A: Variáveis de Ambiente (Recomendado para Docker)

Adicione ao seu arquivo `.env`:

```bash
# Branding Fazer.ai
INSTALLATION_NAME="Fazer.ai Atendimento"
BRAND_NAME="Fazer.ai"
BRAND_URL="https://fazer.ai"
WIDGET_BRAND_URL="https://fazer.ai"
LOGO_THUMBNAIL="https://fazer.ai/assets/logo-512.png"
LOGO="https://fazer.ai/assets/logo.svg"
LOGO_DARK="https://fazer.ai/assets/logo-dark.svg"
TERMS_URL="https://fazer.ai/termos"
PRIVACY_URL="https://fazer.ai/privacidade"
DISPLAY_MANIFEST="false"
```

### Opção B: Rake Task (Para customização avançada)

Se usar imagem customizada (build próprio):

```bash
docker exec -it chatwoot_rails_1 bash
export INSTALLATION_NAME="Fazer.ai Atendimento"
export BRAND_NAME="Fazer.ai"
export LOGO="https://fazer.ai/assets/logo.svg"
bundle exec rails branding:update
exit
```

### Favicon e Assets Personalizados

**Via Zip (método automático):**

```bash
# 1. Crie um zip com seus favicons (veja lista em CUSTOM_BRANDING.md)
zip brand-assets.zip favicon-*.png apple-icon-*.png android-icon-*.png

# 2. Extraia no container
docker cp brand-assets.zip chatwoot_rails_1:/app/
docker exec chatwoot_rails_1 bash -c "cd /app && deployment/extract_brand_assets.sh brand-assets.zip"
```

**Via Volume (método persistente):**

Adicione ao `docker-compose.production.yaml`:

```yaml
volumes:
  - ./public/brand-assets:/app/public/brand-assets:ro
  - ./public/favicon-*.png:/app/public/:ro
```

---

## 2️⃣ Deploy via Docker

### Pré-requisitos

- Docker 24+ e Docker Compose
- Git configurado com acesso ao repositório `fazer-ai/chatwoot`

### Estrutura de Arquivos

```
/seu-servidor/chatwoot/
├── .env                          # Configurações (CRIAR)
├── docker-compose.yml            # Orquestração
└── public/                       # Assets customizados (opcional)
    └── brand-assets/
```

### Setup Inicial

```bash
# 1. Clone o repositório customizado
git clone https://github.com/fazer-ai/chatwoot.git
cd chatwoot

# 2. Configure variáveis de ambiente
cp .env.example .env
nano .env  # Ou vim/code
```

### Configuração `.env` Essencial

```bash
# === Database ===
POSTGRES_PASSWORD=SuaSenhaSegura123!
POSTGRES_DB=chatwoot_production

# === Redis ===
REDIS_PASSWORD=OutraSenhaSegura456!

# === Rails ===
SECRET_KEY_BASE=$(openssl rand -hex 64)
RAILS_ENV=production
NODE_ENV=production

# === URLs ===
FRONTEND_URL=https://atendimento.fazer.ai
FORCE_SSL=true

# === Email (exemplo SMTP) ===
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@fazer.ai
SMTP_PASSWORD=senha-app
SMTP_DOMAIN=fazer.ai
MAILER_SENDER_EMAIL=atendimento@fazer.ai

# === Branding (adicione as vars da seção 1) ===
INSTALLATION_NAME="Fazer.ai Atendimento"
BRAND_NAME="Fazer.ai"
# ... (resto das vars de branding)

# === Z-API (integração customizada Fazer.ai) ===
# Adicione suas credenciais Z-API se usar WhatsApp
ZAPI_INSTANCE_ID=sua-instance-id
ZAPI_TOKEN=seu-token
```

### Ajuste Docker Compose para Produção

Crie `docker-compose.override.yml` (ou edite `docker-compose.production.yaml`):

```yaml
version: '3'

services:
  rails:
    image: ghcr.io/fazer-ai/chatwoot:latest  # Ou sua imagem customizada
    restart: unless-stopped
    ports:
      - "3000:3000"  # Ajuste se usar nginx reverso
    environment:
      - RAILS_LOG_TO_STDOUT=true
    volumes:
      - storage_data:/app/storage
      - ./public/brand-assets:/app/public/brand-assets:ro  # Se usar assets locais
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  sidekiq:
    image: ghcr.io/fazer-ai/chatwoot:latest
    restart: unless-stopped

  postgres:
    image: pgvector/pgvector:pg16
    restart: unless-stopped
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups  # Para backups
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB:-chatwoot_production}

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - redis_data:/data

volumes:
  storage_data:
  postgres_data:
  redis_data:
```

### Deploy

```bash
# 1. Iniciar serviços
docker-compose -f docker-compose.production.yaml up -d

# 2. Verificar logs
docker-compose -f docker-compose.production.yaml logs -f rails

# 3. Rodar migrações (primeira vez)
docker-compose -f docker-compose.production.yaml exec rails bundle exec rails db:chatwoot_prepare

# 4. (Opcional) Aplicar branding via rake task
docker-compose -f docker-compose.production.yaml exec rails \
  env INSTALLATION_NAME="Fazer.ai" BRAND_NAME="Fazer.ai" \
  bundle exec rails branding:update
```

### Verificação

```bash
# Status dos containers
docker-compose -f docker-compose.production.yaml ps

# Acessar console Rails (debugging)
docker-compose -f docker-compose.production.yaml exec rails bundle exec rails console

# Logs em tempo real
docker-compose -f docker-compose.production.yaml logs -f
```

Acesse: `http://localhost:3000` (ou sua URL configurada)

---

## 3️⃣ Build Customizado (Opcional)

Se quiser incluir assets no build:

```bash
# 1. Adicione seus logos em public/brand-assets/
mkdir -p public/brand-assets
cp /caminho/para/logo.svg public/brand-assets/
cp /caminho/para/favicon-*.png public/

# 2. Edite Dockerfile se necessário
nano docker/Dockerfile

# 3. Build
docker build -t fazer.ai/chatwoot:v4.8.0-custom -f docker/Dockerfile .

# 4. Atualize docker-compose.yml
# image: fazer.ai/chatwoot:v4.8.0-custom

# 5. Push para registry (GitHub, Docker Hub, etc.)
docker tag fazer.ai/chatwoot:v4.8.0-custom ghcr.io/fazer-ai/chatwoot:v4.8.0-custom
docker push ghcr.io/fazer-ai/chatwoot:v4.8.0-custom
```

---

## 4️⃣ Nginx Reverso (Produção)

Exemplo de configuração nginx:

```nginx
server {
    listen 80;
    server_name atendimento.fazer.ai;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name atendimento.fazer.ai;

    ssl_certificate /etc/letsencrypt/live/atendimento.fazer.ai/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/atendimento.fazer.ai/privkey.pem;

    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

---

## 5️⃣ Atualizações

```bash
# 1. Baixar última versão fazer-ai
cd /caminho/para/chatwoot
git pull origin main

# 2. Rebuild (se necessário)
docker-compose -f docker-compose.production.yaml pull

# 3. Recriar containers
docker-compose -f docker-compose.production.yaml up -d --force-recreate

# 4. Rodar migrações
docker-compose -f docker-compose.production.yaml exec rails bundle exec rails db:migrate
```

---

## 6️⃣ Backup

```bash
# Postgres
docker-compose -f docker-compose.production.yaml exec postgres \
  pg_dump -U postgres chatwoot_production > backup-$(date +%Y%m%d).sql

# Storage (anexos, etc.)
docker run --rm -v chatwoot_storage_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/storage-$(date +%Y%m%d).tar.gz /data

# Redis (opcional - dados voláteis)
docker-compose -f docker-compose.production.yaml exec redis redis-cli --rdb /data/dump.rdb
```

---

## 🔧 Troubleshooting

**Assets não aparecem:**
```bash
# Recompilar assets
docker-compose -f docker-compose.production.yaml exec rails bundle exec rails assets:precompile
```

**Branding não aplicado:**
```bash
# Verificar variáveis
docker-compose -f docker-compose.production.yaml exec rails env | grep BRAND

# Reaplicar
docker-compose -f docker-compose.production.yaml exec rails \
  bundle exec rails branding:update
```

**Logs de erro:**
```bash
# Rails
docker-compose -f docker-compose.production.yaml logs rails | tail -100

# Sidekiq (jobs)
docker-compose -f docker-compose.production.yaml logs sidekiq | tail -100
```

---

## 📚 Referências

- [Documentação oficial Docker](https://www.chatwoot.com/docs/self-hosted/deployment/docker)
- [Customização de branding](./CUSTOM_BRANDING.md)
- [Changelog Fazer.ai](https://github.com/fazer-ai/chatwoot/releases)
