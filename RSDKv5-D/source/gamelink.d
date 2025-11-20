module gamelink;
import gamevariables;
import core.runtime;
import core.stdc.string;
import std.stdint;
import std.conv : to;
import std.string : toStringz;

// =========================
// Standard Types
// =========================

alias memset = core.stdc.string.memset;
alias memcpy = core.stdc.string.memcpy;

alias int8 = int8_t;
alias uint8 = uint8_t;
alias int16 = int16_t;
alias uint16 = uint16_t;
alias int32 = int32_t;
alias uint32 = uint32_t;
alias int64 = uint64_t;
alias uint64 = uint64_t;
alias bool32 = uint32;

struct color
{
    uint32 value;
    alias value this;

    this(uint32 v)
    {
        value = v;
    }

    void opAssign(uint32 rhs)
    {
        value = rhs;
    }

    uint32 opCast(T : uint32)() const
    {
        return value;
    }

    @property uint8 a() const
    {
        return cast(uint8)(value >> 24);
    }

    @property void a(uint8 v)
    {
        value = (value & 0x00FF_FFFF) | (cast(uint32)(v << 24));
    }

    @property uint8 r() const
    {
        return cast(uint8)(value >> 16);
    }

    @property void r(uint8 v)
    {
        value = (value & 0xFF00_FFFF) | (cast(uint32)(v << 16));
    }

    @property uint8 g() const
    {
        return cast(uint8)(value >> 8);
    }

    @property void g(uint8 v)
    {
        value = (value & 0xFFFF_00FF) | (cast(uint32)(v << 8));
    }

    @property uint8 b() const
    {
        return cast(uint8)(value);
    }

    @property void b(uint8 v)
    {
        value = (value & 0xFFFF_FF00) | cast(uint32)(v << 0);
    }
}

// =========================
// Constants
// =========================

public const int32 SCREEN_XMAX = 1280;
public const int32 SCREEN_YSIZE = 240;
public const int32 SCREEN_YCENTER = SCREEN_YSIZE / 2;

public const int32 LAYER_COUNT = 8;
public const int32 DRAWGROUP_COUNT = 16;

version (RETRO_REV02)
    public const int32 SCREEN_COUNT = 4;
else
    public const int32 SCREEN_COUNT = 2;

public const int32 PLAYER_COUNT = 4;
public const int32 CAMERA_COUNT = 4;

public const int32 PALETTE_BANK_COUNT = 0x8;
public const int32 PALETTE_BANK_SIZE = 0x100;

// 0x800 scene objects, 0x40 reserved ones, and 0x100 spare slots for creation
public const int32 RESERVE_ENTITY_COUNT = 0x40;
public const int32 TEMPENTITY_COUNT = 0x100;
public const int32 SCENEENTITY_COUNT = 0x800;
public const int32 OBJECT_COUNT = 0x400;
public const int32 ENTITY_COUNT = RESERVE_ENTITY_COUNT + SCENEENTITY_COUNT + TEMPENTITY_COUNT;
public const int32 TEMPENTITY_START = ENTITY_COUNT - TEMPENTITY_COUNT;

public const int32 TYPE_COUNT = 0x100;
public const int32 TYPEGROUP_COUNT = TYPE_COUNT + 4;
public const int32 CHANNEL_COUNT = 0x10;
public const int32 TILE_SIZE = 16;

// =========================
// Macros
// =========================

auto MIN(T)(T a, T b) => a < b ? a : b;
auto MAX(T)(T a, T b) => a > b ? a : b;

auto CLAMP(T)(T value, T minimum, T maximum) => value < minimum ? minimum : (
    value > maximum ? maximum : value);
auto FABS(T)(T a) => a > 0 ? a : -a;

void SET_BIT(ref int32 value, bool set, int32 pos)
{
    value ^= (-(cast(int32) set) ^ value) & (1 << pos);
}

bool GET_BIT(int32 b, int32 pos) => (b >> pos) & 1;

void* INT_TO_VOID(int32 x) => cast(void*)(cast(size_t) x);
void* FLOAT_TO_VOID(float x) => INT_TO_VOID(*cast(int32*)&x);
int32 VOID_TO_INT(void* x) => cast(int32)(cast(size_t) x);
float VOID_TO_FLOAT(void* x) => *cast(float*) x;

int32 TO_FIXED(int32 x) => x << 16;
int32 FROM_FIXED(int32 x) => x >> 16;

float TO_FIXED(float x) => x * 6_5536.0f;
float FROM_FIXED(float x) => x / 6_5536.0f;

public const float RSDK_PI = 3.1415927f;

// =========================
// Structs
// =========================

struct Vector2
{
    int32 x;
    int32 y;

    this(int32 vec2X, int32 vec2Y)
    {
        x = vec2X;
        y = vec2Y;
    }

    ref Vector2 opOpAssign(string op)(Vector2 rhs) if (op == "+" || op == "-")
    {
        static if (op == "+")
        {
            x += rhs.x;
            y += rhs.y;
        }
        else
        {
            x -= rhs.x;
            y -= rhs.y;
        }
        return this;
    }

    Vector2 opBinary(string op)(Vector2 rhs) if (op == "+" || op == "-")
    {
        Vector2 vv = this;
        vv.opOpAssign!op(rhs);
        return vv;
    }

    bool32 checkOnScreen(Vector2* range) => RSDK.checkPosOnScreen(&this, range);
}

struct Entity
{
    // ===========================
    // Default Registration Events
    // ===========================

    void update()
    {
    }

    void lateUpdate()
    {
    }

    void staticUpdate()
    {
    }

    void draw()
    {
    }

    void create(void* data)
    {
    }

    static void stageLoad()
    {
    }

    version (RETRO_REV0U)
    {
        static void staticLoad(Object* sVars)
        {
            sVars.classID = DefaultObjects.defaultObject;
            sVars.active = ActiveFlags.never;
        }
    }

    static void serialize()
    {
    }

    static void editorLoad()
    {
    }

    void editorDraw()
    {
    }

    // =====================
    // Base Entity Variables
    // =====================

    version (RETRO_REV0U) private void* vfTable;

    Vector2 position;
    Vector2 scale;
    Vector2 velocity;
    Vector2 updateRange;
    int32 angle;
    int32 alpha;
    int32 rotation;
    int32 groundVel;
    int32 zdepth;
    uint16 group;
    uint16 classID;
    bool32 inRange;
    bool32 isPermanent;
    int32 tileCollisions;
    bool32 interaction;
    bool32 onGround;
    uint8 active;

    version (RETRO_REV02) uint8 filter;

    uint8 direction;
    uint8 drawGroup;
    uint8 collisionLayers;
    uint8 collisionPlane;
    uint8 collisionMode;
    uint8 drawFX;
    uint8 inkEffect;
    uint8 visible;
    uint8 onScreen;

    // =====================
    // Base Entity Functions
    // =====================

    void initialize()
    {
        active = ActiveFlags.bounds;
        visible = false;
        updateRange.x = TO_FIXED(128);
        updateRange.y = TO_FIXED(128);
    }

    uint16 slot() => RSDK.getEntitySlot(&this);
    void destroy() => RSDK.resetEntity(&this, DefaultObjects.defaultObject, null);

    void reset(uint16 type, void* data) => RSDK.resetEntity(&this, type, data);
    void reset(uint16 type, int32 data) => RSDK.resetEntity(&this, type, INT_TO_VOID(data));

    void copy(Entity* dst, bool32 clearThis) => RSDK.copyEntity(dst, &this, clearThis);

    bool32 checkOnScreen(Vector2* range) => RSDK.checkOnScreen(&this, range);

    void addDrawListRef(uint8 drawGroup) => RSDK.addDrawListRef(drawGroup, slot());

    bool32 tileCollision(uint16 collisionLayers, uint8 collisionMode, uint8 collisionPlane, int32 xOffset, int32 yOffset, bool32 setPos)
    {
        return RSDK.objectTileCollision(&this, collisionLayers, collisionMode, collisionPlane, xOffset, yOffset, setPos);
    }

    bool32 tileGrip(uint16 collisionLayers, uint8 collisionMode, uint8 collisionPlane, int32 xOffset, int32 yOffset, int32 tolerance)
    {
        return RSDK.objectTileGrip(&this, collisionLayers, collisionMode, collisionPlane, xOffset, yOffset, tolerance);
    }

    void processMovement(Hitbox* outerBox, Hitbox* innerBox) => RSDK.processObjectMovement(&this, outerBox, innerBox);

    bool32 checkCollisionTouchBox(Hitbox* thisHitbox, Entity* other, Hitbox* otherHitbox)
    {
        return RSDK.checkObjectCollisionTouchBox(&this, thisHitbox, other, otherHitbox);
    }

    bool32 checkCollisionTouchCircle(int32 thisRadius, Entity* other, int32 otherRadius)
    {
        return RSDK.checkObjectCollisionTouchCircle(&this, thisRadius, other, otherRadius);
    }

    uint8 checkCollisionBox(Hitbox* thisHitbox, Entity* other, Hitbox* otherHitbox, bool32 setPos = true)
    {
        return RSDK.checkObjectCollisionBox(&this, thisHitbox, other, otherHitbox, setPos);
    }

    bool32 checkCollisionPlatform(Hitbox* thisHitbox, Entity* other, Hitbox* otherHitbox, bool32 setPos = true)
    {
        return RSDK.checkObjectCollisionPlatform(&this, thisHitbox, other, otherHitbox, setPos);
    }

    version (RETRO_USE_MOD_LOADER) void superCallback(int32 callback, void* data = null) => mod.superCallback(classID, callback, data);
}

struct Object
{
    uint16 classID;
    uint8 active;

    void editableVar(uint8 type, const char* name, uint32 offset) => RSDK.setEditableVar(type, name, cast(
            uint8) classID, offset);

    int32 Count(bool32 isActive = false) => RSDK.getEntityCount(classID, isActive);

    version (RETRO_USE_MOD_LOADER) void superCallback(int32 callback, void* data = null) => mod.superCallback(classID, callback, data);
}

mixin template RSDK_OBJECT()
{
    alias object this;
    gamelink.Object object;
}

mixin template RSDK_ENTITY()
{
    alias entity this;
    gamelink.Entity entity;
}

struct EntityBase
{
    mixin RSDK_ENTITY;
    void*[0x100] data;

    version (RETRO_REV0U) void* unknown;
}

version (RETRO_REV02)
{
    struct RSDKSKUInfo
    {
        int32 platform;
        int32 language;
        int32 region;
    }

    struct RSDKUnknownInfo
    {
        int32 unknown1;
        int32 unknown2;
        int32 unknown3;
        int32 unknown4;
        bool32 pausePress;
        int32 unknown5;
        int32 unknown6;
        int32 unknown7;
        int32 unknown8;
        int32 unknown9;
        bool32 anyKeyPress;
        int32 unknown10;
    }
}

