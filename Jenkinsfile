pipeline {
    agent any

    environment {
        OCI_CONFIG_FILE = '/var/lib/jenkins/.oci/config'  // OCI config for Jenkins user
        OCI_COMPARTMENT_ID = 'ocid1.tenancy.oc1..aaaaaaaa6jvn6ty3gevdog7phzcnbh7x3ek4suj4cwyd7imjhe62qwv7x2iq' // Replace with your OCI compartment OCID
    }

    stages {
        stage('Clone Nginx Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Karthikbhatkarkada/nginx.git'
            }
        }

        stage('Build Nginx from Source') {
            steps {
                sh '''
                    sudo apt-get update
                    sudo apt-get install -y build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev
                    
                    ./configure --prefix=/usr/local/nginx --with-http_ssl_module
                    make
                    mkdir -p nginx-build/sbin nginx-build/conf
                    
                    cp objs/nginx nginx-build/sbin/
                    cp conf/* nginx-build/conf/
                '''
            }
        }

        stage('Packer Build Image in OCI') {
            steps {
                sh '''
                    packer build \
                        -var "oci_config_file=${OCI_CONFIG_FILE}" \
                        -var "compartment_id=${OCI_COMPARTMENT_ID}" \
                        nginx-ubuntu.pkr.hcl
                '''
            }
        }
    }
}
