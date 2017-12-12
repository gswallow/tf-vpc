data "template_file" "user_data" {
  template = "${file("user-data/minion.sh.tpl")}"
  vars {
    ORG = "${var.ORG}"
    ENV = "${terraform.workspace}"
    DOMAIN = "${data.aws_route53_zone.internal.comment}" # The use of comment is a code smell
    GRAINS = <<EOF
  roles:
    - test
  environment: ${terraform.workspace}
EOF
  }
}

resource "aws_instance" "salt_minion" {
  ami                  = "${data.aws_ami.redhat.id}"
  key_name             = "${var.SSH_KEY}"
  security_groups      = [ "${data.aws_security_group.selected.id}" ]
  subnet_id            = "${data.aws_subnet_ids.selected.ids[0]}"
  user_data            = "${data.template_file.user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.salt_minion.id}" 
  instance_type        = "t2.micro"
  tags {
    Name = "salt-minion_ec2_instance"
    Environment = "${terraform.workspace}"
  }
}
