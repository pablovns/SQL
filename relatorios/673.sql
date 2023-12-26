SELECT
    C.CONTA,
    COALESCE(C.CPF, C.CGC) CPF_CNPJ,
    C.NOME ASSOCIADO,
    MOV.CONTAC,
    MOV.VALOR,
    MOV.DATA
FROM
    (
        SELECT
            *
        FROM
            CC_MVOPEN
        WHERE
            COD_LANC = '1024'
            AND ESTORNADO = 'F'
            AND DATA BETWEEN :1DATA_INI AND :2DATA_FIM
        UNION
        ALL
        SELECT
            *
        FROM
            CC_MVCLOS
        WHERE
            COD_LANC = '1024'
            AND ESTORNADO = 'F'
            AND DATA BETWEEN :1DATA_INI AND :2DATA_FIM
    ) MOV
    LEFT JOIN CC_CADASSOC CC_A ON MOV.CONTAC = CC_A.CONTAC AND CC_A.TITULAR = 'T'
    LEFT JOIN C_CAD C ON CC_A.CONTA = C.CONTA
ORDER BY
    ASSOCIADO,
    DATA,
    VALOR DESC