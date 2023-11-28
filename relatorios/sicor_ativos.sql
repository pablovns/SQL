SELECT
    A.CONTA,
    A.NOME ASSOCIADO,
    A.CPF,
    A.ENDERECO || ', ' || A.END_NUM ENDERECO,
    B.NOME BAIRRO,
    A.CEP,
    C.NOME || ' - ' || C.UF CIDADE
FROM
    FACMUTUO.C_CAD A,
    FACMUTUO.C_BAIRRO B,
    FACMUTUO.C_CIDADE C,
    FACMUTUO.CC_CADASSOC D,
    FACMUTUO.CC_CAD E
WHERE
    A.COD_BAI = B.COD_BAI
    AND A.COD_CID = C.COD_CID
    AND A.SITUACAO = 'Normal'
    AND A.CONTA = D.CONTA
    AND D.CONTAC = E.CONTAC
    AND E.ATIVO <> 3
ORDER BY
    A.NOME