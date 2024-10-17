# Imagem base
FROM amazonlinux:latest

RUN yum update -y ; \
    yum install -y \
    gcc gcc-c++ freetype-devel yum-utils findutils openssl-devel python3 less unzip ; \
    curl "https://bootstrap.pypa.io/get-pip.py" -o get-pip.py ; \
    python3 get-pip.py ; \
    rm get-pip.py ; \
    yum clean all

ENV PATH=$PATH:/root/.local/bin

# Pasta padrão onde ficam os scripts
WORKDIR /app

# Variáveis de ambiente que tem que ser passadas pro container
ENV FUNCTION=""
ENV PART_SIZE_MB=""
ENV EBCDIC_BUCKET=""
ENV EBCDIC_FILE=""
ENV CPY_FILE=""
ENV INPUT_FOLDER=""
ENV PARTS_FOLDER=""
ENV OUTPUT_KEY=""

# Copia os programas Python, o script bash que roda os comandos e as credenciais
ADD ebcdic_converter .
ADD run_job.sh .

# Instalação e configuração do AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip ; rm awscliv2.zip
RUN ./aws/install

# Biblioteca Python necessária pros scripts
RUN pip3 install --user -r requirements*

# Habilita o script bash pra execução
RUN chmod u+x run_job.sh

# Comando executado no start do container
ENTRYPOINT [ "bash", "run_job.sh" ]