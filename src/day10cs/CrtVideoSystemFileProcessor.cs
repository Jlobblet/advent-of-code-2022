namespace AoC202210;

public class CrtVideoSystemFileProcessor : IFileProcessor
{
    private readonly IInstructionHandler instructionHandler;
    private readonly IInstructionParser instructionParser;

    public CrtVideoSystemFileProcessor(IInstructionParser instructionParser, IInstructionHandler instructionHandler)
    {
        this.instructionParser  = instructionParser;
        this.instructionHandler = instructionHandler;
    }

    public void ProcessLine(string line)
    {
        Instruction instruction = instructionParser.Parse(line);
        instructionHandler.HandleInstruction(instruction);
    }

    public void ProcessFile(IEnumerable<string> lines)
    {
        foreach (string line in lines)
        {
            ProcessLine(line);
        }
        Console.WriteLine(instructionHandler.Format());
    }
}

