// HandleContainer.cs -*-c#-*-
using System;
using System.Runtime.InteropServices;

class HandleContainer
{
    public static GCHandle gchSystemCode;
    public static GCHandle gchCardIdm;
    public static GCHandle gchCardPmm;
    public static GCHandle gchServiceCodeList;
    public static GCHandle gchBlockList;
    public static GCHandle gchWriteBlockData;
    public static GCHandle gchStatusFlag1;
    public static GCHandle gchStatusFlag2;
    public static GCHandle gchResultNumberOfBlocks;
    public static GCHandle gchReadBlockData;
    public static GCHandle gchNumberOfCards;


    public static void FreeHandle()
    {
        //free handle objects.
        if (gchSystemCode.IsAllocated == true)
        {
            gchSystemCode.Free();
        }
        if (gchCardIdm.IsAllocated == true)
        {
            gchCardIdm.Free();
        }
        if (gchCardPmm.IsAllocated == true)
        {
            gchCardPmm.Free();
        }
        if (gchServiceCodeList.IsAllocated == true)
        {
            gchServiceCodeList.Free();
        }
        if (gchBlockList.IsAllocated == true)
        {
            gchBlockList.Free();
        }
        if (gchWriteBlockData.IsAllocated == true)
        {
            gchWriteBlockData.Free();
        }
        if (gchStatusFlag1.IsAllocated == true)
        {
            gchStatusFlag1.Free();
        }
        if (gchStatusFlag2.IsAllocated == true)
        {
            gchStatusFlag2.Free();
        }
        if (gchResultNumberOfBlocks.IsAllocated == true)
        {
            gchResultNumberOfBlocks.Free();
        }
        if (gchReadBlockData.IsAllocated == true)
        {
            gchReadBlockData.Free();
        }
        if (gchNumberOfCards.IsAllocated == true)
        {
            gchNumberOfCards.Free();
        }
    }
}