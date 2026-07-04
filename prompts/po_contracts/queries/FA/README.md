# FA — Assets 🏭

## 🇧🇷 Versão em Português (PT-BR)

**Queries de Assets — Oracle Fusion Cloud ERP 26B.** Parâmetros em bind variables `:p_*` — veja [CONVENTIONS.md](../CONVENTIONS.md).

### fa_asset_deprn_multibook.sql

Custo e depreciação (do período, YTD e reserva acumulada) de um ativo em todos os seus livros — uma linha por livro/período; pivote para comparar livros lado a lado.

**Parâmetros:** `:p_asset_number`, `:p_period_name` (opcional)
**Exemplo:** compare a depreciação societária vs fiscal vs IFRS de um ativo durante o UAT.

⚠️ Diferença Fusion (MOS Doc 2259590.1): `DEPRN_METHOD_CODE` e `LIFE_IN_MONTHS` não existem mais em `FA_BOOKS` — vêm de `FA_METHODS` via `METHOD_ID`.

### fa_cost_transactions.sql

Transações que afetam custo (adições, ajustes, transferências, baixas) lançadas num período para um livro, com categoria, conta de custo e localização.

**Parâmetros:** `:p_book_type_code`, `:p_period_name`
**Exemplo:** reconcilie o movimento de custo FA do mês contra a conta de custo de ativo no GL.

### fa_categories_by_book.sql

Lista de referência das categorias de ativo por livro de depreciação, com segmentos concatenados.

**Parâmetros:** `:p_book_type_code` (opcional)
**Exemplo:** monte a planilha de mapeamento de categorias numa migração de dados.

---

## 🇺🇸 English Version (EN-US)

**Assets queries — Oracle Fusion Cloud ERP 26B.** Parameters use `:p_*` bind variables — see [CONVENTIONS.md](../CONVENTIONS.md).

### fa_asset_deprn_multibook.sql

Cost and depreciation (period, YTD, accumulated reserve) for one asset across all its depreciation books — one row per book/period; pivot to compare books side by side.

**Parameters:** `:p_asset_number`, `:p_period_name` (optional)
**Example:** compare corporate vs tax vs IFRS depreciation of an asset during UAT.

⚠️ Fusion difference (MOS Doc 2259590.1): `DEPRN_METHOD_CODE` and `LIFE_IN_MONTHS` no longer exist in `FA_BOOKS` — they come from `FA_METHODS` via `METHOD_ID`.

### fa_cost_transactions.sql

Cost-affecting transactions (additions, adjustments, transfers, retirements) entered in a period for a book, with category, cost account and location.

**Parameters:** `:p_book_type_code`, `:p_period_name`
**Example:** reconcile the month's FA cost movement against the GL asset cost account.

### fa_categories_by_book.sql

Reference list of asset categories per depreciation book with concatenated segments.

**Parameters:** `:p_book_type_code` (optional)
**Example:** build the category mapping sheet during a data migration.
