SELECT
    B.CONTA,
    SUM(A.SALDO) VLR_VCTO,
    (
        SELECT
            MAX(TO_DATE('30/07/2023') - Z.VENC_FIM)
        FROM
            FACMUTUO.E_CTOPEN Z,
            FACMUTUO.C_CAD W,
            FACMUTUO.E_CART Y,
            FACMUTUO.E_PRODUTO V,
            FACMUTUO.E_LF K,
            FACMUTUO.C_CAD S,
            FACMUTUO.CC_AGENCIA T
        WHERE
            TO_DATE('30/07/2023') - Z.VENC_FIM >= 1
            AND SUBSTR(Z.CONTRATO, 10, 3) <> '000'
            AND Z.PARC_GER >= Z.NUM_PARC
            AND Z.PGTO_FIM >= Z.VENC_FIM
            AND Z.SALDO > 0
            AND Y.COD_CART = Z.COD_CART
            AND K.COD_LF = Z.COD_LF
            AND V.COD_PRODUTO = K.COD_PRODUTO
            AND Z.CONTA = W.CONTA
            AND ((W.SITUACAO = 'Normal') OR (W.SITUACAO = 'Afastado') OR (substr(W.SITUACAO, 1, 3) = 'Dem') OR (W.SITUACAO = 'Inativo'))
            AND W.AGENTE = S.CONTA
            AND W.COD_AGENCIA = T.COD_AGENCIA
            AND W.CONTA = B.CONTA
    ) AS DIAS
FROM
    FACMUTUO.E_CTOPEN A,
    FACMUTUO.C_CAD B
WHERE
    TO_DATE('30/07/2023') - A.VENC_FIM >= 1
    AND SUBSTR(A.CONTRATO, 10, 3) <> '000'
    AND A.PARC_GER >= A.NUM_PARC
    AND A.PGTO_FIM >= A.VENC_FIM
    AND A.SALDO > 0
    AND A.CONTA = B.CONTA
    AND ((B.SITUACAO = 'Normal') OR (B.SITUACAO = 'Afastado') OR (substr(B.SITUACAO, 1, 3) = 'Dem') OR (B.SITUACAO = 'Inativo'))
GROUP BY
    B.CONTA