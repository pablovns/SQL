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
            DATA BETWEEN '01/08/2023'
            AND '31/08/2023'
        GROUP BY
            CONTAC,
            DC,
            DATA
        UNION
        SELECT
            CONTAC,
            DC,
            DATA,
            --SUM(VALOR) AS VALOR
            VALOR
        FROM
            FACMUTUO.CC_MVCLOS
        WHERE
            DATA BETWEEN '01/08/2023'
            AND '31/08/2023'
            AND CONTAC LIKE '015365-6' --GROUP BY
            --CONTAC,
            --DC,
            --DATA
    )
GROUP BY
    CONTAC,
    DC