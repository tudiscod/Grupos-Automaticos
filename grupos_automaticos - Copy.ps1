# Importando o módulo Active Directory
Import-Module ActiveDirectory

# Carregar usuários ignorados do arquivo
$usuariosIgnorados = Get-Content "C:\Grupos_Automaticos\ignorados.txt" -Delimiter ";"

# Filtrando os usuários com o atributo "Title" começando com "Coordenador", "Gerente", "Diretoria" ou "Supervisor"
$usuariosCoordenadores = Get-ADUser -Filter {(Title -like 'Coordenador*') -and (extensionAttribute2 -ne 'Demitido')}
$usuariosGerentes = Get-ADUser -Filter {(Title -like 'Gerente*') -and (extensionAttribute2 -ne 'Demitido')}
$usuariosDiretoria = Get-ADUser -Filter {(Title -like 'Diretor*') -and (extensionAttribute2 -ne 'Demitido')}
$usuariosSupervisores = Get-ADUser -Filter {(Title -like 'Supervis*') -and (extensionAttribute2 -ne 'Demitido')}

# Grupos para Coordenadores, Gerentes, Diretoria e Supervisores
$grupoCoordenadores = "Coordenadores_Grupo"
$grupoGerentes = "Gerentes_Grupo"
$grupoDiretoria = "Diretoria_Grupo"
$grupoSupervisores = "Supervisores_Grupo"

# Grupos organizacionais
$gruposOrganizacionais = @($grupoCoordenadores, $grupoGerentes, $grupoDiretoria, $grupoSupervisores)

# Função para adicionar o usuário ao grupo correto e remover de grupos antigos
function AtualizarGrupos($usuario, $grupoAtual) {
    $gruposUsuario = Get-ADPrincipalGroupMembership -Identity $usuario
    $gruposRemover = $gruposUsuario | Where-Object { $gruposOrganizacionais -contains $_.Name -and $_.Name -ne $grupoAtual }

    # Remover o usuário de todos os grupos antigos
    foreach ($grupo in $gruposRemover) {
        Remove-ADGroupMember -Identity $grupo -Members $usuario -Confirm:$false
        Write-Host "Usuário $($usuario.SamAccountName) removido do grupo $grupo."
    }

    # Adicionar o usuário ao novo grupo, se não estiver na lista de ignorados
    if (-not $usuariosIgnorados.Contains($usuario.SamAccountName) -and
        -not ($gruposUsuario | Where-Object { $_.Name -eq $grupoAtual })) {
        Add-ADGroupMember -Identity $grupoAtual -Members $usuario
        Write-Host "Usuário $($usuario.SamAccountName) adicionado ao grupo $grupoAtual."
    }
}

# Atualizar grupos para coordenadores
foreach ($usuarioCoordenador in $usuariosCoordenadores) {
    AtualizarGrupos $usuarioCoordenador $grupoCoordenadores
}

# Atualizar grupos para gerentes
foreach ($usuarioGerente in $usuariosGerentes) {
    AtualizarGrupos $usuarioGerente $grupoGerentes
}

# Atualizar grupos para diretoria
foreach ($usuarioDiretor in $usuariosDiretoria) {
    AtualizarGrupos $usuarioDiretor $grupoDiretoria
}

# Atualizar grupos para supervisores
foreach ($usuarioSupervisor in $usuariosSupervisores) {
    AtualizarGrupos $usuarioSupervisor $grupoSupervisores
}

# Remover usuários demitidos dos grupos
foreach ($grupo in $gruposOrganizacionais) {
    Get-ADGroupMember -Identity $grupo | ForEach-Object {
        if ((Get-ADUser $_.SamAccountName -Properties extensionAttribute2).extensionAttribute2 -eq 'Demitido' -and
            -not $usuariosIgnorados.Contains($_.SamAccountName)) {
            Remove-ADGroupMember -Identity $grupo -Members $_ -Confirm:$false
            Write-Host "Usuário $($_.SamAccountName) removido do grupo $grupo."
        }
    }
}

#função que percorre os grupos organizacionais (Coordenadores, Gerentes, Supervisores) e remove os usuários que não têm mais o cargo correspondente
function RemoverUsuariosIncompativeis($grupo, $tituloEsperado) {
    $membros = Get-ADGroupMember -Identity $grupo | Where-Object { $_.objectClass -eq 'user' }

    foreach ($membro in $membros) {
        $usuario = Get-ADUser -Identity $membro.SamAccountName -Properties Title, extensionAttribute2

        $title = $usuario.Title
        $demitido = $usuario.extensionAttribute2 -eq 'Demitido'
        $ignorado = $usuariosIgnorados -contains $usuario.SamAccountName

        # Verifica se o título ainda corresponde
        if (-not $title -or -not ($title -like "$tituloEsperado*") -and -not $demitido -and -not $ignorado) {
            Remove-ADGroupMember -Identity $grupo -Members $usuario -Confirm:$false
            Write-Host "Usuário $($usuario.SamAccountName) removido de $grupo (título atual: '$title')."
        }
    }
}

# Remover usuários que não têm mais o título esperado
RemoverUsuariosIncompativeis $grupoCoordenadores 'Coordenador*'
RemoverUsuariosIncompativeis $grupoGerentes 'Gerente*'
RemoverUsuariosIncompativeis $grupoSupervisores 'Supervis*'