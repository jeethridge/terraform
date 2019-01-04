# Don't set a default for this - terraform will ask the admin for the initial password interactively. 
# This way it is never stored by terraform.
variable "admin_password" {
  description = "Default Administrator password to be used."
}

# The IP address of the management machine
variable "management_cidr" {
  description = "The ip address of the control machine"
}
