SELECT
    C.CONTA,
    GER.APELIDO AGENTE
FROM
    FACMUTUO.C_CAD C
    LEFT JOIN FACMUTUO.C_CAD GER ON C.AGENTE = GER.CONTA