struct RSDKGameInfo
{
    char[0x40] gameTitle;
    char[0x100] gameSubtitle;
    char[0x10] gameVersion;

    version (RETRO_REV02)
    {
    }
    else
    {
        uint8 platform;
        uint8 language;
        uint8 region;
    }
}

struct SceneListInfo
{
    uint32[4] hash;
    char[0x20] name;
    uint16 sceneOffsetStart;
    uint16 sceneOffsetEnd;
    uint8 sceneCount;
}

struct SceneListEntry
{
    uint32[4] hash;
    char[0x10] name;
    char[0x10] folder;
    char[0x08] id;

    version (RETRO_REV02) uint8 filter;
}

struct RSDKSceneInfo
{
    Entity* entity;
    SceneListEntry* listData;
    SceneListInfo* listCategory;
    int32 timeCounter;
    int32 currentDrawGroup;
    int32 currentScreenID;
    uint16 listPos;
    uint16 entitySlot;
    uint16 createSlot;
    uint16 classCount;
    bool32 inEditor;
    bool32 effectGizmo;
    bool32 debugMode;
    bool32 useGlobalScripts;
    bool32 timeEnabled;
    uint8 activeCategory;
    uint8 categoryCount;
    uint8 state;

    version (RETRO_REV02) uint8 filter;

    uint8 milliseconds;
    uint8 seconds;
    uint8 minutes;
}

struct InputState
{
    bool32 down;
    bool32 press;
    int32 keyMap;
}

struct RSDKControllerState
{
    InputState keyUp;
    InputState keyDown;
    InputState keyLeft;
    InputState keyRight;
    InputState keyA;
    InputState keyB;
    InputState keyC;
    InputState keyX;
    InputState keyY;
    InputState keyZ;
    InputState keyStart;
    InputState keySelect;

    // Rev01 hasn't split these into different structs yet
    version (RETRO_REV01)
    {
        InputState keyBumperL;
        InputState keyBumperR;
        InputState keyTriggerL;
        InputState keyTriggerR;
        InputState keyStickL;
        InputState keyStickR;
    }
}

struct RSDKAnalogState
{
    InputState keyUp;
    InputState keyDown;
    InputState keyLeft;
    InputState keyRight;

    version (RETRO_REV02)
    {
        InputState keyStick;
        float deadzone;
        float hDelta;
        float vDelta;
    }
    else
    {
        float deadzone;
        float triggerDeltaL;
        float triggerDeltaR;
        float hDeltaL;
        float vDeltaL;
        float hDeltaR;
        float vDeltaR;
    }
}

version (RETRO_REV02) struct RSDKTriggerState
{
    InputState keyBumper;
    InputState keyTrigger;
    float bumperDelta;
    float triggerDelta;
}

struct RSDKTouchInfo
{
    float[0x10] x;
    float[0x10] y;
    bool32[0x10] down;
    uint8 count;

    version (RETRO_REV02)
    {
    }
    else
    {
        bool32 pauseHold;
        bool32 pausePress;
        bool32 unknown1;
        bool32 anyKeyHold;
        bool32 anyKeyPress;
        bool32 unknown2;
    }
}

struct RSDKScreenInfo
{
    uint16[SCREEN_XMAX * SCREEN_YSIZE] frameBuffer;
    Vector2 position;
    Vector2 size;
    Vector2 center;
    int32 pitch;
    int32 clipBound_X1;
    int32 clipBound_Y1;
    int32 clipBound_X2;
    int32 clipBound_Y2;
    int32 waterDrawPos;
}

extern (C)
struct EngineInfo
{
    RSDKFunctionTable* functionTable;
    version (RETRO_REV02) APIFunctionTable* apiTable;

    RSDKGameInfo* gameInfo;
    version (RETRO_REV02) RSDKSKUInfo* currentSKU;

    RSDKSceneInfo* sceneInfo;
    RSDKControllerState* controllerInfo;
    RSDKAnalogState* stickInfoL;
    version (RETRO_REV02)
    {
        RSDKAnalogState* stickInfoR;
        RSDKTriggerState* triggerInfoL;
        RSDKTriggerState* triggerInfoR;
    }

    RSDKTouchInfo* touchInfo;
    version (RETRO_REV02) RSDKUnknownInfo* unknownInfo;

    RSDKScreenInfo* screenInfo;
    version (RETRO_REV0U) void* hedgehogLink;

    version (RETRO_USE_MOD_LOADER) ModFunctionTable* modTable;
}

version (RETRO_USE_MOD_LOADER) struct ModVersionInfo
{
    uint8 engineVer;
    uint8 gameVer;
    uint8 modLoaderVer;
}

struct Matrix
{
    int32[4][4] values;

    this(ref Matrix other)
    {
        copy(&this, &other);
    }

    void setIdentity() => RSDK.setIdentityMatrix(&this);
    void translateXYZ(int32 x, int32 y, int32 z, bool32 setIdentity = true) => RSDK
        .matrixTranslateXYZ(&this, x, y, z, setIdentity);
    void scaleXYZ(int32 x, int32 y, int32 z) => RSDK.matrixScaleXYZ(&this, x, y, z);
    void rotateX(int32 angle) => RSDK.matrixRotateX(&this, angle);
    void rotateY(int32 angle) => RSDK.matrixRotateY(&this, angle);
    void rotateZ(int32 angle) => RSDK.matrixRotateZ(&this, angle);
    void rotateXYZ(int32 x, int32 y, int32 z) => RSDK.matrixRotateXYZ(&this, x, y, z);
    void inverse() => RSDK.matrixInverse(&this, &this);

    static void multiply(Matrix* dest, Matrix* matrixA, Matrix* matrixB) => RSDK.matrixMultiply(dest, matrixA, matrixB);
    static void copy(Matrix* matDest, Matrix* matSrc) => RSDK.matrixCopy(matDest, matSrc);
    static void inverse(Matrix* dest, Matrix* matrix) => RSDK.matrixInverse(dest, matrix);

    ref Matrix opOpAssign(string op)(ref Matrix rhs) if (op == "*")
    {
        multiply(&this, &this, rhs);
        return this;
    }

    Matrix opBinary(string op)(ref Matrix rhs) if (op == "*")
    {
        Matrix dest;
        multiply(dest, &this, rhs);
        return dest;
    }
}

struct String
{
    uint16* chars;
    uint16 length;
    uint16 size;

    this(const char* str)
    {
        if (str != null)
            initialize(str);
    }

    this(ref String other)
    {
        this.chars = other.chars;
        this.length = other.length;
        this.size = other.size;
    }

    bool opEquals(ref String other) const
    {
        return RSDK.compareStrings(cast(String*)&this, &other, true) != false;
    }

    String opBinary(string op)(String rhs) if (op == "+")
    {
        auto ss = this;
        ss += rhs;
        return ss;
    }

    ref String opOpAssign(string op)(String rhs) if (op == "+")
    {
        append(&rhs);
        return this;
    }

    ref String opOpAssign(string op)(const char* rhs) if (op == "+")
    {
        append(rhs);
        return this;
    }

    ref String opOpAssign(string op)(string rhs) if (op == "+")
    {
        append(rhs.ptr);
        return this;
    }

    void initialize(const char* str, uint32 length = 0)
    {
        RSDK.initString(&this, str, length);
    }

    void set(const char* str)
    {
        RSDK.setString(&this, str);
    }

    void prepend(String* str)
    {
        String tmp;
        tmp = *str;
        tmp += this;
        this.chars = tmp.chars;
        this.length = tmp.length;
        this.size = tmp.size;
    }

    void prepend(const char* str)
    {
        String tmp = String(str);
        prepend(&tmp);
    }

    void append(String* str)
    {
        RSDK.appendString(&this, str);
    }

    void append(const char* str)
    {
        RSDK.appendText(&this, str);
    }

    static void copy(String* dst, String* src)
    {
        RSDK.copyString(dst, src);
    }

    static void copy(String* dst, const char* src)
    {
        RSDK.setString(dst, src);
    }

    static bool compare(String* a, String* b, bool32 exactMatch)
    {
        return RSDK.compareStrings(a, b, exactMatch) != false;
    }

    void cStr(char* buffer) => RSDK.getCString(buffer, &this);

    bool isInitialized()
    {
        return chars != null;
    }

    bool isEmpty()
    {
        return !length;
    }
}

struct Hitbox
{
    int16 left;
    int16 top;
    int16 right;
    int16 bottom;

    this(int16 hitboxLeft, int16 hitboxTop, int16 hitboxRight, int16 hitboxBottom)
    {
        left = hitboxLeft;
        top = hitboxTop;
        right = hitboxRight;
        bottom = hitboxBottom;
    }
}

struct SpriteSheet
{
    uint16 id;

    void initialize()
    {
        id = cast(uint16)-1;
    }

    void load(const char* path, Scopes scopeType)
    {
        id = RSDK.loadSpriteSheet(path, scopeType);
    }

    bool loaded() => id != cast(uint16)-1;

    bool matches(ref SpriteSheet other) => id == other.id;
    bool matches(SpriteSheet* other)
    {
        if (other)
            return id == other.id;
        else
            return !loaded();
    }
}

struct SpriteFrame
{
    int16 sprX;
    int16 sprY;
    int16 width;
    int16 height;
    int16 pivotX;
    int16 pivotY;
    uint16 delay;
    int16 id;
    uint8 sheetID;
}

struct SpriteAnimation
{
    uint16 id;

    void initialize()
    {
        id = cast(uint16)-1;
    }

    void load(const char* path, Scopes scopeType)
    {
        id = RSDK.loadSpriteAnimation(path, scopeType);
    }

    void create(const char* filename, uint32 frameCount, uint32 listCount, Scopes scopeType)
    {
        id = RSDK.createSpriteAnimation(filename, frameCount, listCount, scopeType);
    }

    void edit(uint16 listID, const char* name, int32 frameOffset, uint16 frameCount, int16 speed, uint8 loopIndex, uint8 rotationStyle)
    {
        RSDK.editSpriteAnimation(id, listID, name, frameOffset, frameCount, speed, loopIndex, rotationStyle);
    }

    uint16 findAnimation(const char* name) => RSDK.findSpriteAnimation(id, name);

    bool loaded() => id != cast(uint16)-1;

    SpriteFrame* getFrame(uint16 listID, int32 frameID) => RSDK.getFrame(id, listID, frameID);

    bool matches(ref SpriteAnimation other) => id == other.id;
    bool matches(SpriteAnimation* other)
    {
        if (other)
            return id == other.id;
        else
            return !loaded();
    }
}

struct Mesh
{
    uint16 id;

    void initialize()
    {
        id = cast(uint16)-1;
    }

    void load(const char* path, Scopes scopeType)
    {
        id = RSDK.loadMesh(path, scopeType);
    }

    bool loaded()
    {
        return id != cast(uint16)-1;
    }

