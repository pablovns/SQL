SELECT
    COALESCE(resultados.CONTA, C_CAD.CONTA) AS CONTA,
    resultados.CONTAC,
    resultados.DATA,
    resultados.NUM_CHEQUE,
    resultados.VALOR,
    resultados.LIMITE_CHESP,
    resultados.SALDO_ATUAL,
    resultados.DIAS_AD,
    resultados.SALDO_BLOQ,
    SUM(resultados.SALDO) AS EMPRESTIMO,
    resultados.NIVEL,
    A_SDA.SD,
    queryAplicacao.APLICACAO,
    queryVencido.VENCIDO
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
        FACMUTUO.CC_CONTA D
        JOIN FACMUTUO.CC_CHEQUE A ON A.DT_ATUALIZADO LIKE '%21/08/2023%'
        JOIN FACMUTUO.CC_TALAO B ON A.COD_TALAO = B.COD_TALAO
        JOIN FACMUTUO.CC_CAD C ON B.CONTAC = C.CONTAC
        JOIN FACMUTUO.E_NIVEL E ON C.NV_ATUAL = E.NIVEL
        LEFT JOIN FACMUTUO.E_CTOPEN F ON D.CONTA = F.CONTA
    WHERE
        A.COD_SITUACAO = 9
        AND TO_DATE('21/08/2023') - F.VENC_FIM >= 1
    ORDER BY
        DT_ATUALIZADO DESC
) resultados
FULL OUTER JOIN FACMUTUO.A_SDA A_SDA ON resultados.CONTA = A_SDA.CONTA
FULL OUTER JOIN (
    SELECT
        CONTA,
        SUM(VALOR) AS APLICACAO
    FROM F_CTOPEN
    WHERE NOME = 'Aplicação'
    GROUP BY CONTA
) queryAplicacao ON resultados.CONTA = queryAplicacao.CONTA
FULL OUTER JOIN (
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
) queryVencido ON resultados.CONTA = VENCIDO.CONTA
FULL OUTER JOIN C_CAD ON resultados.CONTA = C_CAD.CONTA