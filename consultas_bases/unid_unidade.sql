SELECT
    C.CONTA,
    C.NOME AS ASSOCIADO,
    C.COD_AGENCIA UNID,
    AG.NOME UNIDADE
FROM
    FACMUTUO.C_CAD C
    LEFT JOIN CC_AGENCIA AG
    ON C.COD_AGENCIA = AG.COD_AGENCIA
