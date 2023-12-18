variable startup_script {}

resource "aws_instance" "flask_server_aws" {
  ami           = "ami-0759f51a90924c166"
  instance_type = "t2.micro"
  user_data     = var.startup_script

  tags = {
    Name = "FlaskServerAWS"
  }
}
