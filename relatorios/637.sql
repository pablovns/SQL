SELECT
    CC.CONTAC,
    C.CONTA,
    C.CPF,
    C.NOME ASSOCIADO,
    C.PPE,
    C.COD_AGENCIA UNID,
    AG.NOME UNIDADE,
    GER.APELIDO AGENTE,
    CC.COD_PACOTE,
    PAC.DESCRICAO PACOTE,
    B.CARGO,
    B.PROFISSAO,
    C.ADM_COOP,
    PF2.COD_PERFIL,
    PF2.DESCRICAO
FROM
    C_CAD C
    LEFT JOIN C_CADUNI B ON C.CONTA = B.CONTA
    LEFT JOIN C_CAD_PERFIL PF1 ON C.CONTA = PF1.CONTA
    LEFT JOIN C_PERFIL PF2 ON PF1.COD_PERFIL = PF2.COD_PERFIL
    LEFT JOIN CC_AGENCIA AG ON C.COD_AGENCIA = AG.COD_AGENCIA
    LEFT JOIN FACMUTUO.C_CAD GER ON C.AGENTE = GER.CONTA
    LEFT JOIN FACMUTUO.CC_CADASSOC CC_A ON C.CONTA = CC_A.CONTA
    LEFT JOIN FACMUTUO.CC_CAD CC ON CC_A.CONTAC = CC.CONTAC
    LEFT JOIN FACMUTUO.CC_PACOTE PAC ON CC.COD_PACOTE = PAC.COD_PACOTE
WHERE
    C.PPE = 'T'
    -- AND C.ASSOCIADO = 'T'
ORDER BY
    C.NOME