namespace AoC202210;

public class RegisterAccumulatorCollection : IRegisterAccumulator
{
    private readonly ImmutableArray<IRegisterAccumulator> registerAccumulators;

    public RegisterAccumulatorCollection(IRegisterAccumulator registerAccumulator)
    {
        registerAccumulators = ImmutableArray.Create(registerAccumulator);
    }

    public RegisterAccumulatorCollection(IRegisterAccumulator registerAccumulator1,
                                         IRegisterAccumulator registerAccumulator2)
    {
        registerAccumulators = ImmutableArray.Create(registerAccumulator1, registerAccumulator2);
    }

    public void Accumulate(int clockCycle, int xValue)
    {
        foreach (IRegisterAccumulator registerAccumulator in registerAccumulators)
        {
            registerAccumulator.Accumulate(clockCycle, xValue);
        }
    }

    public string Format()
    {
        var stringBuilder = new StringBuilder();
        foreach (IRegisterAccumulator registerAccumulator in registerAccumulators)
        {
            stringBuilder.AppendLine($"{registerAccumulator.GetType().FullName}:\n{registerAccumulator.Format()}\n");
        }

        return stringBuilder.ToString();
    }
}
