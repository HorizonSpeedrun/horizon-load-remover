// Created by ISO2768mK
// Version detection from the Death Stranding and Alan Wake ASL

state("HorizonForbiddenWest", "v38/9660601-Steam")
{
    // Steam 1.0.38.0
    uint stateInd : 0x026B1828;
    uint stateIndSecondary : 0x026B182C;
}

/*
Getting address for new game version:

Scan settings:
8 bytes
in static memory (HFW in the process dropdown)
Hex-Value 000000200000000D

Procedure:
1) Pause game (don't change from selected "Resume" during tab-out)
2) Perform scan
3) Change the selection in the pause screen

The address we need is the one that has changed to 000000200000000E
*/

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

    vars.prevUpdateTime = -1;

    // memory to store actual previous states
    vars.stateIndMem1 = 0;
    vars.stateIndMem2 = 0;
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
        (current.stateInd == 11 && vars.stateIndMem1 != 10) ||
        (current.stateInd == 12 && vars.stateIndMem2 != 10) ||
        // NG+ start
        current.stateInd == 32 ||
        current.stateInd == 33 ||
        current.stateInd == 34 ||
        // FT from campfire
        current.stateInd == 47 ||
        current.stateInd == 48 ||
        (current.stateInd == 49 && vars.stateIndMem2 != 47) || // extra condition needed for Standby Screen option Informative
        // FT from hotbar or map
        current.stateInd == 51 ||
        current.stateInd == 52 ||
        (current.stateInd == 53 && vars.stateIndMem2 != 51) || // extra condition needed for Standby Screen option Informative
        // for convenience to copy lines
        false
    );
}

update
{
    // Debug output
    var timeSinceLastUpdate = Environment.TickCount - vars.prevUpdateTime;
    if (timeSinceLastUpdate > 500 && vars.prevUpdateTime != -1)
    {
        vars.DebugOutput("Last update "+timeSinceLastUpdate+"ms ago");
    }
    vars.prevUpdateTime = Environment.TickCount;

    if (current.stateInd != old.stateInd)
    {
        vars.stateIndMem2 = vars.stateIndMem1;
        vars.stateIndMem1 = old.stateInd;
    }
}

exit
{
    timer.IsGameTimePaused = false;
}
