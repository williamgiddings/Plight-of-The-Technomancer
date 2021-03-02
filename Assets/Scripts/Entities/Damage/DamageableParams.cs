using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( fileName = "New Health Data", menuName = "DataAssets/Health", order = 2 )]
public class DamageableParams : ScriptableObject
{
    public float MaxHealth = 100.0f;
}
