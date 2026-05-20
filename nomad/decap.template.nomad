# Job template: site + Decap CMS in one group (same allocation, shared network).
# Parameterize with __SERVICE__, __ENVIRONMENT__, __USE_DECAP__, __IMAGE_*__, __REGISTRY_*__,
# and Decap-specific: __DECAP_IMAGE_NAME__, __DECAP_IMAGE_TAG__, __ORIGINS__, __OAUTH_CLIENT_ID__, __OAUTH_CLIENT_SECRET__, __CMS_BACKEND_DEBUG__ (optional).
job "${__SERVICE__}-${__ENVIRONMENT__}" {
  meta {
    run_uuid = "${uuidv4()}"
  }

  type        = "service"
  datacenters = ${__DATACENTERS__}
  namespace   = "${__NAMESPACE__}"

  constraint {
    attribute = "${meta.role}"
    operator  = "set_contains"
    value     = "non-data-portal"
  }

  constraint {
    attribute = "${meta.role}"
    operator  = "!="
    value     = "rcg-ingress"
  }

  constraint {
    distinct_hosts = true
  }

  spread {
    attribute = "${node.unique.name}"
    weight    = 50
  }

  update {
    max_parallel      = 1
    stagger           = "10s"
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "5m"
    progress_deadline = "10m"
    auto_revert       = true
    auto_promote      = false
    canary            = 0
  }

  group "${__SERVICE__}-${__ENVIRONMENT__}" {
    count = ${__GROUP_COUNT__}

    scaling {
      enabled = true
      min     = ${__GROUP_COUNT__}
      max     = 10
    }

    network {
      port "http" {
        to = 80
      }
      port "decap-http" {
        to = 80
      }
      port "decap-api" {
        to = 3000
      }
    }

    task "${__SERVICE__}-${__ENVIRONMENT__}" {
      driver = "${__JOB_DRIVER__}"

      config {
        image              = "${__IMAGE_NAME__}:${__IMAGE_TAG__}"
        image_pull_timeout = "10m"
        ports              = ["http"]
        force_pull         = true
        auth {
          username = "${__REGISTRY_USERNAME__}"
          password = "${__REGISTRY_PASSWORD__}"
        }
        volumes = [
          "local/server.conf:/etc/nginx/conf.d/server.conf:ro"
        ]
        healthchecks {
          disable = true
        }
      }

      template {
        data = <<EOH
upstream site_upstream {
    server {{ env "NOMAD_ADDR_http" }};
}
upstream cms_upstream {
    server {{ env "NOMAD_ADDR_decap_api" }};
}
EOH
        destination = "local/server.conf"
        change_mode = "restart"
      }

      env {
        # true = Decap CMS (decap.conf + server.conf); false = static only (default.conf)
        USE_DECAP = "${__USE_DECAP__}"
      }

      restart {
        attempts = 3
        interval = "5m"
        delay    = "15s"
        mode     = "fail"
      }

      service {
        name     = "${__SERVICE__}-${__ENVIRONMENT__}"
        port     = "http"
        provider = "nomad"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.rcg-${__SERVICE__}-${__ENVIRONMENT__}.rule=Host(`${__WEB_URL__}`)",
          "traefik.http.routers.rcg-${__SERVICE__}-${__ENVIRONMENT__}-nossl.rule=Host(`${__WEB_URL__}`)",
          "traefik.http.routers.rcg-${__SERVICE__}-${__ENVIRONMENT__}.tls=true",
          "traefik.http.routers.rcg-${__SERVICE__}-${__ENVIRONMENT__}.entrypoints=websecure",
          
          "traefik.http.routers.researchcomputinggroup-${__SERVICE__}-${__ENVIRONMENT__}.rule=Host(`${__SERVICE__}-${__ENVIRONMENT__}.${__RESEARCHER__}.researchcomputinggroup.ca`)",
          "traefik.http.routers.researchcomputinggroup-${__SERVICE__}-${__ENVIRONMENT__}-nossl.rule=Host(`${__SERVICE__}-${__ENVIRONMENT__}.${__RESEARCHER__}.researchcomputinggroup.ca`)",
          "traefik.http.routers.researchcomputinggroup-${__SERVICE__}-${__ENVIRONMENT__}.tls=true",
          "traefik.http.routers.researchcomputinggroup-${__SERVICE__}-${__ENVIRONMENT__}.entrypoints=websecure",
        ]

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }

    task "decap-cms" {
      driver = "docker"

      config {
        image = "${__DECAP_IMAGE_NAME__}:${__DECAP_IMAGE_TAG__}"
        ports = ["decap-http", "decap-api"]
        healthchecks {
          disable = true
        }
      }

      env {
        CMS_BACKEND_DEBUG   = "${__CMS_BACKEND_DEBUG__}"
        ORIGINS             = "${__ORIGINS__}"
        OAUTH_CLIENT_ID     = "${__OAUTH_CLIENT_ID__}"
        OAUTH_CLIENT_SECRET = "${__OAUTH_CLIENT_SECRET__}"
      }

      restart {
        attempts = 3
        interval = "5m"
        delay    = "15s"
        mode     = "fail"
      }

      service {
        name     = "${__SERVICE__}-${__ENVIRONMENT__}-decap-cms"
        port     = "decap-http"
        provider = "nomad"
        tags = [
          "traefik.enable=false",
        ]

        check {
          type     = "http"
          port     = "decap-api"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
