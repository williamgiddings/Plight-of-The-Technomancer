using System;
using System.Collections.Generic;
using System.Linq;

public static class EnumUtils
{
    public static List<EnumType> EnumToList<EnumType>() where EnumType : System.Enum
    {
        return new List<EnumType>( System.Enum.GetValues( typeof( EnumType ) ).Cast<EnumType>() );
    }

}



