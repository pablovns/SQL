SELECT
    G.CONTAC,
    C.CONTA,
    C.MATRICULA,
    REPLACE(REPLACE(C.CPF, '.', ''), '-', '') || REPLACE(
        REPLACE(REPLACE(C.CGC, '.', ''), '-', ''),
        '/',
        ''
    ) AS CPF_CNPJ,
    C.NOME,
    E.APELIDO AGENTE,
    C.COD_AGENCIA,
    AG.NOME NOMEAGENCIA,
    I.COD_PACOTE,
    I.DESCRICAO PACOTE,
    C.DEMISSAO,
    (
        SELECT
            MIN(AZ.DT_ABERT) DT_ABERT_CC
        FROM
            FACMUTUO.CC_CAD AZ,
            FACMUTUO.CC_CADASSOC BZ
        WHERE
            AZ.CONTAC = BZ.CONTAC
            AND BZ.CONTA = C.CONTA
            AND BZ.TITULAR = 'T'
    ) DT_ABERT_CC,
    DECODE(
        C.NIVEL,
        1,
        'AA',
        DECODE(
            C.NIVEL,
            2,
            'A',
            DECODE(
                C.NIVEL,
                3,
                'B',
                DECODE(
                    C.NIVEL,
                    4,
                    'C',
                    DECODE(
                        C.NIVEL,
                        5,
                        'D',
                        DECODE(
                            C.NIVEL,
                            6,
                            'E',
                            DECODE(
                                C.NIVEL,
                                7,
                                'F',
                                DECODE(C.NIVEL, 8, 'G', DECODE(C.NIVEL, 9, 'H', ''))
                            )
                        )
                    )
                )
            )
        )
    ) AS NIVEL,
    C.ADM_COOP,
    C.SITUACAO,
    C.CGC,
    C.FISICA,
    D.NOME CIDADE,
    C.MOTIVO_DEMISSAO,
    C.NASCIMENTO DT_NASC,
    FACMUTUO.ANOSENTREDATAS(C.NASCIMENTO, SYSDATE) IDADE,
    CU.PROFISSAO,
    CU.SALARIO,
    C.VRFATURAMENTO,
    AG.COD_AGENCIA AS UNID,
    (
        SELECT
            SD
        FROM
            FACMUTUO.A_SD Y
        WHERE
            Y.CONTA = C.CONTA
    ) AS SALDO_CAPITAL,
    (
        SELECT
            SUM(K.VLR_LIMITE)
        FROM
            FACMUTUO.CC_CARTAO K
        WHERE
            (
                K.ATIVO = '1'
                OR K.ATIVO IS NULL
                OR K.ATIVO = '3'
            )
            AND F.CONTAC = K.CONTAC(+)
    ) LIMITE,
    -----LIMITE
    FACMUTUO.FACCOR_FUNCTIONS.LIMITE_CHESP(F.CONTAC, SYSDATE) LIM_CHESP,
    M.PATRIMONIO,
    N.CHDEV,
    P.DESCR_GRUPO,
    R.RISCO,
    T.DEBITO,
    T.CREDITO,
    C.CONJUGUE,
    C.CPFCONJUGE
