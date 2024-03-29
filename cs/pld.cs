public string RetornaPld(string pDataIni, string pDataFim, string pRiscoAlto, string pGerente, string pTipo, string pAcimaCinquenta, string pRiscoBaixo)
{
    StringBuilder stbSelecao = new StringBuilder();

    stbSelecao.AppendLine("SELECT");
    stbSelecao.AppendLine("B.CONTA,");
    stbSelecao.AppendLine("UNI.CONTAC,");
    stbSelecao.AppendLine("B.NOME AS ASSOCIADO,");
    stbSelecao.AppendLine("COALESCE(B.CPF, B.CGC) AS CPF_CNPJ,");
    stbSelecao.AppendLine("MOV.DC,");
    stbSelecao.AppendLine("COALESCE(B.VRFATURAMENTO, UNI.SALARIO) SALARIO_OU_FATURAMENTO,");
    stbSelecao.AppendLine("MOV.VALOR VALOR_TOTAL,");
    stbSelecao.AppendLine("B.PPE,");
    stbSelecao.AppendLine("A.COD_PERFIL,");
    stbSelecao.AppendLine("C_PERFIL.DESCRICAO,");
    stbSelecao.AppendLine("UNI.PROFISSAO,");
    stbSelecao.AppendLine("GER.APELIDO AS AGENTE,");
    stbSelecao.AppendLine("B.COD_AGENCIA,");
    stbSelecao.AppendLine("AG.NOME AGENCIA,");
    stbSelecao.AppendLine("TO_CHAR(B.ADM_COOP, 'dd/MM/yyyy') AS DATA_ADMISSAO_COOPERATIVA,");
    stbSelecao.AppendLine("B.DATACAD AS DATA_CADASTRO,");
    stbSelecao.AppendLine("CASE");
    stbSelecao.AppendLine("WHEN UNI.PROFISSAO = 'FUNCIONARIO COOPERATIVA' THEN 'SIM'");
    stbSelecao.AppendLine("WHEN UNI.PROFISSAO = 'FUNCIONARIO CREDICOOPAVEL' THEN 'SIM'");
    stbSelecao.AppendLine("ELSE 'NÃO'");
    stbSelecao.AppendLine("END AS E_FUNCIONARIO");
    stbSelecao.AppendLine("FROM");
    stbSelecao.AppendLine("FACMUTUO.C_CAD B");
    stbSelecao.AppendLine("INNER JOIN FACMUTUO.C_CAD GER ON B.AGENTE = GER.CONTA");
    stbSelecao.AppendLine("INNER JOIN FACMUTUO.C_CAD_PERFIL A ON A.CONTA = B.CONTA");
    stbSelecao.AppendLine("INNER JOIN FACMUTUO.C_PERFIL ON A.COD_PERFIL = C_PERFIL.COD_PERFIL");
    stbSelecao.AppendLine("LEFT JOIN FACMUTUO.CC_AGENCIA AG ON B.COD_AGENCIA = AG.COD_AGENCIA");
    stbSelecao.AppendLine("LEFT JOIN FACMUTUO.CC_CADASSOC CC_A ON B.CONTA = CC_A.CONTA");
    stbSelecao.AppendLine("LEFT JOIN FACMUTUO.C_CADUNI UNI ON B.CONTA = UNI.CONTA");
    stbSelecao.AppendLine("INNER JOIN (");
    stbSelecao.AppendLine("SELECT");
    stbSelecao.AppendLine("CONTAC,");
    stbSelecao.AppendLine("DC,");
    stbSelecao.AppendLine("SUM(VALOR) AS VALOR");
    stbSelecao.AppendLine("FROM");
    stbSelecao.AppendLine("(");
    stbSelecao.AppendLine("SELECT");
    stbSelecao.AppendLine("CONTAC,");
    stbSelecao.AppendLine("DC,");
    stbSelecao.AppendLine("DATA,");
    stbSelecao.AppendLine("SUM(VALOR) AS VALOR");
    stbSelecao.AppendLine("FROM");
    stbSelecao.AppendLine("FACMUTUO.CC_MVOPEN");
    stbSelecao.AppendLine("WHERE");
    stbSelecao.AppendLine("ESTORNADO = 'F'");
    stbSelecao.AppendLine("AND COMPENSADO = 'T'");
    stbSelecao.AppendLine("AND COD_LANC NOT IN ('2004', '2016', '4004', '3004')");
    stbSelecao.AppendLine($"AND DATA BETWEEN '{pDataIni}'");
    stbSelecao.AppendLine($"AND '{pDataFim}'");
    stbSelecao.AppendLine("GROUP BY");
    stbSelecao.AppendLine("CONTAC,");
    stbSelecao.AppendLine("DC,");
    stbSelecao.AppendLine("DATA");
    stbSelecao.AppendLine("UNION");
    stbSelecao.AppendLine("SELECT");
    stbSelecao.AppendLine("CONTAC,");
    stbSelecao.AppendLine("DC,");
    stbSelecao.AppendLine("DATA,");
    stbSelecao.AppendLine("SUM(VALOR) AS VALOR");
    stbSelecao.AppendLine("FROM");
    stbSelecao.AppendLine("FACMUTUO.CC_MVCLOS");
    stbSelecao.AppendLine("WHERE");
    stbSelecao.AppendLine("ESTORNADO = 'F'");
    stbSelecao.AppendLine("AND COMPENSADO = 'T'");
    stbSelecao.AppendLine("AND COD_LANC NOT IN ('2004', '2016', '4004', '3004')");
    stbSelecao.AppendLine($"AND DATA BETWEEN '{pDataIni}'");
    stbSelecao.AppendLine($"AND '{pDataFim}'");
    stbSelecao.AppendLine("GROUP BY");
    stbSelecao.AppendLine("CONTAC,");
    stbSelecao.AppendLine("DC,");
    stbSelecao.AppendLine("DATA");
    stbSelecao.AppendLine(")");
    stbSelecao.AppendLine("GROUP BY");
    stbSelecao.AppendLine("CONTAC,");
    stbSelecao.AppendLine("DC");
    stbSelecao.AppendLine(") MOV ON UNI.CONTAC = MOV.CONTAC");
    stbSelecao.AppendLine("WHERE");
    stbSelecao.AppendLine("CC_A.TITULAR = 'T'");
    if (!string.IsNullOrEmpty(pGerente))
    {
        stbSelecao.AppendLine($"AND GER.APELIDO LIKE '{pGerente}'");
    };
    if (!string.IsNullOrEmpty(pRiscoAlto)) 
    {
        stbSelecao.AppendLine("AND (");
        stbSelecao.AppendLine("A.COD_PERFIL IN (11, 13, 14, 15)");
        stbSelecao.AppendLine("OR C_PERFIL.COD_PERFIL IN (11, 13, 14, 15)");
        stbSelecao.AppendLine(")");
    };
    if (!string.IsNullOrEmpty(pRiscoBaixo)) 
    {
        stbSelecao.AppendLine("AND (");
        stbSelecao.AppendLine("A.COD_PERFIL = 16");
        stbSelecao.AppendLine("OR C_PERFIL.COD_PERFIL = 16");
        stbSelecao.AppendLine(")");
    };
    stbSelecao.AppendLine("AND (");
    stbSelecao.AppendLine("(");
    stbSelecao.AppendLine("INSTR(COALESCE(B.CPF, B.CGC), '/') <= 0");
    stbSelecao.AppendLine("AND MOV.VALOR > COALESCE(B.VRFATURAMENTO, UNI.SALARIO) * 5");
    stbSelecao.AppendLine(")");
    stbSelecao.AppendLine("OR (");
    stbSelecao.AppendLine("INSTR(COALESCE(B.CPF, B.CGC), '/') > 0");
    stbSelecao.AppendLine("AND MOV.VALOR > COALESCE(B.VRFATURAMENTO, UNI.SALARIO) / 12 * 5");
    stbSelecao.AppendLine(")");
    stbSelecao.AppendLine(")");
    stbSelecao.AppendLine("ORDER BY");
    stbSelecao.AppendLine("B.NOME");

    return stbSelecao.ToString();
}