    bool matches(ref Mesh other)
    {
        return id == other.id;
    }

    bool matches(Mesh* other)
    {
        if (other)
            return id == other.id;
        else
            return !loaded();
    }
}

struct Scene3D
{
    uint16 id;

    void initialize()
    {
        id = cast(uint16)-1;
    }

    void create(const char* identifier, uint16 faceCount, Scopes scopeType)
    {
        id = RSDK.create3DScene(identifier, faceCount, scopeType);
    }

    void prepare() => RSDK.prepare3DScene(id);
    void draw() => RSDK.draw3DScene(id);

    void setDiffuseColor(uint8 x, uint8 y, uint8 z)
    {
        RSDK.setDiffuseColor(id, x, y, z);
    }

    void setDiffuseIntensity(uint8 x, uint8 y, uint8 z)
    {
        RSDK.setDiffuseIntensity(id, x, y, z);
    }

    void setSpecularIntensity(uint8 x, uint8 y, uint8 z)
    {
        RSDK.setSpecularIntensity(id, x, y, z);
    }

    void addModel(ref Mesh modelFrames, Scene3DDrawTypes drawMode, Matrix* matWorld, Matrix* matView, color color)
    {
        RSDK.addModelTo3DScene(modelFrames.id, id, drawMode, matWorld, matView, color);
    }

    void addMesh(ref Mesh modelFrames, Animator* animator, Scene3DDrawTypes drawMode, Matrix* matWorld, Matrix* matNormal, color c)
    {
        RSDK.addMeshFrameTo3DScene(modelFrames.id, id, animator, drawMode, matWorld, matNormal, c);
    }

    bool loaded() => id != cast(uint16)-1;

    bool matches(ref Scene3D other) => id == other.id;
    bool matches(Scene3D* other)
    {
        if (other)
            return id == other.id;
        else
            return !loaded();
    }
}

struct Animator
{
    SpriteFrame* frames;
    int32 frameID;
    int16 animationID;
    int16 prevAnimationID;
    int16 speed;
    int16 timer;
    int16 frameDuration;
    int16 frameCount;
    uint8 loopIndex;
    uint8 rotationStyle;

    version (RETRO_MOD_LOADER_VER_2)
        alias _frameID_t = int32;
    else
        alias _frameID_t = int16;

    void setAnimation(ref SpriteAnimation spriteAni, uint16 listID, bool32 forceApply, _frameID_t frameID)
    {
        RSDK.setSpriteAnimation(spriteAni.id, listID, &this, forceApply, frameID);
    }

    void setAnimation(SpriteAnimation* spriteAni, uint16 listID, bool32 forceApply, _frameID_t frameID)
    {
        RSDK.setSpriteAnimation(spriteAni ? spriteAni.id : cast(uint16)-1, listID, &this, forceApply, frameID);
    }

    void setAnimation(ref Mesh mesh, int16 speed, uint8 loopIndex, bool32 forceApply, int16 frameID)
    {
        RSDK.setModelAnimation(mesh.id, &this, speed, loopIndex, forceApply, frameID);
    }

    void setAnimation(Mesh* mesh, int16 speed, uint8 loopIndex, bool32 forceApply, int16 frameID)
    {
        RSDK.setModelAnimation(mesh ? mesh.id : cast(uint16)-1, &this, speed, loopIndex, forceApply, frameID);
    }

    void process() => RSDK.processAnimation(&this);

    int32 getFrameID() => RSDK.getFrameID(&this);
    Hitbox* getHitbox(uint8 id) => RSDK.getHitbox(&this, id);
    SpriteFrame* getFrame(SpriteAnimation aniFrames) => aniFrames.getFrame(animationID, frameID);

    void drawSprite(Vector2* position, bool32 screenRelative) => RSDK.drawSprite(&this, position, screenRelative);
    void drawString(Vector2* position, String* str, int32 endFrame, int32 textLength, Alignments alignment, int32 spacing, Vector2* charOffsets, bool32 screenRelative)
    {
        RSDK.drawText(&this, position, str, endFrame, textLength, alignment, spacing, null, charOffsets, screenRelative);
    }

    version (RETRO_REV0U)
    {
        void drawAniTiles(uint16 tileID) => RSDK.drawDynamicAniTiles(&this, tileID);
    }
    else version (RETRO_USE_MOD_LOADER)
    {
        version (RETRO_MOD_LOADER_VER_2) void drawAniTiles(uint16 tileID) => mod.drawDynamicAniTiles(&this, tileID);
    }
}

struct ScrollInfo
{
    int32 tilePos;
    int32 parallaxFactor;
    int32 scrollSpeed;
    int32 scrollPos;
    uint8 deform;
    uint8 unknown;
}

struct ScanlineInfo
{
    Vector2 position;
    Vector2 deform;
}

struct Tile
{
    uint16 id = 0xFFFF;

    this(uint16 tileID)
    {
        id = tileID;
    }

    uint16 index()
    {
        return id & 0x3FF;
    }

    uint8 direction()
    {
        return (id >> 10) & 3;
    }

    uint8 solidA()
    {
        return (id >> 12) & 3;
    }

    uint8 solidB()
    {
        return (id >> 14) & 3;
    }

    void setIndex(uint16 index)
    {
        id &= ~0x3FF;
        id |= (index & 0x3FF);
    }

    void setDirection(uint8 dir)
    {
        id &= ~(3 << 10);
        id |= (dir & 3) << 10;
    }

    void setSolidA(uint8 solid)
    {
        id &= ~(3 << 12);
        id |= (solid & 3) << 12;
    }

    void setSolidB(uint8 solid)
    {
        id &= ~(3 << 14);
        id |= (solid & 3) << 14;
    }

    static void copy(uint16 dst, uint16 src, uint16 count = 1) => RSDK.copyTile(dst, src, count);

    int32 getAngle(uint8 cPlane, uint8 cMode) => RSDK.getTileAngle(id, cPlane, cMode);
    void setAngle(uint8 cPlane, uint8 cMode, uint8 angle) => RSDK.setTileAngle(id, cPlane, cMode, angle);
    uint8 getFlags(uint8 cPlane) => RSDK.getTileFlags(id, cPlane);
    void setFlags(uint8 cPlane, uint8 flag) => RSDK.setTileFlags(id, cPlane, flag);
}

struct TileLayer
{
    uint8 type;
    uint8[CAMERA_COUNT] drawGroup;
    uint8 widthShift;
    uint8 heightShift;
    uint16 width;
    uint16 height;
    Vector2 position;
    int32 parallaxFactor;
    int32 scrollSpeed;
    int32 scrollPos;
    int32 deformationOffset;
    int32 deformationOffsetW;
    int32[0x400] deformationData;
    int32[0x400] deformationDataW;
    extern (C) void function(ScanlineInfo*) scanlineCallback;
    uint16 scrollInfoCount;
    ScrollInfo[0x100] scrollInfo;
    uint32[4] name;
    Tile* layout;
    uint8* lineScroll;

    void processParallax() => RSDK.processParallax(&this);
}

struct SceneLayer
{
    uint16 id;

    void initialize()
    {
        id = cast(uint16)-1;
    }

    void get(const char* name)
    {
        id = RSDK.getTileLayerID(name);
    }

    void set(uint16 layerID)
    {
        id = layerID;
    }

    bool loaded()
    {
        return id != cast(uint16)-1;
    }

    bool matches(ref SceneLayer other)
    {
        return id == other.id;
    }

    bool matches(SceneLayer* other)
    {
        if (other)
            return id == other.id;
        else
            return !loaded();
    }

    TileLayer* getTileLayer()
    {
        return RSDK.getTileLayer(id);
    }

    void size(Vector2* size, bool32 usePixelUnits)
    {
        RSDK.getLayerSize(id, size, usePixelUnits);
    }

    Tile getTile(int32 x, int32 y)
    {
        return Tile(RSDK.getTile(id, x, y));
    }

    void setTile(int32 x, int32 y, Tile tile)
    {
        RSDK.setTile(id, x, y, tile.id);
    }

    static TileLayer* getTileLayer(const char* name)
    {
        return RSDK.getTileLayer(RSDK.getTileLayerID(name));
    }

    static TileLayer* getTileLayer(uint16 id)
    {
        return RSDK.getTileLayer(id);
    }

    static void copy(SceneLayer dstLayer, int32 dstStartX, int32 dstStartY, SceneLayer srcLayer, int32 srcStartX, int32 srcStartY,
        int32 countX, int32 countY)
    {
        RSDK.copyTileLayer(dstLayer.id, dstStartX, dstStartY, srcLayer.id, srcStartX, srcStartY, countX, countY);
    }
}

struct CollisionSensor
{
    Vector2 position;
    bool32 collided;
    uint8 angle;

    version (RETRO_REV0U)
    {
        static void SetPathGripSensors(CollisionSensor* sensors) => RSDK.setPathGripSensors(
            sensors);

        void findFloorPosition() => RSDK.findFloorPosition(&this);
        void findLWallPosition() => RSDK.findLWallPosition(&this);
        void findRoofPosition() => RSDK.findRoofPosition(&this);
        void findRWallPosition() => RSDK.findRWallPosition(&this);
        void floorCollision() => RSDK.floorCollision(&this);
        void lWallCollision() => RSDK.lWallCollision(&this);
        void roofCollision() => RSDK.roofCollision(&this);
        void rWallCollision() => RSDK.rWallCollision(&this);
    }
    else version (RETRO_REV0U)
    {
        version (RETRO_MOD_LOADER_VER_2)
        {
            static void SetPathGripSensors(CollisionSensor* sensors) => mod.setPathGripSensors(
                sensors);

            void findFloorPosition() => mod.findFloorPosition(&this);
            void findLWallPosition() => mod.findLWallPosition(&this);
            void findRoofPosition() => mod.findRoofPosition(&this);
            void findRWallPosition() => mod.findRWallPosition(&this);
            void floorCollision() => mod.floorCollision(&this);
            void lWallCollision() => mod.lWallCollision(&this);
            void roofCollision() => mod.roofCollision(&this);
            void rWallCollision() => mod.rWallCollision(&this);
        }
    }
}

struct CollisionMask
{
    uint8[TILE_SIZE] floorMasks;
    uint8[TILE_SIZE] lWallMasks;
    uint8[TILE_SIZE] rWallMasks;
    uint8[TILE_SIZE] roofMasks;
}

struct TileInfo
{
    uint8 floorAngle;
    uint8 lWallAngle;
    uint8 rWallAngle;
    uint8 roofAngle;
    uint8 flag;
}

version (RETRO_REV02)
{
    enum LeaderboardLoadTypes
    {
        init,
        prev,
        next
    }

    struct LeaderboardAvail
    {
        int32 start;
        int32 length;
    }

    struct StatInfo
    {
        uint8 statID;
        const char* name;
        void*[64] data;
    }
}

