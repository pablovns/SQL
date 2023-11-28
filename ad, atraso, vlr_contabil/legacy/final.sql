SELECT
    consulta3.*,
    consultaVlrContabil.VLR_CONTABIL,
    0 PROJECAO_NIVEL_AD,
    0 PROJECAO_NIVEL_ATRASO
    FROM (
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
    ) consulta3
    FULL OUTER JOIN
    (
        SELECT
            CONTA,
            SUM(VLR_CONTABIL) AS VLR_CONTABIL
        FROM (
            SELECT
                A.ANOMES,
                A.CONTA,
                B.NOME AS ASSOCIADO,
                ( A.SALDO + A.CTB_CORRECAO + A.CTB_JCAP + A.CTB_JNCAP + A.CTB_MORA + A.RAA_FUTURAS ) AS VLR_CONTABIL,
                A.COD_CART AS CART,
                A.NV_ATUAL AS NIVEL,
                AG.COD_AGENCIA AS UNID
            FROM
                FACMUTUO.E_SDA A, FACMUTUO.C_CAD B, FACMUTUO.C_CAD Z, FACMUTUO.C_CADUNI D, FACMUTUO.C_UNID C, FACMUTUO.E_TAXA E, FACMUTUO.E_LF F, FACMUTUO.E_CART G, FACMUTUO.C_CIDADE H, FACMUTUO.CC_AGENCIA AG, FACMUTUO.E_Forma_Bco J, FACMUTUO.C_SDA K, FACMUTUO.C_SETOR S, FACMUTUO.E_NIVEL NV
            WHERE
                A.CONTA = B.CONTA
                AND A.CONTA = K.CONTA
                AND A.ANOMES = K.ANOMES
                AND K.COD_AGENCIA = AG.COD_AGENCIA
                AND B.COD_UNID = D.COD_UNID
                AND B.CONTA = D.CONTA
                AND D.COD_UNID = C.COD_UNID
                AND B.AGENTE = Z.CONTA(+)
                AND D.COD_UNID = S.COD_UNID
                AND D.COD_SET = S.COD_SET
                AND A.COD_TAXA = E.COD_TAXA
                AND A.COD_LF = F.COD_LF
                AND A.COD_CART = G.COD_CART
                AND B.COD_CID = H.COD_CID
                AND A.COD_FORMA = J.COD_FORMA(+)
                AND A.NV_ATUAL = NV.NIVEL
                AND A.SALDO > 0
                AND A.COD_CART <> 10
                AND A.ANOMES = '2023/07'
        ) B
        GROUP BY
            CONTA
    ) consultaVlrContabil
ON consulta3.CONTA = consultaVlrContabil.CONTA
ORDER BY ASSOCIADO