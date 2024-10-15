# Conversor de arquivos binários EBCDIC para Parquet

![](diagrama.svg)

O sistema representado pelo diagrama acima tem o objetivo de converter arquivos 
binários (EBCDIC) originados do mainframe para ASCII e depois para parquet. O
processo funciona da seguinte maneira:

 1. Um arquivo binário é colocado no bucket na pasta de arquivos binários.
 2. O bucket S3 dispara uma notificação quando recebe o arquivo e uma função lambda é executada.
 3. O arquivo original é processado em um container ECS onde ele é quebrado em várias partes menores.
 4. As partes são colocadas de volta no bucket, na pasta de arquivos particionados.
 5. Novamente o bucket dispara uma notificação pra cada arquivo novo criado.
 6. A função lambda inicia outro container no ECS que converte as partes do arquivo binário para ASCII e depois ASCII para parquet.
 7. O arquivo convertido em formato parquet é colocado de volta no S3.
 8. O bucket dispara uma notificação que insere na fila do SQS a informação do arquivo pra ser consumido pelo Glue Crawler.