struct AchievementID
{
    uint8 idPS4; // achievement ID (PS4)
    int32 idUnknown; // achievement ID (unknown platform)
    const char* id; // achievement ID (as a string, used for most platforms)
}

struct LeaderboardID
{
    int32 idPS4; // leaderboard id (PS4)
    int32 idUnknown; // leaderboard id (unknown platform)
    int32 idSwitch; // leaderboard id (switch)
    const char* idXbox; // Xbox One Leaderboard id (making an assumption based on the MS docs)
    const char* idPC; // Leaderboard id (as a string, used for PC platforms)
}

struct LeaderboardEntry
{
    String username;

    version (RETRO_REV02) String userID;

    int32 globalRank;
    int32 score;
    bool32 isUser;
    int32 status;
}

// =========================
// Enums
// =========================

enum GamePlatforms
{
    platformPC,
    platformPS4,
    platformXB1,
    platformSwitch,
    platformDev = 0xFF,
}

enum Scopes : uint8
{
    none,
    global,
    stage
}

enum InkEffects
{
    none,
    blend,
    alpha,
    add,
    sub,
    tint,
    masked,
    unmasked,
}

enum DrawFX
{
    none = 0,
    flip = 1,
    rotate = 2,
    scale = 4
}

enum FlipFlags
{
    none,
    x,
    y,
    xy
}

version (RETRO_REV02)
    enum DefaultObjects
    {
        defaultObject,
        devOutput,
        count
    }
else
    enum DefaultObjects
    {
        defaultObject,
        count
    }

enum InputIDs
{
    unassigned = -2,
    autoassign = -1,
    none = 0,
}

enum InputSlotIDs
{
    any,
    P1,
    P2,
    P3,
    P4
}

enum InputDeviceTypes
{
    none,
    keyboard,
    controller,
    unknown,
    steamOverlay
}

enum InputDeviceIDs
{
    keyboard,
    xbox,
    PS4,
    saturn,
    switchHandheld,
    switchJoyconGrip,
    switchJoyconL,
    switchJoyconR,
    switchPro
}

enum InputDeviceAPIs
{
    none,
    keyboard,
    xInput,
    rawInput,
    steam
}

enum Alignments : int32
{
    left,
    right,
    center
}

version (RETRO_REV02)
    enum PrintModes
    {
        normal,
        popup,
        error,
        fatal
    }
else
    enum PrintMessageTypes
    {
        msgString,
        msgInt32,
        msgUint32,
        msgFloat
    }

enum VariableTypes : uint8
{
    varUInt8,
    varUInt16,
    varUInt32,
    varInt8,
    varInt16,
    varInt32,
    varEnum,
    varBool,
    varString,
    varVector2,
    varFloat, // Not actually used in Sonic Mania so it's just an assumption, but this is the only thing that'd fit the 32 bit limit and make sense
    varColor,
}

version (RETRO_REV02)
{
    enum DBVarTypes
    {
        varUnknown,
        varBool,
        varUInt8,
        varUInt16,
        varUInt32,
        varUInt64, // unimplemented in RSDKv5
        varInt8,
        varInt16,
        varInt32,
        varInt64, // unimplemented in RSDKv5
        varFloat,
        varDouble, // unimplemented in RSDKv5
        varVector2, // unimplemented in RSDKv5
        varVector3, // unimplemented in RSDKv5
        varVector4, // unimplemented in RSDKv5
        varColor,
        varString,
        varHashMD5, // unimplemented in RSDKv5
    }

    enum ViewableVarTypes
    {
        varInvalid,
        varBool,
        varUint8,
        varUInt16,
        varUInt32,
        varInt8,
        varInt16,
        varInt32,
    }
}

enum ActiveFlags
{
    never, // never update
    always, // always update (even if paused/frozen)
    normal, // always update (unless paused/frozen)
    paused, // update only when paused/frozen
    bounds, // update if in x & y bounds
    xBounds, // update only if in x bounds (y bounds dont matter)
    yBounds, // update only if in y bounds (x bounds dont matter)
    rBounds, // update based on radius boundaries (updateRange.x == radius)

    // Not really even a real active value, but some objects set their active states to this so here it is I suppose
    disabled = 0xFF,
}

enum RotationStyles
{
    none,
    full,
    deg45,
    deg90,
    deg180,
    staticFrames
}

enum LayerTypes
{
    hScroll,
    vScroll,
    rotoZoom,
    basic
}

enum CModes
{
    floor,
    lWall,
    roff,
    rWall
}

enum CSides
{
    none,
    top,
    left,
    right,
    bottom
}

version (RETRO_REV0U)
    enum TileCollisionModes
    {
        none,
        down,
        up
    }
else
    enum TileCollisionModes
    {
        none,
        down
    }

enum Scene3DDrawTypes : uint8
{
    wireFrame,
    solidColor,
    unused1,
    unused2,
    wireFrameShaded,
    solidColorShaded,
    solidColorShadedBlended,
    wireFrameScreen,
    solidColorScreen,
    wireFrameShadedScreen,
    solidColorShadedScreen,
    solidColorShadedScreenBlended,
}

version (RETRO_REV02)
{
    enum VideoSettingsValues
    {
        windowed,
        bordered,
        exclusideFS,
        vSync,
        trippleBuffered,
        windowWidth,
        windowHeight,
        fsWidth,
        fsHeight,
        refreshRate,
        shaderSupport,
        shaderID,
        screenCount,
        dimTimer,
        streamsEnabled,
        streamVol,
        sfxVol,
        language,
        store,
        reload,
        changed,
        write,
    }
}
else
{
    enum VideoSettingsValues
    {
        windowed,
        bordered,
        exclusideFS,
        vSync,
        trippleBuffered,
        windowWidth,
        windowHeight,
        fsWidth,
        fsHeight,
        refreshRate,
        shaderSupport,
        shaderID,
        screenCount,
        streamsEnabled,
        streamVol,
        sfxVol,
        language,
        store,
        reload,
        changed,
        write,
    }
}

enum TypeGroups
{
    all = 0,
    custom0 = TYPE_COUNT,
    custom1,
    custom2,
    custom3,
}

enum StatusCodes
{
    codeNone = 0,
    codeContinue = 100,
    codeOK = 200,
    codeForbidden = 403,
    codeNotFound = 404,
    codeError = 500,
    codeNoWiFi = 503,
    codeTimeout = 504,
    codeCorrupt = 505,
    codeNoSpace = 506,
}

enum GameRegions
{
    us,
    jp,
    eu
}

enum GameLanguages
{
    en,
    fr,
    it,
    ge,
    sp,
    jp,
    ko,
    sc,
    tc
}

version (RETRO_REV0U)
{
    enum EngineStates
    {
        load,
        regular,
        paused,
        frozen,
        stepOver = 4,
        devMenu = 8,
        videoPlayback,
        showImage,
        errorMsg,
        errorMsgFatal,
        none,
        // Prolly origins-only, called by the ending so I assume this handles playing ending movies and returning to menu
        gameFinished,
    }
}
else version (RETRO_REV02)
{
    enum EngineStates
    {
        load,
        regular,
        paused,
        frozen,
        stepOver = 4,
        devMenu = 8,
        videoPlayback,
        showImage,
        errorMsg,
        errorMsgFatal,
        none,
    }
}
else
{
    enum EngineStates
    {
        load,
        regular,
        paused,
        frozen,
        stepOver = 4,
        devMenu = 8,
        videoPlayback,
        showImage,
        none,
    }
}

