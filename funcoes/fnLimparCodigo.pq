// fnLimparCodigo
// Padroniza códigos (material, fornecedor, cliente) para permitir cruzamento entre bases.
//
// Problema comum: a mesma chave chega como "000000000000123456" de uma extração
// e como "123456" (ou número) de outra planilha, e o merge não encontra o par.
//
// Regra:
//   - remove espaços
//   - se o código for só dígitos, remove zeros à esquerda
//   - códigos alfanuméricos ("A-0012") ficam como estão, pois os zeros podem fazer parte da chave
//   - sempre devolve texto (nunca número), para não perder chaves longas
//
// Uso:
//   Table.TransformColumns(Fonte, {{"Material", fnLimparCodigo, type nullable text}})

(codigo as any) as nullable text =>
let
    texto = if codigo = null then null else Text.Trim(Text.From(codigo)),

    soDigitos = texto <> null and texto <> "" and Text.Select(texto, {"0".."9"}) = texto,

    semZeros = if soDigitos then Text.TrimStart(texto, "0") else texto,

    // Código "0000" vira "0", e não texto vazio
    resultado = if soDigitos and semZeros = "" then "0" else semZeros
in
    resultado
