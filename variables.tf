variable "region" {
  description = "Região em que será provisionada a infra AWS"
  type        = string
  default     = "us-east-1"
}

variable "push_bin_to_ascii_image_to_ecr" {
  description = "Nome do script que sobe a imagem docker pro ECR"
  type        = string
  default     = "containers/bin_to_ascii/push_image_to_ecr.sh"
}

variable "reference_copybook" {
  description = "Nome do copybook de referencia pra tradução do ebcdic"
  type        = string
  default     = "COBPACK3.cpy"
}

variable "input_folder" {
  description = "Pasta no bucket que guarda os arquivos brutos (binarios)"
  type        = string
  default     = "binarios"
}

variable "partitioned_folder" {
  description = "Pasta no bucket que guarda os arquivos separados em chunks"
  type        = string
  default     = "particionados"
}

variable "output_folder" {
  description = "Pasta no bucket que guarda os arquivos processados (ascii)"
  type        = string
  default     = "processados"
}

variable "file_size_limit" {
  description = "Tamanho (MB) máximo que um arquivo pode ter para ser processado sem particionamento"
  type        = number
  default     = 200
}