FROM
    FACMUTUO.C_CAD C,
    FACMUTUO.C_CADUNI CU,
    FACMUTUO.C_Unid U,
    FACMUTUO.C_CIDADE D,
    FACMUTUO.C_SETOR S,
    FACMUTUO.C_BAIRRO B,
    FACMUTUO.C_CAD E,
    FACMUTUO.CC_AGENCIA AG,
    FACMUTUO.CC_CADASSOC F,
    FACMUTUO.CC_CONTA G,
    FACMUTUO.CC_CAD H,
    FACMUTUO.CC_PACOTE I,
    FACMUTUO.E_ASSOC_GPSOL O,
    FACMUTUO.E_GPSOL P,
    FACMUTUO.CC_CARTAO K,
    (
        SELECT
            CONTA,
            SUM(SOMA) PATRIMONIO
        FROM
            (
                SELECT
                    CONTA,
                    SUM(VALOR) SOMA,
                    'Imoveis Urbanos' Nome
                FROM
                    FACMUTUO.CR_IMOU
                GROUP BY
                    CONTA
                UNION
                ALL
                SELECT
                    CONTA,
                    SUM(VALOR) SOMA,
                    'Imoveis Rurais' Nome
                FROM
                    FACMUTUO.CR_IMOR
                GROUP BY
                    CONTA
                UNION
                ALL
                SELECT
                    CONTA,
                    SUM(VALOR) SOMA,
                    'Rebanho' Nome
                FROM
                    FACMUTUO.CR_REB
                GROUP BY
                    CONTA
                UNION
                ALL
                SELECT
                    CONTA,
                    SUM(VALOR) SOMA,
                    'Capital Fixo / Semi Fixo' Nome
                FROM
                    FACMUTUO.CR_CAP
                GROUP BY
                    CONTA
                UNION
                ALL
                SELECT
                    CONTA,
                    SUM(VALOR) SOMA,
                    'Responsabilidades' Nome
                FROM
                    FACMUTUO.CR_RESP
                GROUP BY
                    CONTA
                UNION
                ALL
                SELECT
                    CONTA,
                    SUM(VALOR) - SUM(VALOR_FIN) SOMA,
                    'Veículos' Nome
                FROM
                    FACMUTUO.CM_AUTO
                GROUP BY
                    CONTA
                UNION
                ALL
                SELECT
                    CONTA,
                    (
                        APLIC_FUNDO_INVEST + APLIC_DEP_PRAZO + APLIC_BOLSA_VALORES + APLIC_TIT_PUBLICO + OUTROS_VALOR
                    ) SOMA,
                    'Direitos/Outros' Nome
                FROM
                    FACMUTUO.C_DIREITOS
            )
        GROUP BY
            CONTA
    ) M,
    (
        SELECT
            E.CONTA,
            COUNT(*) CHDEV
        FROM
            FACMUTUO.CC_CHEQUEC A
            INNER JOIN FACMUTUO.CC_TALAO B ON A.COD_TALAO = B.COD_TALAO
            INNER JOIN FACMUTUO.CC_CADASSOC D ON D.CONTAC = B.CONTAC
            INNER JOIN FACMUTUO.C_CAD E ON E.CONTA = D.CONTA
            INNER JOIN FACMUTUO.CC_AGENCIA C ON E.COD_AGENCIA = C.COD_AGENCIA
            LEFT JOIN FACMUTUO.C_CAD F ON E.AGENTE = F.CONTA
        WHERE
            A.COD_SITUACAO = 9
            AND A.COD_MOTDEV IN(11, 12)
            AND DATA BETWEEN '07/06/2023'
            AND '04/12/2023'
            AND TO_CHAR(D.TITULAR) = 'T'
        GROUP BY
            E.CONTA
    ) N,
    (
        SELECT
            DSGRUPO,
            CDGRUPO,
            SUM(SALDO_EMP + SALDO_CCH) RISCO
        FROM
            (
                SELECT
                    DSGRUPO,
                    CDGRUPO,
                    SUM(SALDO_EMP) SALDO_EMP,
                    SUM(SALDO_CCH) SALDO_CCH
                FROM
                    (
                        SELECT
                            TO_CHAR(SYSDATE, 'DD/MM/YYYY') DTA_BASE,
                            G.ID_GPSOL AS CDGRUPO,
                            G.DESCR_GRUPO AS DSGRUPO,
                            G.RESPONSAVEL AS CDTITULAR,
                            CG.NOME AS NMTITULAR,
                            C.CONTA AS CDCLIENTE,
                            C.NOME AS NMCLIENTE,
                            FACMUTUO.ACHANIVEL(C.NIVEL) AS NIVEL,
                            DECODE(
                                G.RESPONSAVEL,
                                CC.CONTA,
                                'TITULAR',
                                DECODE(
                                    GA.PARENTESCO,
                                    1,
                                    'FILHO',
                                    2,
                                    'CÔNJUGE',
                                    3,
                                    'PAI/MÃE',
                                    4,
                                    'GUARDA',
                                    5,
                                    'TUTELA',
                                    6,
                                    'ENTEADO',
                                    7,
                                    'NETO',
                                    8,
                                    'IRMÃO',
                                    9,
                                    'MARITAL',
                                    'OUTROS'
                                )
                            ) PARENTESCO,
                            SUM(
                                FACMUTUO.EMPREST.PEGASOSALDO(1, GA.CONTA, SYSDATE)
                            ) SALDO_EMP,
                            SUM(NVL(VALOR, 0)) SALDO_DESC,
                            SUM(NVL(CC.SALDO, 0)) SALDO_CCH
                        FROM
                            FACMUTUO.E_GPSOL G,
                            FACMUTUO.C_CAD CG,
                            FACMUTUO.C_CAD C,
                            FACMUTUO.E_ASSOC_GPSOL GA,
                            (
                                SELECT
                                    CONTA,
                                    SUM(VALOR) VALOR
                                FROM
                                    FACMUTUO.H_CHOPEN
                                WHERE
                                    (
                                        (SITUACAO = 0)
                                        OR (SITUACAO = 3)
                                        OR (
                                            SITUACAO = 2
                                            AND CONTRATO_EMP IS NULL
                                        )
                                    )
                                GROUP BY
                                    CONTA
                            ) CH,
                            (
                                SELECT
                                    DISTINCT CA.CONTA,
                                    SUM(
                                        FACMUTUO.FACCOR_FUNCTIONS.PEGASALDOAD(CA.CONTAC, SYSDATE) + -- AD 
                                        FACMUTUO.FACCOR_FUNCTIONS.LIMITE_CHESP(CA.CONTAC, SYSDATE) -- CHEQUEESP 
                                    ) SALDO
                                FROM
                                    FACMUTUO.CC_CADASSOC CA
                                WHERE
                                    TITULAR = 'T'
                                GROUP BY
                                    CA.CONTA
                            ) CC
                        WHERE
                            G.RESPONSAVEL = CG.CONTA(+)
                            AND G.ID_GPSOL = GA.ID_GPSOL
                            AND GA.CONTA = C.CONTA
                            AND GA.CONTA = CH.CONTA(+)
                            AND GA.CONTA = CC.CONTA(+)
                        GROUP BY
                            G.ID_GPSOL,
                            G.DESCR_GRUPO,
                            G.RESPONSAVEL,
                            CG.NOME,
                            C.CONTA,
                            C.NIVEL,
                            C.NOME,
                            DECODE(
                                G.RESPONSAVEL,
                                CC.CONTA,
                                'TITULAR',
                                DECODE(
                                    GA.PARENTESCO,
                                    1,
                                    'FILHO',
                                    2,
                                    'CÔNJUGE',
                                    3,
                                    'PAI/MÃE',
                                    4,
                                    'GUARDA',
                                    5,
                                    'TUTELA',
                                    6,
                                    'ENTEADO',
                                    7,
                                    'NETO',
                                    8,
                                    'IRMÃO',
                                    9,
                                    'MARITAL',
                                    'OUTROS'
                                )
                            )
                        ORDER BY
                            G.ID_GPSOL
                    )
                GROUP BY
                    DSGRUPO,
                    CDGRUPO
            )
        GROUP BY
            DSGRUPO,
            CDGRUPO
    ) R,
    ----
    (
        SELECT
            CONTAC,
            CREDITO,
            DEBITO
        FROM
            (
                SELECT
                    CONTAC,
                    SUM(CREDITO) CREDITO,
                    SUM(DEBITO) DEBITO
                FROM
                    (
                        (
                            SELECT
                                CONTAC,
                                SUM(VALOR) CREDITO,
                                0 DEBITO
                            FROM
                                FACMUTUO.CC_MVOPEN
                            WHERE
                                DATA BETWEEN '05/09/2023'
                                AND '04/12/2023'
                                AND DC = 'C'
                            GROUP BY
                                CONTAC
                        )
                        UNION
                        ALL (
                            SELECT
                                CONTAC,
                                SUM(VALOR) CREDITO,
                                0 DEBITO
                            FROM
                                FACMUTUO.CC_MVCLOS
                            WHERE
                                DATA BETWEEN '05/09/2023'
                                AND '04/12/2023'
                                AND DC = 'C'
                            GROUP BY
                                CONTAC
                        )
                        UNION
                        ALL (
                            SELECT
                                CONTAC,
                                0 CREDITO,
                                SUM(VALOR) DEBITO
                            FROM
                                FACMUTUO.CC_MVOPEN
                            WHERE
                                DATA BETWEEN '05/09/2023'
                                AND '04/12/2023'
                                AND DC = 'D'
                            GROUP BY
                                CONTAC
                        )
                        UNION
                        ALL (
                            SELECT
                                CONTAC,
                                0 CREDITO,
                                SUM(VALOR) DEBITO
                            FROM
                                FACMUTUO.CC_MVCLOS
                            WHERE
                                DATA BETWEEN '05/09/2023'
                                AND '04/12/2023'
                                AND DC = 'D'
                            GROUP BY
                                CONTAC
                        )
                    )
                GROUP BY
                    CONTAC
            )
        GROUP BY
            CONTAC,
            CREDITO,
            DEBITO
    ) T
