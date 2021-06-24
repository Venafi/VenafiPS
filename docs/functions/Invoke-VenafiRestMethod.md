# Invoke-VenafiRestMethod

## SYNOPSIS
Generic REST API call

## SYNTAX

### Session (Default)
```
Invoke-VenafiRestMethod -VenafiSession <VenafiSession> [-Method <String>] [-UriRoot <String>] -UriLeaf <String>
 [-Header <Hashtable>] [-Body <Hashtable>] [-FullResponse] [<CommonParameters>]
```

### URL
```
Invoke-VenafiRestMethod -ServerUrl <String> [-UseDefaultCredentials] [-Method <String>] [-UriRoot <String>]
 -UriLeaf <String> [-Header <Hashtable>] [-Body <Hashtable>] [-FullResponse] [<CommonParameters>]
```

## DESCRIPTION
Generic REST API call

## EXAMPLES

### EXAMPLE 1
```

```

## PARAMETERS

### -VenafiSession
VenafiSession object from New-VenafiSession.
For typical calls to New-VenafiSession, the object will be stored as a session object named $VenafiSession.
Otherwise, if -PassThru was used, provide the resulting object.

```yaml
Type: VenafiSession
Parameter Sets: Session
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServerUrl
{{ Fill ServerUrl Description }}

```yaml
Type: String
Parameter Sets: URL
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseDefaultCredentials
{{ Fill UseDefaultCredentials Description }}

```yaml
Type: SwitchParameter
Parameter Sets: URL
Aliases:

Required: False
Position: Named
Default value: False
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS
