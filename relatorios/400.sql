SELECT
    DISTINCT CASE
        WHEN C.SITUACAO LIKE 'Normal' THEN 'Ativo'
        WHEN C.SITUACAO LIKE 'Inativo' THEN 'Bloqueado'
        WHEN C.SITUACAO LIKE 'Demissionário' THEN 'Encerrado'
        ELSE C.SITUACAO
    END AS SITUACAO_CADASTRO,
    C.CONTA,
    COALESCE(C.CPF, C.CGC) CPF_CNPJ,
    C.FISICA,
    C.NOME,
    CC.CONTAC,
    CC.SALDO SALDO_CC,
    Y.SD SALDO_CAPITAL,
    A.CONTRATO,
    A.VALOR,
    A.DATA,
    A.NIVEL,
    A.TIPO,
    ROUND(LAST_DAY('01/' || '12/2099') - A.DATA) DIAS,
    DECODE(
        DECODEINT(
            ROUND(LAST_DAY('01/' || '12/2099') - A.DATA),
            0,
            365
        ),
        1,
        '1',
        (
            DECODE(
                DECODEINT(
                    ROUND(LAST_DAY('01/' || '12/2099') - A.DATA),
                    366,
                    1460
                ),
                1,
                '2',
                DECODE(
                    GREATEST(0, ROUND(LAST_DAY('01/' || '12/2099') - A.DATA)),
                    0,
                    '1',
                    '3'
                )
            )
        )
    ) TIT,
    A.VALOR_ORIGINAL,
    A.RAA,
    (A.VALOR - A.RAA) AS VALOR_CONTABIL,
    P.DESCR_GRUPO GPSOL
FROM
    E_BAIXAS A
    LEFT JOIN C_CAD C ON A.CONTA = C.CONTA
    LEFT JOIN FACMUTUO.CC_CADASSOC CC_A ON C.CONTA = CC_A.CONTA AND CC_A.TITULAR = 'T'
    LEFT JOIN FACMUTUO.CC_CAD CC ON CC_A.CONTAC = CC.CONTAC
    LEFT JOIN FACMUTUO.A_SD Y ON C.CONTA = Y.CONTA
    LEFT JOIN FACMUTUO.E_ASSOC_GPSOL O ON C.CONTA = O.CONTA
    LEFT JOIN FACMUTUO.E_GPSOL P ON O.ID_GPSOL = P.ID_GPSOL
WHERE
    A.CONTRATO IS NOT NULL
    AND A.DATA BETWEEN :1DATA_INI AND :2DATA_FIM
ORDER BY
    TIT,
    NOME,
    CONTAC