docker exec messh pg_dump -U postgres --schema-only messh | Set-Content "$($PSScriptRoot)/schema.sql"
