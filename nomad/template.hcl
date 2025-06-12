job "${__SERVICE__}-${__ENVIRONMENT__}" {
  datacenters = ${__DATACENTERS__}
  namespace = "${__NAMESPACE__}"

  # constraint {
  #   attribute = "${meta.role}"
  #   operator  = "!="
  #   value     = "rcg-ingress"
  # }

  constraint {
    distinct_hosts = true
  }

  spread {
    attribute = "${node.unique.name}"
    weight    = 50
  }

  update {
    stagger      = "10s"
    max_parallel = 1
  }

  group "${__SERVICE__}-${__ENVIRONMENT__}" {
      count = 2

      scaling {
        enabled = true
        min     = 1
        max     = 10
      }

      network {
        port "http" {
          to = 80
        }
   }

    task "${__SERVICE__}-${__ENVIRONMENT__}" {
      driver = "${__JOB_DRIVER__}"
      config {
        image = "${__IMAGE_NAME__}:${__IMAGE_TAG__}"
        ports = ["http"]
        auth {
          username = "${__USERNAME__}"
          password = "${__PASSWORD__}"
        }
      }

    service {
      name = "${__SERVICE__}-${__ENVIRONMENT__}"
      port = "http"
      provider = "nomad"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.rcg-${__SERVICE__}-${__ENVIRONMENT__}.rule=Host(`${__WEB_URL__}`)",
        "traefik.http.routers.rcg-${__SERVICE__}-${__ENVIRONMENT__}-nossl.rule=Host(`${__WEB_URL__}`)",
        "traefik.http.routers.rcg-${__SERVICE__}-${__ENVIRONMENT__}.tls=true",
        "traefik.http.routers.rcg-${__SERVICE__}-${__ENVIRONMENT__}.entrypoints=websecure",
        
        "traefik.http.routers.researchcomputinggroup-${__SERVICE__}-${__ENVIRONMENT__}.rule=Host(`ruthjoy.researchcomputinggroup.ca`)",
        "traefik.http.routers.researchcomputinggroup-${__SERVICE__}-${__ENVIRONMENT__}-nossl.rule=Host(`ruthjoy.researchcomputinggroup.ca`)",
        "traefik.http.routers.researchcomputinggroup-${__SERVICE__}-${__ENVIRONMENT__}.tls=true",
        "traefik.http.routers.researchcomputinggroup-${__SERVICE__}-${__ENVIRONMENT__}.entrypoints=websecure",
      ]
    }

    resources {
      cpu = 500
      memory = 256
      }

    }
  }
}
