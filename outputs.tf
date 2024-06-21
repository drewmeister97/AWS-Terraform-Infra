output "vpc_id" {
  value = module.vpc.vpc_id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.my_s3_bucket_pp.bucket
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.my_ecs_cluster_pp.id
}

