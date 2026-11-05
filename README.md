# powerquery-patterns

Funções reutilizáveis em **Power Query (M)** para tratar dados exportados de ERP (SAP) antes de cruzar bases e montar indicadores.

> Todos os dados deste repositório são **fictícios**. As funções são recriações independentes, feitas para estudo e demonstração.

## O problema

Quem trabalha com extrações do SAP no Excel ou no Power BI costuma enfrentar sempre os mesmos problemas:

- datas em texto (`31.12.2026`, `20261231`) e a "data zero" `00.00.0000`
- números com sinal negativo no final (`1.234,56-`)
- códigos com zeros à esquerda que impedem o merge entre bases
- tabelas de histórico em que só interessa a linha mais recente

Este repositório reúne funções pequenas e comentadas para resolver cada um desses pontos.

## Funções

| Função | O que faz | Exemplo |
|---|---|---|
| [`fnDataSAP`](funcoes/fnDataSAP.pq) | Texto de data SAP para `date` | `"31.12.2026"` → `31/12/2026` |
| [`fnNumeroSAP`](funcoes/fnNumeroSAP.pq) | Texto numérico pt-BR para `number`, com sinal no final | `"1.234,56-"` → `-1234,56` |
| [`fnLimparCodigo`](funcoes/fnLimparCodigo.pq) | Remove zeros à esquerda de códigos numéricos | `"000000000000012345"` → `"12345"` |
| [`fnUltimoRegistro`](funcoes/fnUltimoRegistro.pq) | Mantém a linha mais recente por chave | histórico de status → status atual |

## Exemplo completo

A pasta [`exemplos`](exemplos/) tem uma base fictícia de contratos e uma consulta que:

1. padroniza as chaves (contrato, fornecedor, material)
2. converte datas e valores
3. pega o status atual de cada contrato
4. calcula os dias até o vencimento e classifica em faixas para dashboard

### Antes e depois

Entrada, como sai da extração (dois contratos, com histórico de status):

| Contrato | Fornecedor | Material | Data_Fim | Valor_Total | Status_Data | Status |
|---|---|---|---|---|---|---|
| 4600000101 | 0000100045 | 000000000000012345 | 31.01.2027 | 150.000,00 | 20260201 | Ativo |
| 4600000101 | 0000100045 | 000000000000012345 | 31.01.2027 | 150.000,00 | 20260615 | Em revisão |
| 4600000103 | 0000100045 | A-0012 | 31.12.2026 | 45.000,00 | 20260101 | Ativo |
| 4600000103 | 0000100045 | A-0012 | 31.12.2026 | 45.000,00 | 20261020 | Encerramento previsto |

Saída da consulta (uma linha por contrato, com tipos corretos):

| Contrato | Fornecedor | Material | Data_Fim | Valor_Total | Status |
|---|---|---|---|---|---|
| 4600000101 | 100045 | 12345 | 31/01/2027 | 150000 | Em revisão |
| 4600000103 | 100045 | A-0012 | 31/12/2026 | 45000 | Encerramento previsto |

O que mudou: os zeros à esquerda saíram dos códigos numéricos (o código alfanumérico `A-0012` foi preservado), datas e valores viraram `date` e `number`, e o histórico ficou reduzido ao status mais recente de cada contrato.

## Como usar

1. No Excel ou Power BI: **Obter Dados > Consulta Nula**
2. Abra o **Editor Avançado** e cole o conteúdo de um arquivo `.pq`
3. Renomeie a consulta com o nome da função (ex: `fnDataSAP`)
4. Aplique em uma coluna:

```m
Table.TransformColumns(Fonte, {{"Data_Inicio", fnDataSAP, type nullable date}})
```

## Boas práticas aplicadas

- Funções tratam `null` e valores já tipados, sem conversão dupla
- Chaves sempre como texto, para não perder códigos longos
- Tipos de coluna restaurados após agrupamentos
- Pontos críticos comentados no próprio código

## Licença

MIT
