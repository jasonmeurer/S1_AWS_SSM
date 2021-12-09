#! /bin/bash

FILE_EXTENSION=''
PACKAGE_MANAGER=''
AGENT_INSTALL_SYNTAX=''
AGENT_FILE_NAME=''
AGENT_DOWNLOAD_LINK=''
VERSION_COMPARE_RESULT=''

Color_Off='\033[0m'       # Text Resets
# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow

# Check if awscli is installed.
function awscli_check () {
    if ! [[ -x "$(which aws)" ]]; then
        printf "\n${Yellow}INFO:  Installing awscli utility in order to interact with S1 API... ${Color_Off}\n"
        if [[ $1 = 'apt' ]]; then
            sudo apt-get update && sudo apt-get install -y awscli
        elif [[ $1 = 'yum' ]]; then
            sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
            sudo yum install -y awscli
        elif [[ $1 = 'zypper' ]]; then
            sudo zypper install -y awscli
        elif [[ $1 = 'dnf' ]]; then
            sudo dnf install -y awscli
        else
            printf "\n${Red}ERROR:  Unsupported file extension.${Color_Off}\n"
        fi
    else
        printf "${Yellow}INFO:  awscli is already installed.${Color_Off}\n"
    fi
}

# Check if curl is installed.
function curl_check () {
    if ! [[ -x "$(which curl)" ]]; then
        printf "\n${Yellow}INFO:  Installing curl utility in order to interact with S1 API... ${Color_Off}\n"
        if [[ $1 = 'apt' ]]; then
            sudo apt-get update && sudo apt-get install -y curl
        elif [[ $1 = 'yum' ]]; then
            sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
            sudo yum install -y curl
        elif [[ $1 = 'zypper' ]]; then
            sudo zypper install -y curl
        elif [[ $1 = 'dnf' ]]; then
            sudo dnf install -y curl
        else
            printf "\n${Red}ERROR:  Unsupported file extension.${Color_Off}\n"
        fi
    else
        printf "${Yellow}INFO:  curl is already installed.${Color_Off}\n"
    fi
}

# Detect if the Linux Platform uses RPM/DEB packages and the correct Package Manager to use
if (cat /etc/*release |grep 'ID=ubuntu' || cat /etc/*release |grep 'ID=debian'); then
    FILE_EXTENSION='.deb'
    PACKAGE_MANAGER='apt'
    AGENT_INSTALL_SYNTAX='dpkg -i'
elif (cat /etc/*release |grep 'ID="rhel"' || cat /etc/*release |grep 'ID="amzn"' || cat /etc/*release |grep 'ID="centos"' || cat /etc/*release |grep 'ID="ol"' || cat /etc/*release |grep 'ID="scientific"'); then
    FILE_EXTENSION='.rpm'
    PACKAGE_MANAGER='yum'
    AGENT_INSTALL_SYNTAX='rpm -i --nodigest'
elif (cat /etc/*release |grep 'ID="sles"'); then
    FILE_EXTENSION='.rpm'
    PACKAGE_MANAGER='zypper'
    AGENT_INSTALL_SYNTAX='rpm -i --nodigest'
elif (cat /etc/*release |grep 'ID="fedora"' || cat /etc/*release |grep 'ID=fedora'); then
    FILE_EXTENSION='.rpm'
    PACKAGE_MANAGER='dnf'
    AGENT_INSTALL_SYNTAX='rpm -i --nodigest'
else
    printf "\n${Red}ERROR:  Unknown Release ID: $1 ${Color_Off}\n"
    cat /etc/*release
    echo ""
fi


# sudo apt update &&
# sudo apt-get install -y awscli &&
curl_check $PACKAGE_MANAGER
awscli_check $PACKAGE_MANAGER
sudo curl -L "https://raw.githubusercontent.com/howie-howerton/s1-agents/master/s1-agent-helper.sh" -o s1-agent-helper.sh &&
sudo chmod +x s1-agent-helper.sh &&
secureAPI=$(aws ssm get-parameters --names S1_API_SECURE --with-decryption --region us-east-1 --query "Parameters[*].Value" --output text) &&
secureTOKEN=$(aws ssm get-parameters --names S1_SITE_TOKEN_SECURE --with-decryption --region us-east-1 --query "Parameters[*].Value" --output text) &&
echo $secureAPI &&
echo $secureTOKEN &&
sudo ./s1-agent-helper.sh {{ssm:S1_CONSOLE_PREFIX}} $secureAPI $secureTOKEN {{ssm:S1_VERSION_STATUS}}


