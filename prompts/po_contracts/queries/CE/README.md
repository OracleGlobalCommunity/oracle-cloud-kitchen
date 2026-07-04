# CE — Cash Management 🏦

## 🇧🇷 Versão em Português (PT-BR)

**Queries de Cash Management — Oracle Fusion Cloud ERP 26B.** Parâmetros em bind variables `:p_*` — veja [CONVENTIONS.md](../CONVENTIONS.md).

### ce_bank_account_setup.sql

Visão completa do setup de uma conta bancária interna: dados mestres, usos por Business Unit (habilitação AP/AR) e contas contábeis por uso (caixa, clearing, tarifas, ganho/perda). Outer joins expõem configurações incompletas.

**Parâmetros:** `:p_bank_account_num`
**Exemplo:** no discovery, valide que toda BU que usa a conta tem contas de caixa e clearing atribuídas antes do go-live.

---

## 🇺🇸 English Version (EN-US)

**Cash Management queries — Oracle Fusion Cloud ERP 26B.** Parameters use `:p_*` bind variables — see [CONVENTIONS.md](../CONVENTIONS.md).

### ce_bank_account_setup.sql

Complete setup view of an internal bank account: master data, business unit uses (AP/AR enablement) and GL accounts per use (cash, clearing, charges, gain/loss). Outer joins expose incomplete configurations.

**Parameters:** `:p_bank_account_num`
**Example:** during discovery, validate that every BU using the account has cash and clearing accounts assigned before go-live.
