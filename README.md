Este proyecto se realizó como parte de la actividad "0311AT - K8S: Casi como en producción" de la Cátedra Computación en la Nube.

Alumna: Sonia Guevara 
Comisión 1

# Despliegue Local de Sitio Web Estático con Minikube y K8s

Este repositorio contiene los manifiestos que necesitas para desplegar un entorno de desarrollo local para un sitio web estático simple. El entorno se ejecuta en Minikube y utiliza un volumen persistente (`hostPath` a través de `minikube mount`) para servir contenido web personalizado.


## Prerrequisitos

Asegúrate de tener instalado el siguiente software:

* **Git:** Para clonar los repositorios. [Instalar Git](https://git-scm.com/book/es/v2/Inicio---Sobre-el-Control-de-Versiones-Instalaci%C3%B3n-de-Git)
* **Minikube:** Para ejecutar un clúster local de Kubernetes. [Instalar Minikube](https://minikube.sigs.k8s.io/docs/start/)
* **kubectl:** Para interactuar con el clúster de Kubernetes. [Instalar kubectl](https://kubernetes.io/es/docs/tasks/tools/install-kubectl/)
* Un **Driver** para Minikube: Como Docker, VirtualBox, Hyper-V, etc.

## Pasos para Desplegar el Entorno

Sigue estos pasos para levantar el entorno en tu máquina local:

1.  **Clonar los Repositorios:**
    * Necesitas clonar *dos* repositorios: este (`proyecto-k8s-manifests`) y el que contiene el contenido web (https://github.com/SoniaGuevara/static-website). Abre tu terminal y clónalos:

2.  **Iniciar Minikube:**
    * Abre una terminal Powershell como administrador y ejecuta:
         minikube start
       
    * Verifica que el clúster esté corriendo: `minikube status`

3.  **Montar la Carpeta de Contenido Web:**
    * El PersistentVolume (`pv.yaml`) espera que el contenido web esté disponible *dentro* de la VM de Minikube en la ruta `/data/web`. Para lograr esto, necesitas usar `minikube mount`.
    * **Abre una NUEVA terminal** (déjala abierta mientras uses el entorno) y ejecuta (¡**IMPORTANTE:** Reemplaza la ruta de Windows con la ruta ABSOLUTA a tu carpeta local `static-website`!):
        ```bash
        # Ejemplo para Windows (¡AJUSTA TU RUTA!):
        minikube mount "C:\Ruta\Completa\A\Tu\Carpeta\static-website":/data/web

        # Ejemplo para Linux/macOS (¡AJUSTA TU RUTA!):
        # minikube mount /ruta/completa/a/tu/carpeta/static-website:/data/web
        ```
    * **¡No cierres esta terminal mientras trabajas con la aplicación!**

4.  **Aplicar los Manifiestos de Kubernetes:**
    * Navega con la terminal a la carpeta de este repositorio (donde están los archivos `.yaml`):
       
        cd ruta/a/la/carpeta/proyecto-k8s-manifests
    
    * IMPORTANTE primero crear el Namespace dedicado:
        kubectl apply -f namespace.yaml
      
    * Aplica el resto de los manifiestos para crear el PV, PVC, Deployment y Service dentro del namespace `web-estatica`:

        # Aplica el PV (es cluster-wide, no necesita namespace)
        kubectl apply -f pv.yaml

        # Aplica el resto en el namespace correcto
        kubectl apply -f pvc.yaml -n web-estatica
        kubectl apply -f deployment.yaml -n web-estatica
        kubectl apply -f service.yaml -n web-estatica

        # Alternativa (si todos los archivos YAML excepto namespace.yaml y pv.yaml tienen 'namespace: web-estatica' adentro):
        # kubectl apply -f . -n web-estatica
       

5.  **Verificar el Despliegue:**
    * Espera unos segundos y comprueba que el pod esté corriendo en el namespace `web-estatica`:

        kubectl get pods -n web-estatica -w
       
    * Deberías ver un pod con el nombre `static-website-deployment-...` en estado `Running` y `READY 1/1`. Presiona `Ctrl+C` para salir del modo watch.
    * Puedes verificar todos los recursos creados con:
        
        kubectl get all -n web-estatica
        kubectl get pv # El PV no está en el namespace
        

## Acceso a la Aplicación

Para acceder al sitio web desplegado desde tu navegador:

1.  Ejecuta el siguiente comando de Minikube, especificando el namespace:
   
    minikube service static-website-service -n web-estatica
    
2.  Esto debería abrir automáticamente tu navegador en la URL correcta (algo como `http://127.0.0.1:xxxxx`). Verás el contenido de tu carpeta `static-website`.

## Limpieza (Opcional)

Para detener y eliminar los recursos creados:

1.  **Detener el túnel del servicio:** Presiona `Ctrl+C` en la terminal donde ejecutaste `minikube service ...`.
2.  **Eliminar los recursos de Kubernetes:**
     
     # Borra los objetos del namespace web-estatica
    kubectl delete -f deployment.yaml -n web-estatica
    kubectl delete -f service.yaml -n web-estatica
    kubectl delete -f pvc.yaml -n web-estatica
     # Borra el PV (cluster-wide) y el Namespace
    kubectl delete -f pv.yaml
    kubectl delete -f namespace.yaml
    ```
3.  **Detener el montaje:** Cierra la terminal donde estaba corriendo `minikube mount`.
4.  **Detener Minikube:**
   
    minikube stop
 
5.  **(Opcional) Eliminar el clúster Minikube completamente:**
   
    minikube delete
  