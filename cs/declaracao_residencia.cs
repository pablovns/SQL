public string RetornaSQL()
{
    StringBuilder stbSql = new StringBuilder();

    stbSelecao.AppendLine("SELECT");
	stbSelecao.AppendLine("C.NOME ASSOCIADO,");
	stbSelecao.AppendLine("COALESCE(C.CPF, C.CGC) CPF_CPNJ,");
	stbSelecao.AppendLine("C.CI RG,");
	stbSelecao.AppendLine("C.ORG_EXP,");
	stbSelecao.AppendLine("C.NACIONALIDADE,");
	stbSelecao.AppendLine("C.ENDERECO,");
	stbSelecao.AppendLine("C.END_NUM NUMERO,");
	stbSelecao.AppendLine("C.BAIRRO,");
	stbSelecao.AppendLine("D.NOME CIDADE,");
	stbSelecao.AppendLine("D.UF ESTADO,");
	stbSelecao.AppendLine("C.CEP");
	stbSelecao.AppendLine("FROM");
	stbSelecao.AppendLine("FACMUTUO.C_CAD C");
	stbSelecao.AppendLine("LEFT JOIN FACMUTUO.C_CIDADE D ON C.COD_CID = D.COD_CID");
	stbSelecao.AppendLine("WHERE");
	stbSelecao.AppendLine("C.ASSOCIADO = 'T'");
	stbSelecao.AppendLine("AND C.SITUACAO = 'Normal'");
	stbSelecao.AppendLine("ORDER BY");
	stbSelecao.AppendLine("ASSOCIADO");
	
    return stbSql.ToString();
}
