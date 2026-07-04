# Convenções / Conventions 📐

## 🇧🇷 Versão em Português (PT-BR)

**Padrões que todas as queries deste repositório seguem**

### Plataforma alvo

- **Oracle Fusion Cloud ERP 26B** (SQL de data model BI Publisher / OTBI)
- Tabelas referenciadas **sem prefixo de schema** (padrão em data models BIP)
- Queries convertidas do EBS R12 foram remapeadas:

| EBS R12 (original) | Fusion Cloud 26B (este repo) |
|---|---|
| Schema `APPS.*` | sem prefixo |
| `GL_SETS_OF_BOOKS` | `GL_LEDGERS` |
| `AP_SUPPLIERS` | `POZ_SUPPLIERS_V` |
| `AP_SUPPLIER_SITES_ALL` | `POZ_SUPPLIER_SITES_ALL_M` |
| `HR_ALL_ORGANIZATION_UNITS` / `HR_OPERATING_UNITS` | `FUN_ALL_BUSINESS_UNITS_V` |
| `AP_INVOICES_V` | `AP_INVOICES_ALL` + joins |
| `FA_FINANCIAL_INQUIRY_COST_V` | `FA_TRANSACTION_HEADERS` + joins |
| `FA_BOOKS.DEPRN_METHOD_CODE` / `LIFE_IN_MONTHS` | `FA_METHODS` via `METHOD_ID` (MOS Doc 2259590.1) |
| `CLL_F035_BANK_ACCOUNTS_V` (localização BR) | `CE_BANK_ACCOUNTS` |
| `GL_JE_SOURCES` | `GL_JE_SOURCES_TL` |
| `MO_GLOBAL.SET_POLICY_CONTEXT` | não necessário (BIP) |

### Bind variables

Todos os literais específicos de cliente viram bind variables com prefixo `:p_`:

| Variável | Significado | Exemplo |
|---|---|---|
| `:p_ledger_name` | Nome do ledger (GL_LEDGERS.NAME) | `XX Primary Ledger` |
| `:p_period_name` | Nome do período, `'MMM-YY'` por padrão — case-sensitive, deve bater exatamente com o calendário contábil/FA | `Jan-26` |
| `:p_currency_code` | Moeda | `USD` |
| `:p_legal_entity` | Segmento do CoA que representa a empresa/LE | `1000` |
| `:p_account` | Segmento de conta natural | `11010` |
| `:p_bu_name` | Nome da Business Unit (FUN_ALL_BUSINESS_UNITS_V.BU_NAME) | `XX Brazil BU` |
| `:p_book_type_code` | Livro de depreciação FA | `XX CORP BOOK` |
| `:p_asset_number` | Número do ativo | `100001` |
| `:p_bank_account_num` | Número da conta bancária | `12345678` |
| `:p_gl_date_from` / `:p_gl_date_to` | Intervalo de GL date, sempre `'YYYY-MM-DD'` via `TO_DATE` explícito | `2026-01-01` |

> **Regra de datas:** parâmetros de data são sempre comparados com
> `TO_DATE(:p_x, 'YYYY-MM-DD')` — nunca dependa de conversão implícita,
> que quebra conforme o `NLS_DATE_FORMAT` da sessão.

> **Regra de usabilidade:** parâmetros pedem o que o usuário conhece —
> nomes, números e códigos (`:p_bu_name`, `:p_asset_number`, `:p_ledger_name`) —
> nunca ids internos. A resolução de id acontece dentro da query via joins.

> **Plano de contas:** o papel de cada segmento (empresa, conta, centro de custo)
> varia por implementação. Ajuste as referências `SEGMENT1..SEGMENTn` à sua estrutura.

### Aliases de tabela

Alias = iniciais de cada token do nome da tabela (separado por underscore):

