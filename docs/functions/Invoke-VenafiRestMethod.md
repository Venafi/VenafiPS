# Invoke-VenafiRestMethod

## SYNOPSIS
Ability to execute REST API calls which don't exist in a dedicated function yet

## SYNTAX

### Session (Default)
```
Invoke-VenafiRestMethod [-VenafiSession <PSObject>] [-Method <String>] [-UriRoot <String>] -UriLeaf <String>
 [-Header <Hashtable>] [-Body <Hashtable>] [-FullResponse] [-SkipCertificateCheck] [<CommonParameters>]
```

### URL
```
Invoke-VenafiRestMethod -Server <String> [-UseDefaultCredential] [-Certificate <X509Certificate>]
 [-Method <String>] [-UriRoot <String>] -UriLeaf <String> [-Header <Hashtable>] [-Body <Hashtable>]
 [-FullResponse] [-SkipCertificateCheck] [<CommonParameters>]
```

## DESCRIPTION
Ability to execute REST API calls which don't exist in a dedicated function yet

## EXAMPLES

### EXAMPLE 1
```
Invoke-VenafiRestMethod -Method Delete -UriLeaf 'Discovery/{1345311e-83c5-4945-9b4b-1da0a17c45c6}'
Api call
```

### EXAMPLE 2
```
Invoke-VenafiRestMethod -Method Post -UriLeaf 'Certificates/Revoke' -Body @{'CertificateDN'='\ved\policy\mycert.com'}
Api call with optional payload
```

## PARAMETERS

### -VenafiSession
VenafiSession object from New-VenafiSession.
For typical calls to New-VenafiSession, the object will be stored as a session object named $VenafiSession.
Otherwise, if -PassThru was used, provide the resulting object.

```yaml
Type: PSObject
Parameter Sets: Session
Aliases: Key, AccessToken

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Server
{{ Fill Server Description }}

```yaml
Type: String
Parameter Sets: URL
Aliases: ServerUrl

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseDefaultCredential
{{ Fill UseDefaultCredential Description }}

```yaml
Type: SwitchParameter
Parameter Sets: URL
Aliases: UseDefaultCredentials

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Certificate
{{ Fill Certificate Description }}

```yaml
Type: X509Certificate
Parameter Sets: URL
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method
API method, either get, post, patch, put or delete.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Get
Accept pipeline input: False
Accept wildcard characters: False
```

### -UriRoot
{{ Fill UriRoot Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Vedsdk
Accept pipeline input: False
Accept wildcard characters: False
```

### -UriLeaf
Path to the api endpoint excluding the base url and site, eg.
certificates/import

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

### -Header
Optional additional headers. 
The authorization header will be included automatically.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body
Optional body to pass to the endpoint

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FullResponse
{{ Fill FullResponse Description }}

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

### -SkipCertificateCheck
{{ Fill SkipCertificateCheck Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS
