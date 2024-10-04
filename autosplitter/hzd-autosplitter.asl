// Created by ISO2768mK and DorianSnowball
// Memory location found by Canine
// Version detection from the Death Stranding and Alan Wake ASL

state("HorizonZeroDawn", "v181/7517962-Steam")
{
    ulong worldPtr : 0x0714F830;
    uint loading : 0x0714F830, 0x4B4;
}
state("HorizonZeroDawn", "v181/7517962-GoG")
{
    ulong worldPtr : 0x0714C728;
    uint loading : 0x0714C728, 0x4B4;
}

/*
Getting address for new game version, giving multiple results:
83 B9 B4 04 00 00 00 (hard coded for RCX register)
83 ?? B4 04 00 00 00 (matches any register)

Options:
In static memory (HZD in the process dropdown)
Clear Writable, Check Executable flags
Clear Fast Scan (we probably don't have alignment)

Perform Scan

Right Click -> Disassemble this memory region

check for je, test and mov opcode preceding in order that op -> we need the address from the mov

Get the value after "HorizonZeroDawn+" -> this is the offset we need
*/

startup
{
    Action<string> DebugOutput = (text) => {
        print("[HZD Load Remover] " + text);
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
    var module = modules.Single(x => String.Equals(x.ModuleName, "HorizonZeroDawn.exe", StringComparison.OrdinalIgnoreCase));
    // No need to catch anything here because LiveSplit wouldn't have attached itself to the process if the name wasn't present

    var moduleSize = module.ModuleMemorySize;
    var hash = vars.CalcModuleHash(module);
    vars.DebugOutput(module.ModuleName + ": Module Size " + moduleSize + ", SHA256 Hash " + hash);

    version = "";
    if (hash == "866C131C0BBE6E60DBF4332618BBC2109E60F6620106CFF925D7A5399220AECA")
    {
        version = "v181/7517962-Steam";
        // also denoted as Steam version 1.11.2
    }
    else if (hash == "706BA0C319FCC62F9221D310D1A4FD178214ECC0F9030A62029FF70CF15522D1")
    {
        version = "v181/7517962-GoG";
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
    return (current.worldPtr > 0 && current.loading >= 1);
}

exit
{
    timer.IsGameTimePaused = false;
    // Game crashes do not pause the timer to keep the rules as close as possible to the console LR
}
