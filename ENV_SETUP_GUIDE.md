# 🔧 Configuração de Variáveis de Ambiente - ConectAi Automações

## 📋 Resumo

As variáveis de ambiente definem como o Chatwoot funciona. Existem:
- **Padrões** (valores default que funcionam para testes)
- **Obrigatórias** (você DEVE configurar)
- **Opcionais** (melhoram a experiência, mas não são essenciais)

---

## ✅ Variáveis OBRIGATÓRIAS

Você **DEVE** configurar estas:

### 1. **SECRET_KEY_BASE** (Segurança)
Gera chave criptográfica da aplicação.

```bash
# Gere uma nova chave:
openssl rand -hex 64

# Resultado será algo como:
# a1b2c3d4e5f6... (128 caracteres)

# Cole em SECRET_KEY_BASE
```

### 2. **FRONTEND_URL** (Domínio)
URL de acesso da sua aplicação.

```bash
FRONTEND_URL=https://seu-dominio.com.br
```

### 3. **Senhas do Banco de Dados & Redis**
```bash
POSTGRES_PASSWORD=SenhaSegura123!
REDIS_PASSWORD=Redis123!
```

---

## 📊 Variáveis RECOMENDADAS

São padrões bons, mas pode customizar:

| Variável | Padrão | O que faz |
|----------|--------|----------|
| `POSTGRES_DATABASE` | `chatwoot_production` | Nome do banco |
| `INSTALLATION_NAME` | `ConectAi Automações` | Nome da empresa (aparece na UI) |
| `BRAND_NAME` | `ConectAi` | Nome curto da marca |
| `DEFAULT_LOCALE` | `pt_BR` | Idioma (português) |
| `FORCE_SSL` | `true` | Forçar HTTPS em produção |
| `RAILS_ENV` | `production` | Ambiente (production/development) |

---

## 📧 Variáveis OPCIONAIS

### Email (SMTP)
Se quiser notificações por email:

```bash
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-app-google  # Não é a senha comum!
SMTP_AUTHENTICATION=plain
MAILER_SENDER_EMAIL=noreply@conectai.com.br
```

**Como gerar senha de app no Gmail:**
1. Ative 2FA na sua conta Google
2. Vá em: https://myaccount.google.com/apppasswords
3. Copie a senha gerada e use em `SMTP_PASSWORD`

### Storage (S3 / CloudFlare R2)
Por padrão usa disco local. Se quiser cloud:

```bash
ACTIVE_STORAGE_SERVICE=amazon
AWS_ACCESS_KEY_ID=sua-key
AWS_SECRET_ACCESS_KEY=sua-secret
S3_BUCKET_NAME=chatwoot-conectai
AWS_REGION=us-east-1
```

---

## 🚀 Como Usar no Coolify

### Passo 1: Copie o template
```bash
cp .env.example.conectai .env.coolify
```

### Passo 2: Configure os valores
Edite os valores obrigatórios:
```bash
# Gere nova chave
SECRET_KEY_BASE=$(openssl rand -hex 64)
echo $SECRET_KEY_BASE

# Configure seu domínio
FRONTEND_URL=https://atendimento.suaempresa.com.br

# Configure senhas seguras
POSTGRES_PASSWORD=SuaSenhaSegura123!
REDIS_PASSWORD=OutraSenhaSegura456!
```

### Passo 3: No dashboard do Coolify
1. **Add Resource** → **Docker Compose**
2. Escolha `docker-compose.coolify.prod.yaml`
3. Vá em **Environment Variables**
4. Clique **+ Add**
5. Cole cada variável do seu `.env.coolify`

Ou, se o Coolify suporta, importe o arquivo `.env` diretamente.

---

## 🔍 Variáveis por Caso de Uso

### Caso 1: Teste Local (Docker Local)
**Mínimo necessário:**
```bash
SECRET_KEY_BASE=<qualquer-coisa-segura>
POSTGRES_PASSWORD=postgres123
REDIS_PASSWORD=redis123
FRONTEND_URL=http://localhost:3000
FORCE_SSL=false
```

### Caso 2: Produção no Coolify
**Configure todas estas:**
```bash
SECRET_KEY_BASE=<openssl-rand-hex-64>
FRONTEND_URL=https://seu-dominio.com.br
POSTGRES_PASSWORD=<gere-senha-segura>
REDIS_PASSWORD=<gere-senha-segura>
INSTALLATION_NAME=ConectAi Automações
BRAND_NAME=ConectAi
FORCE_SSL=true
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=<app-password-do-google>
MAILER_SENDER_EMAIL=noreply@seu-dominio.com.br
```

### Caso 3: Com WhatsApp (Z-API ou similar)
**Adicione:**
```bash
BAILEYS_PROVIDER_DEFAULT_CLIENT_NAME=seu-cliente
BAILEYS_PROVIDER_DEFAULT_URL=https://seu-provider.com
BAILEYS_PROVIDER_DEFAULT_API_KEY=sua-api-key
```

---

## ⚠️ Segurança: Boas Práticas

✅ **FAÇA:**
- Gere `SECRET_KEY_BASE` com `openssl rand -hex 64`
- Use senhas com 12+ caracteres e símbolos
- Nunca commit `.env` no git (use `.env.example`)
- Rotacione senhas periodicamente
- Use SSL/HTTPS em produção (`FORCE_SSL=true`)

❌ **NÃO FAÇA:**
- Não use senhas simples como `123456`
- Não commite `.env` no repositório
- Não exponha `SECRET_KEY_BASE` publicamente
- Não use mesmo `SECRET_KEY_BASE` em múltiplas instâncias
- Não deixe `FORCE_SSL=false` em produção

---

## 🧪 Testar Configuração

Depois de configurar, verifique:

```bash
# 1. Verificar conectividade do banco
docker-compose exec rails psql -h postgres -U postgres -d chatwoot_production -c "SELECT 1;"

# 2. Verificar Redis
docker-compose exec rails redis-cli -h redis ping

# 3. Ver logs
docker-compose logs -f rails

# 4. Acessar a aplicação
# http://localhost:3000 (local)
# https://seu-dominio.com.br (Coolify)
```

---

## 📝 Referência Rápida

Arquivo template: `.env.example.conectai`

Para produção, copie e customize:
```bash
# Local
cp .env.example.conectai .env

# Coolify (adicione via dashboard)
```

Dúvidas? Veja `QUICKSTART_COOLIFY.md` para passo-a-passo completo.
