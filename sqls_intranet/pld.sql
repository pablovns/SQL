SELECT
    COUNT(*)
FROM
    (
        SELECT
            *
        FROM
            (
                SELECT
                    consultaFinal.*,
                    D.NOME AS AGENCIA,
                    CASE
                        WHEN PROFISSAO = 'FUNCIONARIO COOPERATIVA' THEN 'SIM'
                        WHEN PROFISSAO = 'FUNCIONARIO CREDICOOPAVEL' THEN 'SIM'
                        ELSE 'NÃO'
                    END AS E_FUNCIONARIO
                FROM
                    (
                        SELECT
                            CONTA,
                            subquery1.CONTAC,
                            DC,
                            COALESCE(FATURAMENTO, SALARIO) AS SALARIO_OU_FATURAMENTO,
                            VALOR_TOTAL,
                            ASSOCIADO,
                            PPE,
                            AGENTE,
                            CPF_CNPJ,
                            COD_PERFIL,
                            DESCRICAO,
                            PROFISSAO,
                            DATA_ADMISSAO_COOPERATIVA,
                            DATA_CADASTRO,
                            COD_AGENCIA
                        FROM
                            (
                                SELECT
                                    CONTAC,
                                    DC,
                                    SUM(VALOR) AS VALOR_TOTAL
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
                                            AND COD_LANC != '2016'
                                            AND COD_LANC != '4004'
                                            AND COD_LANC != '3004'
                                            AND DATA BETWEEN '01/09/2023'
                                            AND '30/09/2023'
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
                                            AND COD_LANC != '2016'
                                            AND COD_LANC != '4004'
                                            AND COD_LANC != '3004'
                                            AND DATA BETWEEN '01/09/2023'
                                            AND '30/09/2023'
                                        GROUP BY
                                            CONTAC,
                                            DC,
                                            DATA
                                    )
                                GROUP BY
                                    CONTAC,
                                    DC
                            ) subquery1
                            INNER JOIN (
                                SELECT
                                    C.CONTAC,
                                    C.CONTA,
                                    subquery2.PPE,
                                    AGENTE,
                                    subquery2.CPF_CNPJ,
                                    C.SALARIO,
                                    subquery2.VRFATURAMENTO AS FATURAMENTO,
                                    C.PROFISSAO,
                                    subquery2.COD_PERFIL,
                                    subquery2.DESCRICAO,
                                    subquery2.ASSOCIADO,
                                    subquery2.COD_AGENCIA,
                                    subquery2.DATA_ADMISSAO_COOPERATIVA,
                                    subquery2.DATA_CADASTRO
                                FROM
                                    FACMUTUO.C_CADUNI C
                                    INNER JOIN (
                                        SELECT
                                            PPE,
                                            consultaConta.CONTA,
                                            consultaApelido.APELIDO AS AGENTE,
                                            VRFATURAMENTO,
                                            CPF_CNPJ,
                                            COD_PERFIL,
                                            DESCRICAO,
                                            ASSOCIADO,
                                            COD_AGENCIA,
                                            DATA_ADMISSAO_COOPERATIVA,
                                            DATA_CADASTRO
                                        FROM
                                            (
                                                SELECT
                                                    B.PPE,
                                                    B.CONTA,
                                                    B.VRFATURAMENTO,
                                                    B.CPF || B.CGC AS CPF_CNPJ,
                                                    subquery.COD_PERFIL,
                                                    subquery.DESCRICAO,
                                                    B.NOME AS ASSOCIADO,
                                                    B.COD_AGENCIA,
                                                    TO_CHAR(B.ADM_COOP, 'dd/MM/yyyy') AS DATA_ADMISSAO_COOPERATIVA,
                                                    B.DATACAD AS DATA_CADASTRO
                                                FROM
                                                    FACMUTUO.C_CAD B
                                                    INNER JOIN (
                                                        SELECT
                                                            A.CONTA,
                                                            A.COD_PERFIL,
                                                            C_PERFIL.DESCRICAO
                                                        FROM
                                                            FACMUTUO.C_CAD_PERFIL A
                                                            INNER JOIN FACMUTUO.C_PERFIL ON A.COD_PERFIL = C_PERFIL.COD_PERFIL
                                                            -- if (!string.IsNullOrEmpty(pRiscoAlto)) {
                                                        WHERE
                                                            A.COD_PERFIL IN (11, 13, 14, 15)
                                                            OR C_PERFIL.COD_PERFIL IN (11, 13, 14, 15)
                                                            -- }
                                                            -- if (!string.IsNullOrEmpty(pRiscoBaixo)) {
                                                            -- WHERE
                                                            --     A.COD_PERFIL = 16
                                                            --     OR C_PERFIL.COD_PERFIL = 16
                                                            -- }
                                                            -- if (!string.IsNullOrEmpty(pAcimaCinquenta)) {
                                                            --     WHERE
                                                            --         A.COD_PERFIL IN (11, 13, 14, 15, 16)
                                                            --         OR C_PERFIL.COD_PERFIL IN (11, 13, 14, 15, 16)
                                                            -- }
                                                    ) subquery ON B.CONTA = subquery.CONTA
                                            ) consultaConta
                                            INNER JOIN (
                                                SELECT
                                                    A.CONTA,
                                                    B.APELIDO
                                                FROM
                                                    FACMUTUO.C_CAD A
                                                    LEFT JOIN FACMUTUO.C_CAD B ON A.AGENTE = B.CONTA
                                            ) consultaApelido ON consultaConta.CONTA = consultaApelido.CONTA
                                    ) subquery2 ON C.CONTA = subquery2.CONTA
                            ) consultaJuncao ON subquery1.CONTAC = consultaJuncao.CONTAC
                        WHERE
                            (
                                (
                                    INSTR(CPF_CNPJ, '/') <= 0
                                    AND VALOR_TOTAL > SALARIO * 4
                                ) -- Verificando se é pessoa física e o VALOR_TOTAL é maior que 4 * o SALARIO
                                OR (
                                    INSTR(CPF_CNPJ, '/') > 0
                                    AND VALOR_TOTAL > FATURAMENTO / 12 * 4
                                ) -- Verificando se é pessoa jurídica e o VALOR_TOTAL é maior que o faturamento por mês * 4
                                -- OR VALOR_TOTAL > 50000
                            )
                    ) consultaFinal
                    INNER JOIN CC_AGENCIA D ON consultaFinal.COD_AGENCIA = D.COD_AGENCIA
                    INNER JOIN (
                        SELECT
                            CONTA AS CONTA1,
                            TITULAR
                        FROM
                            FACMUTUO.CC_CADASSOC D
                        WHERE
                            TITULAR = 'T'
                    ) queryTitular ON consultaFinal.CONTA = queryTitular.CONTA1
                ORDER BY
                    ASSOCIADO
            )
        WHERE
            AGENTE LIKE '%%'
            AND CONTAC LIKE '%%'
        GROUP BY
            CONTA,
            CONTAC,
            DC,
            SALARIO_OU_FATURAMENTO,
            VALOR_TOTAL,
            ASSOCIADO,
            PPE,
            AGENTE,
            CPF_CNPJ,
            COD_PERFIL,
            DESCRICAO,
            PROFISSAO,
            DATA_ADMISSAO_COOPERATIVA,
            DATA_CADASTRO,
            COD_AGENCIA,
            AGENCIA,
            E_FUNCIONARIO
        ORDER BY
            ASSOCIADO
    )