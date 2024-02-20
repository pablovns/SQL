public string RetornaSQLDeclaracaoResidencia()
{
    StringBuilder stbSql = new StringBuilder();

    stbSql.AppendLine("SELECT");
	stbSql.AppendLine("C.NOME ASSOCIADO,");
	stbSql.AppendLine("COALESCE(C.CPF, C.CGC) CPF_CPNJ,");
	stbSql.AppendLine("C.CI RG,");
	stbSql.AppendLine("C.ORG_EXP,");
	stbSql.AppendLine("C.NACIONALIDADE,");
	stbSql.AppendLine("C.ENDERECO,");
	stbSql.AppendLine("C.END_NUM NUMERO,");
	stbSql.AppendLine("C.BAIRRO,");
	stbSql.AppendLine("D.NOME CIDADE,");
	stbSql.AppendLine("D.UF ESTADO,");
	stbSql.AppendLine("C.CEP");
	stbSql.AppendLine("FROM");
	stbSql.AppendLine("FACMUTUO.C_CAD C");
	stbSql.AppendLine("LEFT JOIN FACMUTUO.C_CIDADE D ON C.COD_CID = D.COD_CID");
	stbSql.AppendLine("WHERE");
	stbSql.AppendLine("C.ASSOCIADO = 'T'");
	stbSql.AppendLine("AND C.SITUACAO = 'Normal'");
	stbSql.AppendLine("ORDER BY");
	stbSql.AppendLine("ASSOCIADO");
	
    return stbSql.ToString();
}
