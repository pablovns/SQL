SELECT
    G.CONTAC,
    C.CONTA,
    COALESCE(
        REPLACE(REPLACE(C.CPF, '.', ''), '-', ''),
        REPLACE(
            REPLACE(REPLACE(C.CGC, '.', ''), '-', ''),
            '/',
            ''
        )
    ) CPF_CNPJ,
    C.NOME,
    C.DEMISSAO,
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
    C.FISICA,
    C.MOTIVO_DEMISSAO,
    C.NASCIMENTO DT_NASC,
    FACMUTUO.ANOSENTREDATAS(C.NASCIMENTO, SYSDATE) AS IDADE,
    CU.PROFISSAO,
    CU.SALARIO,
    C.VRFATURAMENTO,
    Y.SD SALDO_CAPITAL,
    K.VLR_LIMITE LIMITE,
    FACMUTUO.FACCOR_FUNCTIONS.LIMITE_CHESP(F.CONTAC, SYSDATE) AS LIM_CHESP,
    M.PATRIMONIO,
    N.CHDEV,
    P.DESCR_GRUPO,
    R.RISCO,
    T.DEBITO,
    T.CREDITO,
    C.CONJUGUE,
    C.CPFCONJUGE
FROM
    FACMUTUO.C_CAD C
    LEFT JOIN FACMUTUO.C_CADUNI CU ON CU.CONTA = C.CONTA
    LEFT JOIN FACMUTUO.CC_CADASSOC F ON C.CONTA = F.CONTA
    AND F.TITULAR = 'T'
    LEFT JOIN FACMUTUO.CC_CONTA G ON F.CONTAC = G.CONTAC
    LEFT JOIN FACMUTUO.E_ASSOC_GPSOL O ON C.CONTA = O.CONTA
    LEFT JOIN FACMUTUO.E_GPSOL P ON O.ID_GPSOL = P.ID_GPSOL
    LEFT JOIN FACMUTUO.A_SD Y ON C.CONTA = Y.CONTA
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
            INNER JOIN FACMUTUO.CC_TALAO B ON A.COD_TALAO = B.COD_TALAO
            INNER JOIN FACMUTUO.CC_CADASSOC D ON D.CONTAC = B.CONTAC
            INNER JOIN FACMUTUO.C_CAD E ON E.CONTA = D.CONTA
        WHERE
            A.COD_SITUACAO = 9
            AND A.COD_MOTDEV IN(11, 12)
            AND A.DATA BETWEEN '07/06/2023'
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
                    G.ID_GPSOL AS CDGRUPO,
                    G.DESCR_GRUPO AS DSGRUPO,
                    SUM(
                        FACMUTUO.EMPREST.PEGASOSALDO(1, GA.CONTA, SYSDATE)
                    ) AS SALDO_EMP,
                    SUM(NVL(CC.SALDO, 0)) AS SALDO_CCH
                FROM
                    FACMUTUO.E_GPSOL G
                    INNER JOIN FACMUTUO.E_ASSOC_GPSOL GA ON G.ID_GPSOL = GA.ID_GPSOL
                    INNER JOIN (
                        SELECT
                            DISTINCT CA.CONTA,
                            SUM(
                                FACMUTUO.FACCOR_FUNCTIONS.PEGASALDOAD(CA.CONTAC, SYSDATE) + FACMUTUO.FACCOR_FUNCTIONS.LIMITE_CHESP(CA.CONTAC, SYSDATE)
                            ) AS SALDO
                        FROM
                            FACMUTUO.CC_CADASSOC CA
                            LEFT JOIN FACMUTUO.E_ASSOC_GPSOL GP ON CA.CONTA = GP.CONTA
                            INNER JOIN (
                                SELECT
                                    GP.ID_GPSOL
                                FROM
                                    FACMUTUO.E_ASSOC_GPSOL GP
                                    LEFT JOIN FACMUTUO.C_CAD C ON GP.CONTA = C.CONTA
                                WHERE
                                    C.CPF || C.CGC LIKE '899.955.039-72'
                            ) F_GP ON GP.ID_GPSOL = F_GP.ID_GPSOL -- FILTRO POR DOCUMENTO NA SOMA PRA OTIMIZAR O TEMPO DE EXECUÇÃO
                            -- SOMA APENAS OS SALDOS DE QUEM PERTENCE AO GRUPO SOLIDARIO DA PESSOA COM O DOCUMENTO INFORMADO ACIMA
                        WHERE
                            CA.TITULAR = 'T'
                        GROUP BY
                            CA.CONTA
                    ) CC ON GA.CONTA = CC.CONTA
                GROUP BY
                    G.ID_GPSOL,
                    G.DESCR_GRUPO,
                    G.RESPONSAVEL
            )
        GROUP BY
            DSGRUPO,
            CDGRUPO
    ) R ON P.ID_GPSOL = R.CDGRUPO
    LEFT JOIN (
        SELECT
            CONTAC,
            SUM(CREDITO) AS CREDITO,
            SUM(DEBITO) AS DEBITO
        FROM
            (
                SELECT
                    MVO.CONTAC,
                    SUM(MVO.VALOR) AS CREDITO,
                    0 AS DEBITO
                FROM
                    FACMUTUO.CC_MVOPEN MVO
                    INNER JOIN FACMUTUO.CC_CADASSOC CC_A ON MVO.CONTAC = CC_A.CONTAC AND CC_A.CONTAC LIKE '016612-0'
                    INNER JOIN FACMUTUO.C_CAD C ON CC_A.CONTA = C.CONTA AND C.CPF || C.CGC LIKE '899.955.039-72'
                WHERE
                    MVO.DATA BETWEEN '05/09/2023'
                    AND '04/12/2023'
                    AND MVO.DC = 'C'
                GROUP BY
                    MVO.CONTAC
                UNION
                ALL
                SELECT
                    MVC.CONTAC,
                    SUM(MVC.VALOR) AS CREDITO,
                    0 AS DEBITO
                FROM
                    FACMUTUO.CC_MVCLOS MVC
                    INNER JOIN FACMUTUO.CC_CADASSOC CC_A ON MVC.CONTAC = CC_A.CONTAC AND CC_A.CONTAC LIKE '016612-0'
                    INNER JOIN FACMUTUO.C_CAD C ON CC_A.CONTA = C.CONTA AND C.CPF || C.CGC LIKE '899.955.039-72'
                WHERE
                    MVC.DATA BETWEEN '05/09/2023'
                    AND '04/12/2023'
                    AND MVC.DC = 'C'
                GROUP BY
                    MVC.CONTAC
                UNION
                ALL
                SELECT
                    MVO.CONTAC,
                    0 AS CREDITO,
                    SUM(MVO.VALOR) AS DEBITO
                FROM
                    FACMUTUO.CC_MVOPEN MVO
                    INNER JOIN FACMUTUO.CC_CADASSOC CC_A ON MVO.CONTAC = CC_A.CONTAC AND CC_A.CONTAC LIKE '016612-0'
                    INNER JOIN FACMUTUO.C_CAD C ON CC_A.CONTA = C.CONTA AND C.CPF || C.CGC LIKE '899.955.039-72'
                WHERE
                    MVO.DATA BETWEEN '05/09/2023'
                    AND '04/12/2023'
                    AND MVO.DC = 'D'
                GROUP BY
                    MVO.CONTAC
                UNION
                ALL
                SELECT
                    MVC.CONTAC,
                    0 AS CREDITO,
                    SUM(MVC.VALOR) AS DEBITO
                FROM
                    FACMUTUO.CC_MVCLOS MVC
                    INNER JOIN FACMUTUO.CC_CADASSOC CC_A ON MVC.CONTAC = CC_A.CONTAC AND CC_A.CONTAC LIKE '016612-0'
                    INNER JOIN FACMUTUO.C_CAD C ON CC_A.CONTA = C.CONTA AND C.CPF || C.CGC LIKE '899.955.039-72'
                WHERE
                    MVC.DATA BETWEEN '05/09/2023'
                    AND '04/12/2023'
                    AND MVC.DC = 'D'
                GROUP BY
                    MVC.CONTAC
            )
        GROUP BY
            CONTAC
    ) T ON F.CONTAC = T.CONTAC
WHERE
    C.ASSOCIADO = 'T'
    AND C.SITUACAO = 'Normal'
    AND C.CPF || C.CGC LIKE '899.955.039-72'
    AND G.CONTAC LIKE '016612-0'
ORDER BY
    C.NOME