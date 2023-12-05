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
    E.APELIDO AS AGENTE,
    C.COD_AGENCIA,
    AG.NOME AS NOMEAGENCIA,
    I.COD_PACOTE,
    I.DESCRICAO AS PACOTE,
    C.DEMISSAO,
    AZ.DT_ABERT AS DT_ABERT_CC,
    CASE
        C.NIVEL
        WHEN 1 THEN 'AA'
        WHEN 2 THEN 'A'
        WHEN 3 THEN 'B'
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'D'
        WHEN 6 THEN 'E'
        WHEN 7 THEN 'F'
        WHEN 8 THEN 'G'
        WHEN 9 THEN 'H'
        ELSE ''
    END AS NIVEL,
    C.ADM_COOP,
    C.SITUACAO,
    C.CGC,
    C.FISICA,
    D.NOME AS CIDADE,
    C.MOTIVO_DEMISSAO,
    C.NASCIMENTO AS DT_NASC,
    FACMUTUO.ANOSENTREDATAS(C.NASCIMENTO, SYSDATE) AS IDADE,
    CU.PROFISSAO,
    CU.SALARIO,
    C.VRFATURAMENTO,
    AG.COD_AGENCIA AS UNID,
    Y.SD AS SALDO_CAPITAL,
    K.VLR_LIMITE LIMITE,
    FACMUTUO.FACCOR_FUNCTIONS.LIMITE_CHESP(F.CONTAC, SYSDATE) AS LIM_CHESP,
    M.PATRIMONIO,
    N.CHDEV,

    P.ID_GPSOL,

    P.DESCR_GRUPO,
    R.RISCO,
    T.DEBITO,
    T.CREDITO,
    C.CONJUGUE CONJUGE,
    C.CPFCONJUGE
