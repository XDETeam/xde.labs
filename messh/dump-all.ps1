docker exec messh pg_dump -U postgres messh | Set-Content "x:\Backup\messh\messh-$([datetime]::UtcNow.ToString('yyyyMMdd-HHmmss')).sql"
