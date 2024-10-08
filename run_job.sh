# Configura o AWS CLI
printf $AWS_ACCESS_KEY'\n'$AWS_SECRET_ACCESS_KEY'\n'$AWS_REGION'\njson' | aws configure

# Cria os diretórios pra bater com o caminho do arquivo no bucket pra facilitar
mkdir -p $(dirname $EBCDIC_FILE)
mkdir -p $(dirname $CPY_FILE)

# Puxa do s3 o arquivo EBCDIC e o arquivo COPYBOOK
aws s3api get-object --bucket $EBCDIC_BUCKET --key $EBCDIC_FILE $EBCDIC_FILE
aws s3api get-object --bucket $EBCDIC_BUCKET --key $CPY_FILE    $CPY_FILE

# Roda os scripts da AWS pra converter o COPYBOOK pra json e o EBCDIC pra ascii
python3 parse_copybook_to_json.py -copybook $CPY_FILE -output $CPY_FILE.json -ebcdic $EBCDIC_FILE -ascii $EBCDIC_FILE"_ascii.csv" -recfm vb
python3 extract_ebcdic_to_ascii.py -local-json $CPY_FILE.json

# Envia o arquivo convertido pro s3
aws s3api put-object --bucket $ASCII_BUCKET --key $EBCDIC_FILE"_ascii.csv" --body $EBCDIC_FILE"_ascii.csv"