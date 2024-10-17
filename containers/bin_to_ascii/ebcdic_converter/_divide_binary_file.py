import os
import sys
import json
import boto3


def split_binary_file(input_file: str, output_dir: str, bytes_per_line: int, mb_per_chunk: int):
    # Define o diretório onde guardar os arquivos divididos e cria as pastas
    output_dir = f"{output_dir}/{os.path.dirname(input_file)}"
    os.makedirs(output_dir, exist_ok=True)

    # Multiplica a quantidade de MB pela quantidade certa de bytes (2^20)
    # mb_per_chunk *= 1024**2

    # Calcula quantas linhas cada arquivo deve ter e o tamanho dos chunks
    lines_per_file = mb_per_chunk // bytes_per_line
    chunk_size = lines_per_file * bytes_per_line

    # Calcula quantas partes resultarão da divisão
    file_size = os.path.getsize(input_file)
    num_chunks = (file_size // chunk_size) + (file_size % chunk_size > 0)

    # Abre o arquivo EBCDIC em formato binário 'rb'
    with open(input_file, "rb") as file:
        filename = os.path.basename(input_file)
        chunk_num = 1

        while True:
            # Lê o próximo chunk do arquivo
            chunk = file.read(chunk_size)

            # Ao chegar no final do arquivo, sai do loop
            if not chunk:
                break

            # Formata strings pra saída
            partnum = str(chunk_num).zfill(len(str(num_chunks)))
            output_filename = f"{filename}_parte_{partnum}_de_{num_chunks}.bin"

            # Grava o chunk em um arquivo binário
            with open(f"{output_dir}/{output_filename}", "wb") as chunk_file:
                chunk_file.write(chunk)
                print(f"Chunk {partnum}/{num_chunks} saved:", output_filename)

            chunk_num += 1


def main():
    # Primeiro parametro: arquivo json com as informações do copybook
    json_file = sys.argv[1]

    # Segundo parametro: tamanho em MB de cada parte resultante da divisão
    part_size_mb = int(sys.argv[2])

    # Lê as infos do json e dispara a função de divisão
    with open(json_file) as jf:
        cpy_dict = json.load(jf)

        split_binary_file(cpy_dict["input"], "binary_parts", cpy_dict["lrecl"], part_size_mb)


if __name__ == "__main__":
    main()
