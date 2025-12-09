# 🚀 Guia Rápido - Testar Chatwoot ConectAi Automações Localmente

## ✅ Pré-requisitos
- Docker Desktop rodando (já está! ✓)

## 📝 Passos para Rodar

### 1. Iniciar Chatwoot
```bash
cd /Users/rogerhounfourt/Documents/GitHub/chatwoot
docker-compose -f docker-compose.local.yaml up -d
```

### 2. Aguardar Inicialização (~2-3 minutos)
```bash
# Ver logs em tempo real
docker-compose -f docker-compose.local.yaml logs -f rails

# Aguarde ver: "=> Booting Puma"
# Pressione Ctrl+C para sair dos logs
```

### 3. Preparar Banco de Dados (PRIMEIRA VEZ)
```bash
# Criar banco e rodar migrações
docker-compose -f docker-compose.local.yaml exec rails bundle exec rails db:chatwoot_prepare
```

### 4. Acessar Chatwoot
Abra no navegador: **http://localhost:3000**

### 5. Criar Conta Admin
- Nome: Seu nome
- Email: seu-email@conectai.com.br
- Senha: (escolha uma senha forte)

---

## ⚙️ Comandos Úteis

### Ver Status
```bash
docker-compose -f docker-compose.local.yaml ps
```

### Parar
```bash
docker-compose -f docker-compose.local.yaml down
```

### Reiniciar (após mudanças)
```bash
docker-compose -f docker-compose.local.yaml restart
```

### Ver Logs
```bash
# Todos os serviços
docker-compose -f docker-compose.local.yaml logs -f

# Apenas Rails
docker-compose -f docker-compose.local.yaml logs -f rails

# Apenas Sidekiq (jobs)
docker-compose -f docker-compose.local.yaml logs -f sidekiq
```

### Acessar Console Rails
```bash
docker-compose -f docker-compose.local.yaml exec rails bundle exec rails console
```

### Limpar Tudo (Reset Completo)
```bash
docker-compose -f docker-compose.local.yaml down -v
# Apaga banco de dados e cache!
```

---

## 🎨 Branding Configurado

- **Nome da Instalação**: ConectAi Automações
- **Nome da Marca**: ConectAi Automações
- **Favicons**: Customizados (seus ícones)
- **Locale Padrão**: Português (pt_BR)

---

## 🔧 Troubleshooting

### Erro "port 3000 already in use"
```bash
# Ver o que está usando a porta
lsof -i :3000

# Parar processo (substitua PID)
kill -9 PID
```

### Erro "database does not exist"
```bash
# Criar banco manualmente
docker-compose -f docker-compose.local.yaml exec postgres psql -U postgres -c "CREATE DATABASE chatwoot_local;"

# Rodar migrações
docker-compose -f docker-compose.local.yaml exec rails bundle exec rails db:migrate
```

### Container não inicia
```bash
# Ver erros
docker-compose -f docker-compose.local.yaml logs rails

# Recriar containers
docker-compose -f docker-compose.local.yaml up -d --force-recreate
```

### Permissões de arquivo (Mac)
```bash
# Dar permissão para Docker acessar storage
chmod -R 777 storage/
```

---

## 📊 Arquitetura Local

```
┌─────────────────────┐
│  localhost:3000     │ ← Você acessa aqui
│  (Rails + Puma)     │
└──────────┬──────────┘
           │
           ├─────────┐
           │         │
    ┌──────▼──┐  ┌──▼──────┐
    │ Postgres│  │  Redis  │
    │  :5432  │  │  :6379  │
    └─────────┘  └─────────┘
           │
      ┌────▼────┐
      │ Sidekiq │ ← Jobs background
      │ (Worker)│
      └─────────┘
```

---

## 🎯 Próximos Passos Após Testar

1. ✅ Confirmar que funciona localmente
2. 📤 Fazer commit do `docker-compose.local.yaml`
3. 🚀 Deploy no Coolify (seguir `DEPLOY_COOLIFY.md`)
4. 🌐 Configurar domínio próprio

---

## ⏱️ Tempo Estimado

- **Primeira execução**: ~5 minutos (download imagens + setup)
- **Execuções seguintes**: ~30 segundos (containers já criados)
- **Acesso**: Imediato após "Booting Puma"

---

## 💡 Dica

Deixe rodando em background com `-d` (detached):
```bash
docker-compose -f docker-compose.local.yaml up -d
```

Para desenvolvimento ativo, rode sem `-d` para ver logs:
```bash
docker-compose -f docker-compose.local.yaml up
```
