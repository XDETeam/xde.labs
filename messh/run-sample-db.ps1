if (docker ps -a -q --filter "name=messh") {
    docker rm messh -f
}

docker build -t messh .
docker run -d `
    --name messh `
    --restart unless-stopped `
    -e POSTGRES_PASSWORD=$(Read-Host "Enter a Password" -MaskInput) `
    -p 25432:5432 `
    -v e:/Data/messh:/var/lib/postgresql/data `
    messh
