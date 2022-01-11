# Find-TppClient

## SYNOPSIS
Get information about registered Server Agents or Agentless clients

## SYNTAX

```
Find-TppClient [[-ClientType] <String>] [[-VenafiSession] <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Get information about registered Server Agent or Agentless clients.

## EXAMPLES

### EXAMPLE 1
```
Find-TppClient
```

Find all clients

### EXAMPLE 2
```
Find-TppClient -ClientType Portal
```

Find clients with the specific type

## PARAMETERS

### -ClientType
The client type.
Allowed values include VenafiAgent, AgentJuniorMachine, AgentJuniorUser, Portal, Agentless, PreEnrollment, iOS, Android

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
Session object created from New-VenafiSession method. 
The value defaults to the script session object $VenafiSession.

```yaml
Type: VenafiSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppClient/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppClient/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppClient.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppClient.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-ClientDetails.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-ClientDetails.php)

