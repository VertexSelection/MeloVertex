dotnet_output=$(./distribution/ios/get_dotnet.sh)
exit_code=$?

if [ $exit_code -eq 0 ]; then
    dotnet="$dotnet_output"
else
    echo "error: .NET not found, Please follow the compilation instructions on the gitea." >&2
    exit 1
fi

$dotnet publish -c Release -r ios-arm64 -p:ExtraDefineConstants=DISABLE_UPDATER src/Ryujinx.Headless.SDL2 --self-contained true

if [ $? -ne 0 ]; then
    echo "warning: Compiling MeloNX failed! Running dotnet clean + restore then Retrying..."
    
    $dotnet clean
    
    $dotnet restore
    
    $dotnet publish -c Release -r ios-arm64 -p:ExtraDefineConstants=DISABLE_UPDATER src/Ryujinx.Headless.SDL2 --self-contained true
fi
