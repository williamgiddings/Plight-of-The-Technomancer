using UnityEngine;

public class AIFriendlyUnitSpawnRequest
{
    public Optional<Vector2> SelectedUnitPositionOptional;
    public Optional<AIFriendlyUnitData> SelectedUnitOptional;

    public AIFriendlyUnitSpawnRequest()
    {
        SelectedUnitPositionOptional = new Optional<Vector2>();
        SelectedUnitOptional = new Optional<AIFriendlyUnitData>();
    }

    public static implicit operator bool( AIFriendlyUnitSpawnRequest InValue )
    {
        return InValue.SelectedUnitOptional && InValue.SelectedUnitPositionOptional;
    }
}