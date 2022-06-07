FROM mcr.microsoft.com/powershell:latest

SHELL ["pwsh"]

RUN Set-PSRepository PSGallery -InstallationPolicy Trusted
RUN Install-Module VenafiPS -ErrorAction Stop
