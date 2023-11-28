SELECT * FROM (
    SELECT
        CONTA,
        CPF_CNPJ,
        ASSOCIADO,
        GERENTE,
        UNID
    FROM (
        SELECT
            D.CONTA,
            D.CPF || D.CGC AS CPF_CNPJ,
            E.APELIDO AS GERENTE,
            E.EMAIL,
            A.FISICA,
            D.DT_SERASA,
            CASE WHEN D.EXECUCAO = 'T' THEN D.DT_EXECUCAO ELSE NULL END DT_EXECUCAO,
            RPAD(A.COD_AGENCIA, 4) UNID,
            FACMUTUO.FACCOR_FUNCTIONS.LIMITE_CHESP(A.CONTAC,'30/07/2023') LIMITE_CHESP,
            FACMUTUO.FACCOR_FUNCTIONS.PEGASALDODIABLOQ(A.CONTAC, '30/07/2023') SALDO_BLOQ,
            RPAD(A.TITULAR, 25) ASSOCIADO,
            E.NOME AGENTE
        FROM
            FACMUTUO.CC_CONTA A,
            FACMUTUO.CC_CAD B,
            FACMUTUO.E_NIVEL C,
            FACMUTUO.C_CAD D,
            FACMUTUO.C_CAD E,
            FACMUTUO.CC_AGENCIA F
        WHERE
            A.CONTAC = B.CONTAC
            AND A.CONTA = D.CONTA
            AND D.COD_AGENCIA = F.COD_AGENCIA
            AND D.AGENTE = E.CONTA(+)
    )
    GROUP BY CONTA, CPF_CNPJ, ASSOCIADO, GERENTE, UNID
) consultaInformacoes