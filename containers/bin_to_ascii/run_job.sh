# Cria os diretórios pra bater com o caminho do arquivo no bucket pra facilitar
mkdir -p $(dirname $EBCDIC_FILE)
mkdir -p $(dirname $CPY_FILE)

# Puxa do s3 o arquivo EBCDIC e o arquivo COPYBOOK
aws s3 cp s3://$EBCDIC_BUCKET/$EBCDIC_FILE $EBCDIC_FILE
aws s3 cp s3://$EBCDIC_BUCKET/$CPY_FILE $CPY_FILE

# Roda os scripts da AWS pra converter o COPYBOOK pra json e o EBCDIC pra ascii
python3 parse_copybook_to_json.py -copybook $CPY_FILE -output $CPY_FILE.json -ebcdic $EBCDIC_FILE -ascii $EBCDIC_FILE"_ascii.csv" -recfm fb

if [ $FUNCTION = "DIVIDE" ]; then
    echo "Executando função de divisão"

    # Lê o arquivo binário e divide ele em partes menores
    python3 divide_binary_file.py $CPY_FILE.json $PART_SIZE_MB

    # Copia as partes criadas pro bucket de arquivos particionados
    aws s3 cp binary_parts/$INPUT_FOLDER/ s3://$EBCDIC_BUCKET/$PARTS_FOLDER/ --recursive
elif [ $FUNCTION = "CONVERT" ]; then
    echo "Executando função de conversão"

    # Abre o arquivo binário e converte ele pra ascii
    python3 extract_ebcdic_to_ascii.py -local-json $CPY_FILE.json

    # Envia o arquivo convertido pro s3
    aws s3 cp $EBCDIC_FILE"_ascii.csv" s3://$EBCDIC_BUCKET/$OUTPUT_KEY"_ascii.csv"
fi
