---
name: azure-task-plan
description: >-
  Planeja a execução de work items do Azure DevOps: busca tarefa, analisa
  requisitos, mapeia código e produz plano de implementação. Use quando o
  usuário pedir para planejar, analisar ou entender uma tarefa/story/task do
  Azure, colar URL do Azure DevOps (workitem=, _workitems/edit/), ou mencionar
  WI/task ID antes de implementar.
---

# Planejar tarefa Azure DevOps

Produz um **plano de execução** antes de escrever código.
Não implemente nesta skill - apenas pesquise, analise e planeje.

## Pré-requisitos

- `AZURE_DEVOPS_EXT_PAT` exportado no ambiente (nunca colar PAT no chat nem commitar).
- `az` com extensão `azure-devops` (fallback: REST via curl no script).
- Defaults locais (se existirem): org `https://bwkm.visualstudio.com`, project `Gow Sign`.

## Passo 1: Identificar o work item

Extrair ID de:
- URL com `workitem=12345` ou `/_workitems/edit/12345`
- Menção direta: "tarefa 28884", "WI 28945"

Se o usuário passou uma **User Story** com filhos, planejar a story inteira mas destacar qual **Task** filha executar primeiro (preferir `Active` ou a que o usuário indicou).

## Passo 2: Buscar dados do Azure

```bash
~/.cursor/skills/azure-task-plan/scripts/fetch-workitem.sh WORK_ITEM_ID | \
  python3 ~/.cursor/skills/azure-task-plan/scripts/parse-workitem.py
```

Para cada **child ID** listado, buscar título, state e AC:

```bash
for id in CHILD_IDS; do
  ~/.cursor/skills/azure-task-plan/scripts/fetch-workitem.sh "$id" none | \
    python3 -c "import sys,json; d=json.load(sys.stdin); f=d['fields']; print(d['id'], f.get('System.State'), f.get('System.Title'))"
done
```

Se `AZURE_DEVOPS_EXT_PAT` não estiver setado, pedir ao usuário para exportar e tentar de novo.

## Passo 3: Entender o codebase

Antes de planejar arquivos, descobrir qual repo/serviço a tarefa afeta.

**Gow Sign** (workspace típico `/home/yago/w/gowsign`):

| Serviço | Pasta | Branch GOW | Branch UOWN |
|---------|-------|------------|-------------|
| App (Next.js) | `next/` | `develop` | `Release/2.1.1-UWON` |
| PDF Generator | `pdf-service/` | `Release/r3.1.0` | `Release/2.1.1-UWON` |
| Document Management (Strapi) | `strapi/` | `develop` | `Release/2.1.1-UWON` |

Ações:
1. Confirmar em qual pasta/repo trabalhar (tags, título, paths mencionados na WI).
2. `grep` por termos da descrição, componentes, endpoints, feature flags.
3. Ler arquivos existentes relacionados - não assumir estrutura.
4. Se a WI referencia PR/branch, buscar no git.

## Passo 4: Extrair requisitos

Listar **cada requisito** da WI como item numerado e independente.
Fontes (nesta ordem):
1. Acceptance Criteria
2. Descrição / Repro Steps
3. Título e subtarefas filhas (se User Story)

Cada requisito deve ser:
- **Atômico** - uma coisa verificável por vez
- **Rastreável** - ter ID interno `R1`, `R2`, ...
- **Sem ambiguidade** - se interpretação for incerta, marcar `[?]` e listar pergunta

## Passo 5: Produzir o plano

Entregar neste formato:

```markdown
## Work Item #ID - [Título](URL)

### Resumo
[1-2 frases do objetivo]

### Escopo
- In scope: ...
- Out of scope: ...

### Repositório e branch
- Repo: ...
- Branch base sugerida: ...
- Branch de feature sugerida: `fix/ID-descricao-curta` ou `feat/ID-descricao-curta`

### Estado atual
- O que já existe no código
- Gaps vs acceptance criteria

### Requisitos e mapeamento previsto

| ID | Requisito (texto da WI) | Onde implementar (previsto) | Status |
|----|-------------------------|------------------------------|--------|
| R1 | ... | `path/to/file.tsx` - função X | Pendente |
| R2 | ... | `path/to/other.ts` | Pendente |

Status possíveis no plano: `Pendente`, `Parcial`, `Já existe`.

### Plano de implementação
1. [ ] Passo concreto - atende R1, R2 (arquivo/função)
2. [ ] ...

### Testes
- [ ] Como validar manualmente (por requisito: R1 → ..., R2 → ...)
- [ ] Testes automatizados existentes a rodar

### Riscos e dependências
- ...

### Próximo passo
Pedir confirmação do usuário antes de executar.
Sugerir: "Use a skill azure-task-execute para implementar."
```

A tabela de requisitos é **obrigatória** - é a base para confirmação na execução.

## Regras

- **Não modificar código** nesta skill.
- **Não alterar dados em banco** salvo instrução explícita do usuário.
- **Não commitar** sem pedido explícito.
- Se requisitos forem ambíguos, listar perguntas objetivas no plano.
- Preferir plano enxuto e acionável - evitar repetir a WI inteira.
- Cada requisito da WI deve aparecer na tabela - nenhum AC ou item da descrição pode ficar de fora.
