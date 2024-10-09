variable "region" {
  default     = "us-east-1"
  description = "Região em que será provisionada a infra AWS"
}

variable "script_name" {
  description = "Name of the script to run after task creation"
  type        = string
  default     = "container/push_image_to_ecr.sh"
}

variable "reference_copybook" {
  description = "Nome do copybook de referencia pra tradução do ebcdic"
  type        = string
  default     = "COBVBFM2.cpy"
}
