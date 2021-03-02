using System;

public class Optional<Type>
{
    private Type Value;
    private bool IsValid;

    public Optional()
    {
        IsValid = false;
    }

    public Optional( Type InValue )
    {
        Set( InValue );
    }

    public void Set( Type InValue )
    {
        Value = InValue; 
        IsValid = InValue!=null;
    }

    public void Reset()
    {
        Value = default( Type );
        IsValid = false;
    }
    
    public Type Get()
    {
        return Value;
    }

    public static implicit operator Optional<Type>( Type InValue ) => new Optional<Type>(InValue);
    public static implicit operator bool( Optional<Type> InValue ) => InValue != null && InValue.IsValid;

}
