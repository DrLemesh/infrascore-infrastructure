# שימוש ב-Bucket קיים שנוצר ידנית
# הבאקט לא יימחק כאשר נריץ terraform destroy
data "aws_s3_bucket" "backups" {
  bucket = "infrascore-db-backup-prod"
}

# יצירת ה-IAM Role ישירות (ללא שימוש במודול)
# זה פותר את בעיית התאימות של גרסאות המודול

# יצירת ה-IAM Role
resource "aws_iam_role" "s3_backup_role" {
  name = "infrascore-s3-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:prod:infrascore-db-sa"
          }
        }
      }
    ]
  })
}

# יצירת Custom IAM Policy עם הרשאות מינימליות (Least Privilege)
resource "aws_iam_policy" "s3_backup_policy" {
  name        = "infrascore-s3-backup-policy"
  description = "Least-privilege policy for database backups to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::infrascore-db-backup-prod/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::infrascore-db-backup-prod"
      }
    ]
  })
}

# צירוף Custom Policy ל-Role
resource "aws_iam_role_policy_attachment" "s3_backup_policy" {
  role       = aws_iam_role.s3_backup_role.name
  policy_arn = aws_iam_policy.s3_backup_policy.arn
}

# Output כדי שנדע מה ה-ARN של ה-Role שנוצר
output "s3_backup_role_arn" {
  value = aws_iam_role.s3_backup_role.arn
}
