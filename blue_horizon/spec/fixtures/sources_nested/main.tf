module "hello" {
  source = "./modules/hello"

  name = var.name
}

output "greeting" {
  value = module.hello.greeting
}