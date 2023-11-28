SELECT
    *
FROM (
    SELECT
        CONTA,
        SALDO_AD,
        DIAS_AD,
        NIVEL_AD
    FROM (
        SELECT
            D.CONTA,
            (
                -1 * (FACMUTUO.FACCOR_FUNCTIONS.PEGASALDODIA(A.CONTAC, '30/07/2023')
                + FACMUTUO.FACCOR_FUNCTIONS.LIMITE_CHESP(A.CONTAC, '30/07/2023'))
            ) SALDO_AD,
            FACMUTUO.FACCOR_FUNCTIONS.NUMDIASAD(A.CONTAC, '30/07/2023') DIAS_AD,
            C.DESCRICAO NIVEL_AD
        FROM
            FACMUTUO.CC_CONTA A,
            FACMUTUO.CC_CAD B,
            FACMUTUO.E_NIVEL C,
            FACMUTUO.C_CAD D,
            FACMUTUO.CC_AGENCIA F
        WHERE
            A.CONTA = D.CONTA
            AND A.CONTAC = B.CONTAC
            AND B.NV_ATUAL = C.NIVEL
            AND D.COD_AGENCIA = F.COD_AGENCIA
    )
    WHERE SALDO_AD > 0
) consulta1