FROM
    FACMUTUO.C_CAD C
    JOIN FACMUTUO.C_CADUNI CU ON CU.CONTA = C.CONTA
    JOIN FACMUTUO.C_CIDADE D ON C.COD_CID = D.COD_CID
    JOIN FACMUTUO.C_SETOR S ON CU.COD_SET = S.COD_SET
    JOIN FACMUTUO.C_BAIRRO B ON C.COD_BAI = B.COD_BAI
    LEFT JOIN FACMUTUO.C_CAD E ON C.AGENTE = E.CONTA
    JOIN FACMUTUO.CC_AGENCIA AG ON AG.COD_AGENCIA = C.COD_AGENCIA
    JOIN FACMUTUO.CC_CADASSOC F ON C.CONTA = F.CONTA
    AND F.TITULAR = 'T'
    LEFT JOIN FACMUTUO.CC_CONTA G ON F.CONTAC = G.CONTAC
    JOIN FACMUTUO.CC_CAD H ON F.CONTAC = H.CONTAC
    JOIN FACMUTUO.CC_PACOTE I ON H.COD_PACOTE = I.COD_PACOTE
    LEFT JOIN FACMUTUO.E_GPSOL P ON C.CONTA = P.CONTA
    JOIN (
        SELECT
            AZ.CONTAC,
            MIN(AZ.DT_ABERT) AS DT_ABERT
        FROM
            FACMUTUO.CC_CAD AZ
            JOIN FACMUTUO.CC_CADASSOC BZ ON AZ.CONTAC = BZ.CONTAC
        WHERE
            BZ.TITULAR = 'T'
        GROUP BY
            AZ.CONTAC
    ) AZ ON F.CONTAC = AZ.CONTAC
    LEFT JOIN (
        SELECT
            Y.CONTA,
            Y.SD
        FROM
            FACMUTUO.A_SD Y
    ) Y ON Y.CONTA = C.CONTA
    LEFT JOIN (
        SELECT
            K.CONTAC,
            K.ATIVO,
            SUM(K.VLR_LIMITE) AS VLR_LIMITE
        FROM
            FACMUTUO.CC_CARTAO K
        WHERE
            (
                K.ATIVO = '1'
                OR K.ATIVO IS NULL
                OR K.ATIVO = '3'
            )
        GROUP BY
            K.CONTAC,
            K.ATIVO
    ) K ON F.CONTAC = K.CONTAC
    LEFT JOIN (
        SELECT
            CONTA,
            SUM(SOMA) AS PATRIMONIO
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
    ) M ON C.CONTA = M.CONTA
    LEFT JOIN (
        SELECT
            E.CONTA,
            COUNT(*) AS CHDEV
        FROM
            FACMUTUO.CC_CHEQUEC A
            JOIN FACMUTUO.CC_TALAO B ON A.COD_TALAO = B.COD_TALAO
            JOIN FACMUTUO.CC_CADASSOC D ON D.CONTAC = B.CONTAC
            JOIN FACMUTUO.C_CAD E ON E.CONTA = D.CONTA
            JOIN FACMUTUO.CC_AGENCIA C ON E.COD_AGENCIA = C.COD_AGENCIA
            LEFT JOIN FACMUTUO.C_CAD F ON E.AGENTE = F.CONTA
        WHERE
            A.COD_SITUACAO = 9
            AND A.COD_MOTDEV IN(11, 12)
            AND DATA BETWEEN '07/06/2023'
            AND '04/12/2023'
            AND TO_CHAR(D.TITULAR) = 'T'
        GROUP BY
            E.CONTA
    ) N ON C.CONTA = N.CONTA
    LEFT JOIN (
        SELECT
            DSGRUPO,
            CDGRUPO,
            SUM(SALDO_EMP + SALDO_CCH) AS RISCO
        FROM
            (
                SELECT
                    DSGRUPO,
                    CDGRUPO,
                    SUM(SALDO_EMP) AS SALDO_EMP,
                    SUM(SALDO_CCH) AS SALDO_CCH
                FROM
                    (
                        SELECT
                            TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS DTA_BASE,
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
                            ) AS PARENTESCO,
                            SUM(
                                FACMUTUO.EMPREST.PEGASOSALDO(1, GA.CONTA, SYSDATE)
                            ) AS SALDO_EMP,
                            SUM(NVL(VALOR, 0)) AS SALDO_DESC,
                            SUM(NVL(CC.SALDO, 0)) AS SALDO_CCH
                        FROM
                            FACMUTUO.E_GPSOL G
                            LEFT JOIN FACMUTUO.C_CAD CG ON G.RESPONSAVEL = CG.CONTA
                            LEFT JOIN FACMUTUO.E_ASSOC_GPSOL GA ON G.ID_GPSOL = GA.ID_GPSOL
                            LEFT JOIN FACMUTUO.C_CAD C ON GA.CONTA = C.CONTA
                            LEFT JOIN FACMUTUO.H_CHOPEN CH ON GA.CONTA = CH.CONTA
                            LEFT JOIN (
                                SELECT
                                    DISTINCT CA.CONTA,
                                    SUM(
                                        FACMUTUO.FACCOR_FUNCTIONS.PEGASALDOAD(CA.CONTAC, SYSDATE) + FACMUTUO.FACCOR_FUNCTIONS.LIMITE_CHESP(CA.CONTAC, SYSDATE)
                                    ) AS SALDO
                                FROM
                                    FACMUTUO.CC_CADASSOC CA
                                WHERE
                                    TITULAR = 'T'
                                GROUP BY
                                    CA.CONTA
                            ) CC ON GA.CONTA = CC.CONTA
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
                    )
                GROUP BY
                    DSGRUPO,
                    CDGRUPO
            )
        GROUP BY
            DSGRUPO,
            CDGRUPO
    ) R ON P.ID_GPSOL = R.CDGRUPO
    LEFT JOIN (
        SELECT
            CONTAC,
            CREDITO,
            DEBITO
        FROM
            (
                SELECT
                    CONTAC,
                    SUM(CREDITO) AS CREDITO,
                    SUM(DEBITO) AS DEBITO
                FROM
                    (
                        SELECT
                            CONTAC,
                            SUM(VALOR) AS CREDITO,
                            0 AS DEBITO
                        FROM
                            FACMUTUO.CC_MVOPEN
                        WHERE
                            DATA BETWEEN '05/09/2023'
                            AND '04/12/2023'
                            AND DC = 'C'
                        GROUP BY
                            CONTAC
                        UNION
                        ALL
                        SELECT
                            CONTAC,
                            SUM(VALOR) AS CREDITO,
                            0 AS DEBITO
                        FROM
                            FACMUTUO.CC_MVCLOS
                        WHERE
                            DATA BETWEEN '05/09/2023'
                            AND '04/12/2023'
                            AND DC = 'C'
                        GROUP BY
                            CONTAC
                        UNION
                        ALL
                        SELECT
                            CONTAC,
                            0 AS CREDITO,
                            SUM(VALOR) AS DEBITO
                        FROM
                            FACMUTUO.CC_MVOPEN
                        WHERE
                            DATA BETWEEN '05/09/2023'
                            AND '04/12/2023'
                            AND DC = 'D'
                        GROUP BY
                            CONTAC
                        UNION
                        ALL
                        SELECT
                            CONTAC,
                            0 AS CREDITO,
                            SUM(VALOR) AS DEBITO
                        FROM
                            FACMUTUO.CC_MVCLOS
                        WHERE
                            DATA BETWEEN '05/09/2023'
                            AND '04/12/2023'
                            AND DC = 'D'
                        GROUP BY
                            CONTAC
                    )
                GROUP BY
                    CONTAC
            )
        GROUP BY
            CONTAC,
            CREDITO,
            DEBITO
    ) T ON F.CONTAC = T.CONTAC
WHERE
    C.ASSOCIADO = 'T'
    AND C.SITUACAO = 'Normal'
    AND C.CPF || C.CGC LIKE '020.013.849-98'
ORDER BY
    ADM_COOP DESC