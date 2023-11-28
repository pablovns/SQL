SELECT
    queryDados.CONTA,
    queryDados.CONTAC,
    queryDados.CPF_CNPJ,
    queryDados.TITULAR,
    queryDados.PROFISSAO,
    querySalarioOuFaturamento.SALARIO_FATURAMENTO,
    queryAplicacao.VALOR_TOTAL APLICACAO_TOTAL,
    queryDados.ANOMES,
    queryDados.DT_ABERT,
    queryDados.AGENCIA,
    queryDados.AGENTE,
    queryDados.DT_SAL,
    queryDados.TIPO
FROM
    (
        SELECT
            CONTA,
            VALOR_ABERTO,
            VALOR_FECHADO,
            VALOR_ABERTO + VALOR_FECHADO AS VALOR_TOTAL
        FROM
            (
                SELECT
                    COALESCE(queryAberto.CONTA, queryFechado.CONTA) CONTA,
                    COALESCE(queryAberto.VALOR_ABERTO, 0) AS VALOR_ABERTO,
                    COALESCE(queryFechado.VALOR_FECHADO, 0) AS VALOR_FECHADO
                FROM
                    (
                        SELECT
                            CONTA,
                            SUM(VALOR) AS VALOR_ABERTO
                        FROM
                            A_MVOPEN
                        WHERE
                            COD_LANC = '202'
                        GROUP BY
                            CONTA
                    ) queryAberto FULL
                    OUTER JOIN (
                        SELECT
                            CONTA,
                            SUM(VALOR) AS VALOR_FECHADO
                        FROM
                            A_MVCLOS
                        WHERE
                            COD_LANC = '202'
                        GROUP BY
                            CONTA
                    ) queryFechado ON queryAberto.CONTA = queryFechado.CONTA
            )
        ORDER BY
            VALOR_ABERTO DESC,
            VALOR_FECHADO DESC
    ) queryAplicacao
    LEFT JOIN (
        SELECT
            D.CONTA,
            E.CPF || E.CGC AS CPF_CNPJ,
            SUBSTR(a.DT_ABERT, 4, 7) ANOMES,
            a.CONTAC,
            TRIM(RPAD(b.titular, 40)) TITULAR,
            a.DT_ABERT,
            RPAD((a.cod_agencia || '  -  ' || c.nome), 40) AGENCIA,
            F.APELIDO AS AGENTE,
            CASE
                WHEN E.FISICA = 'J' THEN 'PESSOA JURÍDICA'
                ELSE G.PROFISSAO
            END PROFISSAO,
            G.DT_SAL,
            E.FISICA TIPO
        FROM
            cc_cad a,
            cc_conta b,
            cc_agencia c,
            CC_CADASSOC D,
            C_CAD E,
            C_CAD F,
            C_CADUNI G
        WHERE
            a.CONTAC = b.CONTAC(+)
            AND a.COD_AGENCIA = c.COD_AGENCIA(+)
            AND a.DT_ABERT BETWEEN '01/08/2023'
            AND '31/08/2023'
            AND A.CONTAC = D.CONTAC(+)
            AND D.CONTA = E.CONTA(+)
            AND E.CONTA = G.CONTA
            AND E.AGENTE = F.CONTA(+)
            AND D.TITULAR = 'T'
    ) queryDados ON queryAplicacao.CONTA = queryDados.CONTA
    LEFT JOIN (
        SELECT
            Y.CONTA,
            COALESCE(Y.VRFATURAMENTO, Z.SALARIO) AS SALARIO_FATURAMENTO --PEGA O FATURAMENTO SE TIVER, CASO CONTRÁRIO PEGA O SALÁRIO EM CADASTROS QUE TENHAM AMBOS, SERÁ CONSIDERADO O FATURAMENTO (DA CONTA PJ ABERTA NA CREDI)
        FROM
            C_CAD Y
            INNER JOIN C_CADUNI Z ON Y.CONTA = Z.CONTA
    ) querySalarioOuFaturamento ON queryDados.CONTA = querySalarioOuFaturamento.CONTA
WHERE
    PROFISSAO NOT LIKE 'FUNCIONARI%'