// see: https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
// for value list & descriptions
enum KeyMappings
{
    autoMapping = -1,
    noMapping = 0,
    lButton = 0x01,
    rButton = 0x02,
    cancel = 0x03,
    mButton = 0x04,
    xButton1 = 0x05,
    xButton2 = 0x06,
    back = 0x08,
    tab = 0x09,
    clear = 0x0C,
    kReturn = 0x0D,
    shift = 0x10,
    control = 0x11,
    menu = 0x12,
    pause = 0x13,
    capital = 0x14,
    kana = 0x15,
    hanguel = 0x15,
    hangul = 0x15,
    junja = 0x17,
    kFinal = 0x18,
    hanja = 0x19,
    kanji = 0x19,
    escape = 0x1B,
    convert = 0x1C,
    nonConvert = 0x1D,
    accept = 0x1E,
    modeChange = 0x1F,
    space = 0x20,
    prior = 0x21,
    kNext = 0x22,
    end = 0x23,
    home = 0x24,
    left = 0x25,
    up = 0x26,
    right = 0x27,
    down = 0x28,
    select = 0x29,
    print = 0x2A,
    execute = 0x2B,
    snapshot = 0x2C,
    insert = 0x2D,
    kDelete = 0x2E,
    help = 0x2F,
    key0 = 0x30,
    key1 = 0x31,
    key2 = 0x32,
    key3 = 0x33,
    key4 = 0x34,
    key5 = 0x35,
    key6 = 0x36,
    key7 = 0x37,
    key8 = 0x38,
    key9 = 0x39,
    keyA = 0x41,
    keyB = 0x42,
    keyC = 0x43,
    keyD = 0x44,
    keyE = 0x45,
    keyF = 0x46,
    keyG = 0x47,
    keyH = 0x48,
    keyI = 0x49,
    keyJ = 0x4A,
    keyK = 0x4B,
    keyL = 0x4C,
    keyM = 0x4D,
    keyN = 0x4E,
    keyO = 0x4F,
    keyP = 0x50,
    keyQ = 0x51,
    keyR = 0x52,
    keyS = 0x53,
    keyT = 0x54,
    keyU = 0x55,
    keyV = 0x56,
    keyW = 0x57,
    keyX = 0x58,
    keyY = 0x59,
    keyZ = 0x5A,
    lWin = 0x5B,
    rWin = 0x5C,
    apps = 0x5D,
    sleep = 0x5F,
    numpad0 = 0x60,
    numpad1 = 0x61,
    numpad2 = 0x62,
    numpad3 = 0x63,
    numpad4 = 0x64,
    numpad5 = 0x65,
    numpad6 = 0x66,
    numpad7 = 0x67,
    numpad8 = 0x68,
    numpad9 = 0x69,
    multiply = 0x6A,
    add = 0x6B,
    separator = 0x6C,
    subtract = 0x6D,
    decimal = 0x6E,
    divide = 0x6F,
    f1 = 0x70,
    f2 = 0x71,
    f3 = 0x72,
    f4 = 0x73,
    f5 = 0x74,
    f6 = 0x75,
    f7 = 0x76,
    f8 = 0x77,
    f9 = 0x78,
    f10 = 0x79,
    f11 = 0x7A,
    f12 = 0x7B,
    f13 = 0x7C,
    f14 = 0x7D,
    f15 = 0x7E,
    f16 = 0x7F,
    f17 = 0x80,
    f18 = 0x81,
    f19 = 0x82,
    f20 = 0x83,
    f21 = 0x84,
    f22 = 0x85,
    f23 = 0x86,
    f24 = 0x87,
    navigationView = 0x88,
    navigationMenu = 0x89,
    navigationUp = 0x8A,
    navigationDown = 0x8B,
    navigationLeft = 0x8C,
    navigationRight = 0x8D,
    navigationAccept = 0x8E,
    navigationCancel = 0x8F,
    numLock = 0x90,
    scroll = 0x91,
    oemNECEqual = 0x92,
    oemFJJisho = 0x92,
    oemFJMasshou = 0x93,
    oemFJTouroku = 0x94,
    oemFJLoya = 0x95,
    oemFJRoya = 0x96,
    lShift = 0xA0,
    rShift = 0xA1,
    lControl = 0xA2,
    rControl = 0xA3,
    lMenu = 0xA4,
    rMenu = 0xA5,
    browserBack = 0xA6,
    browserForward = 0xA7,
    browserRefresh = 0xA8,
    browserStop = 0xA9,
    browserSearch = 0xAA,
    browserFavorites = 0xAB,
    browserHome = 0xAC,
    volumeMute = 0xAD,
    volumeDown = 0xAE,
    volumeUp = 0xAF,
    mediaNextTract = 0xB0,
    mediaPrevTrack = 0xB1,
    mediaStop = 0xB2,
    mediaPlayPause = 0xB3,
    launchMail = 0xB4,
    launchMediaSelect = 0xB5,
    launchApp1 = 0xB6,
    launchApp2 = 0xB7,
    oem1 = 0xBA,
    oemPlus = 0xBB,
    oemComma = 0xBC,
    oemMinus = 0xBD,
    oemPeriod = 0xBE,
    oem2 = 0xBF,
    oem3 = 0xC0,
    gamepadA = 0xC3,
    gamepadB = 0xC4,
    gamepadX = 0xC5,
    gamepadY = 0xC6,
    gamepadRShoulder = 0xC7,
    gamepadLShoulder = 0xC8,
    gamepadLTrigger = 0xC9,
    gamepadRTrigger = 0xCA,
    gamepadDPadUp = 0xCB,
    gamepadDPadDown = 0xCC,
    gamepadDPadLeft = 0xCD,
    gamepadDPadRight = 0xCE,
    gamepadMenu = 0xCF,
    gamepadView = 0xD0,
    gamepadLThumbButton = 0xD1,
    gamepadRThumbButton = 0xD2,
    gamepadLThumbUp = 0xD3,
    gamepadLThumbDown = 0xD4,
    gamepadLThumbRight = 0xD5,
    gamepadLThumbLeft = 0xD6,
    gamepadRThumbUp = 0xD7,
    gamepadRThumbDown = 0xD8,
    gamepadRThumbRight = 0xD9,
    gamepadRThumbLeft = 0xDA,
    oem4 = 0xDB,
    oem5 = 0xDC,
    oem6 = 0xDD,
    oem7 = 0xDE,
    oem8 = 0xDF,
    oemAX = 0xE1,
    oem102 = 0xE2,
    keyIcoHelp = 0xE3,
    keyIco00 = 0xE4,
    keyProcessKey = 0xE5,
    keyIcoClear = 0xE6,
    keyPacket = 0xE7,
    oemReset = 0xE9,
    oemJump = 0xEA,
    oemPa1 = 0xEB,
    oemPa2 = 0xEC,
    oemPa3 = 0xED,
    oemWSctrl = 0xEE,
    oemCusel = 0xEF,
    oemAttn = 0xF0,
    oemFinish = 0xF1,
    oemCopy = 0xF2,
    oemAuto = 0xF3,
    oemEnlw = 0xF4,
    oemBacktab = 0xF5,
    attn = 0xF6,
    crsel = 0xF7,
    exsel = 0xF8,
    ereof = 0xF9,
    play = 0xFA,
    zoom = 0xFB,
    noName = 0xFC,
    pa1 = 0xFD,
    oemCLEAR = 0xFE,
}

version (RETRO_USE_MOD_LOADER)
{
    enum ModCallbackEvents
    {
        onGameStartup,
        onStaticLoad,
        onStageLoad,
        onUpdate,
        onLateUpdate,
        onStaticUpdate,
        onDraw,
        onStageUnload,
        onShaderLoad,
        onVideoSkipCB,
        onScanlineCB,
    }

    enum ModSuper
    {
        update,
        lateUpdate,
        staticUpdate,
        draw,
        create,
        stageload,
        editorload,
        editorDraw,
        serialize
    }
}

// =========================
// FUNCTION TABLES
// =========================

version (RETRO_USE_MOD_LOADER)
{
    extern (C)
    struct ModFunctionTable
    {
        // Registration & Core
        version (RETRO_REV0U)
        {
            void function(const char* globalsPath, void** globals, uint32 size, void function(
                    void* globals) initCB) registerGlobals;
            void function(void** staticVars, void** modStaticVars, const char* name, uint32 entityClassSize, uint32 staticClassSize,
                uint32 modClassSize, void function() update, void function() lateUpdate, void function() staticUpdate, void function() draw,
                void function(void*) create, void function() stageLoad, void function() editorLoad, void function() editorDraw,
                void function() serialize, void function(void*) staticLoad, const char* inherited) registerObject;
        }
        else
        {
            void function(const char* globalsPath, void** globals, uint32 size) registerGlobals;
            void function(void** staticVars, void** modStaticVars, const char* name, uint32 entityClassSize, uint32 staticClassSize,
                uint32 modClassSize, void function() update, void function() lateUpdate, void function() staticUpdate, void function() draw,
                void function(void*) create, void function() stageLoad, void function() editorLoad, void function() editorDraw,
                void function() serialize, const char* inherited) registerObject;
        }

        private void* registerObjectSTD;
        void function(void** staticVars, const char* staticName) registerObjectHook;
        void* function(const char* name) findObject;
        void* function() getGlobals;
        void function(int32 classID, int32 callback, void* data) superCallback;

        // Mod Info
        bool32 function(const char* id, String* name, String* description, String* ver, bool32* active) loadModInfo;
        void function(const char* id, String* result) getModPath;
        int32 function(bool32 active) getModCount;
        const char* function(uint32 index) getModIDByIndex;
        bool32 function(String* id) foreachModID;

        // Mod Callbacks & Public Functions
        void function(int32 callbackID, void function(void*) callback) addModCallback;
        void* addModCallbackSTD;
        void function(const char* functionName, void* functionPtr) addPublicFunction;
        void* function(const char* id, const char* functionName) getPublicFunction;

        // Mod Settings
        bool32 function(const char* id, const char* key, bool32 fallback) getSettingsBool;
        int32 function(const char* id, const char* key, int32 fallback) getSettingsInteger;
        float function(const char* id, const char* key, float fallback) getSettingsFloat;
        void function(const char* id, const char* key, String* result, const char* fallback) getSettingsString;
        void function(const char* key, bool32 val) setSettingsBool;
        void function(const char* key, int32 val) setSettingsInteger;
        void function(const char* key, float val) setSettingsFloat;
        void function(const char* key, String* val) setSettingsString;
        void function() saveSettings;

        // Config
        bool32 function(const char* key, bool32 fallback) getConfigBool;
        int32 function(const char* key, int32 fallback) getConfigInteger;
        float function(const char* key, float fallback) getConfigFloat;
        void function(const char* key, String* result, const char* fallback) getConfigString;
        bool32 function(String* config) foreachConfig;
        bool32 function(String* category) foreachConfigCategory;

        // Achievements
        void function(const char* identifier, const char* name, const char* desc) registerAchievement;
        void function(uint32 id, String* name, String* description, String* identifier, bool32* achieved) getAchievementInfo;
        int32 function(const char* identifier) getAchievementIndexByID;
        int32 function() getAchievementCount;

        // Shaders
        void function(const char* shaderName, bool32 linear) loadShader;

        // StateMachine
        void function(void function() state) stateMachineRun;
        void function(void function() state, bool32 function(bool32 skippedState) hook, bool32 priority) registerStateHook;
        // runs all high priority state hooks hooked to the address of 'state', returns if the main state should be skipped or not
        bool32 function(void function() state) handleRunStateHighPriority;
        // runs all low priority state hooks hooked to the address of 'state'
        void function(void function() state, bool32 skipState) handleRunStateLowPriority;

        version (RETRO_MOD_LOADER_VER_2)
        {
            // Mod Settings (Part 2)
            bool32 function(const char* id, String* setting) foreachSetting;
            bool32 function(const char* id, String* category) foreachSettingCategory;

            // Files
            bool32 function(const char* id, const char* path) excludeFile;
            bool32 function(const char* id) excludeAllFiles;
            bool32 function(const char* id, const char* path) reloadFile;
            bool32 function(const char* id) reloadAllFiles;

            // Graphics
            void* function(uint16 id) getSpriteAnimation;
            void* function(uint16 id) getSpriteSurface;
            uint16* function(uint8 id) getPaletteBank;
            uint8* function() getActivePaletteBuffer;
            void function(uint16** rgb32To16_R, uint16** rgb32To16_G, uint16** rgb32To16_B) getRGB32To16Buffer;
            uint16* function() getBlendLookupTable;
            uint16* function() getSubtractLookupTable;
            uint16* function() getTintLookupTable;
            color function() getMaskColor;
            void* function() getScanEdgeBuffer;
            void* function(uint8 id) getCamera;
            void* function(uint8 id) getShader;
            void* function(uint16 id) getModel;
            void* function(uint16 id) getScene3D;
            void function(Animator* animator, uint16 tileIndex) drawDynamicAniTiles;

            // Audio
            void* function(uint16 id) getSfx;
            void* function(uint8 id) getChannel;

            // Objects/Entities
            bool32 function(uint16 group, void** entity) getGroupEntities;

            // Collision
            void function(CollisionSensor* sensors) setPathGripSensors; // expects 5 sensors
            void function(CollisionSensor* sensor) findFloorPosition;
            void function(CollisionSensor* sensor) findLWallPosition;
            void function(CollisionSensor* sensor) findRoofPosition;
            void function(CollisionSensor* sensor) findRWallPosition;
            void function(CollisionSensor* sensor) floorCollision;
            void function(CollisionSensor* sensor) lWallCollision;
            void function(CollisionSensor* sensor) roofCollision;
            void function(CollisionSensor* sensor) rWallCollision;
            void function(uint16 dst, uint16 src, uint8 cPlane, uint8 cMode) copyCollisionMask;
            void function(CollisionMask** masks, TileInfo** tileInfo) getCollisionInfo;
        }
    }
}

