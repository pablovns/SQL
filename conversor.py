import os
import sys

def converter_sql_cs(arquivo_sql, arquivo_cs, nome_funcao=None):
    conteudo_sql = ""
    with open(arquivo_sql, 'r') as arquivo_entrada:
        for linha in arquivo_entrada:
            conteudo_sql += f"stbSql.AppendLine(\"{linha.strip()}\");\n\t"

    conteudo_completo = f"""public string RetornaSQL{nome_funcao if nome_funcao else None}()
{{
    StringBuilder stbSql = new StringBuilder();

    {conteudo_sql}
    return stbSql.ToString();
}}
"""

    pasta = os.path.join(os.path.dirname(sys.argv[0]), "cs")
    if not os.path.exists(pasta):
        os.makedirs(pasta)

    with open(os.path.join(pasta, arquivo_cs), 'w') as arquivo_saida:
        arquivo_saida.write(conteudo_completo)

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Uso: python conversor.py arquivo_sql [nome_funcao]")
        sys.exit(1)
    
    arquivo_sql = sys.argv[1]
    arquivo_cs = f"{arquivo_sql[:-4]}.cs"  # Substitui a extensão do arquivo por .cs e salva na pasta cs/

    if len(sys.argv) == 3:
        nome_funcao = sys.argv[2]
        converter_sql_cs(arquivo_sql, arquivo_cs, nome_funcao)
    else:
        converter_sql_cs(arquivo_sql, arquivo_cs)

    print(f"Arquivo traduzido salvo como '{arquivo_cs}'")

