
using System;

public static class DelegateUtils
{
    public delegate void VoidDelegateNoArgs();
    public delegate void VoidDelegateFloatArg( float Value );
    public delegate void VoidDelegateIntArg( int Value );
    public delegate void VoidDelegateEntityArg( Entity Ent );
    public delegate void VoidDelegateGenericArg<Type>( Type Payload );

}