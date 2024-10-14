# terraform/variables.tf

variable "project" {
  type = string
  description = "Project name"
}

variable "environment" {
  type = string
  description = "Environment (dev / stage / prod)"
}

variable "location" {
  type = string
  description = "Azure region to deploy module to"
}

variable "deployment_name" {
  type = string
  description = "Deployment name to append to resources"
}

variable "prefix" {
  type        = string
  default     = "function-app"
  description = "Prefix of the resource name"
}