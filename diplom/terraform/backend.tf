terraform {
  cloud {
    organization = "test_2"

    workspaces {
      name = "prod"
    }
  }
}
