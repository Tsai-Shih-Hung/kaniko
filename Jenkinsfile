podTemplate {
  node(POD_LABEL) {
    checkout scm
    props = readProperties(file: 'version.properties')
  }
}

pipeline {
  agent {
    kubernetes {
      yaml """
    apiVersion: v1
    kind: Pod
    metadata:
      labels: 
        some-label: some-label-value
    spec:
      containers:
      - name: owasp-zap
        image: owasp/zap2docker-stable
        command:
        - sleep
        args:
        - 99d
        volumeMounts:
        - name: shared-logs       #同一個pod內的兩個應用共享目錄logdata
          mountPath: /logs
            
      - name: filebeat
        image: docker.elastic.co/beats/${props["version"]}
        imagePullPolicy: Always
        args: [
            "-c", "/opt/filebeat/filebeat.yml",
            "-e",
        ]
        securityContext:
          runAsUser: 0
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 200m
            memory: 200Mi

        volumeMounts:
         - name: config               #將configmap的內容放到容器本地目錄
           mountPath: /opt/filebeat/
         - name: shared-logs       #同一個pod內的兩個應用共享目錄logdata
           mountPath: /logdata

      volumes:
        - name: dockerfile-storage
          persistentVolumeClaim:
            claimName: dockerfile-claim
            
        - name: shared-logs 
          emptyDir: {}

        - name: harbor-secret
          secret:
            secretName: harbor-secret
            items:
            - key: .dockerconfigjson
              path: config.json
              
        - name: config
          configMap:
            name: filebeat-config  #使用前面定義的configmap
            items:
            - key: filebeat.yml
              path: filebeat.yml
        
"""
    }
  }
    stages {
    stage('Test zap') {
      steps {
        container(name: 'owasp-zap') {

          script{
            echo "${props["tfsec.version"]}"
          }
        }
        }
    }
   }
    
}
