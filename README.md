# automated-CI-CD-pipeline

A lightweight web application built with **Flask** and fully **Dockerized** for easy deployment.

## 🚀 Features
* **Backend:** Flask (Python)
* **Containerization:** Docker for isolated and reproducible environments
* **CI/CD:** Automated testing and deployment via GitHub Actions (Coming Soon)

---

## 🛠️ Local Development (Without Docker)

If you want to run the project locally using a Python virtual environment:

1. **Clone the repository:**
   ```bash
   git clone <your-github-repo-url>
   cd <repository-folder>
   ```

2. **Create and activate a virtual environment:**
   * **Linux:**
     ```bash
     python3 -m venv venv
     source venv/bin/activate

     ```
3. **Install the dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application:**
   ```bash
   python main.py
   ```
   The app will be available at `http://localhost:5000`.

---

## 🐳 Running with Docker

To build and run the application inside a isolated Docker container:

1. **Build the Docker image:**
   ```bash
   docker build -t flask-local-app .
   ```

2. **Run the Docker container:**
   ```bash
   docker run -p 5000:5000 flask-local-app
   ```
   Open your browser and navigate to `http://localhost:5000`.

---


## 🔄 CI/CD Pipeline

An automated GitHub Actions pipeline (`.github/workflows/devops-pipeline.yml`) that triggers on every push or pull request to the `main` branch. It automatically:
1. Sets up the Python environment.
2. Installs required dependencies.
3. Executes unit tests via `pytest`.
4. Validates the Docker build inside the `./Aesthetic-Calculator-main` context.


---

## 🚀 Deployment & Operational Workflows

### 1. CI/CD (GitHub Actions)
Every `push` or `pull request` to the `main` branch automatically fires a workflow that:
1. Provisions an isolated Ubuntu worker environment.
2. Installs dependencies and runs unit tests via `pytest`.
3. Asserts container integrity by building the local Docker context.

### 2. Infrastructure Provisioning (Terraform)
The underlying host infrastructure is fully defined and provisioned via code:
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. Configuration Management & Observability (Ansible)
Once the infrastructure is up, Ansible handles the zero-touch configuration of the environment:
```bash
cd ansible
ansible-playbook -i inventory.ini configure-server.yml
```
*This playbook automatically installs Docker, configures Nginx routing, and deploys the Prometheus/Grafana monitoring agents.*

### 4. Web App Deployment (🚧 Next Phase / In Progress)
The application architecture is fully primed for deployment. The next step is updating the GitHub Actions pipeline or Ansible playbooks to handle the automated deployment of the Flask container onto the active host.
