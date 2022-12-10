namespace AoC202210;

public class CrtVideoSystemInstructionHandler : IInstructionHandler, ICrtVideoSystem
{
    private readonly IRegisterAccumulator registerAccumulator;
    private int _clockCycle = 1;
    private int _Xvalue = 1;

    public CrtVideoSystemInstructionHandler(IRegisterAccumulator registerAccumulator)
    {
        this.registerAccumulator = registerAccumulator;
    }

    public void NoOp()
    {
        IncrementClockCycle();
    }

    public void AddX(int value)
    {
        IncrementClockCycle();
        _Xvalue += value;
        IncrementClockCycle();
    }

    public void HandleInstruction(Instruction instruction)
    {
        switch (instruction.Type)
        {
            case InstructionType.NoOp:
                NoOp();
                break;
            case InstructionType.AddX:
                if (!instruction.Amount.HasValue)
                {
                    throw new ArgumentNullException(nameof(instruction),
                                                    $"{nameof(Instruction)} {nameof(instruction)} had no {nameof(instruction.Amount)}");
                }

                AddX(instruction.Amount.Value);
                break;
            default:
                throw new ArgumentOutOfRangeException(nameof(instruction), instruction,
                                                      $"Unknown {nameof(InstructionType)} {instruction.Type}");
        }
    }

    public string Format() => registerAccumulator.Format();

    private void IncrementClockCycle()
    {
        _clockCycle++;
        registerAccumulator.Accumulate(_clockCycle, _Xvalue);
    }
}
