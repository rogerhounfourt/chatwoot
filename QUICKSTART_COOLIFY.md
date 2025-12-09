# Quick Start: Deploy ConectAi no Coolify

Teste em produção em 5 passos.

---

## 1️⃣ Prepare o Repositório

```bash
# Faça push da branch conecta-customizations
git push conectai conecta-customizations

# Ou use a main branch se ja fez merge
git push origin main
```

---

## 2️⃣ No Coolify Dashboard

### Criar Aplicação

1. **Projects** → **New Project** → Nome: `ConectAi Automações`
2. **Add Resource** → **Docker Compose**
3. Preencha:
   - **Name**: `chatwoot-conectai`
   - **Repository URL**: `https://github.com/rogerhounfourt/chatwoot.git`
   - **Branch**: `conecta-customizations` (ou `main`)
   - **Docker Compose File**: `docker-compose.coolify.yaml`

---

## 3️⃣ Variáveis de Ambiente (Essenciais)

Cole no Coolify sob **Environment Variables**:

```bash
# Banco de Dados
POSTGRES_PASSWORD=SenhaSegura123!
POSTGRES_DB=chatwoot_prod
POSTGRES_HOST=postgres

# Redis
REDIS_PASSWORD=Redis123!
REDIS_URL=redis://:Redis123!@redis:6379

# Rails
RAILS_ENV=production
NODE_ENV=production
SECRET_KEY_BASE=<GERAR COM: openssl rand -hex 64>
FORCE_SSL=true

# URLs
FRONTEND_URL=https://seu-dominio.com.br
INSTALLATION_NAME=ConectAi Automações
BRAND_NAME=ConectAi Automações

# Email (opcional)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-app
SMTP_AUTHENTICATION=plain
MAILER_SENDER_EMAIL=noreply@seu-dominio.com.br
```

### Gerar SECRET_KEY_BASE

```bash
openssl rand -hex 64
```

Copie e cole em `SECRET_KEY_BASE`.

---

## 4️⃣ Configurar Domínio

1. No Coolify: **Domains** → **Add Domain**
2. Digite: `seu-dominio.com.br`
3. Coolify configurará SSL automaticamente

---

## 5️⃣ Deploy

1. Clique em **Deploy**
2. Aguarde os containers subirem (~5-10 min)
3. Acesse: `https://seu-dominio.com.br`

---

## ✅ Primeira Execução

Na primeira inicialização:

1. **Rails** fará migrations automáticamente
2. **Sidekiq** iniciará o processamento de jobs
3. Você verá a tela de boas-vindas

### Criar Admin

```bash
# Via terminal do Coolify
docker-compose -f docker-compose.coolify.yaml exec rails \
  bundle exec rails c

# No console Rails:
SuperAdmin.create!(
  email: 'admin@seu-dominio.com.br',
  password: 'SenhaSegura123!',
  password_confirmation: 'SenhaSegura123!'
)

# Ou via Rake task:
docker-compose exec rails bundle exec rake db:seed
```

---

## 🔧 Verificar Status

```bash
# Logs da aplicação
docker-compose -f docker-compose.coolify.yaml logs -f rails

# Verificar containers
docker-compose -f docker-compose.coolify.yaml ps

# Acessar banco de dados
docker-compose exec postgres psql -U postgres -d chatwoot_prod
```

---

## ⚠️ Troubleshooting

### Migrations falhando?
```bash
docker-compose exec rails bundle exec rake db:migrate
docker-compose exec rails bundle exec rake db:seed
```

### Redis/Postgres conexão recusada?
```bash
# Verificar conectividade
docker-compose exec rails redis-cli -h redis -a Redis123! ping
docker-compose exec rails psql -h postgres -U postgres -d chatwoot_prod
```

### Sidekiq não processa jobs?
```bash
docker-compose restart sidekiq
docker-compose logs sidekiq
```

---

## 📋 Checklist Pós-Deploy

- [ ] Acessar HTTPS sem erros
- [ ] Fazer login com admin
- [ ] Testar criar novo inbox
- [ ] Verificar jobs em background (Sidekiq)
- [ ] Testar webhook/integrações
- [ ] Configurar SMTP para notificações

---

## 🎯 Próximos Passos

1. **Backups**: Configure backup automático do Postgres
2. **Monitoring**: Ative alerts no Coolify
3. **CDN**: Configure CloudFlare se necessário
4. **SSL**: Verifique renovação de certificados

Para mais detalhes, veja `DEPLOY_COOLIFY.md`.