version (RETRO_REV02)
{
    extern (C)
    struct APIFunctionTable
    {
        // API Core
        int32 function() getUserLanguage;
        bool32 function() getConfirmButtonFlip;
        void function() exitGame;
        void function() launchManual;

        version (RETRO_REV0U) int32 function() getDefaultGamepadType;

        bool32 function(uint32 deviceID) isOverlayEnabled;
        bool32 function(int32 dlc) checkDLC;

        version (RETRO_USE_EGS)
        {
            bool32 function() setupExtensionOverlay;
            bool32 function(int32 overlay) canShowExtensionOverlay;
        }

        bool32 function(int32 overlay) showExtensionOverlay;

        version (RETRO_USE_EGS)
        {
            bool32 function(int32 overlay) canShowAltExtensionOverlay;
            bool32 function(int32 overlay) showAltExtensionOverlay;
            int32 function() getConnectingStringID;
            bool32 function(int32 id) showLimitedVideoOptions;
        }

        // Achievements
        void function(AchievementID* id) tryUnlockAchievement;
        bool32 function() getAchievementsEnabled;
        void function(bool32 enabled) setAchievementsEnabled;

        version (RETRO_USE_EGS)
        {
            bool32 function() checkAchievementsEnabled;
            void function(String** names, int32 count) setAchievementNames;
        }

        // Leaderboards
        version (RETRO_USE_EGS) bool32 function() checkLeaderboardsEnabled;

        void function() initLeaderboards;
        void function(LeaderboardID* leaderboard, bool32 isUser) fetchLeaderboard;
        void function(LeaderboardID* leaderboard, int32 score, void function(bool32 success, int32 rank) callback) TrackScore;
        int32 function() getLeaderboardsStatus;
        LeaderboardAvail function() leaderboardEntryViewSize;
        LeaderboardAvail function() leaderboardEntryLoadSize;
        void function(int32 start, uint32 end, int32 type) loadLeaderboardEntries;
        void function() resetLeaderboardInfo;
        LeaderboardEntry* function(uint32 entryID) readLeaderboardEntry;

        // Rich Presence
        void function(int32 id, String* text) setRichPresence;

        // Stats
        void function(StatInfo* stat) tryTrackStat;
        bool32 function() getStatsEnabled;
        void function(bool32 enabled) setStatsEnabled;

        // Authorization
        void function() clearPrerollErrors;
        void function() tryAuth;
        int32 function() getUserAuthStatus;
        bool32 function(String* userName) getUsername;

        // Storage
        void function() tryInitStorage;
        int32 function() getStorageStatus;
        int32 function() getSaveStatus;
        void function() clearSaveStatus;
        void function() setSaveStatusContinue;
        void function() setSaveStatusOK;
        void function() setSaveStatusForbidden;
        void function() setSaveStatusError;
        void function(bool32 noSave) setNoSave;
        bool32 function() getNoSave;

        // User File Management
        void function(const char* name, void* buffer, uint32 size, void function(int32 status) callback) loadUserFile;
        void function(const char* name, void* buffer, uint32 size, void function(int32 status) callback, bool32 compressed) saveUserFile;
        void function(const char* name, void function(int32 status) callback) deleteUserFile;

        // User DBs
        uint16 function(const char* name, ...) initUserDB;
        uint16 function(const char* filename, void function(int32 status) callback) loadUserDB;
        bool32 function(uint16 tableID, void function(int32 status) callback) saveUserDB;
        void function(uint16 tableID) clearUserDB;
        void function() clearAllUserDBs;
        uint16 function(uint16 tableID) setupUserDBRowSorting;
        bool32 function(uint16 tableID) getUserDBRowsChanged;
        int32 function(uint16 tableID, int32 type, const char* name, void* value) addRowSortFilter;
        int32 function(uint16 tableID, int32 type, const char* name, bool32 sortAscending) sortDBRows;
        int32 function(uint16 tableID) getSortedUserDBRowCount;
        int32 function(uint16 tableID, uint16 row) getSortedUserDBRowID;
        int32 function(uint16 tableID) addUserDBRow;
        bool32 function(uint16 tableID, uint32 row, int32 type, const char* name, void* value) setUserDBValue;
        bool32 function(uint16 tableID, uint32 row, int32 type, const char* name, void* value) getUserDBValue;
        uint32 function(uint16 tableID, uint16 row) getUserDBRowUUID;
        uint16 function(uint16 tableID, uint32 uuid) getUserDBRowByID;
        void function(uint16 tableID, uint16 row, char* buffer, size_t bufferSize, const char* format) getUserDBRowCreationTime;
        bool32 function(uint16 tableID, uint16 row) removeDBRow;
        bool32 function(uint16 tableID) removeAllDBRows;
    }
}

extern (C)
struct RSDKFunctionTable
{
    // Registration
    version (RETRO_REV0U)
    {
        void function(void** globals, int32 size, void function(void* globals) initCB) registerGlobalVariables;
        void function(void** staticVars, const char* name, uint32 entityClassSize, uint32 staticClassSize, void function() update,
            void function() lateUpdate, void function() staticUpdate, void function() draw, void function(void*) create, void function() stageLoad,
            void function() editorLoad, void function() editorDraw, void function() serialize, void function(
                void*) staticLoad) registerObject;
    }
    else
    {
        void function(void** globals, int32 size) registerGlobalVariables;
        void function(void** staticVars, const char* name, uint32 entityClassSize, uint32 staticClassSize, void function() update,
            void function() lateUpdate, void function() staticUpdate, void function() draw, void function(void*) create, void function() stageLoad,
            void function() editorLoad, void function() editorDraw, void function() serialize) registerObject;
    }

    version (RETRO_REV02) void function(void** varClass, const char* name, uint32 classSize) registerStaticVariables;

    // Entities & Objects
    bool32 function(uint16 group, void** entity) getActiveEntities;
    bool32 function(uint16 classID, void** entity) getAllEntities;
    void function() breakForeachLoop;
    void function(uint8 type, const char* name, uint8 classID, int32 offset) setEditableVar;
    void* function(uint16 slot) getEntity;
    uint16 function(void* entity) getEntitySlot;
    int32 function(uint16 classID, bool32 isActive) getEntityCount;
    int32 function(uint8 drawGroup, uint16 listPos) getDrawListRefSlot;
    void* function(uint8 drawGroup, uint16 listPos) getDrawListRef;
    void function(void* entity, uint16 classID, void* data) resetEntity;
    void function(uint16 slot, uint16 classID, void* data) resetEntitySlot;
    void* function(uint16 classID, void* data, int32 x, int32 y) createEntity;
    void function(void* destEntity, void* srcEntity, bool32 clearSrcEntity) copyEntity;
    bool32 function(void* entity, Vector2* range) checkOnScreen;
    bool32 function(Vector2* position, Vector2* range) checkPosOnScreen;
    void function(uint8 drawGroup, uint16 entitySlot) addDrawListRef;
    void function(uint8 drawGroup, uint16 slot1, uint16 slot2, uint16 count) swapDrawListEntries;
    void function(uint8 drawGroup, bool32 sorted, void function() hookCB) setDrawGroupProperties;

    // Scene Management
    void function(const char* categoryName, const char* sceneName) setScene;
    void function(uint8 state) setEngineState;

    version (RETRO_REV02) void function(bool32 shouldHardReset) forceHardReset;

    bool32 function() checkValidScene;
    bool32 function(const char* folderName) checkSceneFolder;
    void function() loadScene;
    int32 function(const char* name) findObject;

    // Cameras
    void function() clearCameras;
    void function(Vector2* targetPos, int32 offsetX, int32 offsetY, bool32 worldRelative) addCamera;

    // API (Rev01 only)
    version (RETRO_REV02)
    {
    }
    else
        void* function(const char* funcName) getAPIFunction;

    // Window/Video Settings
    int32 function(int32 id) getVideoSetting;
    void function(int32 id, int32 value) setVideoSetting;
    void function() updateWindow;

    // Math
    int32 function(int32 angle) sin1024;
    int32 function(int32 angle) cos1024;
    int32 function(int32 angle) tan1024;
    int32 function(int32 angle) aSin1024;
    int32 function(int32 angle) aCos1024;
    int32 function(int32 angle) sin512;
    int32 function(int32 angle) cos512;
    int32 function(int32 angle) tan512;
    int32 function(int32 angle) aSin512;
    int32 function(int32 angle) aCos512;
    int32 function(int32 angle) sin256;
    int32 function(int32 angle) cos256;
    int32 function(int32 angle) tan256;
    int32 function(int32 angle) aSin256;
    int32 function(int32 angle) aCos256;
    int32 function(int32 min, int32 max) rand;
    int32 function(int32 min, int32 max, int32* seed) randSeeded;
    void function(int32 seed) setRandSeed;
    uint8 function(int32 x, int32 y) aTan2;

    // Matrices
    void function(Matrix* matrix) setIdentityMatrix;
    void function(Matrix* dest, Matrix* matrixA, Matrix* matrixB) matrixMultiply;
    void function(Matrix* matrix, int32 x, int32 y, int32 z, bool32 setIdentity) matrixTranslateXYZ;
    void function(Matrix* matrix, int32 x, int32 y, int32 z) matrixScaleXYZ;
    void function(Matrix* matrix, int32 angle) matrixRotateX;
    void function(Matrix* matrix, int32 angle) matrixRotateY;
    void function(Matrix* matrix, int32 angle) matrixRotateZ;
    void function(Matrix* matrix, int32 x, int32 y, int32 z) matrixRotateXYZ;
    void function(Matrix* dest, Matrix* matrix) matrixInverse;
    void function(Matrix* matDest, Matrix* matSrc) matrixCopy;

    // Strings
    void function(String* string, const char* text, uint32 textLength) initString;
    void function(String* dst, String* src) copyString;
    void function(String* string, const char* text) setString;
    void function(String* string, String* appendString) appendString;
    void function(String* string, const char* appendText) appendText;
    void function(String* stringList, const char* filePath, uint32 charSize) loadStringList;
    bool32 function(String* splitStrings, String* stringList, int32 startStringID, int32 stringCount) splitStringList;
    void function(char* destChars, String* string) getCString;
    bool32 function(String* string1, String* string2, bool32 exactMatch) compareStrings;

    // Screens & Displays
    void function(int32* displayID, int32* width, int32* height, int32* refreshRate, char* text) getDisplayInfo;
    void function(int32* width, int32* height) getWindowSize;
    int32 function(uint8 screenID, uint16 width, uint16 height) setScreenSize;
    void function(uint8 screenID, int32 x1, int32 y1, int32 x2, int32 y2) setClipBounds;

    version (RETRO_REV02) void function(uint8 startVert2P_S1, uint8 startVert2P_S2, uint8 startVert3P_S1, uint8 startVert3P_S2, uint8 startVert3P_S3) setScreenVertices;

    // Spritesheets
    uint16 function(const char* filePath, uint8 scopeType) loadSpriteSheet;

    // Palettes & Colors
    version (RETRO_REV02)
        void function(uint16* lookupTable) setTintLookupTable;
    else
        uint16* function() getTintLookupTable;

