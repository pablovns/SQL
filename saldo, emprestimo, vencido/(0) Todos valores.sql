SELECT
    queryBase.CONTA,
    queryBase.CONTAC,
    queryBase.DATA,
    queryBase.NUM_CHEQUE,
    queryBase.VALOR,
    queryBase.LIMITE_CHESP,
    queryBase.SALDO_ATUAL,
    queryBase.DIAS_AD,
    queryBase.SALDO_BLOQ,
    queryBase.EMPRESTIMO,
    queryBase.NIVEL,
    querySD.SD,
    queryAplicacao.APLICACAO,
    queryVencido.VENCIDO
FROM (
    SELECT
        CONTAC,
        CONTA,
        DATA,
        NUM_CHEQUE,
        VALOR,
        LIMITE_CHESP,
        SALDO_ATUAL,
        DIAS_AD,
        SALDO_BLOQ,
        SUM(SALDO) AS EMPRESTIMO,
        NIVEL
    FROM (
        SELECT
            (
                (
                    FACMUTUO.FACCOR_FUNCTIONS.PEGASALDODIA(D.CONTAC, '21/08/2023')
                    + FACMUTUO.FACCOR_FUNCTIONS.LIMITE_CHESP(D.CONTAC, '21/08/2023')
                )
            ) AS SALDO_ATUAL,
            B.CONTAC,
            D.CONTA,
            A.NUM_CHEQUE,
            A.VALOR,
            A.DT_ATUALIZADO AS DATA,
            C.LIMITE_CHESP,
            FACMUTUO.FACCOR_FUNCTIONS.NUMDIASAD(D.CONTAC, '21/08/2023') AS DIAS_AD,
            E.DESCRICAO AS NIVEL,
            FACMUTUO.FACCOR_FUNCTIONS.PEGASALDODIABLOQ(D.CONTAC, '21/08/2023') AS SALDO_BLOQ,
            F.SALDO
        FROM
            FACMUTUO.CC_CONTA D,
            FACMUTUO.CC_CHEQUE A,
            FACMUTUO.CC_TALAO B,
            FACMUTUO.CC_CAD C,
            FACMUTUO.E_NIVEL E,
            FACMUTUO.E_CTOPEN F
        WHERE
            A.COD_SITUACAO = 9
            --WHERE A.DEVOLUCAO = 2
            AND A.DT_ATUALIZADO LIKE '%21/08/2023%'
            AND A.COD_TALAO = B.COD_TALAO
            AND D.CONTAC = B.CONTAC
            AND B.CONTAC = C.CONTAC
            AND C.NV_ATUAL = E.NIVEL
            AND D.CONTA = F.CONTA(+)
        ORDER BY
            DT_ATUALIZADO DESC
        )
        GROUP BY
            CONTAC,
            CONTA,
            DATA,
            NUM_CHEQUE,
            VALOR,
            LIMITE_CHESP,
            SALDO_ATUAL,
            DIAS_AD,
            SALDO_BLOQ,
            NIVEL
) queryBase
LEFT JOIN (
    SELECT
        CONTA,
        SD
    FROM FACMUTUO.A_SDA A_SDA
    WHERE ANOMES = '2023/07'
) querySD ON queryBase.CONTA = querySD.CONTA
LEFT JOIN (
    SELECT
        CONTA,
        SUM(VALOR) AS APLICACAO
    FROM F_CTOPEN
    WHERE NOME = 'Aplicação'
    GROUP BY CONTA
) queryAplicacao ON queryBase.CONTA = queryAplicacao.CONTA
LEFT JOIN (
    SELECT
        G.SALDO AS VENCIDO,
        G.CONTA AS CONTA
    FROM
        FACMUTUO.CC_CONTA D
        JOIN FACMUTUO.E_CTOPEN G ON D.CONTA = G.CONTA
        JOIN FACMUTUO.CC_CHEQUE A ON A.DT_ATUALIZADO LIKE '%21/08/2023%'
        JOIN FACMUTUO.CC_TALAO B ON G.CONTAC = B.CONTAC AND B.COD_TALAO = A.COD_TALAO
    WHERE
        TO_DATE('21/08/2023') - G.VENC_FIM >= 1
        AND A.COD_SITUACAO = 9
) queryVencido ON queryBase.CONTA = queryVencido.CONTA
LEFT JOIN C_CAD ON queryBase.CONTA = C_CAD.CONTA
GROUP BY
    queryBase.CONTA,
    queryBase.CONTAC,
    queryBase.DATA,
    queryBase.NUM_CHEQUE,
    queryBase.VALOR,
    queryBase.LIMITE_CHESP,
    queryBase.SALDO_ATUAL,
    queryBase.DIAS_AD,
    queryBase.SALDO_BLOQ,
    queryBase.EMPRESTIMO,
    queryBase.NIVEL,
    querySD.SD,
    queryAplicacao.APLICACAO,
    queryVencido.VENCIDO
ORDER BY CONTA, CONTAC, DATA