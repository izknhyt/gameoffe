/// <summary>
/// Game element/attribute system.
/// Easily extensible - just add new values here.
/// </summary>
public enum Element
{
    None,
    // Physical
    Slash,
    Strike,
    Thrust,
    // Magical
    Fire,
    Water,
    Wind,
    Earth,
    Thunder,
    Ice,
    Light,
    Dark,
}

public static class ElementExtensions
{
    public static string Label(this Element element)
    {
        return element switch
        {
            Element.None => "無",
            Element.Slash => "斬",
            Element.Strike => "打",
            Element.Thrust => "突",
            Element.Fire => "火",
            Element.Water => "水",
            Element.Wind => "風",
            Element.Earth => "土",
            Element.Thunder => "雷",
            Element.Ice => "氷",
            Element.Light => "光",
            Element.Dark => "闇",
            _ => "？",
        };
    }

    public static bool IsPhysical(this Element element)
    {
        return element is Element.Slash or Element.Strike or Element.Thrust or Element.None;
    }
}
