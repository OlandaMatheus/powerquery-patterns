// fnNumeroSAP
// Converte números exportados do SAP (texto em formato brasileiro) em number.
//
// Problemas que resolve:
//   "1.234,56"   separador de milhar e vírgula decimal
//   "1.234,56-"  sinal negativo no FINAL, padrão de vários relatórios SAP
//   "  15,00 "   espaços sobrando
//   ""           campo vazio vira null (e não zero)
//
// Uso:
//   Table.TransformColumns(Fonte, {{"Valor_Total", fnNumeroSAP, type nullable number}})

(valor as any) as nullable number =>
let
    resultado =
        if valor = null then null
        // Se já é número, não mexe (evita conversão dupla)
        else if valor is number then valor
        else
            let
                texto = Text.Trim(Text.From(valor)),

                // PONTO CRÍTICO: o SAP coloca o "-" depois do número
                negativo = Text.EndsWith(texto, "-"),
                semSinal = if negativo then Text.Start(texto, Text.Length(texto) - 1) else texto,

                // Culture "pt-BR" interpreta "." como milhar e "," como decimal
                // try/otherwise evita quebrar a carga inteira por uma célula suja;
                // valores que caírem em null merecem conferência na origem
                numero =
                    if semSinal = "" then null
                    else try Number.FromText(semSinal, "pt-BR") otherwise null,

                comSinal = if negativo and numero <> null then -numero else numero
            in
                comSinal
in
    resultado
