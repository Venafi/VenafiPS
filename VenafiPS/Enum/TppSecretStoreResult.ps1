enum TppSecretStoreResult {
    Success = 0
    InvalidCallingAssembly = 1
    CreateDatabaseError = 2
    UseDatabaseError = 3
    CreateTableError = 4
    CreateIndexError = 5
    ConnectionError = 6
    TransactionError = 7
    InvalidVaultID = 8
    InvalidParams = 9
    InsufficientPermissions = 10
    CryptoFailure = 11
    DeleteSecretFailed = 12
    AddSecretFailed = 13
    RetrieveSecretFailed = 14
    RetrieveSecretTypeFailed = 15
    GetNextVaultIDFailed = 16
    DisassociateFailed = 17
    OwnerLookupFailed = 18
    AssociateDataFailed = 19
    LookupFailed = 20
    InvalidKey = 21
    QueryError = 22
    SecurityGroupNotImplemented = 23
    RemoteError = 24
    VaultIdAlreadyExists = 25
    OutOfMemory = 26
    AssociationAlreadyExists = 27
    VaultIdExceedsIntegerCapacity = 28
    AssociationLookupFailed = 29
    AddRevocationStateFailed = 30
    CertificateMigrationStateNotFound = 31
    TodoManagerError = 32
}
