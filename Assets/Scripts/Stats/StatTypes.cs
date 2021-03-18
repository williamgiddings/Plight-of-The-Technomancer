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

    public static bool GetStatFromDamageType( ProjectileTypes ProjectileType, out Stat OutHealthStat )
    {
        OutHealthStat = Stat.STAT_Health;
        switch (ProjectileType)
        {
            case ProjectileTypes.Fire:
                OutHealthStat = Stat.STAT_HeatResistance;
                return true;
            case ProjectileTypes.Arc:
                OutHealthStat = Stat.STAT_EnergyResistance;
                return true;
            case ProjectileTypes.Kinetic:
                OutHealthStat = Stat.STAT_KineticResistance;
                return true;
            case ProjectileTypes.Blast:
                OutHealthStat = Stat.STAT_BlastResistance;
                return true;
        }
        return false;
    }
}