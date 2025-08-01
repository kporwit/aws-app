variable "company" {
  type        = string
  description = "Company name which will be used in the name prefix"
}

variable "business_unit" {
  type        = string
  description = "BU name which will be used in the name prefix"
}

variable "application" {
  type        = string
  description = "application name"
}

variable "application_image" {
  type        = string
  description = "application image name"
}

variable "environment" {
  type        = string
  description = "environment name"
}

variable "application_tag" {
  type        = string
  description = "application image tag"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the project"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of AZs to deploy."
}

variable "alb" {
  type        = map(any)
  description = "Map of variables used by ALB"
}

variable "fargate_capacity_providers" {
  type        = map(any)
  description = "Capactiy providers for Fargate ECS model."
}