| Tabela | Alias |
|---|---|
| `AP_INVOICES_ALL` | `aia` |
| `AP_PAYMENT_SCHEDULES_ALL` | `apsa` |
| `AP_INVOICE_DISTRIBUTIONS_ALL` | `aida` |
| `AP_HOLDS_ALL` / `AP_HOLD_CODES` | `aha` / `ahc` |
| `POZ_SUPPLIERS_V` / `POZ_SUPPLIER_SITES_ALL_M` | `psv` / `pssam` |
| `FUN_ALL_BUSINESS_UNITS_V` | `fabuv` |
| `GL_BALANCES` / `GL_LEDGERS` | `gb` / `gl` |
| `GL_CODE_COMBINATIONS` | `gcc` (duas vezes na query: `gcc_liab`, `gcc_dist`) |
| `GL_JE_BATCHES` / `GL_JE_HEADERS` / `GL_JE_LINES` | `gjb` / `gjh` / `gjl` |
| `GL_JE_SOURCES_TL` | `gjst` |
| `XLA_AE_HEADERS` / `XLA_AE_LINES` | `xah` / `xal` |
| `FA_ADDITIONS_B` / `FA_ADDITIONS_TL` | `fab` / `fat` |
| `FA_BOOKS` / `FA_METHODS` / `FA_TRANSACTION_HEADERS` | `fb` / `fm` / `fth` |
| `FA_DEPRN_SUMMARY` / `FA_DEPRN_PERIODS` | `fds` / `fdp` |
| `FA_CATEGORIES_B` / `FA_CATEGORY_BOOKS` | `fcb` / `fcbs` |
| `FA_DISTRIBUTION_HISTORY` / `FA_LOCATIONS` | `fdh` / `fl` |
| `PO_HEADERS_ALL` / `PO_DISTRIBUTIONS_ALL` | `pha` / `pda` |
| `CE_BANK_ACCOUNTS` / `CE_BANK_ACCT_USES_ALL` / `CE_GL_ACCOUNTS_CCID` | `cba` / `cbaua` / `cgac` |

Em caso de colisão de alias, desambigue com sufixo (`fcbs`) ou sufixo de papel (`gcc_liab`).

### Padrão de arquivos

- Uma query por arquivo `.sql`, nome em `snake_case` com prefixo do módulo (`gl_`, `ap_`, `fa_`, `ce_`)
- Todo arquivo começa com cabeçalho padrão: Purpose, Tables Used, Report Output, Parameters, Notes, Module
- Toda pasta de módulo tem um `README.md` descrevendo cada query
- Filtros de idioma usam `USERENV('LANG')` em vez de idioma fixo

---

## 🇺🇸 English Version (EN-US)

# Conventions 📐

**Standards every query in this repository follows**

### Target platform

- **Oracle Fusion Cloud ERP 26B** (BI Publisher / OTBI data model SQL)
- Tables referenced **without schema prefix** (BIP data model standard)
- Queries converted from EBS R12 were remapped per the table above (PT-BR section)

### Bind variables

Every client-specific literal became a `:p_`-prefixed bind variable — see the table in the PT-BR section for the full list.

> **Date rule:** date parameters are always compared with `TO_DATE(:p_x, 'YYYY-MM-DD')` — never rely on implicit conversion, which breaks depending on the session `NLS_DATE_FORMAT`.

> **Usability rule:** parameters ask for what users actually know — names, numbers and codes (`:p_bu_name`, `:p_asset_number`, `:p_ledger_name`) — never internal ids. Id resolution happens inside the query via joins.

> **Chart of Accounts:** segment roles (legal entity, account, cost center) vary by implementation. Adjust `SEGMENT1..SEGMENTn` references to your CoA structure.

### Table aliases

Alias = initials of each underscore-separated token of the table name (`ap_invoices_all` → `aia`) — full list in the PT-BR section. On collision, disambiguate with a suffix (`fcbs`) or a role suffix (`gcc_liab`).

### File standards

- One query per `.sql` file, `snake_case` name prefixed by module (`gl_`, `ap_`, `fa_`, `ce_`)
- Every file starts with the standard header: Purpose, Tables Used, Report Output, Parameters, Notes, Module
- Every module folder has a `README.md` describing each query
- Language filters use `USERENV('LANG')` instead of hardcoded languages
