data "ibm_container_cluster_config" "cluster1" {
  cluster_name_id = "mycluster-free"
  #config_dir      = "/tmp/config_dir"
}

provider "kubernetes" {
  load_config_file       = "false"
  host                   = "${data.ibm_container_cluster_config.cluster1.host}"
  token                  = "${data.ibm_container_cluster_config.cluster1.token}"
  cluster_ca_certificate = "${data.ibm_container_cluster_config.cluster1.ca_certificate}"
}

resource "kubernetes_deployment" "helloworld" {
  metadata {
    name = "helloworld"
    labels = {
      app = "HelloWorld"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "HelloWorld"
      }
    }

    template {
      metadata {
        labels = {
          app = "HelloWorld"
        }
      }

      spec {
        container {
          image = "de.icr.io/inveni/hello-world"
          name  = "helloworld"
        port {
            container_port = 8085
          }
       
        }
		
    }
  }
}

}

resource "kubernetes_service" "helloworld" {
  metadata {
    name = "helloworld"
  }
  spec {
    selector = {
      App = "${kubernetes_deployment.helloworld.spec.0.template.0.metadata[0].labels.app}"
    }
    port {
      node_port   = 30201
      port        = 8085
      target_port = 8085
    
}
    type = "NodePort"
  }
}

