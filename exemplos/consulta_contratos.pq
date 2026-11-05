// consulta_contratos
// Exemplo completo usando as quatro funções sobre a base fictícia contratos_ficticios.csv
//
// Pré-requisitos no arquivo Excel / Power BI:
//   1. Criar as consultas fnDataSAP, fnNumeroSAP, fnLimparCodigo e fnUltimoRegistro
//      (Nova Consulta > Consulta Nula > Editor Avançado > colar o conteúdo do .pq)
//   2. Criar o parâmetro CaminhoArquivo com o caminho do CSV na sua máquina

let
    // Leitura do CSV (separador ";" e codificação UTF-8)
    Fonte = Csv.Document(
        File.Contents(CaminhoArquivo),
        [Delimiter = ";", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    Cabecalhos = Table.PromoteHeaders(Fonte, [PromoteAllScalars = true]),

    // Padronização de chaves: permite cruzar com outras bases depois
    Chaves = Table.TransformColumns(Cabecalhos, {
        {"Contrato", fnLimparCodigo, type nullable text},
        {"Fornecedor", fnLimparCodigo, type nullable text},
        {"Material", fnLimparCodigo, type nullable text}
    }),

    // Datas e valores no formato SAP
    Tipos = Table.TransformColumns(Chaves, {
        {"Data_Inicio", fnDataSAP, type nullable date},
        {"Data_Fim", fnDataSAP, type nullable date},
        {"Status_Data", fnDataSAP, type nullable date},
        {"Valor_Total", fnNumeroSAP, type nullable number}
    }),

    // Foto atual: último status de cada contrato
    StatusAtual = fnUltimoRegistro(Tipos, {"Contrato"}, "Status_Data"),

    // Indicador simples: dias até o vencimento
    // ATENÇÃO: DateTime.LocalNow() muda a cada atualização; em relatórios
    // com data de corte fixa, substitua por um parâmetro DataReferencia
    Hoje = Date.From(DateTime.LocalNow()),
    DiasVencimento = Table.AddColumn(
        StatusAtual,
        "Dias_para_Vencimento",
        each if [Data_Fim] = null then null else Duration.Days([Data_Fim] - Hoje),
        Int64.Type
    ),

    // Faixa para usar em dashboards
    Faixa = Table.AddColumn(
        DiasVencimento,
        "Faixa_Vencimento",
        each
            let d = [Dias_para_Vencimento] in
            if d = null then "Sem data"
            else if d < 0 then "Vencido"
            else if d <= 30 then "Até 30 dias"
            else if d <= 90 then "31 a 90 dias"
            else "Acima de 90 dias",
        type text
    )
in
    Faixa
