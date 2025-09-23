variable "startup_script" {
    default = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y python3 python3-pip
    sudo pip3 install flask
    echo "from flask import Flask\napp = Flask(__name__)\n@app.route('/')\ndef hello():\n    return 'Hello, World!'\nif __name__ == '__main__':\n    app.run(host='0.0.0.0', port=80)" > app.py
    sudo python3 app.py
    EOF
}

variable "gcp_zone" {}
