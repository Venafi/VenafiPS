- Add framework for dynamic tab completion.

  - TLSPDC: currently, the Path variable is enabled. For any Vdc functions with a Path parameter, you can now use tab completion to provide the path. Tabbing without a value will default to '\ved\policy'. Future versions will be aware of the type of item you are looking for and filter appropriately.

  - TLSPC: Application, MachineType, VSatellite, and Certificate have all been enabled. Tab completion will provide a list of names which are much easier to remember than a uuid. All functions with these parameters have been updated to accept an id or name.

  - To see a bash style listing where you can see a full list and select with arrow keys, you can either set your tab key action via `Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete` or use Alt + =.
