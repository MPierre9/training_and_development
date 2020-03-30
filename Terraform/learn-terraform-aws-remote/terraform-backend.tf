terraform {
  backend "remote" {
    organization = "mpierre"

    workspaces {
      name = "Learning-Workspace"
    }
  }
}