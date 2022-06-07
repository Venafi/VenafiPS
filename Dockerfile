FROM mcr.microsoft.com/powershell:latest

SHELL ["pwsh"]

RUN pwsh -Command Set-PSRepository PSGallery -InstallationPolicy Trusted; Install-Module VenafiPS -ErrorAction Stop
