# Queries SQL — Oracle Fusion Cloud ERP 🍽️

## 🇧🇷 Versão em Português (PT-BR)

**Queries SQL prontas por módulo, parametrizadas e documentadas — Oracle Fusion Cloud ERP 26B**

Criadas por consultores para consultores. Nascidas em projetos reais (era EBS R12), convertidas para as tabelas e views do Fusion Cloud 26B, limpas, parametrizadas e documentadas com refactoring assistido por IA.

### O que tem aqui?

- Queries prontas para BI Publisher / OTBI, organizadas por módulo
- Zero dados de cliente — tudo virou bind variable `:p_*`
- Cabeçalho padrão em cada query: Purpose, Tables Used, Report Output, Parameters, Notes, Module
- README explicativo em cada pasta de módulo
- Convenções de parametrização e aliases documentadas

### Estrutura

- `GL/` → General Ledger (balancete por segmento, razão, account analysis SLA)
- `AP/` → Payables (aging de títulos em aberto, distribuições com PO, holds)
- `FA/` → Assets (depreciação multi-livro, transações de custo, categorias por livro)
- `CE/` → Cash Management (setup de conta bancária com BU e contas contábeis)
- `CONVENTIONS.md` → Padrões de bind variables, aliases e mapeamento EBS → Fusion

### Como usar

1. Entre na pasta do módulo e leia o `README.md` para escolher a query
2. Leia o cabeçalho do `.sql` — ele explica propósito, tabelas e parâmetros
3. Substitua as bind variables `:p_*` pelos seus valores (BIP aceita nativamente como parâmetros)
4. Ajuste as referências `SEGMENTn` à estrutura do seu plano de contas

⚠️ **Teste sempre em ambiente não-produtivo primeiro.** As queries seguem a documentação oficial do 26B (Tables and Views for Financials), mas colunas variam por release e seu perfil de segurança se aplica no BIP.

**Qualquer consultor Oracle ERP é bem-vindo — uma ⭐ é sempre apreciada!**

---

## 🇺🇸 English Version (EN-US)

# SQL Queries — Oracle Fusion Cloud ERP 🍽️

**Ready-to-use SQL queries by module, parameterized and documented — Oracle Fusion Cloud ERP 26B**

Built by consultants for consultants. Born on real implementation projects (EBS R12 era), converted to Fusion Cloud 26B tables and views, then cleaned, parameterized and documented with AI-assisted refactoring.

### What's Inside?

- BI Publisher / OTBI-ready queries, organized by module
- Zero client data — every literal became a `:p_*` bind variable
- Standard header in every query: Purpose, Tables Used, Report Output, Parameters, Notes, Module
- Explanatory README in each module folder
- Documented parameterization and alias conventions

### Structure

- `GL/` → General Ledger (trial balance by segment, journal lines, SLA account analysis)
- `AP/` → Payables (open invoices aging, distributions with PO, holds)
- `FA/` → Assets (multi-book depreciation, cost transactions, categories by book)
- `CE/` → Cash Management (bank account setup with BU and GL accounts)
- `CONVENTIONS.md` → Bind variable standards, aliases and EBS → Fusion mapping

### How to Use

1. Open the module folder and read its `README.md` to pick a query
2. Read the `.sql` header — it explains purpose, tables and parameters
3. Replace the `:p_*` bind variables with your values (BIP accepts them natively as parameters)
4. Adjust `SEGMENTn` references to your Chart of Accounts structure

⚠️ **Always test in a non-production environment first.** Queries follow the official 26B schema documentation (Tables and Views for Financials), but columns vary by release and your security profile applies in BIP.

**Any Oracle ERP consultant is welcome — a ⭐ is always appreciated!**
