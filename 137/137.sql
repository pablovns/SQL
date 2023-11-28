SELECT
    G.CONTAC,
    C.CONTA,
    C.MATRICULA,
    NVL(C.CPF, C.CGC) CPF,
    C.NOME,
    E.APELIDO AGENTE,
    C.COD_AGENCIA,
    AG.NOME NOMEAGENCIA,
    I.COD_PACOTE,
    I.DESCRICAO PACOTE,
    C.DEMISSAO,
    (
        SELECT
            MIN(AZ.DT_ABERT) DT_ABERT_CC
        FROM
            CC_CAD AZ,
            CC_CADASSOC BZ
        WHERE
            AZ.CONTAC = BZ.CONTAC
            AND BZ.CONTA = C.CONTA
            AND BZ.TITULAR = 'T'
    ) DT_ABERT_CC,
    DECODE(
        C.NIVEL,
        1,
        'AA',
        DECODE(
            C.NIVEL,
            2,
            'A',
            DECODE(
                C.NIVEL,
                3,
                'B',
                DECODE(
                    C.NIVEL,
                    4,
                    'C',
                    DECODE(
                        C.NIVEL,
                        5,
                        'D',
                        DECODE(
                            C.NIVEL,
                            6,
                            'E',
                            DECODE(
                                C.NIVEL,
                                7,
                                'F',
                                DECODE(C.NIVEL, 8, 'G', DECODE(C.NIVEL, 9, 'H', ''))
                            )
                        )
                    )
                )
            )
        )
    ) AS NIVEL,
    C.ADM_COOP,
    C.SITUACAO,
    C.CGC,
    C.FISICA,
    D.NOME CIDADE,
    C.MOTIVO_DEMISSAO,
    C.NASCIMENTO || ' (' || ANOSENTREDATAS(C.NASCIMENTO, SYSDATE) || ')' DT_NASC,
    CU.PROFISSAO,
    NVL(CU.SALARIO, (C.VRFATURAMENTO / 12)) SALARIO,
    (
        SELECT
            SD
        FROM
            A_SDA Y
        WHERE
            Y.CONTA = C.CONTA
            AND Y.ANOMES > '2017/01'
            AND Y.ANOMES = (
                SELECT
                    MAX(ANOMES)
                FROM
                    A_SDA
                WHERE
                    CONTA = C.CONTA
            )
    ) AS SALDO_CAPITAL,
    (
        SELECT
            MAX(X.VALOR)
        FROM
            CC_MVCLOS X
        WHERE
            X.COD_LANC = 4015
            AND X.COMPENSADO = 'T'
            AND X.CONTAC = G.CONTAC
            AND X.DATA = (
                SELECT
                    MAX(DATA)
                FROM
                    CC_MVCLOS
                WHERE
                    COD_LANC = 4015
            )
    ) SALARIO_CREDI
FROM
    C_CAD C,
    C_CADUNI CU,
    C_Unid U,
    C_CIDADE D,
    C_SETOR S,
    C_BAIRRO B,
    C_CAD E,
    CC_AGENCIA AG,
    CC_CADASSOC F,
    CC_CONTA G,
    CC_CAD H,
    CC_PACOTE I
WHERE
    CU.CONTA = C.CONTA
    AND CU.COD_SET = S.COD_SET
    AND C.COD_CID = D.COD_CID (+)
    AND C.COD_UNID = S.COD_UNID
    AND C.COD_UNID = U.COD_UNID
    AND C.COD_BAI = B.COD_BAI(+)
    AND C.ASSOCIADO = 'T'
    AND C.AGENTE = E.CONTA(+)
    AND AG.COD_AGENCIA = C.COD_AGENCIA
    AND F.CONTAC = H.CONTAC
    AND H.COD_PACOTE = I.COD_PACOTE
    AND C.SITUACAO = 'Normal'
    AND C.CONTA = F.CONTA
    AND F.TITULAR = 'T'
    AND F.CONTAC = G.CONTAC (+)
ORDER BY
    ADM_COOP DESC