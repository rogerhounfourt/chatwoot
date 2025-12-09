# Setup Git Push - Conecta Chatwoot

## Problema: Permissão Negada ao dar Push

### Solução 1: Configurar SSH (Recomendado)

```bash
# 1. Verificar se já tem chave SSH
ls -la ~/.ssh/id_*.pub

# 2. Se não tiver, gerar nova chave
ssh-keygen -t ed25519 -C "seu-email@conecta.ai"
# Pressione Enter para aceitar local padrão
# Digite senha (opcional, mas recomendado)

# 3. Copiar chave pública
cat ~/.ssh/id_ed25519.pub
# Copie a saída completa (começa com "ssh-ed25519...")

# 4. Adicionar no GitHub
# - Vá em: https://github.com/settings/keys
# - Clique "New SSH Key"
# - Cole a chave pública
# - Salve

# 5. Atualizar remote para usar SSH
cd /Users/rogerhounfourt/Documents/GitHub/chatwoot
git remote set-url origin git@github.com:conectai/chatwoot.git

# 6. Testar conexão
ssh -T git@github.com
# Deve retornar: "Hi username! You've successfully authenticated..."

# 7. Conecta push
git push origin main
```

### Solução 2: Personal Access Token (Alternativa)

```bash
# 1. Gerar token no GitHub
# - Vá em: https://github.com/settings/tokens
# - Generate new token (classic)
# - Scopes: repo (full control)
# - Copie o token gerado (guarde com segurança!)

# 2. Usar token no push
cd /Users/rogerhounfourt/Documents/GitHub/chatwoot
git push https://SEU_TOKEN@github.com/conectai/chatwoot.git main

# 3. Ou configurar credenciais permanentemente
git config credential.helper store
git push origin main
# Digite username: seu-usuario-github
# Digite password: SEU_TOKEN (não a senha normal!)
```

### Solução 3: Fork Pessoal (Se não tiver acesso direto)

Se você não for colaborador do repositório `conectai/chatwoot`:

```bash
# 1. Conecta fork no GitHub
# - Vá em: https://github.com/conectai/chatwoot
# - Clique "Fork" → criar no seu usuário

# 2. Adicionar seu fork como remote
cd /Users/rogerhounfourt/Documents/GitHub/chatwoot
git remote add meu-fork git@github.com:SEU-USUARIO/chatwoot.git

# 3. Push para seu fork
git push meu-fork main

# 4. Criar Pull Request
# - Vá em: https://github.com/SEU-USUARIO/chatwoot
# - Clique "Contribute" → "Open Pull Request"
# - Base: conectai/chatwoot (main)
# - Compare: SEU-USUARIO/chatwoot (main)
```

---

## Status Atual dos Commits Locais

Você tem **2 commits locais** prontos para push:

```
0f089fb90 docs: add Coolify deployment guide
5c1bc2caa feat: add custom Conecta branding and deployment tools
```

**Arquivos incluídos:**
- ✅ `DEPLOY_CONECTA_AI.md` - Guia geral de deploy Docker
- ✅ `DEPLOY_COOLIFY.md` - Guia específico Coolify
- ✅ `deployment/setup_favicons.sh` - Script gerador de favicons
- ✅ `cspell.json` - Dicionário PT-BR
- ✅ 30+ favicons customizados Conecta
- ✅ `favicon.svg`, `favicon.ico`, `site.webmanifest`

---

## Depois de Configurar Acesso

```bash
# Push dos commits
cd /Users/rogerhounfourt/Documents/GitHub/chatwoot
git push origin main

# Verificar no GitHub
# https://github.com/conectai/chatwoot/commits/main
```

---

## Deploy no Coolify Após Push

1. **No Coolify**: Criar nova aplicação
2. **Git Repository**: `https://github.com/conectai/chatwoot`
3. **Branch**: `main`
4. **Compose File**: `docker-compose.coolify.yaml`
5. **Environment**: Configurar variáveis (ver `DEPLOY_COOLIFY.md`)
6. **Deploy** → Aguardar build
7. **Terminal (rails)**: `bundle exec rails db:chatwoot_prepare`
8. **Acessar**: `https://seu-dominio.com`

---

## Qual Solução Escolher?

### Use SSH se:
- ✅ Você é colaborador do repositório conectai
- ✅ Prefere não digitar senha toda vez
- ✅ Quer máxima segurança

### Use Token se:
- ✅ Precisa de acesso temporário
- ✅ Usa CI/CD ou automações
- ✅ SSH está bloqueado no firewall

### Use Fork se:
- ✅ Você não é colaborador direto
- ✅ Quer contribuir via Pull Request
- ✅ Está testando mudanças antes de merge

---

## Verificar Permissões

```bash
# Ver quem é o dono do repositório
cd /Users/rogerhounfourt/Documents/GitHub/chatwoot
git remote -v

# Ver seu usuário GitHub configurado
git config user.name
git config user.email

# Verificar se você é colaborador
# Vá em: https://github.com/conectai/chatwoot/settings/access
```
