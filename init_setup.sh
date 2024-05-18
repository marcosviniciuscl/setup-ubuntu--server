#!/bin/bash

# Variáveis - ajuste conforme necessário
NOVO_USUARIO="marcos"
SSH_PORTA=22  # Altere se você estiver usando uma porta SSH diferente
SERVICOS_ADICIONAIS=(http https)  # Adicione serviços adicionais conforme necessário, por exemplo: "mysql"

# Passo 1: Criar um novo usuário
echo "Criando um novo usuário: $NOVO_USUARIO"
adduser $NOVO_USUARIO

# Passo 2: Adicionar o novo usuário ao grupo sudo
echo "Adicionando $NOVO_USUARIO ao grupo sudo"
usermod -aG sudo $NOVO_USUARIO

# Passo 3: Configurar autenticação de chave pública
echo "Configurando autenticação de chave pública para $NOVO_USUARIO"
echo "Por favor, copie a sua chave pública SSH (geralmente encontrada em ~/.ssh/id_rsa.pub):"
read -p "Chave Pública SSH: " SSH_CHAVE_PUBLICA
mkdir -p /home/$NOVO_USUARIO/.ssh
echo $SSH_CHAVE_PUBLICA > /home/$NOVO_USUARIO/.ssh/authorized_keys
chmod 700 /home/$NOVO_USUARIO/.ssh
chmod 600 /home/$NOVO_USUARIO/.ssh/authorized_keys
chown -R $NOVO_USUARIO:$NOVO_USUARIO /home/$NOVO_USUARIO/.ssh

# Passo 4: Configurar UFW
echo "Instalando e configurando UFW"
apt-get update
apt-get install -y ufw

# Permitir SSH
echo "Permitindo conexões SSH na porta $SSH_PORTA"
ufw allow $SSH_PORTA/tcp

# Permitir serviços adicionais
for servico in "${SERVICOS_ADICIONAIS[@]}"; do
    echo "Permitindo conexões para o serviço: $servico"
    ufw allow $servico
done

# Definir políticas padrão
echo "Definindo políticas padrão do UFW"
ufw default deny incoming
ufw default allow outgoing

# Ativar UFW
echo "Ativando UFW"
ufw --force enable

# Desativar login root via SSH
echo "Desativando login root via SSH"
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Reiniciar serviço SSH
echo "Reiniciando serviço SSH"
systemctl restart sshd

echo "Configuração completa! Agora você pode acessar seu VPS com o usuário $NOVO_USUARIO."
