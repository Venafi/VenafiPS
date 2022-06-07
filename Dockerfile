FROM mcr.microsoft.com/powershell:latest

SHELL ["pwsh"]

RUN -c {Set-PSRepository PSGallery -InstallationPolicy Trusted; Install-Module VenafiPS -ErrorAction Stop}
