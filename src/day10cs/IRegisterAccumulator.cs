namespace AoC202210;

public interface IRegisterAccumulator : IOutputFormatter
{
    void Accumulate(int clockCycle, int xValue);
}
