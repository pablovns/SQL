SELECT DISTINCT
    A.CONTA,
    D.NOME TITULAR
FROM
    FACMUTUO.CC_CCF A
    LEFT JOIN (SELECT COD_MOTDEV, (COD_MOTDEV || ' - ' || DESCRICAO) AS MOTIVO FROM FACMUTUO.CC_MOTDEV) C
    ON A.COD_MOTDEV = C.COD_MOTDEV
    LEFT JOIN (SELECT CONTA, NOME, COD_AGENCIA FROM FACMUTUO.C_CAD) D
    ON A.CONTA = D.CONTA
    LEFT JOIN FACMUTUO.CC_AGENCIA E
    ON D.COD_AGENCIA = E.COD_AGENCIA
WHERE E.COD_AGENCIA IN ( '100' )
