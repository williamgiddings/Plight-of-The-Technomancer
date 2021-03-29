
using System;

public static class DelegateUtils
{
    public delegate void VoidDelegateNoArgs();
    public delegate void VoidDelegateGenericArg<Type>( Type Payload );
}