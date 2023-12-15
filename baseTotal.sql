SELECT
    DISTINCT C.CONTA CADASTRO,
    C.NOME ASSOCIADO,
    C.EMAIL,
    C.TEL_CEL CELULAR,
    COALESCE(C.CPF, C.CGC) CPF,
    C.FISICA,
    C.COD_AGENCIA,
    C.ENDERECO || ' nr ' || C.END_NUM ENDERECO,
    C.NACIONALIDADE,
    C.CI AS RG,
    CID.NOME || '-' || CID.UF CIDADE,
    C.CEP,
    H.NOME AS BAIRRO
FROM
    FACMUTUO.C_CAD C
    LEFT JOIN FACMUTUO.C_CIDADE CID ON C.COD_CID = CID.COD_CID
    LEFT JOIN FACMUTUO.C_BAIRRO H ON C.COD_BAI = H.COD_BAI
ORDER BY
    C.NOME