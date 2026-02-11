resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-backend"
  image_tag_mutability = "MUTABLE" # מאפשר לדחוף גרסאות חדשות לאותו Tag (כמו latest)
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true # סורק את האימג' לאיתור חולשות אבטחה אוטומטית
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ecr_repository" "db" {
  name                 = "${var.project_name}-db"
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = false
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ecr_repository" "pgadmin" {
  name                 = "${var.project_name}-pgadmin"
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = false
  }

  lifecycle {
    prevent_destroy = true
  }
}
