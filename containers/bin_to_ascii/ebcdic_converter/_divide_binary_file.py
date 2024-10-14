import os
import sys
import json
import boto3


def split_binary_file(
    input_file: str, output_dir: str, bytes_per_line: int, mb_per_chunk: int
):
    output_dir = f"{output_dir}/{os.path.dirname(input_file)}"
    os.makedirs(output_dir, exist_ok=True)

    mb_per_chunk *= 1024**2
    lines_per_file = mb_per_chunk // bytes_per_line
    chunk_size = lines_per_file * bytes_per_line

    filename = os.path.basename(input_file)
    file_size = os.path.getsize(input_file)
    num_chunks = (file_size // chunk_size) + (file_size % chunk_size > 0)

    # Open the EBCDIC file in binary mode
    with open(input_file, "rb") as file:
        chunk_num = 1

        while True:
            # Read a chunk of 10 lines (each line being BYTES_PER_LINE bytes)
            chunk = file.read(chunk_size)

            # If we reached the end of the file, break
            if not chunk:
                break

            part_num = str(chunk_num).zfill(len(str(num_chunks)))
            output_filename = (
                f"{filename}_parte_{part_num}_de_{num_chunks}.bin"
            )
            with open(f"{output_dir}/{output_filename}", "wb") as chunk_file:
                chunk_file.write(chunk)
                print(
                    f"Chunk {part_num}/{num_chunks} saved:",
                    output_filename,
                )

            chunk_num += 1


json_file = sys.argv[1]
part_size_mb = int(sys.argv[2])

with open(json_file) as jf:
    cpy_dict = json.load(jf)

    split_binary_file(
        cpy_dict["input"], "binary_parts", cpy_dict["lrecl"], part_size_mb
    )
