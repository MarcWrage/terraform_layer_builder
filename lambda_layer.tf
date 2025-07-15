locals {
  s3_layer = var.bucket != null && var.key != null
}

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = var.layer_name
  compatible_runtimes = var.compatible_runtimes
  skip_destroy        = var.skip_destroy
  filename            = local.s3_layer ? null : "${path.module}/.build/${var.layer_name}.zip"
  source_code_hash    = filebase64sha256("${path.module}/.build/${var.layer_name}.zip")
  s3_bucket           = local.s3_layer ? aws_s3_object.layer[0].bucket : null
  s3_key              = local.s3_layer ? aws_s3_object.layer[0].key : null
}

resource "aws_s3_object" "layer" {
  count  = local.s3_layer ? 1 : 0
  bucket = var.bucket
  key    = var.key
  source = "${path.module}/.build/${var.layer_name}.zip"
  etag   = filemd5("${path.module}/.build/${var.layer_name}.zip")
}

