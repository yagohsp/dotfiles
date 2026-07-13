---
name: azure-task-execute
description: >-
  Executa work items do Azure DevOps: implementa código, testa e valida contra
  acceptance criteria com confirmação por requisito. Use quando o usuário pedir
  para executar, implementar ou codar uma tarefa Azure já planejada, ou após
  usar azure-task-plan com confirmação para começar a implementação.
---

# Executar tarefa Azure DevOps

Implementa a tarefa com base no plano (da skill `azure-task-plan` ou contexto da conversa).

## Pré-requisitos

- Plano claro OU work item já analisado na conversa.
- `AZURE_DEVOPS_EXT_PAT` disponível se precisar reconsultar a WI.
- Repo correto identificado (ver tabela abaixo).
- Tabela de requisitos `R1`, `R2`, ... (do plano ou extraída agora da WI).

## Passo 1: Confirmar escopo e requisitos

Se não houver plano na conversa, rodar primeiro a skill **azure-task-plan** ou buscar a WI:

```bash
~/.cursor/skills/azure-task-plan/scripts/fetch-workitem.sh WORK_ITEM_ID | \
  python3 ~/.cursor/skills/azure-task-plan/scripts/parse-workitem.py
```

Extrair requisitos atômicos (AC + descrição) e numerar como `R1`, `R2`, ...
Confirmar com o usuário se houver ambiguidade (branch, ambiente GOW vs UOWN, escopo).

## Passo 2: Preparar git

**Gow Sign** - escolher repo e branch:

| Serviço | Pasta | Branch GOW | Branch UOWN |
|---------|-------|------------|-------------|
| App | `next/` | `develop` | `Release/2.1.1-UWON` |
| PDF | `pdf-service/` | `Release/r3.1.0` | `Release/2.1.1-UWON` |
| Strapi | `strapi/` | `develop` | `Release/2.1.1-UWON` |

Workflow:
1. `git fetch origin`
2. Checkout da branch base correta
3. Criar branch: `fix/ID-descricao` ou `feat/ID-descricao`
4. Garantir working tree limpa antes de começar

## Passo 3: Implementar

### Regra central: rastreabilidade por requisito

Manter mentalmente (ou anotar) quais requisitos `R#` cada alteração atende.
Ao **terminar** todas as alterações de um arquivo, reportar ao usuário antes de passar ao próximo.

### Fluxo por arquivo

1. Abrir/editar o arquivo até concluir tudo que nele for necessário.
2. **Ao finalizar o arquivo** (não a cada linha ou hunk), enviar ao usuário:

```markdown
#### `path/to/file.tsx`

**Requisitos atendidos:** R1, R3

**O que foi alterado:**
- [bullet objetivo descrevendo a mudança]
- [outro bullet se necessário]

**Comentários adicionados:** (omitir esta linha se nenhum comentário foi necessário)
- `linha/função`: por quê (só se não for óbvio)
```

3. Só então passar para o próximo arquivo.

**Não** interromper a implementação para explicar cada edit individual dentro do mesmo arquivo.
**Sim** explicar uma vez, completa, quando o arquivo estiver pronto.

### Comentários no código

- **Padrão: sem comentários** - o código deve ser autoexplicativo.
- **Adicionar comentário somente quando** a alteração não for óbvia: workaround, regra de negócio implícita, constraint não evidente pelo código, integração externa com comportamento surpresa.
- **Nunca** comentar o óbvio (`// increment counter`, `// return result`).
- Preferir nomes claros de variáveis/funções em vez de comentários.

### Demais regras de implementação

- **Escopo mínimo**: só o necessário para cumprir requisitos da WI.
- Seguir convenções do repo (lint, patterns, nomes).
- Feature flags: respeitar flags existentes (`NEXT_PUBLIC_*`, `USE_STRAPI`, etc.).
- Não refatorar código não relacionado.

## Passo 4: Confirmar requisitos

Após implementar e testar, produzir **matriz de confirmação** - obrigatória:

```markdown
### Confirmação de requisitos

| ID | Requisito | Status | Onde na implementação | Como verificado |
|----|-----------|--------|----------------------|-----------------|
| R1 | texto do requisito | Concluído | `path/file.tsx` - `funcaoX`, linhas ~N-M | teste/manual/descrição |
| R2 | ... | Concluído | `path/other.ts` | ... |
| R3 | ... | Parcial | ... | o que falta |
```

Status permitidos: `Concluído`, `Parcial`, `Não aplicável`, `Bloqueado`.

Regras:
- **Todo** `R#` deve aparecer na tabela - nenhum requisito da WI pode ficar sem linha.
- `Concluído` exige apontar **arquivo + símbolo/função/componente** concreto.
- Se `Parcial` ou `Bloqueado`, explicar o que falta ou o impedimento.

## Passo 5: Testar

1. Reproduzir o bug/cenário da WI quando aplicável.
2. Rodar linter/tests do repo afetado.
3. Validar **cada requisito** `R#` - cruzar com a matriz de confirmação.
4. Para APIs: testar endpoint local ou ambiente indicado pelo usuário.
5. **Não gerenciar dados diretamente no banco** salvo instrução explícita.

Ambientes comuns (referência - confirmar com usuário):
- GOW dev: `gowsign-app-dev-filas.azurewebsites.net`
- UOWN dev: `gowsign-app-dev-uown.azurewebsites.net`

## Passo 6: Entregar

Reportar ao usuário:

```markdown
## WI #ID - Execução concluída

### Confirmação de requisitos
[tabela completa R1..Rn]

### Resumo das alterações por arquivo
- `path/a.tsx`: ...
- `path/b.ts`: ...

### Testes rodados
- ...

### Pendências
- (se houver)

### Próximos passos sugeridos
- Commit / PR (só se o usuário pedir)
- Atualizar state da WI no Azure (só se pedido)
```

A seção "Confirmação de requisitos" é **obrigatória** no fechamento.

## Regras

- **Não commitar** sem pedido explícito do usuário.
- **Não push/PR** sem pedido explícito.
- **Nunca** hardcodar secrets, PAT ou credenciais.
- Se bloqueado (auth Azure, ambiente fora do ar, requisito unclear), reportar e parar.
- Se encontrar bug fora do escopo mas óbvio e pequeno, mencionar - corrigir só se não desviar do escopo.
- Explicações por arquivo vão **no chat**, não em comentários no código (salvo quando a lógica não for óbvia).

## Atualizar work item (opcional)

Só se o usuário pedir:

```bash
az boards work-item update --id WORK_ITEM_ID --state "Active" --discussion "Implementado: ..."
```

States comuns: `New`, `Active`, `Resolved`, `Closed` - verificar workflow do projeto.
