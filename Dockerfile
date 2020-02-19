ARG DOTNET_SDK_VERSION=2.2-alpine3.9
ARG DOTNET_RUNTIME_VERSION=2.1.14-alpine3.10
ARG FROM_REPO_SDK=mcr.microsoft.com/dotnet/core/sdk
ARG FROM_REPO_RUNTIME=mcr.microsoft.com/dotnet/core/runtime-deps

FROM ${FROM_REPO_SDK}:${DOTNET_SDK_VERSION} AS build

WORKDIR /app

COPY api/api.csproj api/api.csproj
COPY tests/Integration.Tests/Integration.Tests.csproj tests/IntegrationTests/IntegrationTests.csproj

COPY . .

RUN dotnet publish api/api.csproj -c Release -r linux-musl-x64 -o /out --no-restore
RUN mkdir /out/logs

FROM ${FROM_REPO_SDK}:${DOTNET_SDK_VERSION} AS tests

COPY --from=build /app /app
COPY --from=build /root/.nuget/packages /root/.nuget/packages
WORKDIR /app
CMD ["dotnet", "test", "github-actions-poc.sln"]

FROM ${FROM_REPO_RUNTIME}:${DOTNET_RUNTIME_VERSION}

COPY --from=build /out /app
WORKDIR /app
CMD ["./api"]
