namespace AoC202210;

public class SignalStrengthAccumulator : IRegisterAccumulator, IOutputFormatter
{
    private readonly ImmutableHashSet<int> cycles;
    private int total;

    public SignalStrengthAccumulator()
    {
        ImmutableHashSet<int>.Builder builder = ImmutableHashSet.CreateBuilder<int>();
        builder.Add(20);
        builder.Add(60);
        builder.Add(100);
        builder.Add(140);
        builder.Add(180);
        builder.Add(220);
        cycles = builder.ToImmutable();
    }

    public string Format() => $"{total}";

    public void Accumulate(int clockCycle, int xValue)
    {
        if (cycles.Contains(clockCycle))
        {
            total += clockCycle * xValue;
        }
    }
}
