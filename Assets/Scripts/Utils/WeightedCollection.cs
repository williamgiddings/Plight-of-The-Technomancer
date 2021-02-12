using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class WeightedCollection<CollectionType>
{
    [System.Serializable]
    public struct Entry<EntryType>
    { 
        [HideInInspector]
        public float        AccumulatedWeight;
        public EntryType    Object;
        public float        Weight;
    }

    [SerializeField]
    public Entry<CollectionType>[] Entries;

    public CollectionType Get( float NormalizedValue )
    {
        float TotalWeight = 0.0f;
        for ( int i = 0; i < Entries.Length; i++ )
        {
            TotalWeight += Entries[ i ].Weight;
            Entries[ i ].AccumulatedWeight = TotalWeight;
        }

        float MappedValue = TotalWeight * NormalizedValue;

        foreach ( Entry<CollectionType> E in Entries )
        {
            if ( E.AccumulatedWeight >= MappedValue )
            {
                return E.Object;
            }
        }
        return Entries[ 0 ].Object;
    } 
}
