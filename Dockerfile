FROM mcr.microsoft.com/powershell:lts-alpine-3.14

RUN pwsh -Command 'Set-PSRepository PSGallery -InstallationPolicy Trusted; Install-Module VenafiPS -ErrorAction Stop'

ENV TPP_SERVER=${TPP_SERVER}
ENV TPP_TOKEN=${TPP_TOKEN}
ENV VAAS_KEY=${VAAS_KEY}
ENV POWERSHELL_TELEMETRY_OPTOUT=1

SHELL ["pwsh"]
