variable startup_script {}

resource "aws_instance" "flask_server_aws" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  user_data     = var.startup_script

  tags = {
    Name = "FlaskServerAWS"
  }
}
