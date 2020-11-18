resource "aws_instance" "cassandra_ec2_instance" {
  ami = "ami-0ac80df6eff0e70b5"  #  Ubuntu 18.04 LTS - Bionic - hvm:ebs-ssde  https://cloud-images.ubuntu.com/locator/ec2/
  instance_type = "m5.large"   # $0.096/hour ; 2 vCPU  ; 10 ECU  ; 8 GiB memory   ; EBS disk              ; EBS Optimized by default
#  instance_type = "m5d.metal" # $5.424/hour ; 96 vCPU ; 345 ECU ; 384 GiB memory ; 4 x 900 NVMe SSD disk ; EBS Optimized by default ; max bandwidth 19,000 Mbps ; max throughput 2,375 MB/s ; Max IOPS 80,000
  key_name = aws_key_pair.cassandra_key_pair.key_name
  ebs_optimized = true
  security_groups = [aws_security_group.cassandra.name]
  root_block_device {
    volume_type           = "io1"
    volume_size           = 10 # GB
    iops                  = 500
    delete_on_termination = true
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    script = "provision.cassandra.sh"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../src/db/DERIVEDFACT.csv"
    destination = "/tmp/DERIVEDFACT.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../src/db/MEMBERHEALTHSTATE.csv"
    destination = "/tmp/MEMBERHEALTHSTATE.csv"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../src/db/changeset.cassandra.sql"
    destination = "/tmp/changeset.cassandra.sql"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "liquibase.jar"
    destination = "/tmp/liquibase.jar"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../liquibase_drivers/CassandraJDBC42.jar"
    destination = "/tmp/CassandraJDBC42.jar"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "../../liquibase_drivers/liquibase-cassandra-4.0.0.2.jar"
    destination = "/tmp/liquibase-cassandra-4.0.0.2.jar"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    script = "02_populate.sh"
  }
  tags = {
    Name = "Cassandra Instance"
  }
}

# FOR NOW, JUST USE ROOT DEVICE resource "aws_ebs_volume" "cassandra_ebs_volume" {
# FOR NOW, JUST USE ROOT DEVICE   availability_zone     = aws_instance.cassandra_ec2_instance.availability_zone
# FOR NOW, JUST USE ROOT DEVICE   type                  = "io2" # SSD 4-16TB 1,000 MiB/s
# FOR NOW, JUST USE ROOT DEVICE   size                  = 10    # 10 GB
# FOR NOW, JUST USE ROOT DEVICE   iops                  = 3000  # 100 - 64,000
# FOR NOW, JUST USE ROOT DEVICE #  timeouts {
# FOR NOW, JUST USE ROOT DEVICE #    create = "60m"
# FOR NOW, JUST USE ROOT DEVICE #    delete = "2h"
# FOR NOW, JUST USE ROOT DEVICE #  }
# FOR NOW, JUST USE ROOT DEVICE }
# FOR NOW, JUST USE ROOT DEVICE
# FOR NOW, JUST USE ROOT DEVICE resource "aws_volume_attachment" "example-volume-attachment" {
# FOR NOW, JUST USE ROOT DEVICE   device_name = "/dev/xvdb"
# FOR NOW, JUST USE ROOT DEVICE   instance_id = aws_instance.cassandra_ec2_instance.id
# FOR NOW, JUST USE ROOT DEVICE   volume_id   = aws_ebs_volume.cassandra_ebs_volume.id
# FOR NOW, JUST USE ROOT DEVICE }

