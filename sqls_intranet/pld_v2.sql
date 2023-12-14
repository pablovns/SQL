SELECT
    B.CONTA,
    UNI.CONTAC,
    B.NOME AS ASSOCIADO,
    COALESCE(B.CPF, B.CGC) AS CPF_CNPJ,
    MOV.DC,
    COALESCE(B.VRFATURAMENTO, UNI.SALARIO) SALARIO_OU_FATURAMENTO,
    MOV.VALOR VALOR_TOTAL,
    B.PPE,
    A.COD_PERFIL,
    C_PERFIL.DESCRICAO,
    UNI.PROFISSAO,
    GER.APELIDO AS AGENTE,
    B.COD_AGENCIA,
    AG.NOME AGENCIA,
    TO_CHAR(B.ADM_COOP, 'dd/MM/yyyy') AS DATA_ADMISSAO_COOPERATIVA,
    B.DATACAD AS DATA_CADASTRO,
    CASE
        WHEN UNI.PROFISSAO = 'FUNCIONARIO COOPERATIVA' THEN 'SIM'
        WHEN UNI.PROFISSAO = 'FUNCIONARIO CREDICOOPAVEL' THEN 'SIM'
        ELSE 'NÃO'
    END AS E_FUNCIONARIO
FROM
    FACMUTUO.C_CAD B
    INNER JOIN FACMUTUO.C_CAD GER ON B.AGENTE = GER.CONTA
    INNER JOIN FACMUTUO.C_CAD_PERFIL A ON A.CONTA = B.CONTA
    INNER JOIN FACMUTUO.C_PERFIL ON A.COD_PERFIL = C_PERFIL.COD_PERFIL
    LEFT JOIN FACMUTUO.CC_AGENCIA AG ON B.COD_AGENCIA = AG.COD_AGENCIA
    LEFT JOIN FACMUTUO.CC_CADASSOC CC_A ON B.CONTA = CC_A.CONTA
    LEFT JOIN FACMUTUO.C_CADUNI UNI ON B.CONTA = UNI.CONTA
    INNER JOIN (
        SELECT
            CONTAC,
            DC,
            SUM(VALOR) AS VALOR
        FROM
            (
                SELECT
                    CONTAC,
                    DC,
                    DATA,
                    SUM(VALOR) AS VALOR
                FROM
                    FACMUTUO.CC_MVOPEN
                WHERE
                    ESTORNADO = 'F'
                    AND COMPENSADO = 'T'
                    AND COD_LANC NOT IN ('2004', '2016', '4004', '3004')
                    AND DATA BETWEEN '01/11/2023'
                    AND '30/11/2023'
                GROUP BY
                    CONTAC,
                    DC,
                    DATA
                UNION
                SELECT
                    CONTAC,
                    DC,
                    DATA,
                    SUM(VALOR) AS VALOR
                FROM
                    FACMUTUO.CC_MVCLOS
                WHERE
                    ESTORNADO = 'F'
                    AND COMPENSADO = 'T'
                    AND COD_LANC NOT IN ('2004', '2016', '4004', '3004')
                    AND DATA BETWEEN '01/11/2023'
                    AND '30/11/2023'
                GROUP BY
                    CONTAC,
                    DC,
                    DATA
            )
        GROUP BY
            CONTAC,
            DC
    ) MOV ON UNI.CONTAC = MOV.CONTAC
WHERE
    CC_A.TITULAR = 'T'
    AND GER.APELIDO LIKE '%%'
    AND UNI.CONTAC LIKE '%%'
    AND (
        A.COD_PERFIL IN (11, 13, 14, 15)
        OR C_PERFIL.COD_PERFIL IN (11, 13, 14, 15)
    )
    AND (
        (
            INSTR(COALESCE(B.CPF, B.CGC), '/') <= 0
            AND MOV.VALOR > COALESCE(B.VRFATURAMENTO, UNI.SALARIO) * 5
        )
        OR (
            INSTR(COALESCE(B.CPF, B.CGC), '/') > 0
            AND MOV.VALOR > COALESCE(B.VRFATURAMENTO, UNI.SALARIO) / 12 * 5
        )
    )
ORDER BY
    B.NOME