resource "aws_security_group" "web" {
  name = "default_web"
  description = "Allow HTTP and HTTPS from the public"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    self = true
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "default_web_sg"
  }
} 

resource "aws_security_group" "private" {
  name = "private"
  description = "Private subnet accessible by SSH bastions"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [ "${aws_security_group.ssh.id}" ]
    self = true
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "private_sg"
  }
}

resource "aws_security_group" "ssh" {
  count = "${var.CREATE_BASTION == "true" ? 1 : 0 }"
  name = "default_ssh"
  description = "Allow SSH from specified CIDR blocks"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [ "${var.ALLOWED_SSH}" ]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "default_ssh_sg"
  }
}
