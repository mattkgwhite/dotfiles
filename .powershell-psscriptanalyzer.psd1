@{
    ExcludeRules = @(
        # install.ps1 is intentionally without a BOM — it is published as a GitHub Release
        # asset and fetched via `irm ... | iex` in a pipeline context where BOMs cause issues.
        'PSUseBOMForUnicodeEncodedFile'
    )
}
