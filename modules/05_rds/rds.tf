resource "aws_db_subnet_group" "rds" {
  name        = "subnet-group-demo"
  description = "rds subnet group for demo"
  subnet_ids  = ["subnet-09e532f3238a4d9bb","subnet-0068689ad015b15a1","subnet-005fc72d40087a06c","subnet-0ceaf7e2df23f7dfd"]
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 3
  identifier         = "aurora-cluster-demo-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = "db.t2.small"
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
  apply_immediately = true
}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.12.1"
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  database_name           = "mydb"
  master_username         = "foo"
  master_password         = "bar12345678"
  backup_retention_period = 1
  skip_final_snapshot = true
}
