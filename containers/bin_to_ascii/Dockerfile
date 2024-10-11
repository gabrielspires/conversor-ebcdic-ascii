# Como rodar o container na mão (pra testar)
# docker run --rm \
# -e AWS_ACCESS_KEY=AKIAZROIAOKYDRC66GEW \
# -e AWS_SECRET_ACCESS_KEY=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 \
# -e AWS_REGION=us-east-1 \
# -e EBCDIC_BUCKET='dev-ebcdic-bucket-wwi0rofi' \
# -e EBCDIC_FILE='2024/10/08/COBVBFM2.EBCDIC' \
# -e CPY_FILE='cpy/COBVBFM2.cpy' \
# -e ASCII_BUCKET='dev-ascii-bucket-wwi0rofi' \
# ebcdic_converter

# Imagem base
FROM python:3.12.7

# Pasta padrão onde ficam os scripts
ENV APP_HOME=/app

# Variáveis de ambiente que tem que ser passadas pro container
ENV EBCDIC_BUCKET=""
ENV EBCDIC_FILE=""
ENV CPY_FILE=""

# Copia os programas Python, o script bash que roda os comandos e as credenciais
ADD ebcdic_converter ${APP_HOME}
ADD run_job.sh ${APP_HOME}
# ADD .aws /

# Utilitários necessários pra ver a saída dos scripts (talvez tire depois)
RUN apt update -y
RUN apt install less -y

# Instalação e configuração do AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Biblioteca Python necessária pros scripts
RUN pip install boto3

# Seta a pasta padrão
WORKDIR ${APP_HOME}

# Habilita o script bash pra execução
RUN chmod u+x run_job.sh

# Comando executado no start do container
ENTRYPOINT [ "bash", "run_job.sh" ]