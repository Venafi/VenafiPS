FROM mcr.microsoft.com/powershell:lts-alpine-3.14

RUN pwsh -Command 'Set-PSRepository PSGallery -InstallationPolicy Trusted; Install-Module VenafiPS -ErrorAction Stop'

ENV TLSPDC_SERVER=${TLSPDC_SERVER}
ENV TLSPDC_TOKEN=${TLSPDC_TOKEN}
ENV TLSPC_KEY=${TLSPC_KEY}
ENV POWERSHELL_TELEMETRY_OPTOUT=1

SHELL ["pwsh"]
