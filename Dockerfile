FROM mcr.microsoft.com/azure-powershell:latest
RUN apt-get update && curl -sL https://aka.ms/InstallAzureCLIDeb | bash
