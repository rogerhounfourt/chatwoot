# Deploy Chatwoot Conecta no Coolify

Guia rápido para deployar o fork customizado da Conecta usando Coolify.

---

## ✅ Pré-requisitos

- Coolify instalado e configurado
- Acesso ao repositório `https://github.com/conectai/chatwoot`
- Domínio configurado (ex: `atendimento.conecta.ai`)

---

## 🚀 Deploy no Coolify

### 1. Criar Novo Projeto

No Coolify:
1. **Projects** → **New Project**
2. Nome: `Chatwoot Conecta`

### 2. Adicionar Aplicação

1. **Add New Resource** → **Docker Compose**
2. Configurar:
   - **Name**: `chatwoot-conectai`
   - **Git Repository**: `https://github.com/conectai/chatwoot`
   - **Branch**: `main`
   - **Docker Compose File**: `docker-compose.coolify.yaml`

### 3. Configurar Variáveis de Ambiente

No Coolify, vá em **Environment Variables** e adicione:

```bash
# === Database ===
POSTGRES_PASSWORD=SuaSenhaSegura123!
POSTGRES_DB=chatwoot_production

# === Redis ===
REDIS_PASSWORD=OutraSenhaSegura456!

# === Rails ===
SECRET_KEY_BASE=<gerar_com_openssl_rand_hex_64>
RAILS_ENV=production
NODE_ENV=production
RAILS_LOG_TO_STDOUT=true

# === URLs ===
FRONTEND_URL=https://atendimento.conecta.ai
FORCE_SSL=true

# === Email (SMTP) ===
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
SMTP_USERNAME=seu-email@conecta.ai
SMTP_PASSWORD=senha-app-gmail
SMTP_DOMAIN=conecta.ai
MAILER_SENDER_EMAIL=atendimento@conecta.ai

# === Branding Conecta ===
INSTALLATION_NAME=Conecta Atendimento
BRAND_NAME=Conecta
BRAND_URL=https://conecta.ai
WIDGET_BRAND_URL=https://conecta.ai
LOGO_THUMBNAIL=/brand-assets/logo_thumbnail.svg
LOGO=/brand-assets/logo.svg
LOGO_DARK=/brand-assets/logo_dark.svg
TERMS_URL=https://conecta.ai/termos
PRIVACY_URL=https://conecta.ai/privacidade
DISPLAY_MANIFEST=false

# === Integração Z-API (WhatsApp) ===
# Adicione suas credenciais Z-API aqui
ZAPI_INSTANCE_ID=sua-instance-id
ZAPI_TOKEN=seu-token

# === Storage (opcional - S3/CloudFlare R2) ===
ACTIVE_STORAGE_SERVICE=local
# Para S3/R2, descomentar:
# ACTIVE_STORAGE_SERVICE=amazon
# S3_BUCKET_NAME=chatwoot-conectai
# AWS_ACCESS_KEY_ID=sua-key
# AWS_SECRET_ACCESS_KEY=sua-secret
# AWS_REGION=us-east-1
```

### 4. Gerar SECRET_KEY_BASE

No terminal do Coolify ou localmente:

```bash
openssl rand -hex 64
```

Copie o resultado e cole em `SECRET_KEY_BASE`.

### 5. Configurar Domínio

1. No Coolify, vá em **Domains**
2. Adicione: `atendimento.conecta.ai`
3. Coolify configurará SSL automaticamente via Let's Encrypt

### 6. Deploy

1. Clique em **Deploy**
2. Aguarde o build (primeira vez: ~5-10 min)
3. Monitore logs em **Logs** tab

### 7. Rodar Migrações (Primeira Vez)

Após primeiro deploy bem-sucedido:

1. Vá em **Terminal** do serviço `rails`
2. Execute:

```bash
bundle exec rails db:chatwoot_prepare
```

---

## 🔍 Como Saber se Está Rodando em Docker

### No Coolify (servidor remoto)

```bash
# Via Coolify Terminal ou SSH no servidor
docker ps | grep chatwoot
```

