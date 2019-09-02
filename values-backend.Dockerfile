FROM mcr.microsoft.com/dotnet/core/aspnet:3.0-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.0-buster AS build
WORKDIR /src
COPY ["src/Values.Backend/Values.Backend.csproj", "src/Values.Backend/"]
RUN dotnet restore "src/Values.Backend/Values.Backend.csproj"
COPY . .
WORKDIR /src
RUN dotnet build "src/Values.Backend/Values.Backend.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "src/Values.Backend/Values.Backend.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "Values.Backend.dll"]