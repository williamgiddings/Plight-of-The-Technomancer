using System;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class StatResistance
{
    public float HeatResistance;
    public float KineticResistance;
    public float EnergyResistance;
    public float BlastResistance;

    public bool TryGetStatBinding( StatTypes.Stat Stat, out float Value )
    {
        Value = -1.0f;
        switch ( Stat )
        {
            case StatTypes.Stat.STAT_HeatResistance:
                Value = HeatResistance;
                return true;
            case StatTypes.Stat.STAT_EnergyResistance:
                Value = EnergyResistance;
                return true;
            case StatTypes.Stat.STAT_KineticResistance:
                Value = KineticResistance;
                return true;
            case StatTypes.Stat.STAT_BlastResistance:
                Value = BlastResistance;
                return true;
        }
        return false;
    }
}