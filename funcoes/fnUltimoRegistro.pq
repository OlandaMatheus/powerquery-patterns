// fnUltimoRegistro
// Mantém apenas a linha mais recente de cada chave.
//
// Caso típico: uma base de histórico (status de contrato, aprovações, alterações de preço)
// em que você precisa da "foto atual" de cada item.
//
// Parâmetros:
//   tabela      tabela de origem
//   chaves      lista de colunas que identificam o item, ex: {"Contrato"} ou {"Contrato", "Item"}
//   colunaData  coluna usada para decidir qual linha é a mais recente
//
// Uso:
//   fnUltimoRegistro(Historico, {"Contrato"}, "Status_Data")

(tabela as table, chaves as list, colunaData as text) as table =>
let
    colunas = Table.ColumnNames(tabela),

    // Table.Max devolve o registro (linha inteira) com o maior valor da coluna de data
    // ATENÇÃO: em caso de empate na data, mantém apenas uma linha (a primeira encontrada).
    // Se empates forem possíveis, inclua um critério de desempate (ex: hora ou sequencial).
    agrupado = Table.Group(
        tabela,
        chaves,
        {{"_ultima", each Table.Max(_, colunaData), type record}}
    ),

    // Remove as chaves do agrupamento, pois elas já estão dentro do registro
    soRegistros = Table.SelectColumns(agrupado, {"_ultima"}),
    expandido = Table.ExpandRecordColumn(soRegistros, "_ultima", colunas),

    // PONTO CRÍTICO: o expand perde os tipos das colunas; aqui eles são restaurados
    resultado = Value.ReplaceType(expandido, Value.Type(tabela))
in
    resultado
