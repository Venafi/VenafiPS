# New-VaasConnector

## SYNOPSIS
Create a new connector

## SYNTAX

```
New-VaasConnector [-Name] <String> [-Url] <String> [-EventType] <String[]> [[-Token] <PSCredential>]
 [-PassThru] [[-VenafiSession] <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Create a new connector

## EXAMPLES

### EXAMPLE 1
```
New-VaasConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Authentication'
```

Create a new connector

### EXAMPLE 2
```
New-VaasConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Authentication', 'Certificates', 'Applications'
```

Create a new connector with multiple event types

### EXAMPLE 3
```
New-VaasConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Authentication' -Token $myTokenCred
```

Create a new connector with optional token

### EXAMPLE 4
```
New-VaasConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Authentication' -PassThru
```

Create a new connector returning the newly created object

## PARAMETERS

### -Name
Connector name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Url
Endpoint to be called when the event type is triggered

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventType
One or more event types to trigger on.
You can retrieve a list of possible values from the Event Log and filtering on Event Type.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Token
Token/secret to pass to Url for authentication.
Set the token as the password on a pscredential.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return newly created connector object

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A VaaS key can also provided.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSCustomObject, if PassThru provided
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/New-VaasConnector/](http://VenafiPS.readthedocs.io/en/latest/functions/New-VaasConnector/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VaasConnector.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VaasConnector.ps1)

[https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=connectors-service#/Connectors/connectors_create](https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=connectors-service#/Connectors/connectors_create)

