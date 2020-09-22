data "aws_vpc" "default" {
  filter {
    name = "tag:Name"
    values = ["VPC Default"]
  }
}

data "aws_subnet_ids" "database" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name = "tag:Tier"
    values = ["database"]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name = "default"
}

data "aws_route53_zone" "internal" {
  name         = "lab.picpay.internal."
  private_zone = true
}

module "rds_instance" {
  source               = "../../../../../module-terraform-rds"
  name                 = "foo"
  squad                = "infracore"
  environment          = "lab"
  costcenter           = "1100"
  tribe                = "Infra Cloud"
  database_name        = "foobardb"
  database_user        = "foo"
  database_password    = "foobar123456"
  database_port        = "3306"
  multi_az             = false
  storage_type         = "gp2"
  allocated_storage    = "20"
  storage_encrypted    = false
  engine               = "mysql"
  engine_version       = "5.7.17"
  major_engine_version = "5.7"
  instance_class       = "db.t2.medium"
  db_parameter_group   = "mysql5.7"
  publicly_accessible  = false
  host_name            = "testedb.lab.picpay.internal"
  dns_zone_id          = data.aws_route53_zone.internal.zone_id
  vpc_id               = data.aws_vpc.default.id
  subnet_ids           = data.aws_subnet_ids.database.ids
  security_group_ids   = [data.aws_security_group.default.id]
  apply_immediately    = "true"
  enabled              = "true"

  db_parameter = [
    {
      name         = "myisam_sort_buffer_size"
      value        = "1048576"
      apply_method = "immediate"
    },
    {
      name         = "sort_buffer_size"
      value        = "2097152"
      apply_method = "immediate"
    }
  ]
}