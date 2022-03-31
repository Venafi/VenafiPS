# New-VenafiTeam

## SYNOPSIS
Create a new team

## SYNTAX

### VaaS
```
New-VenafiTeam -Name <String> -Owner <String[]> -Member <String[]> -Role <String> [-PassThru]
 [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### TPP
```
New-VenafiTeam -Name <String> -Owner <String[]> -Member <String[]> [-Policy <String[]>] -Product <String[]>
 [-Description <String>] [-PassThru] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Create a new VaaS or TPP team

## EXAMPLES

### EXAMPLE 1
```
New-VenafiTeam -Name 'My New Team' -Member 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4') -Role 'System Admin'
```

Create a new VaaS team

### EXAMPLE 2
```
New-VenafiTeam -Name 'My New Team' -Member 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4') -Role 'System Admin' -PassThru
```

id                : a7d60730-a967-11ec-8832-4d051bf6d0b4
name              : My New Team
systemRoles       : {SYSTEM_ADMIN}
productRoles      :
role              : SYSTEM_ADMIN
members           : {443de910-a6cc-11ec-ad22-018e33741844}
owners            : {0a2adae0-b22b-11ea-91f3-ebd6dea5452e}
companyId         : 09b24f81-b22b-11ea-91f3-ebd6dea5452e
userMatchingRules : {}
modificationDate  : 3/21/2022 6:38:40 PM

Create a new VaaS team returning the new team

### EXAMPLE 3
```
New-VenafiTeam -Name 'My New Team' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}' -Product 'TLS'
```

Create a new TPP team

### EXAMPLE 4
```
New-VenafiTeam -Name 'My New Team' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}' -Product 'TLS' -Policy '\ved\policy\myfolder'
```

Create a new TPP team and assign it to a policy

### EXAMPLE 5
```
New-VenafiTeam -Name 'My New Team' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}' -Product 'TLS' -Description 'One amazing team'
```

Create a new TPP team with optional description

### EXAMPLE 6
```
New-VenafiTeam -Name 'My New Team' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}' -Product 'TLS' -PassThru
```

Name     : My New Team
ID       : local:{a6053090-e309-49d9-98a7-28cbe7896c27}
Path     : \VED\Identity\My New Team
FullName : local:My New Team
IsGroup  : True
Members  : @{Name=sample-user; ID=local:{6baad36c-7cac-48c8-8e54-000cc22ad88f};
           Path=\VED\Identity\sample-user; FullName=local:sample-user; IsGroup=False}
Owners   : @{Name=sample-owner; ID=local:{d1a76bc7-d3a6-431b-9bea-d2d8780ecd86};
           Path=\VED\Identity\sample-owner; FullName=local:sample-owner; IsGroup=False}

Create a new TPP team returning the new team

## PARAMETERS

### -Name
Team name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Owner
1 or more owners for the team
For VaaS, this is the unique guid obtained from Get-VenafiIdentity.
For TPP, this is the identity ID property from Find-TppIdentity or Get-VenafiIdentity.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Member
1 or more members for the team
For VaaS, this is the unique guid obtained from Get-VenafiIdentity.
For TPP, this is the identity ID property from Find-TppIdentity or Get-VenafiIdentity.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Role
Team role, either 'System Admin', 'PKI Admin', 'Resource Owner' or 'Guest'. 
VaaS only.

```yaml
Type: String
Parameter Sets: VaaS
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Policy
1 or more policy folder paths this team manages. 
TPP only.

```yaml
Type: String[]
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Product
1 or more product names, 'TLS', 'SSH', and/or 'Code Signing'. 
TPP only.

```yaml
Type: String[]
Parameter Sets: TPP
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Team description or purpose. 
TPP only.

```yaml
Type: String
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
{{ Fill PassThru Description }}

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
Session object created from New-VenafiSession method. 
The value defaults to the script session object $VenafiSession.

```yaml
Type: VenafiSession
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/create_1](https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/create_1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Teams.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Teams.php)

