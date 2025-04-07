# 🧠 Script PowerShell - Gerenciamento Automático de Grupos por Cargo no Active Directory

Este script automatiza o processo de **inclusão e remoção de usuários** em grupos do Active Directory com base nos seus cargos (`Title`). Ideal para manter grupos organizacionais como **Coordenadores, Gerentes, Diretores e Supervisores** sempre atualizados.

---

## ⚙️ O que esse script faz?

🔎 **Filtra usuários ativos** (não demitidos) com títulos:

- `Coordenador*`
- `Gerente*`
- `Diretor*`
- `Supervis*`

📂 **Grupos organizacionais usados:**

- `Coordenadores_Grupo`
- `Gerentes_Grupo`
- `Diretoria_Grupo`
- `Supervisores_Grupo`

🛑 **Usuários demitidos ou na lista de ignorados** não são incluídos/removidos.

---

## 🧾 Funcionalidades passo a passo

1. 📄 **Carrega uma lista de usuários ignorados** (arquivo `ignorados.txt`) para não serem afetados.

2. 👥 **Identifica os usuários ativos por cargo** no AD usando o campo `Title`.

3. 🔁 Para cada usuário com cargo reconhecido:
   - ✅ É **adicionado** ao grupo correspondente
   - ❌ É **removido** de grupos de cargos que não correspondem
   - 🛡️ Se estiver na lista de ignorados, **nenhuma ação é feita**

4. 🧹 **Remove dos grupos organizacionais** qualquer usuário:
   - Que esteja com o campo `extensionAttribute2 = 'Demitido'`
   - Ou cujo `Title` **não condiz mais** com o grupo em que está

---

## 🛑 Exclusões

- 👤 Usuários listados no arquivo `ignorados.txt` (1 por linha, apenas `SamAccountName`)
- 🛑 Usuários com `extensionAttribute2 = 'Demitido'`

---

## 📁 Exemplo de execução

Se o usuário `joao.silva` tem `Title = Gerente de Vendas`, ele será:

- ➕ Adicionado ao grupo `Gerentes_Grupo`
- ❌ Removido de `Coordenadores_Grupo`, `Diretoria_Grupo`, `Supervisores_Grupo` (se estiver)
- Se for demitido ou listado no `ignorados.txt`, nenhuma alteração será feita

---

## 📝 Requisitos

- PowerShell rodando como administrador
- Módulo Active Directory instalado (`RSAT: Active Directory`)
- Permissão para adicionar/remover membros de grupos no AD
- Arquivo `ignorados.txt` contendo os usuários que não devem ser alterados

---

## 🚀 Como executar

1. Coloque o script em uma pasta local (ex: `C:\Grupos_Automaticos\AtualizarGrupos.ps1`)
2. Crie o arquivo `ignorados.txt` com os `SamAccountName` dos usuários a serem ignorados (um por linha)
3. Execute o PowerShell como **administrador**
4. Rode o script:

```powershell
.\AtualizarGrupos.ps1


🧠 Dica extra
Você pode agendar esse script para rodar automaticamente via Agendador de Tarefas do Windows, garantindo que os grupos estejam sempre atualizados conforme as movimentações de cargo no AD.

🤝 Contribuições
Sinta-se à vontade para abrir uma issue com dúvidas ou sugestões de melhoria! 🚀


