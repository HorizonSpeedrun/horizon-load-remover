// Created by ISO2768mK
// Version detection from the Death Stranding and Alan Wake ASL

state("HorizonForbiddenWest", "v1.1.47.0-Steam")
{
    uint loading : 0x089760D8, 0x4B4;
    uint gamePaused : 0x089760D8, 0x20;
}
state("HorizonForbiddenWest", "v1.0.43.0-2-Steam")
{
    uint loading : 0x0896FA58, 0x4B4;
    uint gamePaused : 0x0896FA58, 0x20;
}
state("HorizonForbiddenWest", "v1.0.43.0-Steam")
{
    uint loading : 0x0896FA18, 0x4B4;
    uint gamePaused : 0x0896FA18, 0x20;
}
state("HorizonForbiddenWest", "v1.0.38.0-Steam")
{
    uint loading : 0x0896D790, 0x4B4;
    uint gamePaused : 0x0896D790, 0x20;
}

/*
Getting address for new game version:

Value (HEX)
48 8B 05 ?? ?? ?? ?? 48 85 C0 74 15 83 B8 B4 04 00 00 00 75 0C 83 B8 74 06 00 00 02 74 03 B0 01 C3 32 C0

Alternatively, giving multiple results:
83 B8 B4 04 00 00 00 (hard coded for RAX register)
83 ?? B4 04 00 00 00 (matches any register)

Options:
In static memory (HFW in the process dropdown)
Clear Writable, Check Executable flags
Clear Fast Scan (we probably don't have alignment)

Perform Scan

Right Click -> Disassemble this memory region

Get the value after "HorizonForbiddenWest+" -> this is the offset we need
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

}

init
{
    var module = modules.Single(x => String.Equals(x.ModuleName, "HorizonForbiddenWest.exe", StringComparison.OrdinalIgnoreCase));
    // No need to catch anything here because LiveSplit wouldn't have attached itself to the process if the name wasn't present

    var moduleSize = module.ModuleMemorySize;
    var hash = vars.CalcModuleHash(module);
    vars.DebugOutput(module.ModuleName + ": Module Size " + moduleSize + ", SHA256 Hash " + hash);

    version = "";
    if (hash == "71C0A02F4B9FCE5BA7461DB75361C7A2F38CA839250F24D94E211A5B08003E64")
    {
        version = "v1.1.47.0-Steam";
    }
    else if (hash == "5C77F54C0FE4B37E1024B607E0ED18649995617FF2BB12E2498378150BC52BB7")
    {
        version = "v1.0.43.0-2-Steam";
    }
    else if (hash == "187A532FDDDAB188EF0319634028969D3E1CF0431C9458F5A9B6AE4B3C0196EC")
    {
        version = "v1.0.43.0-Steam";
    }
    else if (hash == "6629083175B524CFF9EE3369A7EB8E1D6188B421032B84AFFEE60FD7BE767449")
    {
        version = "v1.0.38.0-Steam";
    }
    
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
    return (current.loading >= 1);
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
}

exit
{
    timer.IsGameTimePaused = false;
}