    void function(color maskColor) setPaletteMask;
    void function(uint8 bankID, uint8 index, uint32 color) setPaletteEntry;
    color function(uint8 bankID, uint8 index) getPaletteEntry;
    void function(uint8 newActiveBank, int32 startLine, int32 endLine) setActivePalette;
    void function(uint8 sourceBank, uint8 srcBankStart, uint8 destinationBank, uint8 destBankStart, uint8 count) copyPalette;

    version (RETRO_REV02) void function(uint8 bankID, const char* path, uint16 disabledRows) loadPalette;

    void function(uint8 bankID, uint8 startIndex, uint8 endIndex, bool32 right) rotatePalette;
    void function(uint8 destBankID, uint8 srcBankA, uint8 srcBankB, int16 blendAmount, int32 startIndex, int32 endIndex) setLimitedFade;

    version (RETRO_REV02) void function(uint8 destBankID, color* srcColorsA, color* srcColorsB, int32 blendAmount, int32 startIndex, int32 count) blendColors;

    // Drawing
    void function(int32 x, int32 y, int32 width, int32 height, uint32 color, int32 alpha, int32 inkEffect, bool32 screenRelative) drawRect;
    void function(int32 x1, int32 y1, int32 x2, int32 y2, uint32 color, int32 alpha, int32 inkEffect, bool32 screenRelative) drawLine;
    void function(int32 x, int32 y, int32 radius, uint32 color, int32 alpha, int32 inkEffect, bool32 screenRelative) drawCircle;
    void function(int32 x, int32 y, int32 innerRadius, int32 outerRadius, uint32 color, int32 alpha, int32 inkEffect, bool32 screenRelative) drawCircleOutline;
    void function(Vector2* vertices, int32 vertCount, int32 r, int32 g, int32 b, int32 alpha, int32 inkEffect) drawFace;
    void function(Vector2* vertices, color* vertColors, int32 vertCount, int32 alpha, int32 inkEffect) drawBlendedFace;
    void function(Animator* animator, Vector2* position, bool32 screenRelative) drawSprite;
    void function(uint16 sheetID, int32 inkEffect, bool32 screenRelative) drawDeformedSprite;
    void function(Animator* animator, Vector2* position, String* str, int32 endFrame, int32 textLength, int32 alignment, int32 spacing, void* unused, Vector2* charOffsets, bool32 screenRelative) drawText;
    void function(uint16* tiles, int32 countX, int32 countY, Vector2* position, Vector2* offset, bool32 screenRelative) drawTile;
    void function(uint16 dest, uint16 src, uint16 count) copyTile;
    void function(uint16 sheetID, uint16 tileIndex, uint16 srcX, uint16 srcY, uint16 width, uint16 height) drawAniTiles;

    version (RETRO_REV0U) void function(Animator* animator, uint16 tileIndex) drawDynamicAniTiles;

    void function(uint32 color, int32 alphaR, int32 alphaG, int32 alphaB) fillScreen;

    // Meshes & 3D Scenes
    uint16 function(const char* filename, uint8 scopeType) loadMesh;
    uint16 function(const char* identifier, uint16 faceCount, uint8 scopeType) create3DScene;
    void function(uint16 sceneIndex) prepare3DScene;
    void function(uint16 sceneIndex, uint8 x, uint8 y, uint8 z) setDiffuseColor;
    void function(uint16 sceneIndex, uint8 x, uint8 y, uint8 z) setDiffuseIntensity;
    void function(uint16 sceneIndex, uint8 x, uint8 y, uint8 z) setSpecularIntensity;
    void function(uint16 modelFrames, uint16 sceneIndex, uint8 drawMode, Matrix* matWorld, Matrix* matView, color color) addModelTo3DScene;
    void function(uint16 modelFrames, Animator* animator, int16 speed, uint8 loopIndex, bool32 forceApply, int16 frameID) setModelAnimation;
    void function(uint16 modelFrames, uint16 sceneIndex, Animator* animator, uint8 drawMode, Matrix* matWorld, Matrix* matView, color color) addMeshFrameTo3DScene;
    void function(uint16 sceneIndex) draw3DScene;

    // Sprite Animations & Frames
    uint16 function(const char* filePath, uint8 scopeType) loadSpriteAnimation;
    uint16 function(const char* filePath, uint32 frameCount, uint32 listCount, uint8 scopeType) createSpriteAnimation;

    version (RETRO_MOD_LOADER_VER_2)
        void function(uint16 aniFrames, uint16 listID, Animator* animator, bool32 forceApply, int32 frameID) setSpriteAnimation;
    else
        void function(uint16 aniFrames, uint16 listID, Animator* animator, bool32 forceApply, int16 frameID) setSpriteAnimation;

    void function(uint16 aniFrames, uint16 listID, const char* name, int32 frameOffset, uint16 frameCount, int16 speed, uint8 loopIndex, uint8 rotationStyle) editSpriteAnimation;
    void function(uint16 aniFrames, uint16 listID, String* str) setSpriteString;
    uint16 function(uint16 aniFrames, const char* name) findSpriteAnimation;
    SpriteFrame* function(uint16 aniFrames, uint16 listID, int32 frameID) getFrame;
    Hitbox* function(Animator* animator, uint8 hitboxID) getHitbox;
    int16 function(Animator* animator) getFrameID;
    int32 function(uint16 aniFrames, uint16 listID, String* str, int32 startIndex, int32 length, int32 spacing) getStringWidth;
    void function(Animator* animator) processAnimation;

    // Tile Layers
    uint16 function(const char* name) getTileLayerID;
    TileLayer* function(uint16 layerID) getTileLayer;
    void function(uint16 layer, Vector2* size, bool32 usePixelUnits) getLayerSize;
    uint16 function(uint16 layer, int32 x, int32 y) getTile;
    void function(uint16 layer, int32 x, int32 y, uint16 tile) setTile;
    void function(uint16 dstLayerID, int32 dstStartX, int32 dstStartY, uint16 srcLayerID, int32 srcStartX, int32 srcStartY, int32 countX, int32 countY) copyTileLayer;
    void function(TileLayer* tileLayer) processParallax;
    ScanlineInfo* function() getScanlines;

    // Object & Tile Collisions
    bool32 function(void* thisEntity, Hitbox* thisHitbox, void* otherEntity, Hitbox* otherHitbox) checkObjectCollisionTouchBox;
    bool32 function(void* thisEntity, int32 thisRadius, void* otherEntity, int32 otherRadius) checkObjectCollisionTouchCircle;
    uint8 function(void* thisEntity, Hitbox* thisHitbox, void* otherEntity, Hitbox* otherHitbox, bool32 setPos) checkObjectCollisionBox;
    bool32 function(void* thisEntity, Hitbox* thisHitbox, void* otherEntity, Hitbox* otherHitbox, bool32 setPos) checkObjectCollisionPlatform;
    bool32 function(void* entity, uint16 collisionLayers, uint8 collisionMode, uint8 collisionPlane, int32 xOffset, int32 yOffset, bool32 setPos) objectTileCollision;
    bool32 function(void* entity, uint16 collisionLayers, uint8 collisionMode, uint8 collisionPlane, int32 xOffset, int32 yOffset, int32 tolerance) objectTileGrip;
    void function(void* entity, Hitbox* outer, Hitbox* inner) processObjectMovement;

    version (RETRO_REV0U)
    {
        void function(int32 minDistance, uint8 lowTolerance, uint8 highTolerance, uint8 floorAngleTolerance, uint8 wallAngleTolerance, uint8 roofAngleTolerance) setupCollisionConfig;
        void function(CollisionSensor* sensors) setPathGripSensors; // expects 5 sensors
        void function(CollisionSensor* sensor) findFloorPosition;
        void function(CollisionSensor* sensor) findLWallPosition;
        void function(CollisionSensor* sensor) findRoofPosition;
        void function(CollisionSensor* sensor) findRWallPosition;
        void function(CollisionSensor* sensor) floorCollision;
        void function(CollisionSensor* sensor) lWallCollision;
        void function(CollisionSensor* sensor) roofCollision;
        void function(CollisionSensor* sensor) rWallCollision;
    }

    int32 function(uint16 tile, uint8 cPlane, uint8 cMode) getTileAngle;
    void function(uint16 tile, uint8 cPlane, uint8 cMode, uint8 angle) setTileAngle;
    uint8 function(uint16 tile, uint8 cPlane) getTileFlags;
    void function(uint16 tile, uint8 cPlane, uint8 flag) setTileFlags;

    version (RETRO_REV0U)
    {
        void function(uint16 dst, uint16 src, uint8 cPlane, uint8 cMode) copyCollisionMask;
        void function(CollisionMask** masks, TileInfo** tileInfo) getCollisionInfo;
    }

    // Audio
    uint16 function(const char* path) getSfx;
    int32 function(uint16 sfx, int32 loopPoint, int32 priority) playSfx;
    void function(uint16 sfx) stopSfx;
    int32 function(const char* filename, uint32 channel, uint32 startPos, uint32 loopPoint, bool32 loadASync) playStream;
    void function(uint8 channel, float volume, float pan, float speed) setChannelAttributes;
    void function(uint32 channel) stopChannel;
    void function(uint32 channel) pauseChannel;
    void function(uint32 channel) resumeChannel;
    bool32 function(uint16 sfx) isSfxPlaying;
    bool32 function(uint32 channel) channelActive;
    uint32 function(uint32 channel) getChannelPos;

    // Videos & "HD Images"
    bool32 function(const char* filename, double startDelay, bool32 function() skipCallback) loadVideo;
    bool32 function(const char* filename, double displayLength, double fadeSpeed, bool32 function() skipCallback) loadImage;

    // Input
    version (RETRO_REV02)
    {
        uint32 function(uint8 inputSlot) getInputDeviceID;
        uint32 function(bool32 confirmOnly, bool32 unassignedOnly, uint32 maxInactiveTimer) getFilteredInputDeviceID;
        int32 function(uint32 deviceID) getInputDeviceType;
        bool32 function(uint32 deviceID) isInputDeviceAssigned;
        int32 function(uint32 deviceID) getInputDeviceUnknown;
        int32 function(uint32 deviceID, int32 unknown1, int32 unknown2) inputDeviceUnknown1;
        int32 function(uint32 deviceID, int32 unknown1, int32 unknown2) inputDeviceUnknown2;
        int32 function(uint8 inputSlot) getInputSlotUnknown;
        int32 function(uint8 inputSlot, int32 unknown1, int32 unknown2) inputSlotUnknown1;
        int32 function(uint8 inputSlot, int32 unknown1, int32 unknown2) inputSlotUnknown2;
        void function(uint8 inputSlot, uint32 deviceID) assignInputSlotToDevice;
        bool32 function(uint8 inputSlot) isInputSlotAssigned;
        void function() resetInputSlotAssignments;
    }
    else
    {
        void function(int32 inputSlot, int32 type, int32* value) getUnknownInputValue;
    }