Você verá algo como:
```
chatwoot-rails-1     running
chatwoot-sidekiq-1   running
chatwoot-postgres-1  running
chatwoot-redis-1     running
```

### No Mac (desenvolvimento local)

```bash
# Verificar se Docker Desktop está rodando
docker ps

# Se retornar lista ou erro "Cannot connect", Docker não está ativo
# Abrir Docker Desktop: open -a Docker
```

---

## 📊 Verificação Pós-Deploy

### Checar Status

No Coolify:
1. **Deployments** → verificar status verde
2. **Logs** → sem erros críticos

### Testar Aplicação

```bash
# Health check
curl https://atendimento.conecta.ai/health

# Deve retornar: {"status":"ok"}
```

### Acessar Interface

1. Abra: `https://atendimento.conecta.ai`
2. Crie primeira conta (admin)
3. Verifique se favicons Conecta estão aparecendo

---

## 🔧 Troubleshooting

### Assets não carregam

No terminal do Coolify (serviço `rails`):

```bash
bundle exec rails assets:precompile
# Reiniciar serviço após
```

### Migrações pendentes

```bash
bundle exec rails db:migrate
```

### Ver logs em tempo real

No Coolify:
- **Logs** tab → ativar **Follow**

Ou via SSH:

```bash
docker-compose -f docker-compose.coolify.yaml logs -f rails
docker-compose -f docker-compose.coolify.yaml logs -f sidekiq
```

### Branding não aplicado

Verificar variáveis:

```bash
# No terminal do container rails
env | grep BRAND
env | grep INSTALLATION_NAME
```

Reaplicar:

```bash
bundle exec rails branding:update
```

---

## 🔄 Atualizações

### Via Coolify (Automático)

1. Faça push no GitHub: `git push origin main`
2. No Coolify: **Deploy** → pull automático + rebuild

### Forçar Rebuild

Se algo não atualizar:
1. **Settings** → **Force Rebuild**
2. Ou via webhook (configurar no GitHub)

---

## 💾 Backup

### Postgres

No Coolify Terminal (serviço `postgres`):

```bash
pg_dump -U postgres chatwoot_production > /backups/chatwoot-$(date +%Y%m%d).sql
```

Configure volume persistente em `docker-compose.coolify.yaml`:

```yaml
volumes:
  - ./backups:/backups
```

### Storage (Anexos)

Volume `storage_data` é persistente por padrão no Coolify.

Para backup externo, configure S3/R2 (veja variáveis acima).

---

## 🌐 Múltiplos Ambientes

### Staging

1. Crie nova aplicação no Coolify
2. Branch: `develop` (ou `staging`)
3. Domínio: `staging.atendimento.conecta.ai`
4. Variáveis: copiar de produção, ajustar `FRONTEND_URL`

### Produção

- Branch: `main`
- Domínio: `atendimento.conecta.ai`

---

## 📚 Arquivos Importantes

- `docker-compose.coolify.yaml` - Configuração para Coolify
- `DEPLOY_CONECTA_AI.md` - Guia geral de deploy
- `CUSTOM_BRANDING.md` - Customização de marca
- `.env.example` - Exemplo de variáveis

---

## ✅ Checklist de Deploy

- [ ] Repositório `conectai/chatwoot` acessível
- [ ] Variáveis de ambiente configuradas no Coolify
- [ ] `SECRET_KEY_BASE` gerado (64 chars hex)
- [ ] Senhas `POSTGRES_PASSWORD` e `REDIS_PASSWORD` fortes
- [ ] SMTP configurado (Gmail App Password ou outro)
- [ ] Domínio apontando para servidor Coolify
- [ ] Primeiro deploy executado
- [ ] Migrações rodadas: `rails db:chatwoot_prepare`
- [ ] Conta admin criada
- [ ] Favicons Conecta visíveis
- [ ] Health check retornando OK
- [ ] Branding Conecta aplicado

---

## 🆘 Suporte

- **Documentação Coolify**: https://coolify.io/docs
- **Chatwoot Docs**: https://www.chatwoot.com/docs
- **Conecta Changelog**: https://github.com/conectai/chatwoot/releases
