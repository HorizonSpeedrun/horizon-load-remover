// Created by ISO2768mK
// Version detection from the Death Stranding and Alan Wake ASL

state("HorizonForbiddenWest", "v38/9660601-Steam")
{
    uint stateInd : 0x026B1828;
}

startup
{
    Action<string> DebugOutput = (text) => {
        print("[HFW Load Remover] " + text);
    };
    vars.DebugOutput = DebugOutput;

    Func<ProcessModuleWow64Safe, string> CalcModuleHash = (module) => {
        byte[] exeHashBytes = new byte[0];
        using (var sha = System.Security.Cryptography.SHA256.Create())
        {
            using (var s = File.Open(module.FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            {
                exeHashBytes = sha.ComputeHash(s);
            }
        }
        var hash = exeHashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
        return hash;
    };
    vars.CalcModuleHash = CalcModuleHash;
}

init
{
    var module = modules.Single(x => String.Equals(x.ModuleName, "HorizonForbiddenWest.exe", StringComparison.OrdinalIgnoreCase));
    // No need to catch anything here because LiveSplit wouldn't have attached itself to the process if the name wasn't present

    var moduleSize = module.ModuleMemorySize;
    var hash = vars.CalcModuleHash(module);
    vars.DebugOutput(module.ModuleName + ": Module Size " + moduleSize + ", SHA256 Hash " + hash);

    version = "";
    if (hash == "6629083175B524CFF9EE3369A7EB8E1D6188B421032B84AFFEE60FD7BE767449")
    {
        version = "v38/9660601-Steam";
        // also denoted as Steam version 1.0.38.0
    }
    /*else if (hash == "PLACEHOLDER")
    {
        version = "PLACEHOLDER";
    }
    */
    if (version != "")
    {
        vars.DebugOutput("Recognized version: " + version);
    }
    else
    {
        vars.DebugOutput("Unrecognized version of the game.");
    }
}

isLoading
{
    return (
        // Loading save files and RFS
        current.stateInd == 11 ||
        current.stateInd == 12 ||
        // FT from campfire
        current.stateInd == 47 ||
        current.stateInd == 48 ||
        current.stateInd == 49 ||
        // FT from hotbar or map
        current.stateInd == 51 ||
        current.stateInd == 52 ||
        current.stateInd == 53 ||
        // for convenience to copy lines
        false
    );
}

exit
{
    timer.IsGameTimePaused = false;
}