    // User File Management
    bool32 function(const char* fileName, void* buffer, uint32 size) loadUserFile; // load user file from exe dir
    bool32 function(const char* fileName, void* buffer, uint32 size) saveUserFile; // save user file to exe dir

    // Printing (Rev02)
    version (RETRO_REV02)
    {
        void function(int32 mode, const char* message, ...) printLog;
        void function(int32 mode, const char* message) printText;
        void function(int32 mode, String* message) printString;
        void function(int32 mode, const char* message, uint32 i) printUInt32;
        void function(int32 mode, const char* message, int32 i) printInt32;
        void function(int32 mode, const char* message, float f) printFloat;
        void function(int32 mode, const char* message, Vector2 vec) printVector2;
        void function(int32 mode, const char* message, Hitbox hitbox) printHitbox;
    }

    // Editor
    void function(int32 classID, const char* message) setActiveVariable;
    void function(const char* name) addVarEnumValue;

    // Printing (Rev01)
    version (RETRO_REV02)
    {
    }
    else
        void function(void* message, uint8 type) printMessage;

    // Debugging
    version (RETRO_REV02)
    {
        void function() clearViewableVariables;
        void function(const char* name, void* value, int32 type, int32 min, int32 max) addViewableVariable;
    }

    // Origins Extras
    version (RETRO_REV0U)
    {
        void function(int32 callbackID, int32 param1, int32 param2, int32 param3) notifyCallback;
        void function() setGameFinished;
        void function() stopAllSfx;
    }
}

// =========================
// HELPERS
// =========================

alias StateMachine = extern (C) void delegate();

void stateMachineRun(StateMachine state)
{
    version (RETRO_USE_MOD_LOADER)
    {
        bool32 skipState = mod.handleRunStateHighPriority(state.funcptr);

        if (!skipState && state)
            state();

        mod.handleRunStateLowPriority(state.funcptr, skipState);
    }
    else
    {
        if (state)
            state();
    }
}

// RSDK_EDITABLE_VAR!(TestObject, "variableName")(VariableTypes.varInt32);
static void RSDK_EDITABLE_VAR(T, string name)(VariableTypes type)
{
    T.sVars.editableVar(type, name, __traits(getMember, T, name).offsetof);
}

// RSDK_EDITABLE_ARRAY!(TestObject, "arrayName", 4, int32)(VariableTypes.varInt32);
static void RSDK_EDITABLE_ARRAY(T, string name, int32 count, alias arrType)(VariableTypes type)
{
    enum size_t start = __traits(getMember, T, name).offsetof;
    static foreach (i; 0 .. count)
        T.sVars.editableVar(type, (name ~ i.to!string).toStringz, start + i * arrType.sizeof);
}

void RSDK_ACTIVE_VAR(void* o, string var)
{
    Object* object = cast(Object*) o;
    RSDK.setActiveVariable(object ? object.classID : -1, var.ptr);
}

void RSDK_ENUM_VAR(string name) => RSDK.addVarEnumValue(name.ptr);

void RSDK_INIT_STATIC_VARS(T)(void* sVars)
{
    memset(sVars, 0, T.Static.sizeof);
}

mixin template RSDK_DECLARE(T)
{
    static T.Static* sVars = null;

    static void _create(void* data) => (cast(T*) sceneInfo.entity).create(data);
    static void _draw() => (cast(T*) sceneInfo.entity).draw();
    static void _update() => (cast(T*) sceneInfo.entity).update();
    static void _lateUpdate() => (cast(T*) sceneInfo.entity).lateUpdate();
    static void _editorDraw() => (cast(T*) sceneInfo.entity).editorDraw();

    version (RETRO_REV0U) static void _staticLoad(void* data) => T.staticLoad(cast(T.Static*) data);
}

mixin template RSDK_REGISTER_OBJECT(T)
{
    static this()
    {
        version (RETRO_REV0U)
        {
            RSDK.registerObject(cast(void**)&T.sVars, T.stringof.ptr, T.sizeof, T.Static.sizeof,
                &T._update,
                &T._lateUpdate,
                &T.staticUpdate,
                &T._draw,
                &T._create,
                &T.stageLoad,
                &T.editorLoad,
                &T._editorDraw,
                &T.serialize,
                &T._staticLoad
            );
        }
        else
        {
            RSDK.registerObject(cast(void**)&T.sVars, T.stringof.ptr, T.sizeof, T.Static.sizeof,
                &T._update,
                &T._lateUpdate,
                &T.staticUpdate,
                &T._draw,
                &T._create,
                &T.stageLoad,
                &T.editorLoad,
                &T._editorDraw,
                &T.serialize
            );
        }
    }
}

version (RETRO_USE_MOD_LOADER)
{
    mixin template MOD_DECLARE(T)
    {
        static T.ModStatic* modSVars = null;
        mixin RSDK_DECLARE!T;
    }

    mixin template MOD_REGISTER_OBJECT(T)
    {
        static this()
        {
            version (RETRO_REV0U)
            {
                mod.registerObject(cast(void**)&T.sVars, cast(void**)&T.modSVars, T.stringof.ptr, T.sizeof, T
                        .Static.sizeof, T.ModStatic.sizeof,
                        &T._update,
                        &T._lateUpdate,
                        &T.staticUpdate,
                        &T._draw,
                        &T._create,
                        &T.stageLoad,
                        &T.editorLoad,
                        &T._editorDraw,
                        &T.serialize,
                        &T._staticLoad,
                        T.stringof.ptr
                );
            }
            else
            {
                mod.registerObject(cast(void**)&T.sVars, cast(void**)&T.modSVars, T.stringof.ptr, T.sizeof, T
                        .Static.sizeof, T.ModStatic.sizeof,
                        &T._update,
                        &T._lateUpdate,
                        &T.staticUpdate,
                        &T._draw,
                        &T._create,
                        &T.stageLoad,
                        &T.editorLoad,
                        &T._editorDraw,
                        &T.serialize,
                        T.stringof.ptr
                );
            }
        }
    }
}

mixin template RSDK_THIS(T)
{
    T* self = cast(T*) sceneInfo.entity;
}

mixin template RSDK_THIS_GEN()
{
    Entity* self = cast(Entity*) sceneInfo.entity;
}

T* RSDK_GET_ENTITY(T)(uint16 slot)
{
    return cast(T*) RSDK.getEntity(slot);
}

Entity* RSDK_GET_ENTITY_GEN()(uint16 slot)
{
    return cast(Entity*) RSDK.getEntity(slot);
}

T* CREATE_ENTITY(T)(int32 data, int32 x, int32 y)
{
    return cast(T*) RSDK.createEntity(T.sVars.classID, INT_TO_VOID(data), x, y);
}

T* CREATE_ENTITY(T)(void* data, int32 x, int32 y)
{
    return cast(T*) RSDK.createEntity(T.sVars.classID, data, x, y);
}

T*[] activeEntities(T)()
{
    T*[] list;
    T* entity = null;
    while (RSDK.getActiveEntities(T.sVars.classID, cast(void**)&entity) == true)
        list ~= entity;

    return list;
}

T*[] allEntities(T)()
{
    T*[] list;
    T* entity = null;
    while (RSDK.getAllEntities(T.sVars.classID, cast(void**)&entity) == true)
        list ~= entity;

    return list;
}

Entity*[] activeType(uint16 type)
{
    Entity*[] list;
    Entity* entity = null;
    while (RSDK.getActiveEntities(type, cast(void**)&entity) == true)
        list ~= entity;

    return list;
}

Entity*[] allType(uint16 type)
{
    Entity*[] list;
    Entity* entity = null;
    while (RSDK.getAllEntities(type, cast(void**)&entity) == true)
        list ~= entity;

    return list;
}

version (RETRO_USE_MOD_LOADER)
{
    version (RETRO_MOD_LOADER_VER_2)
    {
        Entity*[] activeGroup(uint16 group)
        {
            Entity*[] list;
            Entity* entity = null;
            while (mod.getGroupEntities(group, cast(void**)&entity) == true)
                list ~= entity;

            return list;
        }
    }

    String*[] config()
    {
        String*[] list;
        String* str = null;
        while (mod.foreachConfig(str) == true)
            list ~= str;

        return list;
    }

    String*[] configCategory()
    {
        String*[] list;
        String* str = null;
        while (mod.foreachConfigCategory(str) == true)
            list ~= str;

        return list;
    }

    version (RETRO_MOD_LOADER_VER_2)
    {
        String*[] setting(const char* id)
        {
            String*[] list;
            String* str = null;
            while (mod.foreachSetting(id, str) == true)
                list ~= str;

            return list;
        }

        String*[] settingCategory(const char* id)
        {
            String*[] list;
            String* str = null;
            while (mod.foreachSettingCategory(id, str) == true)
                list ~= str;

            return list;
        }
    }
}

// =========================
// Engine Variables
// =========================

void initEngineInfo(EngineInfo* info)
{
    RSDK = info.functionTable;
    version (RETRO_REV02)
        API = info.apiTable;

    gameInfo = info.gameInfo;
    version (RETRO_REV02)
        SKU = info.currentSKU;

    sceneInfo = info.sceneInfo;
    controllerInfo = info.controllerInfo;

    analogStickInfoL = info.stickInfoL;
    version (RETRO_REV02)
    {
        analogStickInfoR = info.stickInfoR;
        triggerInfoL = info.triggerInfoL;
        triggerInfoR = info.triggerInfoR;
    }

    touchInfo = info.touchInfo;
    version (RETRO_REV02)
        unknownInfo = info.unknownInfo;

    screenInfo = info.screenInfo;
    version (RETRO_USE_MOD_LOADER)
        mod = info.modTable;

    rt_init();
}

extern (C)
pragma(mangle, "RSDKRevision")
__gshared int32 rsdkRevision = RETRO_REVISION;

extern (C) __gshared ModVersionInfo modInfo = {
    RETRO_REVISION, 0, RETRO_MOD_LOADER_VER
};

public RSDKFunctionTable* RSDK;
version (RETRO_REV02) public APIFunctionTable* API;

version (RETRO_USE_MOD_LOADER) public ModFunctionTable* mod;

public RSDKSceneInfo* sceneInfo;
public RSDKGameInfo* gameInfo;
version (RETRO_REV02) public RSDKSKUInfo* SKU;

public RSDKControllerState* controllerInfo;
public RSDKAnalogState* analogStickInfoL;
version (RETRO_REV02)
{
    public RSDKAnalogState* analogStickInfoR;
    public RSDKTriggerState* triggerInfoL;
    public RSDKTriggerState* triggerInfoR;
}

public RSDKTouchInfo* touchInfo;
version (RETRO_REV02) public RSDKUnknownInfo* unknownInfo;

public RSDKScreenInfo* screenInfo;
