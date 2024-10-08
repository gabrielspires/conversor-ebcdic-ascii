# docker run --rm \
# -e EBCDIC_BUCKET='dev-ebcdic-bucket-wwi0rofi' \
# -e EBCDIC_FILE='2024/10/08/COBVBFM2.EBCDIC' \
# -e CPY_FILE='cpy/COBVBFM2.cpy' \
# -e ASCII_BUCKET='dev-ascii-bucket-wwi0rofi' \
# ebcdic_converter
FROM python:3.12.7

ENV APP_HOME /app
ENV EBCDIC_BUCKET ""
ENV EBCDIC_FILE ""
ENV CPY_FILE ""

ENV ASCII_BUCKET ""

ADD ebcdic_converter ${APP_HOME}
ADD run_job.sh ${APP_HOME}
ADD .aws /

RUN apt update -y
RUN apt install less -y

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

RUN aws configure < /cli_config

RUN pip install boto3

WORKDIR ${APP_HOME}

RUN mkdir ebcdic
RUN mkdir cpy
RUN mkdir ascii

# RUN aws s3api get-object --bucket ${EBCDIC_BUCKET} --key ${EBCDIC_FILE} ebcdic/${EBCDIC_FILE}
# RUN aws s3api get-object --bucket ${EBCDIC_BUCKET} --key ${CPY_FILE}    cpy/${CPY_FILE}
# RUN python3 parse_copybook_to_json.py -copybook cpy/${CPY_FILE} -output output/${CPY_FILE}.json -ebcdic ebcdic/${EBCDIC_FILE} -ascii ascii/${ASCII_FILE} -recfm vb
# RUN python3 extract_ebcdic_to_ascii.py -local-json output/${CPY_FILE}.json
# RUN aws s3api put-object --bucket ${ASCII_BUCKET} --key ascii/${ASCII_FILE} 

RUN chmod u+x run_job.sh

ENTRYPOINT [ "bash", "run_job.sh" ]