// fnDataSAP
// Converte datas exportadas do SAP (texto) em valores do tipo date.
//
// Formatos aceitos:
//   "31.12.2026"  (dd.MM.yyyy, padrão de exportação em pt-BR)
//   "31/12/2026"  (dd/MM/yyyy)
//   "20261231"    (yyyyMMdd, padrão de tabelas e de alguns relatórios)
//   valores que já chegam como date ou datetime
//
// Retorna null para vazios e para a "data zero" do SAP ("00.00.0000" / "00000000").
//
// Uso:
//   Table.TransformColumns(Fonte, {{"Data_Inicio", fnDataSAP, type nullable date}})

(valor as any) as nullable date =>
let
    // PONTO CRÍTICO: tratar primeiro os tipos que já vêm prontos,
    // senão Text.From devolve um texto dependente da cultura da máquina
    resultado =
        if valor = null then null
        else if valor is date then valor
        else if valor is datetime then Date.From(valor)
        else
            let
                // Normaliza separador "/" para "." para usar um único formato
                texto = Text.Replace(Text.Trim(Text.From(valor)), "/", "."),

                // "Data zero" do SAP significa campo não preenchido
                vazio = texto = "" or texto = "00.00.0000" or texto = "00000000",

                // yyyyMMdd: 8 dígitos sem separador
                compacto = Text.Length(texto) = 8 and Text.Select(texto, {"0".."9"}) = texto,

                data =
                    if vazio then null
                    else if compacto then
                        #date(
                            Number.From(Text.Start(texto, 4)),
                            Number.From(Text.Middle(texto, 4, 2)),
                            Number.From(Text.End(texto, 2))
                        )
                    // ATENÇÃO: o parâmetro Format exige Power Query recente.
                    // Em versões antigas do Excel, troque por
                    // Date.FromText(texto, "pt-BR") com o texto no formato dd/MM/yyyy.
                    else Date.FromText(texto, [Format = "dd.MM.yyyy", Culture = "pt-BR"])
            in
                data
in
    resultado
