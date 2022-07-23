## 4.6.3
- Add paging support to `Find-VenafiCertificate` for VaaS
- Update `Get-VaasApplication -ID` and `Get-VenafiTeam -ID` for VaaS to accept a name in addition to guid


## 4.6.2
- Fix `Set-TppAttribute` failing to set a custom field value on a policy, [#131](https://github.com/Venafi/VenafiPS/issues/131)


## 4.6.1
- Add validation and error handling in `Get-VenafiTeam` for invalid IDs, [#126](https://github.com/Venafi/VenafiPS/issues/126)
- Add messaging and error handling in `Get-VenafiTeam` for local groups, [#127](https://github.com/Venafi/VenafiPS/issues/127)
- Add support for PrefixedName identity format in `Test-TppIdentity` and `Get-VenafiIdentity`, [#128](https://github.com/Venafi/VenafiPS/issues/128)
- Fix Split-Path failing in TppObject class, and other functions where applicable, when PowerShell reserved characters are used in the object name, [#129](https://github.com/Venafi/VenafiPS/issues/129)


## 4.6.0
- Add `Import-VaasCertificate`.  Export from TPP right into VaaS (and vice versa).
- `Import-TppCertificate` updates
   - Add pipelining with either `-CertificatePath` or `CertificateData`.  You can provide FileInfo objects or just an array of paths.
   - If using PS v6+, import will now use parallel processing.  Control the number of certificates imported at once with the new parameter `-ThrottleLimit`.  This is definitely the recommended approach for bulk importing.
   - Add prepending '\ved\policy' to `-PolicyPath` if not provided
 - `Get-TppAttribute` updates
   - `-Attribute` can now accept custom field labels/names to retrieve the value, [#74](https://github.com/Venafi/VenafiPS/issues/74)
   - Return Locked and Overridden values where applicable
   - Notify user when attribute name provided to `-Attribute` is not valid
 - Fix SecretManagement module existence check not always being triggered in `New-VenafiSession`, [#123](https://github.com/Venafi/VenafiPS/issues/123)
 - Add 'certificate' field to `Write-VerboseWithSecret` to hide certificate data being passed to VaaS
 - Allow any attribute names for `Get-TppIdentityAttribute -Attribute`, [#125](https://github.com/Venafi/VenafiPS/issues/125)


## 4.5.0
- Add docker image with each new build and [publish to dockerhub](https://hub.docker.com/repository/docker/venafi/venafips-module).  Add the below environment variables recognition for use with docker image, but could be used outside of it as well.  This is great for ci/cd scenarios and more.
  - TPP_SERVER - TPP server url
  - TPP_TOKEN - TPP oauth token
  - VAAS_KEY - VaaS key
- Fix `Set-TppAttribute` not clearing a value.  You can now pass $null to clear an object's attribute value, [#119](https://github.com/Venafi/VenafiPS/issues/119)


## 4.4.0
- Add `New-VaasApplication` to create a new application on VaaS
- Add `Get-VaasIssuingTemplate` to retrieve 1 or all certificate issuing templates on VaaS
- Add `-All` parameter to `Get-VaasApplication` to retrieve all applications
- Deprecate `Get-VaasOrgUnit` as it's being deprecated by VaaS


## 4.3.0
- Add new output format for `Get-TppAttribute` using the parameter `-New`.  Attributes will now be provided as object properties as opposed to individual objects for each property, which made it difficult to retrieve the value itself.  This new format is available for all ways of using the function including attribute, effective attribute, and policy retrieval.  This new format will become the default in the future.
- Add `Get-TppAttribute -PolicyClass -All` to retrieve all policy attributes at once
- Add `New-TppCertificate -WorkToDoTimeout` to override the global setting for a CA to issue/renew certificate
- Add support for api limitation of 5k clients at a time when calling `Remove-TppClient`
- Add support for VaaS user matching rules with `New-VenafiTeam`
- Add setting common name, if not provided, as the object name in `New-TppCertificate`, [#110](https://github.com/Venafi/VenafiPS/issues/110)
- Fix syntax error when using `New-TppCertificate -Csr`, [#111](https://github.com/Venafi/VenafiPS/issues/111)
- `-Guid` has been deprecated from `Get-TppAttribute`


## 4.2.4
- Add `Search-TppHistory` to find historical items by attribute value and their associated current item
- Fix `Move-TppObject` not appending object name when moving multiple objects to a new folder and passed via pipeline
- Update `Find-TppObject` to allow passing of empty string for `-Pattern` to find objects which don't have a value set


## 4.2.3
- Fix certain aliases not being exported

## 4.2.2
- Add authentication options, VaaS key or TPP token, in addition to VenafiSession to be provided directly to any function that supports that platform.  This better enables devops scenarios so 1 call can be made for a function as opposed to executing New-VenafiSession first.  Note, if using this with TPP, an environment variable named TppServer with the url of the server must be set.
- Add `Test-VenafiSession` private function to add support for the new authentication methods as VenafiSession.Validate isn't used.  `Invoke-VenafiRestMethod` has been updated to accept these new authentication methods as well.
- Add option to export from VaaS in JKS format
- Migrate docs site to Material theme

## 4.2.1
- Update `Find-TppCertificate` to `Find-VenafiCertificate` and add VaaS certificate search functionality
- Add `-Policy` to `New-VenafiTeam` so a team can be associated with one or more policies
- Fix `PolicyPath` property of `TppObject` not returning the proper value due to special characters


## 4.2.0
- Add `New-VaasSearchQuery` (private function) as the framework for VaaS searching including filtering, ordering, and paging.  This will be used by certificate search, log search, and probably more in the future.
- Add `Read-VenafiLog` utilizing the new search framework for VaaS.  Merge existing `Read-TppLog` into 1 function to support both VaaS and TPP.
- Add `Get-VenafiTeam` to retrieve all or specific team info, VaaS and TPP
- Add `New-VenafiTeam` to create a new team, VaaS and TPP
- Add `Remove-VenafiTeam` to remove a team, VaaS and TPP
- Add `Add-VenafiTeamMember` to add a team member, VaaS and TPP
- Add `Add-VenafiTeamOwner` to add a team owner, VaaS and TPP
- Add `Remove-VenafiTeamMember` to remove a team member, VaaS and TPP
- Add `Remove-VenafiTeamOwner` to remove a team owner, VaaS and TPP
- Add `ConvertTo-TppIdentity` to standardize TPP identity objects
- Add `Get-VenafiIdentity` to retrieve a specific identity, the current user, or all, VaaS and TPP.  This replaces `Get-TppIdentity`.  The ability to retrieve associated identities and group members has been extended to `-All`.
- Change `Invoke-TppRestMethod` to `Invoke-VenafiRestMethod` in remaining internal module calls
- Move key/token refresh messaging to TPP only in `VenafiSession` as no refresh for VaaS
- Default `-UriRoot` in `Invoke-VenafiRestMethod` to v1 for VaaS


## 4.1.6
- Fix `VenafiSession` reporting incorrect session platform on PS v5
- Fix `Export-VenafiCertificate` for VaaS failing with ConvertTo-Json error


## 4.1.5
- Add support for double slash paths used by the adaptable framework, [#75](https://github.com/Venafi/VenafiPS/issues/75)
- Add `AsValue` parameter to `Get-TppAttribute` making it easy to retrieve just the value when 1 attribute is requested
- Update return type when using `Find-TppCertificate -CountOnly` from string to int


## 4.1.4
- Add `-IncludeMembers` parameter to `Get-TppIdentity` to include members if the identity is a group, [#83](https://github.com/Venafi/VenafiPS/issues/83)
- Update `Get-TppIdentity` to return `IsGroup` for all objects, not just ones where IsGroup is true
- Update `Get-TppIdentity -IncludeAssociated` to return the property `Associated` for all objects, not just ones where there was a value
- Add `-VaultAccessTokenName` to `Test-TppToken` to validate a token stored in a vault, [#81](https://github.com/Venafi/VenafiPS/issues/81)


## 4.1.3
- Add `-Csr` parameter to `New-TppCertificate` and `Invoke-TppCertificateRenewal`, [#76](https://github.com/Venafi/VenafiPS/issues/76)
- Add `-Device` and `-Application` parameters to `New-TppCertificate` to allow creation of devices and apps
- Add `NoWorkToDo` parameter to `New-TppCertificate` to turn off processing for that update
- Fix revision part of version being -1 when running `Get-TppVersion`, [#80](https://github.com/Venafi/VenafiPS/issues/80)
- Fix Invoke-VenafiRestMethod alias not working in PS v5 in VenafiSession, [#85](https://github.com/Venafi/VenafiPS/issues/85)
- Fix duplicate parameter error using `-IncludeAssociated` in `Get-TppIdentity`, [#82](https://github.com/Venafi/VenafiPS/issues/82)
- Update vault usage in readme, [#78](https://github.com/Venafi/VenafiPS/issues/78)


## 4.1.2
- [#71](https://github.com/Venafi/VenafiPS/issues/71), add group and event id validation to `Write-TppLog` as well as help updates
- Add the ability to access classes and enums outside the module
- Add paging to `Find-TppCertificate`, deprecation messaging for `-Limit` and `-Offset` in favor of PS standard `-First` and `-Skip`
- Update `Get-VenafiCertificate` to ensure empty values for some date properties don't cause an exception


## 4.1.1
- [#69](https://github.com/Venafi/VenafiPS/issues/69), add `-CustomField` property to `New-TppCertificate`, required when working with mandatory custom fields.
- Update `New-TppCertificate` to ensure `-CertificateType` property is honored
- Update with new Venafi logo


## 4.1.0
- **BREAKING CHANGE**: Fix [#4](https://github.com/Venafi/VenafiPS/issues/4), Remove-TppCertificate deletes associated objects by default, add `-KeepAssociatedApps` and remove `-Force`
- Add pipeline support to `-SourcePath` in `Move-TppObject`.  Use this to move multiple objects to the same target path.
- Add `New-TppCustomField`
- Add `-PassThru` option to `Convert-TppObject`.  This is helpful in piping to Set-TppAttribute to update the driver and any other attributes needed.
- Update `Find-TppObject` class search to default to searching all policies recursively if no path provided
- Add Platform and AuthType properties to VenafiSession class.  This helps better define and validate tpp vs vaas and key vs token.
- Cleanup all docs.venafi.com links to reference 'current' instead of a specific version
- Fix [#63](https://github.com/Venafi/VenafiPS/issues/63), New-VenafiSession vault params fail if SecretManagement module not loaded in current session
- Better document token/key secret usage in readme


## 4.0.1
- Help updates, [#56](https://github.com/Venafi/VenafiPS/issues/56)

## 4.0.0
- Moved to Venafi GitHub org, rebranded
- **License is now Apache 2.0**
- Add `Find-TppClient` to get information about registered Server Agents or Agentless clients
- Add `Find-TppVaultId` to find vault IDs in the secret store
- Add `Get-TppCredential` to get different credential types, password, username/password, certificate
- Add parameter `-IncludeAssociated` to `Get-TppIdentity` to retrieve associated groups and folders
- Add `Remove-TppClient` to remove registered client agents
- Add `Set-TppCredential` to update credential values

## 3.5.2
- Convert dates from ISO 8601 to datetime objects in `Get-VenafiCertificate`

## 3.5.1
- Older versions of TPP failing to update attributes, [#50](https://github.com/Venafi/VenafiPS/issues/50)
- Fix pipeline for `-Path` parameter with `Set-TppAttribute`

## 3.5.0
- BREAKING CHANGE: change parameter `-NewName` to `-NewPath` in `Rename-TppObject` to allow moving an object in addition to renaming
- Add `Convert-TppObject` to change the class/type of an existing object
- Fix typos in examples for `Add-TppCertificateAssociation` and `Remove-TppCertificateAssociation`
- Set the default for `-Path` in `Find-TppObject` to \ved\policy.  Running `Find-TppObject` without a path will now recursively search from \ved\policy.
- Add additional pipeline options to `Get-TppAttribute`
- Add help and examples to `Invoke-VenafiRestMethod`, [#48](https://github.com/Venafi/VenafiPS/issues/48)
- Set VenafiSession default value in `Invoke-VenafiRestMethod`, [#47](https://github.com/Venafi/VenafiPS/issues/47)

## 3.4.0
- Add `-All` option to `Get-TppAttribute` to get ALL effective attribute values for an object.  This will provide the values as well as the path where the policy was applied
- Add getting policies (policy attributes) with `Get-TppAttribute`
- Add setting policies (policy attributes) with `Set-TppAttribute`
- Add `Invoke-VenafiCertificateAction`.  This is your one stop shop for certificate actions on TPP or VaaS.  You can Retire, Reset, Renew, Push, Validate, or Revoke.
- Cleanup output and verbose logging with `Remove-TppCertificate`
- Fix parameter set issue in `New-VenafiSession`, ensure version and custom field info retrieval doesn't occur when creating a VaaS session

## 3.3.1
- Remove validation/limitation from `Get-TppCustomField` to only retrieve classes of type X509 Certificate and Device
- Retrieve Application Base custom fields during `New-VenafiSession`
- Fix parameter sets in `Import-TppCertificate` requiring PrivateKey be provided with PKCS#12 certificate, [#37](https://github.com/Venafi/VenafiPS/issues/37)
- Add `-CertificateAuthorityAttribute` to `New-TppCertificate` to submit values to the CA during enrollment

## 3.3.0
- Add support for local token/key storage with [PowerShell SecretManagement](https://devblogs.microsoft.com/powershell/secretmanagement-and-secretstore-are-generally-available/).  Store your access or refresh token securely and have VenafiPS use it to create a new session.
- Add `Get-TppClassAttribute` to list all attributes for a specific class.  Helpful for attribute validation and getting values for all attributes.

## 3.2.0
- Add support for token refresh to `New-VenafiSession` and `New-TppToken`.  Auto-refresh $VenafiSession when token expires and we have a refresh token.  [#33](https://github.com/Venafi/VenafiPS/issues/33)
- Fix invalid grant details in `Test-TppToken`, [#32](https://github.com/Venafi/VenafiPS/issues/32)
- Update Version in VenafiSession object, from `Get-TppVersion`, to be of type Version.  Drop Revision from version so now only 3 octets.  This assists in performing version validation.
- Update `New-TppToken` to account for a bug in pre 21.3 which expected the client_id to be lowercase
- Update `Test-TppToken` to validate the tpp version is supported

## 3.1.7
- Fix/finalize certificate-based oauth token support, [#29](https://github.com/Venafi/VenafiPS/issues/29)

## 3.1.6
- Thanks to @harrisonmeister for this contribution!
- Add support to `Export-VenafiCertificate` for `-IncludeChain` and `-IncludePrivateKey` when using JKS format, [#24](https://github.com/Venafi/VenafiPS/issues/24) and [#26](https://github.com/Venafi/VenafiPS/issues/26)
- Add 'CertificateData' to the list of values hidden with `Write-VerboseWithSecret`, [#25](https://github.com/Venafi/VenafiPS/issues/25)
- Help updates

## 3.1.5
- Thanks to @wilddev65 for this contribution!
- Add `Test-TppToken` function to test if a TPP token is valid.
  - Tests an AccessToken, TppToken, or VenafiSession
  - `-GrantDetail` parameter returns detailed info about token from TPP server response
- Update `New-TppToken` to capture the refresh token expiry if part of the response.
- Update `Find-TppCertificate` to add `-CertificateType` as a parameter to filter results by type of certificate.  Can use CodeSigning, Device, Server, and/or User.
- Update `Get-VenafiCertificate` to get historical certificate versions with `-IncludePreviousVersions`.  `-ExcludeExpired` and `-ExcludeRevoked` filters the results.

## 3.1.4
- Fix [#19](https://github.com/Venafi/VenafiPS/issues/19), `Revoke-TppToken -AccessToken` not decrypting password
- Update `Set-TppAttribute`
  - Change from name and value parameters to hashtable
  - API calls were sending deprecated payloads, fix this
  - Add custom field validation and `-BypassValidation` switch.  The validation is field type aware and will validate string, date, list, and identity.

## 3.1.3
- Add `-Force` parameter to `Revoke-TppToken` and `Revoke-TppCertificate` to bypass confirmation prompt

## 3.1.2
- Add `-EventId` parameter to `Read-TppLog` to filter by a specific event id.
- Add EventId to `Read-TppLog` output.  The value matches the hex value seen in Event Definitions in TPP.

## 3.1.1
- Add -UseBasicParsing to `Invoke-WebRequest` to avoid IE profile error

## 3.1.0
- Add `-CountOnly` to `Find-TppCertificate` to return the number of certificates found based on the filters provided, [#12](https://github.com/Venafi/VenafiPS/issues/12)
- Move from `Invoke-RestMethod` to `Invoke-WebRequest` in `Invoke-VenafiRestMethod` so we get response headers, to be used with `-CountOnly` above.  `Invoke-VenafiRestMethod` has a new parameter, `-FullResponse`, to retrieve the complete response, not just content value.
- Add `New-HttpQueryString` private function to support HEAD api calls which require a query string and not body.
- Fix `Test-TppIdentityFormat` which was failing when the identity guid was surrounded with curly braces
- Replace `-Limit` parameter and standardize on `-First`

## 3.0.3
- Fix [#10](https://github.com/Venafi/VenafiPS/issues/10), Get-VenafiCertificate not recognizing session.

## 3.0.2
- Add `Test-ModuleHash` to validate the script files in the module.  The release pipeline has been updated to create a GitHub release with a file which stores the file hashes with SHA256.  This function will validate the current module against these hashes and provide true/false for success or failure.

## 3.0.1
- Fix [#6](https://github.com/Venafi/VenafiPS/issues/6), truncation on json conversion.

## 3.0
- Rebrand from VenafiTppPS to VenafiPS as the module will now support Venafi products other than TPP.  Functions with -Tpp in the name will now be TPP only, -Vaas will be for Venafi as a Service only, and -Venafi will be both
- Rename `New-TppSession` to `New-VenafiSession` and add support for Venafi as a Service.  Use the parameter `-VaasKey`
- Rename `Get-TppCertificate` to `Export-VenafiCertificate` and now supports Venafi as a Service.  Alias added so existing scripts don't break.
- Rename `Get-TppCertificateDetail` to `Get-VenafiCertificate` and now supports Venafi as a Service.  Alias added so existing scripts don't break.
- Add `Get-VaasOrgUnit` for OutagePREDICT
- Add `Get-VaasApplication` for OutagePREDICT
- Rename `Invoke-TppRestMethod` to `Invoke-VenafiRestMethod`
- All tokens and keys have been changed from plaintext to PSCredential for added security

## 2.2.4
- Add `-KeystorePassword` option to `Get-TppCertificate`.  [#147](https://github.com/gdbarron/VenafiTppPS/issues/147).  Thanks @Curtmcgirt!

## 2.2.3
- Fix [#145](https://github.com/gdbarron/VenafiTppPS/issues/145), `Revoke-TppToken` doesn't show target.  Thanks @wilddev65!

## 2.2.2
- Rename 'Provision' to 'Push', aliases added for existing code
- Add `Invoke-TppCertificatePush`
- Fix [#130](https://github.com/gdbarron/VenafiTppPS/issues/130), `Get-TppDevice` only accepting IP address for host, not hostname.  Thanks @Curtmcgirt!
- Fix [#131](https://github.com/gdbarron/VenafiTppPS/issues/131), add examples to `New-TppCapiApplication`.  Thanks @Curtmcgirt!
- Fix [#132](https://github.com/gdbarron/VenafiTppPS/issues/132), 500 error setting BindingIpAddress running `New-TppCapiApplication`.    Thanks @Curtmcgirt!
- Fix [#134](https://github.com/gdbarron/VenafiTppPS/issues/134), server url is blank when running `Get-TppObject` with secondary token.  This was an issue for `Get-TppPermission` as well.  Thanks @stevekeever!
- Add missing parameters comment-based help for `New-TppCapiApplication`
- Fix certificate push not working in `New-TppCapiApplication`
- Update links to reference `main` branch instead of `master`

## v2.2.0
- Identity format validation fix, [#126](https://github.com/gdbarron/VenafiTppPS/issues/126).  Thanks @DadsVacayShorts!
- Add `Get-TppIdentity` to retrieve Identity info given an id
- Add `Remove-TppPermission`, accepts output from `Get-TppPermission`
- Add Path param to `Set-TppPermission` in addition to guid
- `Get-TppPermission` now accepts TppObject, eg. from `Find-TppObject`
- `Set-TppPermission` now accepts output from `Get-TppPermission` for the object and IdentityId so you only need to specify Permission. No need to get guid and identity manually to pass in.
- `Find-TppIdentity` output standardized so you can now pipe to permission functions
- `Get-TppPermission` returns additional object and identity info
- Centralize format validation for identities
- Update help links referring to versions no longer available
- `Find-TppIdentity -Me` to be deprecated for `Get-TppIdentity -Me`
- Add option to `Get-TppObject` for guid
- Standardized on Id/IdentityId for the identity across all identity and permission functions
- Force missing slash retry to status codes of only 307 and 401
- Better error handling and messaging through the permission functions

## v2.1.1
- `Get-TppPermission` fix when retrieving multiple permissions, [#124](https://github.com/gdbarron/VenafiTppPS/issues/124).  Thanks @DadsVacayShorts!

## v2.1.0
- Update `Get-TppCertificateDetail` help to ensure output lists the correct properties, [#119](https://github.com/gdbarron/VenafiTppPS/issues/119).  Thanks @doyle043!
- Hide secret info, eg. passwords, tokens, etc, when verbose logging.  [#120](https://github.com/gdbarron/VenafiTppPS/issues/120).  Thanks @bwright86!
- Add search, get, and remove code sign project and environment functions
- Fix, provide the correct error message when making rest call and testing to see if a trailing slash is needed or not
- Update `New-TppSession` to ensure $TppSession is created even if subsequent custom field calls fail
- Update TppSession object Validate method to check if token auth is required.  Needed for code sign.

## v2.0.5
- Add missing filters CreateDate, CreatedBefore, and CreatedAfter to `Find-TppCertificate`, [#117](https://github.com/gdbarron/VenafiTppPS/issues/117).  Thanks @doyle043!

## v2.0.4
- Fix header getting stripped causing `Write-TppLog` to fail, [#114](https://github.com/gdbarron/VenafiTppPS/issues/114).  Thanks @stevekeever!
- Update `Invoke-TppRestMethod` to retry with trailing slash for all methods, not just Get

## v2.0.3
- Add Origin property when creating a new certificate
- Add icon to project, [#37](https://github.com/gdbarron/VenafiTppPS/issues/37)

## v2.0.2
- Process to convert a secure password to plain text was failing on Linux, [#108](https://github.com/gdbarron/VenafiTppPS/issues/108).  Thanks @macflurry7!

## v2.0.1
- Add Import-TppCertificate, [#88](https://github.com/gdbarron/VenafiTppPS/issues/88).  Thanks @smokey7722!
- Make Invoke-TppRestMethod accessible, [#106](https://github.com/gdbarron/VenafiTppPS/issues/106).  Thanks @wilddev65!
- Fix verbose being turned on incorrectly in New-TppSession when getting by token

## v2.0.0
- Add token-based authentication support, Integrated, OAuth, and Certificate. Tokens can be used in or out of this module. [#94](https://github.com/gdbarron/VenafiTppPS/issues/94).  Thanks @BeardedPrincess!
- Add CertificateType option to New-TppCertificate
- Add support for GET api calls which require a trailing slash
- Fixes in multiple functions where .Add on a hashtable was called in the process block
- Fix issue #102, Base64 with private key not an available option
- Update formats which support IncludeChain

## v1.2.5
- Add offset parameter to Find-TppCertificate, [#92](https://github.com/gdbarron/VenafiTppPS/issues/92)
- Allow inclusion of private key for format Base64 (PKCS #8) in Get-TppCertificate.  Earlier versions of Venafi documentation listed this incorrectly, but has been resolved.  [#95](https://github.com/gdbarron/VenafiTppPS/issues/95)
- Get-TppCertificate failing when pipilining due to adding a key to a hashtable that already exists, [#96](https://github.com/gdbarron/VenafiTppPS/issues/96)
- Linux style paths which use / instead of \ were failing path check due to invalid regex, [#97](https://github.com/gdbarron/VenafiTppPS/issues/97)
- PSSA fix for Read-TppLog

## v1.2.3
- ProvisionCertificate not triggering a push, [#89](https://github.com/gdbarron/VenafiTppPS/issues/89)

## v1.2.2
- Add Linux support
- Add New-TppDevice
- New-TppCapiApplication
    - Add ProvisionCertificate parameter to provision a certificate when the application is created
    - Removed UpdateIis switch as unnecessary, simply use WebSiteName
    - Add ApplicationName parameter to support pipelining of path
    - Add SkipExistenceCheck parameter to bypass some validation which some users might not have access to
- New-TppCertificate
    - Certificate authority is no longer required
    - Fix failure when SAN parameter not provided
    - Fix Management Type not applying
- Add ability to provide root level path, \ved, in some `Find-` functions
- Add pipelining and ShouldProcess functionality to multiple functions
- Update New-TppObject to make Attribute not mandatory
- Remove ability to write to the log with built-in event groups.  This is no longer supported by Venafi.  Custom event groups are still supported.
- Add aliases for Find-TppObject (fto), Find-TppCertificate (ftc), and Invoke-TppCertificateRenewal (itcr)
- Simplified class and enum loading

## v1.1
- fix session state not being preserved across internal function calls, thanks Kory B!
- add Pipeline and ShouldProcess support to New-TppPolicy
- add ShouldProcess support to New-TppObject

## v1.0.5
- add many search options to Read-TppLog
- ensure the Recursive parameter of Find-TppCertificate can only be applied when providing a path
- ensure InputObject property of Find-TppCertificate only accepts type Policy so we get a path
- add TppManagementType enum
- add private function to convert a date to UTC ISO 8601 format
- cleanup help in Find-TppCertificate

## v1.0.4
- add Subject Alternate Name parameter to New-TppCertificate

## v1.0.3
- add Add-TppCertificateAssociation to associate a certificate to one or more application objects
- update New-TppObject to use Add-TppCertificateAssociation when a certificate is provided
- update New-TppCapiApplication to use the updated New-TppObject
- update Get-TppIdentityAttribute to use Test-TppIdentity for validation

## v1.0.2
- additional fixes in identity functions

## v1.0.1
- fix validation in identity functions

## v1.0
- Add Integrated Authentication, a credential is no longer required
- Add Write-TppLog with support for default and custom event groups
- Add PassThru option for all 'New-' functions, returning TppObject
- Standardize all enums with Tpp prefix
- Make enums/classes available outside of the module scope, access these directly at the command line.  For example, [TppObject]::new('\ved\policy\object').
- Fix finding by Stage, StageGreaterThan, and StageLessThan in Find-TppCertificate
- Add error handling for Get-TppSystemStatus
- Add Get-TppVersion
- Rename Restore-TppCertificate to Invoke-TppCertificateRenewal
- Lots of help/documentation updates
- Breaking change: Update New-TppObject to simplify the attributes provided, now just pass a hashtable of object key/value pairs.
- Better parameter support for New-TppCertificate with Name and CommonName
- Rename Get-TppLog to Read-TppLog



















