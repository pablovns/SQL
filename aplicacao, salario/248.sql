SELECT
    *
FROM
    (
        SELECT
            A1.CONTA,
            A1.NOME,
            A1.ADM_COOP,
            A1.TIPO,
            A1.VALOR,
            A2.SALDO_ATUAL,
            A1.APELIDO,
            A1.UNID,
            A3.PROFISSAO
        FROM
            (
                SELECT
                    CONTA,
                    NOME,
                    ADM_COOP,
                    'CAPITAL SALDO ATUAL COM LANC. ABERTOS' AS TIPO,
                    SUM(VALORCTB) VALOR,
                    APELIDO,
                    UNID
                FROM
                    (
                        SELECT
                            0 tipo,
                            C.COD_SET,
                            E.NOME,
                            A.ORDEM,
                            A.VALOR,
                            E.ADM_COOP,
                            A.CONTA,
                            A.COD_LANC,
                            A.DATA,
                            E.COD_AGENCIA UNID,
                            B.DESCRICAO,
                            B.CREDITO,
                            A.COMPLEMENTO,
                            CASE
                                WHEN CREDITO = 'T' THEN VALOR
                                ELSE VALOR * -1
                            END VALORCTB,
                            F.APELIDO
                        FROM
                            A_MVCLOS A,
                            A_CODIGO B,
                            C_CADUNI C,
                            C_SETOR D,
                            C_CAD E,
                            C_CAD F
                        WHERE
                            A.COD_LANC = B.COD_LANC
                            AND A.CONTA = C.CONTA
                            AND A.CONTA = E.CONTA
                            AND C.COD_UNID = D.COD_UNID
                            AND C.COD_SET = D.COD_SET
                            AND E.AGENTE = F.CONTA
                            AND E.DEMISSAO IS NULL
                        UNION
                        ALL
                        SELECT
                            1 tipo,
                            C.COD_SET,
                            E.NOME,
                            CHAVE ORDEM,
                            A.VALOR,
                            E.ADM_COOP,
                            A.CONTA,
                            A.COD_LANC,
                            A.DATA,
                            E.COD_AGENCIA UNID,
                            B.DESCRICAO,
                            B.CREDITO,
                            A.COMPLEMENTO,
                            CASE
                                WHEN CREDITO = 'T' THEN VALOR
                                ELSE VALOR * -1
                            END VALORCTB,
                            F.APELIDO
                        FROM
                            A_MVOPEN A,
                            A_CODIGO B,
                            C_CADUNI C,
                            C_SETOR D,
                            C_CAD E,
                            C_CAD F
                        WHERE
                            A.COD_LANC = B.COD_LANC
                            AND A.CONTA = C.CONTA
                            AND A.CONTA = E.CONTA
                            AND C.COD_UNID = D.COD_UNID
                            AND C.COD_SET = D.COD_SET
                            AND E.AGENTE = F.CONTA
                            AND E.DEMISSAO IS NULL
                    )
                GROUP BY
                    CONTA,
                    NOME,
                    ADM_COOP,
                    APELIDO,
                    UNID
                UNION
                ALL
                SELECT
                    CONTA,
                    NOME,
                    ADM_COOP,
                    'LANÇAMENTOS ABERTOS *' AS TIPO,
                    SUM(VALORCTB) AS VALOR,
                    APELIDO,
                    UNID
                FROM
                    (
                        SELECT
                            1 tipo,
                            C.COD_SET,
                            E.NOME,
                            CHAVE ORDEM,
                            A.VALOR,
                            E.ADM_COOP,
                            A.CONTA,
                            A.COD_LANC,
                            A.DATA,
                            E.COD_AGENCIA UNID,
                            B.DESCRICAO,
                            B.CREDITO,
                            A.COMPLEMENTO,
                            CASE
                                WHEN CREDITO = 'T' THEN VALOR
                                ELSE VALOR * -1
                            END VALORCTB,
                            F.APELIDO
                        FROM
                            A_MVOPEN A,
                            A_CODIGO B,
                            C_CADUNI C,
                            C_SETOR D,
                            C_CAD E,
                            C_CAD F
                        WHERE
                            A.COD_LANC = B.COD_LANC
                            AND A.CONTA = C.CONTA
                            AND A.CONTA = E.CONTA
                            AND C.COD_UNID = D.COD_UNID
                            AND C.COD_SET = D.COD_SET
                            AND E.AGENTE = F.CONTA
                            AND E.DEMISSAO IS NULL
                    )
                GROUP BY
                    CONTA,
                    NOME,
                    ADM_COOP,
                    APELIDO,
                    UNID
            ) A1,
            (
                SELECT
                    SUM(VALORCTB) SALDO_ATUAL,
                    CONTA
                FROM
                    (
                        SELECT
                            0 tipo,
                            CZ.COD_SET,
                            EZ.NOME,
                            AZ.ORDEM,
                            AZ.VALOR,
                            EZ.ADM_COOP,
                            AZ.CONTA,
                            AZ.COD_LANC,
                            AZ.DATA,
                            EZ.COD_AGENCIA UNID,
                            BZ.DESCRICAO,
                            BZ.CREDITO,
                            AZ.COMPLEMENTO,
                            CASE
                                WHEN CREDITO = 'T' THEN VALOR
                                ELSE VALOR * -1
                            END VALORCTB
                        FROM
                            A_MVCLOS AZ,
                            A_CODIGO BZ,
                            C_CADUNI CZ,
                            C_SETOR DZ,
                            C_CAD EZ
                        WHERE
                            AZ.COD_LANC = BZ.COD_LANC
                            AND AZ.CONTA = CZ.CONTA
                            AND AZ.CONTA = EZ.CONTA
                            AND CZ.COD_UNID = DZ.COD_UNID
                            AND CZ.COD_SET = DZ.COD_SET
                            AND EZ.DEMISSAO IS NULL
                        UNION
                        ALL
                        SELECT
                            1 tipo,
                            CZ.COD_SET,
                            EZ.NOME,
                            CHAVE ORDEM,
                            AZ.VALOR,
                            EZ.ADM_COOP,
                            AZ.CONTA,
                            AZ.COD_LANC,
                            AZ.DATA,
                            EZ.COD_AGENCIA UNID,
                            BZ.DESCRICAO,
                            BZ.CREDITO,
                            AZ.COMPLEMENTO,
                            CASE
                                WHEN CREDITO = 'T' THEN VALOR
                                ELSE VALOR * -1
                            END VALORCTB
                        FROM
                            A_MVOPEN AZ,
                            A_CODIGO BZ,
                            C_CADUNI CZ,
                            C_SETOR DZ,
                            C_CAD EZ
                        WHERE
                            AZ.COD_LANC = BZ.COD_LANC
                            AND AZ.CONTA = CZ.CONTA
                            AND AZ.CONTA = EZ.CONTA
                            AND CZ.COD_UNID = DZ.COD_UNID
                            AND CZ.COD_SET = DZ.COD_SET
                            AND EZ.DEMISSAO IS NULL
                    )
                GROUP BY
                    CONTA,
                    NOME,
                    ADM_COOP
            ) A2,
            C_CADUNI A3
        WHERE
            (
                (
                    A1.VALOR < 100
                    AND A1.TIPO LIKE '%SALDO ATUAL%'
                )
                OR A1.TIPO LIKE '%LANÇAM%'
            )
            AND A1.CONTA = A2.CONTA
            AND A1.CONTA = A3.CONTA
            AND A1.CONTA NOT IN (
                SELECT
                    CONTA
                FROM
                    A_SDA
                WHERE
                    ANOMES = (
                        SELECT
                            MAX(ANOMES)
                        FROM
                            A_SDA
                    )
                    AND SD > 99
            )
        UNION
        ALL
        SELECT
            A.CONTA,
            A.NOME,
            A.ADM_COOP,
            'SEM LANC CAPITAL' TIPO,
            0 AS VALOR,
            0 AS SALDO_ATUAL,
            B.APELIDO,
            A.COD_AGENCIA UNID,
            C.PROFISSAO
        FROM
            C_CAD A,
            C_CAD B,
            C_CADUNI C
        WHERE
            A.DEMISSAO IS NULL
            AND A.AGENTE = B.CONTA
            AND A.CONTA = C.CONTA
            AND A.CONTA NOT IN (
                SELECT
                    CONTA
                FROM
                    A_SDA
                WHERE
                    ANOMES = (
                        SELECT
                            MAX(ANOMES)
                        FROM
                            A_SDA
                    )
                    AND SD > 99
            )
            AND A.CONTA NOT IN (
                SELECT
                    CONTA
                FROM
                    A_MVOPEN
                WHERE
                    COD_LANC = '202'
            )
            AND A.CONTA NOT IN (
                SELECT
                    CONTA
                FROM
                    A_MVCLOS
                WHERE
                    COD_LANC = '202'
            )
            AND A.MATRICULA IS NOT NULL
            AND A.MATRICULA > 0
        ORDER BY
            nome,
            TIPO,
            VALOR,
            APELIDO
    )
WHERE
    VALOR = 0