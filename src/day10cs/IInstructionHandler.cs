namespace AoC202210;

public interface IInstructionHandler : IOutputFormatter
{
    void HandleInstruction(Instruction instruction);
}
