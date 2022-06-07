FROM mcr.microsoft.com/powershell:latest

SHELL ["pwsh"]

RUN -Command Set-PSRepository PSGallery -InstallationPolicy Trusted; Install-Module VenafiPS -ErrorAction Stop