WHERE
    CU.CONTA = C.CONTA
    AND CU.COD_SET = S.COD_SET
    AND C.COD_CID = D.COD_CID(+)
    AND C.COD_UNID = S.COD_UNID
    AND C.COD_UNID = U.COD_UNID
    AND C.COD_BAI = B.COD_BAI(+)
    AND C.ASSOCIADO = 'T'
    AND C.AGENTE = E.CONTA(+)
    AND AG.COD_AGENCIA = C.COD_AGENCIA
    AND F.CONTAC = H.CONTAC
    AND H.COD_PACOTE = I.COD_PACOTE
    AND C.SITUACAO = 'Normal'
    AND C.CONTA = F.CONTA
    AND F.TITULAR = 'T'
    AND F.CONTAC = G.CONTAC(+)
    AND F.CONTAC = T.CONTAC(+)
    AND C.CONTA = M.CONTA(+)
    AND C.CONTA = N.CONTA(+)
    AND C.CONTA = O.CONTA(+)
    AND O.ID_GPSOL = P.ID_GPSOL(+)
    AND P.ID_GPSOL = R.CDGRUPO(+)
    AND F.CONTAC = K.CONTAC(+)
    AND C.CPF || C.CGC LIKE '241.408.489-87'
GROUP BY
    G.CONTAC,
    C.CONTA,
    C.MATRICULA,
    C.CPF,
    C.NOME,
    E.APELIDO,
    C.COD_AGENCIA,
    AG.NOME,
    I.DESCRICAO,
    I.COD_PACOTE,
    C.DEMISSAO,
    C.NIVEL,
    C.ADM_COOP,
    C.SITUACAO,
    C.CGC,
    C.FISICA,
    D.NOME,
    C.MOTIVO_DEMISSAO,
    C.NASCIMENTO,
    CU.PROFISSAO,
    CU.SALARIO,
    C.VRFATURAMENTO,
    F.CONTAC,
    M.PATRIMONIO,
    N.CHDEV,
    O.ID_GPSOL,
    P.DESCR_GRUPO,
    R.RISCO,
    T.DEBITO,
    T.CREDITO,
    C.CONJUGUE,
    C.CPFCONJUGE,
    AG.COD_AGENCIA
ORDER BY
    ADM_COOP DESC