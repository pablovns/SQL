-- COLUNA 'SALARIO_CREDI' NO 137 ORIGINAL
SELECT
    MV.CONTAC,
    MV.VALOR
FROM
    CC_MVCLOS MV
    JOIN (
        SELECT
            CONTAC,
            MAX(DATA) AS MAX_DATA
        FROM
            CC_MVCLOS
        WHERE
            COD_LANC = 4015
            AND COMPENSADO = 'T'
        GROUP BY
            CONTAC
    ) maioresDatas ON MV.CONTAC = maioresDatas.CONTAC
    AND MV.DATA = maioresDatas.MAX_DATA
WHERE
    MV.COD_LANC = 4015
    AND MV.COMPENSADO = 'T'