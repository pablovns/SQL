public string RetornaSQLFormularioAbertura(int pIdFormulario)
{
    StringBuilder stbSelecao = new StringBuilder();
    
    stbSelecao.AppendLine("SELECT CONTEUDO, DATAINCLUSAO, STATUS, FORMULARIO_ID FROM C_FORMULARIO_RESULTADO");
    // stbSelecao.AppendLine("WHERE STATUS = 'N'");
    // stbSelecao.AppendLine($"AND FORMULARIO_ID = '{pIdFormulario}'");
    stbSelecao.AppendLine($"WHERE FORMULARIO_ID = '{pIdFormulario}'");

    return stbSelecao.ToString();
}