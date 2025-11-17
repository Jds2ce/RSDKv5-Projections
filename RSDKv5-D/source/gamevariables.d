module gamevariables;
import gamelink;

version (RETRO_REV0U)
    public const int32 RETRO_REVISION = 3;
else version (RETRO_REV02)
    public const int32 RETRO_REVISION = 2;
else version (RETRO_REV01)
    public const int32 RETRO_REVISION = 1;

version (RETRO_MOD_LOADER_VER_2)
    public const int32 RETRO_MOD_LOADER_VER = 2;
else version (RETRO_MOD_LOADER_VER_1)
    public const int32 RETRO_MOD_LOADER_VER = 1;

version (RETRO_REV02)
{
    enum SceneFilters
    {
        none = 0 << 0,
        slot1 = 1 << 0,
        slot2 = 1 << 1,
        slot3 = 1 << 2,
        slot4 = 1 << 3,
        slot5 = 1 << 4,
        slot6 = 1 << 5,
        slot7 = 1 << 6,
        slot8 = 1 << 7,
        any = slot1 | slot2 | slot3 | slot4 | slot5 | slot6 | slot7 | slot8,
    }
}

version (RETRO_REV0U)
{
    bool hasNotifyCallback() => RSDK.notifyCallback != null;

    void notifyCallback(int32 callback, int32 param1, int32 param2, int32 param3)
    {
        if (hasNotifyCallback())
            RSDK.notifyCallback(callback, param1, param2, param3);
    }
}
else
{
    bool hasNotifyCallback() => false;

    void notifyCallback(int32 callback, int32 param1, int32 param2, int32 param3)
    {
    }
}
