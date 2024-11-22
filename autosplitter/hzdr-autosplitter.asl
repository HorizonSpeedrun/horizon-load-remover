// Created by ISO2768mK and DorianSnowball
// Version detection from the Death Stranding and Alan Wake ASL

state("HorizonZeroDawnRemastered", "v1.3.51.0-Steam")
{
    uint loading : 0x099A9520, 0x4DC;
}
/*
Placeholder for Epic Games version
state("HorizonZeroDawnRemastered", "v???-Epic")
{
    uint loading : ????, 0x4DC;
}
*/

/*
Getting address for new game version, giving multiple results:
83 B8 DC 04 00 00 00 (hard coded for RAX register)
83 ?? DC 04 00 00 00 (matches any register)

Options:
In static memory (HZDR in the process dropdown)
Clear Writable, Check Executable flags
Clear Fast Scan (we probably don't have alignment)

Perform Scan

Right Click -> Disassemble this memory region

check for je, test and mov opcode preceding in order that op -> we need the address from the mov

Get the value after "HorizonZeroDawnRemastered+" -> this is the offset we need
*/

startup
{
    Action<string> DebugOutput = (text) => {
        print("[HZDR Load Remover] " + text);
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
    var module = modules.Single(x => String.Equals(x.ModuleName, "HorizonZeroDawnRemastered.exe", StringComparison.OrdinalIgnoreCase));
    // No need to catch anything here because LiveSplit wouldn't have attached itself to the process if the name wasn't present

    var hash = vars.CalcModuleHash(module);

    version = "";
    if (hash == "416560393850E7C50F323975DC909C4F1367266DC235753AE3AF5BF197B98B04")
    {
        version = "v1.3.51.0-Steam";
    }
    /*
    else if (hash == "????")
    {
        version = "v???-Epic";
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
    return (current.loading >= 1);
}

exit
{
    timer.IsGameTimePaused = false;
    // Game crashes do not pause the timer to keep the rules as close as possible to the console LR
}
