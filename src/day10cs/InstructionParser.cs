namespace AoC202210;

public class InstructionParser : IInstructionParser
{
    private const string AddX = "addx";
    private const int AddXLength = 2;
    private const InstructionType AddXType = InstructionType.AddX;
    private const string NoOp = "noop";
    private const int NoOpLength = 1;
    private const InstructionType NoOpType = InstructionType.NoOp;
    private const StringComparison StringComparisonMethod = StringComparison.InvariantCulture;

    public Instruction Parse(string instruction)
    {
        string[] parts = instruction.Split(' ');

        return parts.Length switch
        {
            AddXLength when parts[0].Equals(AddX, StringComparisonMethod) && int.TryParse(parts[1], out int amount) =>
                new Instruction { Amount = amount, Type = AddXType },
            NoOpLength when parts[0] == NoOp => new Instruction { Amount = null, Type = NoOpType },
            _ => throw new ArgumentException("Cannot parse as instruction", nameof(instruction)),
        };
    }
}
