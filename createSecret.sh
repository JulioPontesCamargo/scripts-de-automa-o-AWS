#!/bin/bash

# Definindo o perfil da conta AWS
aws_profile="julio_dev"

# Solicitando o nome do Secret
echo "Digite o nome do Secret: "
read secret_name

# Solicitando o caminho do arquivo de texto
echo "Digite o caminho do arquivo de texto (ou pressione Enter para usar o valor padrão): "
read text_file_path

# Definindo o valor padrão da secret
default_secret_value="KEY_EXEMPLE=secret_value_exemple"

# Verificando se o caminho do arquivo de texto foi fornecido
if [ -z "$text_file_path" ]; then
    # Usando o valor padrão se o caminho do arquivo não foi fornecido
    secret_value="$default_secret_value"
else
    # Verificando se o arquivo de texto existe
    if [ ! -f "$text_file_path" ]; then
        echo "Erro: Arquivo não encontrado: $text_file_path"
        exit 1
    fi

    # Lendo o conteúdo do arquivo de texto
    secret_value=$(cat "$text_file_path")
fi

# Verificando se a secret já existe
existing_secret_arn=$(aws secretsmanager describe-secret \
    --profile "$aws_profile" \
    --secret-id "$secret_name" \
    --query 'ARN' \
    --output text 2>/dev/null)

if [ -n "$existing_secret_arn" ]; then
    echo "Secret '$secret_name' já existe. ARN: $existing_secret_arn"
else
    # Definindo as tags
    tags="Key=product,Value=space"

    # Criando o Secret Manager
    aws secretsmanager create-secret \
        --profile "$aws_profile" \
        --name "$secret_name" \
        --secret-string "$secret_value" \
        --tags "$tags" \
        > /dev/null

    # Verificando se o Secret foi criado com sucesso
    if [ $? -eq 0 ]; then
        echo "Secret '$secret_name' criado com sucesso!"

        # Obtendo o ARN da secret criada
        secret_arn=$(aws secretsmanager describe-secret \
            --profile "$aws_profile" \
            --secret-id "$secret_name" \
            --query 'ARN' \
            --output text)
        
        echo "ARN da secret '$secret_name': $secret_arn"
    else
        echo "Erro ao criar Secret '$secret_name': Falha na comunicação com a AWS."
    fi
fi
