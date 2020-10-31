resource "aws_instance" "oracle_ec2_instance" {
  ami = "ami-00cf6ad74f988f94b"  #  Oracle Linux 7 update 7
  instance_type = "m5.large"   # $0.096/hour ; 2 vCPU  ; 10 ECU  ; 8 GiB memory   ; EBS disk              ; EBS Optimized by default
#  instance_type = "m5d.metal" # $5.424/hour ; 96 vCPU ; 345 ECU ; 384 GiB memory ; 4 x 900 NVMe SSD disk ; EBS Optimized by default ; max bandwidth 19,000 Mbps ; max throughput 2,375 MB/s ; Max IOPS 80,000
  key_name = aws_key_pair.oracle_key_pair.key_name
  ebs_optimized = true
  security_groups = [aws_security_group.oracle.name]
  root_block_device {
    volume_type           = "io1"
    volume_size           = 30 # GB
    iops                  = 500
    delete_on_termination = true
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "provision.oracle.sh"
    destination = "/tmp/provision.oracle.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "mkdir -p /home/ec2-user/.aws",
    ]
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "~/.aws/config"
    destination = "/home/ec2-user/.aws/config"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "~/.aws/credentials"
    destination = "/home/ec2-user/.aws/credentials"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "provision.oracle.response.file.rsp"
    destination = "/tmp/provision.oracle.response.file.rsp"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = ["chmod +x /tmp/provision.oracle.sh", "/tmp/provision.oracle.sh"]
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../src/db/DERIVEDFACT.csv"
    destination = "/tmp/DERIVEDFACT.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../src/db/MEMBERHEALTHSTATE.csv"
    destination = "/tmp/MEMBERHEALTHSTATE.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../src/db/changeset.oracle.xml"
    destination = "/tmp/changeset.oracle.xml"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../06_Cassandra_AWS/liquibase.jar"
    destination = "/tmp/liquibase.jar"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../liquibase_drivers/ojdbc8.jar"
    destination = "/tmp/ojdbc8.jar"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "02_populate.sh"
    destination = "/tmp/02_populate.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = ["chmod +x /tmp/02_populate.sh", "/tmp/02_populate.sh"]
  }
  tags = {
    Name = "Oracle Instance"
  }
}

