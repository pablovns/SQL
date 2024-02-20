public static string DadosEmailChamadoAbertoEDirecionado(string pStrSolicitante, string pStrResponsavel)
{
    StringBuilder stbDados = new StringBuilder();

    stbDados.Append("<body style='font-family: Maven Pro; font-weight: normal;'>");
    stbDados.Append("    <br><p style='font-weight: bold;'><span style='font-size:25px; color:#00FF00;'>&#9632;</span>\tNovo chamado</p>");
    stbDados.Append($"    <p>Chamado aberto pelo usuário {pStrSolicitante} - Automaticamente redirecionado para {pStrResponsavel}.</p>");
    stbDados.Append("</body>");

    return stbDados.ToString();
}

public static string DadosEmailChamadoAberto(string pStrSolicitante)
{
    StringBuilder stbDados = new StringBuilder();

    stbDados.Append("<body style='font-family: Maven Pro; font-weight: normal;'>");
    stbDados.Append("    <br><p style='font-weight: bold;'><span style='font-size:25px; color:#00FF00;'>&#9632;</span>\tNovo chamado</p>");
    stbDados.Append($"    <p>Chamado aberto pelo usuário {pStrSolicitante}. Por favor, verifique o mesmo no Service Desk.</p>");
    stbDados.Append("</body>");

    return stbDados.ToString();
}

///adicionar \t antes dos titulo dos chamado

public static string DadosEmailChamadoDirecionado(string pStrSolicitante, string pStrServicoSolicitado, string pStrUrgencia, string pStrDescricao)
{
    StringBuilder stbDados = new StringBuilder();

    // stbDados.Append("<br>");
    // stbDados.Append("<table border='0' cellpadding='0' cellspacing='0' style='font-family:Maven Pro; font-weight:normal'>");
    // stbDados.Append("<td align='left' valign='middle'><b>" + "Chamado direcionado</b></td>");
    // stbDados.Append("</table>");
    // stbDados.Append("<br>");
    // stbDados.Append("Um chamado foi direcionado para você, por favor verifique o mesmo no Service Desk." + "<BR>");
    // stbDados.Append(" <BR>");
    // stbDados.Append("Solicitante: " + pStrSolicitante + "<BR>");
    // stbDados.Append("Solicitação: " + pStrServicoSolicitado + "<BR>");
    // stbDados.Append("Urgência: " + pStrUrgencia + "<BR><BR>");
    // stbDados.Append("Descrição: <BR>" + pStrDescricao.Replace("\r\n", "<br>") + "<BR><BR>");

    stbDados.Append("<body style='font-family: Maven Pro; font-weight: normal;'>");
    stbDados.Append("    <br><p style='font-weight: bold;'><span style='font-size:25px; color:#00FF00;'>&#9632;</span>Chamado direcionado</p><br><br>");
    stbDados.Append("    Um chamado foi direcionado para você, por favor verifique o mesmo no Service Desk.<br><br>");
    stbDados.Append($"    Solicitante: {pStrSolicitante}<br>");
    stbDados.Append($"    Solicitação: {pStrServicoSolicitado}<br>");
    stbDados.Append($"    Urgência: {pStrUrgencia}<br><br>");
    stbDados.Append($"    Descrição: <br>{pStrDescricao.Replace("\r\n", "<br>")}<br><br>");
    stbDados.Append("</body>");

    return stbDados.ToString();
}

public static string DadosEmailChamadoAtualizado(string pStrSolicitante, string pStrServicoSolicitado, string pStrUrgencia, string pStrDescricao, string pStrMensagemAtualizacao)
{
    StringBuilder stbDados = new StringBuilder();

    // stbDados.Append("<br>");
    // stbDados.Append("<table border='0' cellpadding='0' cellspacing='0' style='font-family:Maven Pro; font-weight:normal'>");
    // stbDados.Append("<td align='left' valign='middle'><b>" + "Chamado atualizado</b></td>");
    // stbDados.Append("</table>");
    // stbDados.Append("<br>");
    // stbDados.Append("O chamado foi atualizado!" + "<BR>");
    // stbDados.Append(" <BR>");
    // stbDados.Append("Solicitação: " + pStrServicoSolicitado + "<BR>");
    // stbDados.Append("Urgência: " + pStrUrgencia + "<BR><BR>");
    // stbDados.Append("Descrição: <BR>" + pStrDescricao.Replace("\r\n", "<br>") + "<BR><BR>");
    // stbDados.Append("Atualização: " + pStrMensagemAtualizacao + "<BR>");

    stbDados.Append("<body style='font-family: Maven Pro; font-weight: normal;'>");
    stbDados.Append("    <br><p style='font-weight: bold;'><span style='font-size:25px; color:#FFD700;'>&#9632;</span>Chamado atualizado</p><br><br>");
    stbDados.Append("    O chamado foi atualizado!<br><br>");
    stbDados.Append($"    Solicitação: {pStrServicoSolicitado}<br>");
    stbDados.Append($"    Urgência: {pStrUrgencia}<br>");
    stbDados.Append($"    Descrição: <br>{pStrDescricao.Replace("\r\n", "<br>")}<br><br>");
    stbDados.Append($"    Atualização: {pStrMensagemAtualizacao}");
    stbDados.Append($"</body>");

    return stbDados.ToString();
}

public static string DadosEmailChamadoConcluido(string pStrSolicitante, string pStrServicoSolicitado, string pStrUrgencia, string pStrDescricao, string pStrSolucao)
{
    StringBuilder stbDados = new StringBuilder();

    // stbDados.Append("<br>");
    // stbDados.Append("<table border='0' cellpadding='0' cellspacing='0' style='font-family:Maven Pro; font-weight:normal'>");
    // stbDados.Append("<td align='left' valign='middle'><b>" + "Chamado Concluído</b></td>");
    // stbDados.Append("</table>");
    // stbDados.Append("<br>");
    // stbDados.Append("O chamado foi Concluído!" + "<BR>");
    // stbDados.Append(" <BR>");
    // stbDados.Append("Solicitação: " + pStrServicoSolicitado + "<BR>");
    // stbDados.Append("Urgência: " + pStrUrgencia + "<BR><BR>");
    // stbDados.Append("Descrição: <BR>" + pStrDescricao.Replace("\r\n", "<br>") + "<BR><BR>");
    // stbDados.Append("Solução: " + pStrSolucao + "<BR>");

    stbDados.Append("<body style='font-family: Maven Pro; font-weight: normal;'>");
    stbDados.Append("    <br><p style='font-weight: bold;'><span style='font-size:25px; color:#000080;'>&#9632;</span>Chamado concluído</p><br><br>");
    stbDados.Append("    O chamado foi Concluído!<br><br>");
    stbDados.Append($"    Solicitação: {pStrServicoSolicitado}<br>");
    stbDados.Append($"    Urgência: {pStrUrgencia}<br><br>");
    stbDados.Append($"    Descrição: <br>{pStrDescricao.Replace("\r\n", "<br>")}<br><br>");
    stbDados.Append($"    Solução: {pStrSolucao}<br>");
    stbDados.Append($"</body>");

    return stbDados.ToString();
}
