# 🚀 TechFlow Azure DevSecOps Challenge

Solución integral para el reto técnico de TechFlow. Esta arquitectura implementa un backend serverless altamente seguro utilizando **Azure Container Apps**, gestionado mediante **Terraform** y automatizado con **GitHub Actions**.

## 🏗️ Arquitectura de la Solución
* **Infraestructura:** Terraform Modular (Security, Registry, Compute).
* **App:** API en Python (Flask) con soporte para secretos vía Azure Key Vault.
* **Seguridad:** Managed Identity (Zero Trust), Escaneo IaC (Checkov) y Escaneo de Imágenes (Trivy).
* **Automatización:** GitFlow con pipelines diferenciados para Infraestructura (IaC) y Aplicación.

---

## 🛠️ Guía de Despliegue (Paso a Paso)

Sigue estas instrucciones cuidadosamente para asegurar que el entorno se aprovisione correctamente:

### 1. Fusión de Infraestructura (Merge PR)
Para iniciar el aprovisionamiento de los recursos en Azure, debes realizar el **Pull Request** y posterior **Merge** de la rama `feature/infra-setup` hacia la rama `develop`.
* Esto disparará el workflow `Terraform Plan & Apply`.
* **Nota:** Debes esperar a que este pipeline finalice con éxito antes de intentar desplegar la aplicación, ya que los recursos (ACR, Container App Environment) deben existir previamente.

### 2. Despliegue de la Aplicación (Workflow Dispatch)
Debido a que la infraestructura se entrega inicialmente en estado "destruido" (o inexistente), el pipeline automático disparado por el PR de la aplicación podría fallar al no encontrar los recursos de Azure aún activos.

Para solucionar esto, tienes dos opciones una vez que la infraestructura esté lista:
* **Opción A (Recomendada):** Ir a la pestaña **Actions**, seleccionar el workflow `Deploy Application` y ejecutarlo manualmente vía **Workflow Dispatch**.
* **Opción B:** Si el pipeline automático de la aplicación falló, simplemente dale a **"Re-run jobs"** una vez que el pipeline de Terraform haya terminado.

### 3. Verificación de Resultados
Una vez que el workflow `Deploy Application` finalice:
1.  Entra al **Summary** (Resumen) de la ejecución del Job en GitHub Actions.
2.  Busca la sección titulada **"🚀 Ingresa a este link para visualizar tu aplicación"**.
3.  Haz clic en el enlace de la FQDN generada para ver el JSON con el mensaje de éxito y el secreto recuperado de Key Vault.

---

## ⚙️ Componentes Técnicos

### Pipelines de CI/CD
* **`deploy-iac-plan-apply.yml`**: Gestiona el ciclo de vida de Terraform (Init, Plan, Apply). Incluye escaneo de seguridad estático.
* **`deploy-app.yml`**: Construye la imagen Docker, ejecuta escaneo de vulnerabilidades con **Trivy**, sube la imagen al **ACR** y actualiza la revisión de la Container App.
* **`deploy-iac-plan-destroy.yml`**: Permite limpiar el entorno manualmente mediante una confirmación de seguridad ("destroy").

### Gestión de Errores Conocidos
> [!IMPORTANT]
> **Carrera de recursos:** Si ejecutas la infraestructura y la aplicación al mismo tiempo, el despliegue de la app fallará porque el contenedor aún no existe en el registro. **Solución:** Re-ejecutar el pipeline de la aplicación una vez que la infraestructura confirme que el ACR y el servicio de cómputo están activos.

---

## 📝 Documentación de IA
Los detalles sobre los prompts utilizados para acelerar el desarrollo y la lógica detrás de las decisiones técnicas se encuentran en:
👉 [PROMPTS.md](./PROMPTS.md)

---
**Candidato:** DevSecOps Engineer - TechFlow Challenge 2026.