SELECT
    consulta1.CONTA,
    CPF_CNPJ,
    ASSOCIADO,
    GERENTE,
    UNID,
    SALDOAD,
    DIASAD,
    NIVEL AS NIVEL_AD,
    VLR_VCTO,
    DIAS,
    NIVEL_ATRASO
FROM (
    SELECT
        CONTA,
        CPF_CNPJ,
        TITULAR AS ASSOCIADO,
        APELIDO AS GERENTE,
        AG AS UNID,
        SALDOAD,
        DIASAD,
        NIVEL
    FROM (
        SELECT
            D.CONTA,
            D.CPF || D.CGC AS CPF_CNPJ,
            E.APELIDO,
            E.EMAIL,
            A.FISICA,
            D.DT_SERASA,
            CASE WHEN D.EXECUCAO = 'T' THEN D.DT_EXECUCAO ELSE NULL END DT_EXECUCAO,
            RPAD(A.COD_AGENCIA, 4) AG,
            FACMUTUO.FACCOR_FUNCTIONS.LIMITE_CHESP(A.CONTAC,'30/07/2023') LIMITE_CHESP,
            (-1 * (FACMUTUO.FACCOR_FUNCTIONS.PEGASALDODIA(A.CONTAC, '30/07/2023') + FACMUTUO.FACCOR_FUNCTIONS.LIMITE_CHESP(A.CONTAC, '30/07/2023'))) SALDOAD,
            FACMUTUO.FACCOR_FUNCTIONS.PEGASALDODIABLOQ(A.CONTAC, '30/07/2023') SALDO_BLOQ,
            RPAD(A.TITULAR, 25) TITULAR,
            FACMUTUO.FACCOR_FUNCTIONS.NUMDIASAD(A.CONTAC, '30/07/2023') DIASAD,
            C.DESCRICAO NIVEL,
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
            AND B.NV_ATUAL = C.NIVEL
            AND A.CONTA = D.CONTA
            AND D.COD_AGENCIA = F.COD_AGENCIA
            AND D.AGENTE = E.CONTA(+)
    )
    WHERE SALDOAD > 0
) consulta1
INNER JOIN (
    SELECT
        B.CONTA,
        SUM(A.SALDO) VLR_VCTO,
        (
            SELECT
                MAX(TO_DATE('30/07/2023') - Z.VENC_FIM)
            FROM
                FACMUTUO.E_CTOPEN Z,
                FACMUTUO.C_CAD W,
                FACMUTUO.E_CART Y,
                FACMUTUO.E_PRODUTO V,
                FACMUTUO.E_LF K,
                FACMUTUO.C_CAD S,
                FACMUTUO.CC_AGENCIA T
            WHERE
                TO_DATE('30/07/2023') - Z.VENC_FIM >= 1
                AND SUBSTR(Z.CONTRATO, 10, 3) <> '000'
                AND Z.PARC_GER >= Z.NUM_PARC
                AND Z.PGTO_FIM >= Z.VENC_FIM
                AND Z.SALDO > 0
                AND Y.COD_CART = Z.COD_CART
                AND K.COD_LF = Z.COD_LF
                AND V.COD_PRODUTO = K.COD_PRODUTO
                AND Z.CONTA = W.CONTA
                AND ((W.SITUACAO = 'Normal') OR (W.SITUACAO = 'Afastado') OR (substr(W.SITUACAO, 1, 3) = 'Dem') OR (W.SITUACAO = 'Inativo'))
                AND W.AGENTE = S.CONTA
                AND W.COD_AGENCIA = T.COD_AGENCIA
                AND W.CONTA = B.CONTA
        ) AS DIAS,
        CASE
            WHEN B.NIVEL = 2 THEN 'A'
            WHEN B.NIVEL = 3 THEN 'B'
            WHEN B.NIVEL = 4 THEN 'C'
            WHEN B.NIVEL = 5 THEN 'D'
            WHEN B.NIVEL = 6 THEN 'E'
            WHEN B.NIVEL = 7 THEN 'F'
            WHEN B.NIVEL = 8 THEN 'G'
            WHEN B.NIVEL = 9 THEN 'H'
        END AS NIVEL_ATRASO

    FROM
        FACMUTUO.E_CTOPEN A,
        FACMUTUO.C_CAD B
    WHERE
        TO_DATE('30/07/2023') - A.VENC_FIM >= 1
        AND SUBSTR(A.CONTRATO, 10, 3) <> '000'
        AND A.PARC_GER >= A.NUM_PARC
        AND A.PGTO_FIM >= A.VENC_FIM
        AND A.SALDO > 0
        AND A.CONTA = B.CONTA
        AND ((B.SITUACAO = 'Normal') OR (B.SITUACAO = 'Afastado') OR (substr(B.SITUACAO, 1, 3) = 'Dem') OR (B.SITUACAO = 'Inativo'))
    GROUP BY
        B.CONTA,
        B.NIVEL
) consulta2
ON consulta1.CONTA = consulta2.CONTA
