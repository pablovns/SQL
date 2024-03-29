SELECT CONTA, NOME, CPF, UPPER(NACIONALIDADE) AS NACIONALIDADE
FROM C_CAD INNER JOIN (
    SELECT CONTA AS CONTA1, TITULAR FROM CC_CADASSOC D
) queryTitular
ON CONTA = queryTitular.CONTA1
WHERE UPPER(NACIONALIDADE) NOT LIKE '%LEIR%'
AND UPPER(NACIONALIDADE) NOT LIKE '%ELIRO%'
AND TITULAR = 'T'
AND DEMISSAO IS NULL
ORDER BY NOME
