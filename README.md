# Projeto: pipeline de CI/CD governado

## Objetivo
Demonstrar na prática o fluxo de CI/CD que a vaga de Engenharia de Plataforma Júnior do Itaú pede:
GitHub Actions (CI) + Artifactory (artefatos) + Terraform (infraestrutura) + Harness (CD com RBAC).

## Estrutura do repositório
- `app.py` / `test_app.py` / `requirements.txt` / `Dockerfile` -> API simples em Flask, com endpoint de health-check
- `.github/workflows/ci.yml` -> pipeline de CI: instala dependências, roda os testes, builda a imagem Docker e publica no Artifactory
- `terraform/main.tf` -> provisiona a infraestrutura na AWS (EC2 + Security Group + IAM Role com policy de menor privilégio)

## Próximos passos
1. Criar conta gratuita no JFrog Artifactory Cloud e configurar um repositório Docker
2. Adicionar os secrets no GitHub: `ARTIFACTORY_URL`, `ARTIFACTORY_USER`, `ARTIFACTORY_TOKEN`
3. Rodar `terraform init` e `terraform plan` localmente para validar o código (não precisa aplicar de verdade ainda)
4. Criar conta gratuita no Harness e configurar Connectors para GitHub, AWS e Artifactory
5. Montar um pipeline no Harness com duas Stages: deploy automático em "dev" e um step de Approval antes de "prod"

## Como cada peça conecta com a vaga
- GitHub Actions -> CI: build e testes automatizados a cada push
- Artifactory -> armazena o artefato (imagem Docker) gerado pelo CI e as dependências do projeto
- Terraform -> cria a infraestrutura na AWS de forma automatizada (Infrastructure as Code, equivalente ao Cloudformation/Terraform da descrição da vaga)
- IAM Role com policy restrita (`least_privilege_policy`) -> exemplo concreto de RBAC e menor privilégio na prática
- Harness -> orquestra o deploy final, pegando o artefato do Artifactory e rodando na infraestrutura, com um gate de aprovação simulando governança antes de produção
