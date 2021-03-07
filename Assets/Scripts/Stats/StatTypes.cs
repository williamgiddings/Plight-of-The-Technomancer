using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class StatTypes
{
    public enum Stat
    {
        STAT_Health,
        STAT_HeatResistance,
        STAT_EnergyResistance,
        STAT_KineticResistance,
        STAT_BlastResistance,
        STAT_DeployTime,
        STAT_FireRate,
        STAT_TargettingTime
    }

    public static readonly Stat[] StatCollection = new Stat[]
        {
            Stat.STAT_Health,
            Stat.STAT_HeatResistance,
            Stat.STAT_EnergyResistance,
            Stat.STAT_KineticResistance,
            Stat.STAT_BlastResistance,
            Stat.STAT_DeployTime,
            Stat.STAT_FireRate,
            Stat.STAT_TargettingTime
        };
}