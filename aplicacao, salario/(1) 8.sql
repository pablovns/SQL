SELECT
    D.CONTA,
    E.CPF,
    E.DEMISSAO,
    SUBSTR(DT_ABERT, 4, 7) ANOMES,
    a.contac,
    TRIM(RPAD(b.titular, 40)) TITULAR,
    a.dt_abert,
    1 total,
    A.COD_AGENCIA,
    C.NOME AS AGENCIA,
    RPAD((a.cod_agencia || '  -  ' || c.nome), 40) agencia,
    F.NOME AS AGENTE,
    0 NR_ATA,
    ' ' FUNC_COOP,
    ' ' DTA_REUNIAO,
    CASE
        WHEN E.FISICA = 'J' THEN 'PESSOA JURÍDICA'
        ELSE G.PROFISSAO
    END PROFISSAO,
    G.SALARIO,
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
    a.contac = b.contac(+)
    AND a.cod_agencia = c.cod_agencia(+)
    AND A.CONTAC = D.CONTAC(+)
    AND D.CONTA = E.CONTA(+)
    AND E.CONTA = G.CONTA
    AND E.AGENTE = F.CONTA(+)
    AND D.TITULAR = 'T'