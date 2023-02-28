/// TinyGLTF is a library for loading JSON serialized (embedded) GLTF models.
module tinygltf;

import std.stdio;
import std.string;
import std.file;
import std.json;
import core.stdcpp.array;
import std.conv;
import std.algorithm.iteration;
import std.base64;

/// OpenGL rendering mode POINTS.
enum TINYGLTF_MODE_POINTS = (0);
/// OpenGL rendering mode LINE.
enum TINYGLTF_MODE_LINE = (1);
/// OpenGL rendering mode LINE LOOP.
enum TINYGLTF_MODE_LINE_LOOP = (2);
/// OpenGL rendering mode LINE STRIP.
enum TINYGLTF_MODE_LINE_STRIP = (3);
/// OpenGL rendering mode TRIANGLES.
enum TINYGLTF_MODE_TRIANGLES = (4);
/// OpenGL rendering mode TRIANGLE STRIP.
enum TINYGLTF_MODE_TRIANGLE_STRIP = (5);
/// OpenGL rendering mode TRIANGLE FAN.
enum TINYGLTF_MODE_TRIANGLE_FAN = (6);

/// GLTF data component type BYTE.
enum TINYGLTF_COMPONENT_TYPE_BYTE = (5120);
/// GLTF data component type UNSIGNED BYTE.
enum TINYGLTF_COMPONENT_TYPE_UNSIGNED_BYTE = (5121);
/// GLTF data component type SHORT.
enum TINYGLTF_COMPONENT_TYPE_SHORT = (5122);
/// GLTF data component type UNSIGNED SHORT.
enum TINYGLTF_COMPONENT_TYPE_UNSIGNED_SHORT = (5123);
/// GLTF data component type INTEGER.
enum TINYGLTF_COMPONENT_TYPE_INT = (5124);
/// GLTF data component type UNSIGNED INTEGER.
enum TINYGLTF_COMPONENT_TYPE_UNSIGNED_INT = (5125);
/// GLTF data component type FLOAT.
enum TINYGLTF_COMPONENT_TYPE_FLOAT = (5126);
/**
    OpenGL double type. Note that some of glTF 2.0 validator does not;
    support double type even the schema seems allow any value of
    integer:
    https://github.com/KhronosGroup/glTF/blob/b9884a2fd45130b4d673dd6c8a706ee21ee5c5f7/specification/2.0/schema/accessor.schema.json#L22
*/
enum TINYGLTF_COMPONENT_TYPE_DOUBLE = (5130);

/// OpenGL texture filtering mode NEAREST.
enum TINYGLTF_TEXTURE_FILTER_NEAREST = (9728);
/// OpenGL texture filtering mode LINEAR.
enum TINYGLTF_TEXTURE_FILTER_LINEAR = (9729);
/// OpenGL texture filtering mode NEAREST MIPMAP NEAREST.
enum TINYGLTF_TEXTURE_FILTER_NEAREST_MIPMAP_NEAREST = (9984);
/// OpenGL texture filtering mode LINEAR MIPMAP NEAREST.
enum TINYGLTF_TEXTURE_FILTER_LINEAR_MIPMAP_NEAREST = (9985);
/// OpenGL texture filtering mode NEAREST MIPMAP LINEAR.
enum TINYGLTF_TEXTURE_FILTER_NEAREST_MIPMAP_LINEAR = (9986);
/// OpenGL texture filtering mode LINEAR MIPMAP LINEAR.
enum TINYGLTF_TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR = (9987);

/// OpenGL texture wrap mode REPEAT.
enum TINYGLTF_TEXTURE_WRAP_REPEAT = (10497);
/// OpenGL texture wrap mode CLAMP TO EDGE.
enum TINYGLTF_TEXTURE_WRAP_CLAMP_TO_EDGE = (33071);
/// OpenGL texture wrap mode MIRRORED REPEAT.
enum TINYGLTF_TEXTURE_WRAP_MIRRORED_REPEAT = (33648);

// Redeclarations of the above for technique.parameters.
/// GLTF data component type BYTE.
enum TINYGLTF_PARAMETER_TYPE_BYTE = (5120);
/// GLTF data component type UNSIGNED BYTE.
enum TINYGLTF_PARAMETER_TYPE_UNSIGNED_BYTE = (5121);
/// GLTF data component type SHORT.
enum TINYGLTF_PARAMETER_TYPE_SHORT = (5122);
/// GLTF data component type UNSIGNED SHORT.
enum TINYGLTF_PARAMETER_TYPE_UNSIGNED_SHORT = (5123);
/// GLTF data component type INTEGER.
enum TINYGLTF_PARAMETER_TYPE_INT = (5124);
/// GLTF data component type UNSIGNED INTEGER.
enum TINYGLTF_PARAMETER_TYPE_UNSIGNED_INT = (5125);
/// GLTF data component type FLOAT.
enum TINYGLTF_PARAMETER_TYPE_FLOAT = (5126);

/// GLTF float Vector 2 parameter type.
enum TINYGLTF_PARAMETER_TYPE_FLOAT_VEC2 = (35664);
/// GLTF float Vector 3 parameter type.
enum TINYGLTF_PARAMETER_TYPE_FLOAT_VEC3 = (35665);
/// GLTF float Vector 4 parameter type.
enum TINYGLTF_PARAMETER_TYPE_FLOAT_VEC4 = (35666);

/// GLTF integer Vector 2 parameter type.
enum TINYGLTF_PARAMETER_TYPE_INT_VEC2 = (35667);
/// GLTF integer Vector 3 parameter type.
enum TINYGLTF_PARAMETER_TYPE_INT_VEC3 = (35668);
/// GLTF integer Vector 4 parameter type.
enum TINYGLTF_PARAMETER_TYPE_INT_VEC4 = (35669);

/// GLTF Boolean parameter type.
enum TINYGLTF_PARAMETER_TYPE_BOOL = (35670);
/// GLTF Boolean Vector 2 parameter type.
enum TINYGLTF_PARAMETER_TYPE_BOOL_VEC2 = (35671);
/// GLTF Boolean Vector 3 parameter type.
enum TINYGLTF_PARAMETER_TYPE_BOOL_VEC3 = (35672);
/// GLTF Boolean Vector 4 parameter type.
enum TINYGLTF_PARAMETER_TYPE_BOOL_VEC4 = (35673);

/// GLTF float Matrix 2x2 parameter type.
enum TINYGLTF_PARAMETER_TYPE_FLOAT_MAT2 = (35674);
/// GLTF float Matrix 3x3 parameter type.
enum TINYGLTF_PARAMETER_TYPE_FLOAT_MAT3 = (35675);
/// GLTF float Matrix 4x4 parameter type.
enum TINYGLTF_PARAMETER_TYPE_FLOAT_MAT4 = (35676);

// End parameter types

/// GLTF Vector 2 data type.
enum TINYGLTF_TYPE_VEC2 = (2);
/// GLTF Vector 3 data type.
enum TINYGLTF_TYPE_VEC3 = (3);
/// GLTF Vector 4 data type.
enum TINYGLTF_TYPE_VEC4 = (4);

/// GLTF Matrix 2x2 data type.
enum TINYGLTF_TYPE_MAT2 = (32 + 2);
/// GLTF Matrix 3x3 data type.
enum TINYGLTF_TYPE_MAT3 = (32 + 3);
/// GLTF Matrix 4x4 data type.
enum TINYGLTF_TYPE_MAT4 = (32 + 4);

/// GLTF Scalar data type.
enum TINYGLTF_TYPE_SCALAR = (64 + 1);
/// GLTF Vector data type.
enum TINYGLTF_TYPE_VECTOR = (64 + 4);
/// GLTF Matrix data type.
enum TINYGLTF_TYPE_MATRIX = (64 + 16);

/// Enumerators for Values to define which type they are.
enum Type {
    NULL_TYPE,
    REAL_TYPE,
    INT_TYPE,
    BOOL_TYPE,
    STRING_TYPE,
    ARRAY_TYPE,
    BINARY_TYPE,
    OBJECT_TYPE
}

/// Null type enumerator. D type nothing/null.
alias NULL_TYPE   = Type.NULL_TYPE;
/// Double type enumerator. D type double.
alias REAL_TYPE   = Type.REAL_TYPE;
/// Integer type enumerator. D type int.
alias INT_TYPE    = Type.INT_TYPE;
/// Boolean type enumerator. D type bool.
alias BOOL_TYPE   = Type.BOOL_TYPE;
/// String type enumerator. D type string.
alias STRING_TYPE = Type.STRING_TYPE;
/// Array type enumerator. D type Value[].
alias ARRAY_TYPE  = Type.ARRAY_TYPE;
/// Binary type enumerator. D type ubyte[].
alias BINARY_TYPE = Type.BINARY_TYPE;
/// Object type enumerator. D type Value[[str][ing]].
alias OBJECT_TYPE = Type.OBJECT_TYPE;

/// Gets the component size in byte size. (Integer)
pragma(inline, true) private int getComponentSizeInBytes(uint componentType) {
    if (componentType == TINYGLTF_COMPONENT_TYPE_BYTE) {
        return 1;
    } else if (componentType == TINYGLTF_COMPONENT_TYPE_UNSIGNED_BYTE) {
        return 1;
    } else if (componentType == TINYGLTF_COMPONENT_TYPE_SHORT) {
        return 2;
    } else if (componentType == TINYGLTF_COMPONENT_TYPE_UNSIGNED_SHORT) {
        return 2;
    } else if (componentType == TINYGLTF_COMPONENT_TYPE_INT) {
        return 4;
    } else if (componentType == TINYGLTF_COMPONENT_TYPE_UNSIGNED_INT) {
        return 4;
    } else if (componentType == TINYGLTF_COMPONENT_TYPE_FLOAT) {
        return 4;
    } else if (componentType == TINYGLTF_COMPONENT_TYPE_DOUBLE) {
        return 8;
    } else {
        // Unknown component type
        return -1;
    }
}

/// Gets the number of components in a type. (For example vec3 has 3 components.)
pragma(inline, true) private int getNumComponentsInType(uint ty) {
    if (ty == TINYGLTF_TYPE_SCALAR) {
        return 1;
    } else if (ty == TINYGLTF_TYPE_VEC2) {
        return 2;
    } else if (ty == TINYGLTF_TYPE_VEC3) {
        return 3;
    } else if (ty == TINYGLTF_TYPE_VEC4) {
        return 4;
    } else if (ty == TINYGLTF_TYPE_MAT2) {
        return 4;
    } else if (ty == TINYGLTF_TYPE_MAT3) {
        return 9;
    } else if (ty == TINYGLTF_TYPE_MAT4) {
        return 16;
    } else {
        // Unknown component type
        return -1;
    }
}

//* Translation Note: This whole thing is duck typed
/// Simple class to represent a JSON object.
class Value {

public:
    // The value becomes whatever it is constructed with

    /// Construct as a NULL type
    this() {
        this.type_ = NULL_TYPE;
        this.int_value_ = 0;
        this.real_value_ = 0.0;
        this.boolean_value_ = false;
    }
    /// Construct as a BOOL (boolean) type.
    this(bool b) {
        this.boolean_value_ = b;
        this.type_ = BOOL_TYPE;
    }
    /// Construct as a INT (integer) type.
    this(int i) {
        this.int_value_ = i;
        this.real_value_ = i;
        this.type_ = INT_TYPE;
    }
    /// Construct as a REAL (double) type.
    this(double n) {
        this.real_value_ = n;
        this.type_ = REAL_TYPE;
    }
    /// Construct as a STRING (string) type.
    this(string s) {
        this.string_value_ = s;
        this.type_ = STRING_TYPE;
    }
    /// Construct as a BINARY (ubyte[]) type.
    this(ubyte[] v) {
        this.binary_value_ = v;
        this.type_ = BINARY_TYPE;
    }
    /// Construct as an ARRAY (Value[]) type.
    this(Value[] a) {
        this.array_value_ = a;
        this.type_ = ARRAY_TYPE;
    }
    /// Construct as an OBJECT (Value[string]) type.
    this(Value[string] o) {
        this.object_value_ = o;
        this.type_ = OBJECT_TYPE;
    }
    /// Get what Type this Value is.
    Type type(){
        return this.type_;
    }
    /// Gets if it's a bool.
    bool isBool() {
        return (this.type_ == BOOL_TYPE);
    }
    /// Gets if it's an integer.
    bool isInt() {
        return (this.type_ == INT_TYPE);
    }
    /// Gets if it's a number.
    bool isNumber() {
        return (this.type_ == REAL_TYPE) || (this.type_ == INT_TYPE);
    }
    /// Gets if it's a double.
    bool isReal() {
        return (this.type_ == REAL_TYPE);
    }
    /// Gets if it's a string.
    bool isString() {
        return (this.type_ == STRING_TYPE);
    }
    /// Gets if it's a binary.
    bool isBinary() {
        return (this.type_ == BINARY_TYPE);
    }
    /// Gets if it's an array.
    bool isArray() {
        return (this.type_ == ARRAY_TYPE);
    }
    /// Gets if it's an object.
    bool isObject() {
        return (this.type_ == OBJECT_TYPE);
    }

    /// Use this function if you want to have number value as double.
    double getNumberAsDouble() {
        if (this.type_ == INT_TYPE) {
            return cast(double)this.int_value_;
        } else {
            return this.real_value_;
        }
    }

    // TODO(syoyo): Support int value larger than 32 bits
    /// Use this function if you want to have number value as int.
    int getNumberAsInt() {
        if (this.type_ == REAL_TYPE) {
            return cast(int)this.real_value_;
        } else {
            return this.int_value_;
        }
    }

    /// Lookup value from an array.
    Value get(int idx) {
        static Value null_value;
        assert(this.isArray());
        assert(idx >= 0);
        return (idx < this.array_value_.length) ? array_value_[idx] : null_value;
    }

    /// Lookup value from a key-value pair.
    Value get(const string key) {
        static Value null_value;
        assert(this.isArray());
        assert(this.isObject());
        return object_value_.get(key, null_value);
    }

    /// Get the length of the array if this is an array.
    size_t arrayLen() {
        if (!this.isArray())
            return 0;
        return this.array_value_.length;
    }

    /// Valid only for object type.
    bool has(const string key) {
        if (!this.isObject())
            return false;
        return (key in this.object_value_) !is null;
    }

    /// List keys
    string[] keys() {
        /// Clone in memory
        string[] tempKeys;
        foreach (k,v; this.object_value_) {
            tempKeys ~= k;
        }
        return tempKeys;
    }

    size_t size() {
        return (this.isArray() ? this.arrayLen() : keys().length);
    }

    //* Translation note: This is the more D way to do this than the weird mixin in C
    mixin(TINYGLTF_VALUE_GET("bool", "boolean_value_"));
    mixin(TINYGLTF_VALUE_GET("double", "real_value_"));
    mixin(TINYGLTF_VALUE_GET("int", "int_value_"));
    mixin(TINYGLTF_VALUE_GET("string", "string_value_"));
    mixin(TINYGLTF_VALUE_GET("ubyteArray", "binary_value_", "ubyte[]"));
    mixin(TINYGLTF_VALUE_GET("Array", "array_value_", "Value[]"));
    mixin(TINYGLTF_VALUE_GET("Object", "object_value_", "Value[string]"));

protected:

    Type type_ = NULL_TYPE;

    int int_value_ = 0;
    double real_value_ = 0.0;
    string string_value_;
    ubyte[] binary_value_;
    Value[] array_value_;
    Value[string] object_value_;
    bool boolean_value_ = false;
    
}

// Generate mixins so I don't have to type a bunch of things.
private string TINYGLTF_VALUE_GET(string ctype, string var, string returnType = "") {
    if (returnType == "") {
        returnType = ctype;
    }
    const string fancyCType = capitalize(ctype);
    return "\n" ~
    returnType ~ " Get" ~ fancyCType ~ "() {\n" ~
         "return this." ~ var ~ ";\n" ~
    "}";
}

/**
    Holds animation channels. Animations channels are the root of the animation in the model.
    An animation channel combines an animation sampler with a target property being animated.
*/
class AnimationChannel {
    /// Required. Points to the index of the AnimationSampler.
    int sampler = -1;
    /**
        REQUIRED. The index of the node to target (alternative target should be provided by extension).
        Extensions are not supported in this translation so this is required.
        This is the joint if you're wondering.
    */
    int target_node = -1;

    /**
        REQUIRED with standard values of ["translation", "rotation", "scale", "weights"]
    */
    string target_path;

    this(int sampler = -1, int target_node = -1) {
        this.sampler = sampler;
        this.target_node = target_node;
    }
}

/**
    An animation sampler combines timestamps with a sequence of output values and defines an interpolation algorithm.
*/
class AnimationSampler {
    /// REQUIRED. The index of an accessor containing keyframe timestamps.
    int input = -1;
    /// REQUIRED. The index of an accessor, containing keyframe output values.
    int output = -1;
    /**
        Interpolation algorithm.
        "LINEAR", "STEP","CUBICSPLINE" or user defined string.
        Default: "LINEAR".
    */
    string interpolation = "LINEAR";
    
    this(int input = -1, int output = -1, string interpolation = "LINEAR"){
        this.input = input;
        this.output = output;
        this.interpolation = interpolation;
    }
}

/**
    A keyframe animation.
*/
class Animation {
    /// The animation name.
    string name;
    /**
        An array of animation channels. An animation channel combines an animation sampler with a target property being animated.
        Different channels of the same animation MUST NOT have the same targets.
    */
    AnimationChannel[] channels;
    /**
        An array of animation samplers.
        An animation sampler combines timestamps with a sequence of output values and defines an interpolation algorithm.
    */
    AnimationSampler[] samplers;
    
    this() {}
}

/**
    Joints and matrices defining a skin.
*/
class Skin {
    /// Name of the skin.
    string name;
    /// REQUIRED. The index of the accessor containing the floating-point 4x4 inverse-bind matrices.
    int inverseBindMatrices = -1;
    /// The index of the node used as a skeleton root.
    int skeleton = -1;
    /// Indices of skeleton nodes, used as joints in this skin.
    int[] joints;

    this() {}
}

/**
    Texture sampler properties for filtering and wrapping modes.
*/
class Sampler {
    /// The name of this sampler.
    string name;
    // glTF 2.0 spec does not define default value for `minFilter` and
    // `magFilter`. Set -1 in TinyGLTF(issue #186)

    /**
        OPTIONAL. -1 is no filter defined. ["NEAREST", "LINEAR",
        "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
        "NEAREST_MIPMAP_LINEAR", "LINEAR_MIPMAP_LINEAR"]
    */
    int minFilter = -1;

    /// OPTIONAL. -1 is no filter defined. ["NEAREST", "LINEAR"]
    int magFilter = -1;
    
    /// ["CLAMP_TO_EDGE", "MIRRORED_REPEAT", "REPEAT"], default "REPEAT"
    int wrapS = TINYGLTF_TEXTURE_WRAP_REPEAT;

    /// ["CLAMP_TO_EDGE", "MIRRORED_REPEAT", "REPEAT"], default "REPEAT"
    int wrapT = TINYGLTF_TEXTURE_WRAP_REPEAT;

    this(int minFilter = -1, int magFilter = -1, int wrapS = TINYGLTF_TEXTURE_WRAP_REPEAT, int wrapT = TINYGLTF_TEXTURE_WRAP_REPEAT) {
        this.minFilter = minFilter;
        this.magFilter = magFilter;
        this.wrapS = wrapS;
        this.wrapT = wrapT;
    }
}

/**
    A view into a buffer generally representing a subset of the buffer.
*/
class BufferView {
    /// The name of the bufferView.
    string name;
    /// REQUIRED. The index of the buffer.
    int buffer = -1;
    /**
        The offset into the buffer in bytes.
        Minimum 0, default 0.
    */
    size_t byteOffset = 0;
    /**
        The length of the bufferView in bytes.
        REQUIRED. Minimum 1. 0 is invalid.
    */
    size_t byteLength = 0;
    /**
        The stride, in bytes.
        Minimum 4. Maximum 252 (multiple of 4). Default 0 is understood to be tightly packed.
    */
    size_t byteStride = 0;
    /**
        The hint representing the intended GPU buffer type to use with this buffer view.
        ["ARRAY_BUFFER", "ELEMENT_ARRAY_BUFFER"] for vertex indices or attribs. Could be 0 for other data.
    */
    int target = 0;

    this(int buffer = -1, int byteOffset = 0, int byteLength = 0, int byteStride = 0, int target = 0) {
        this.buffer = buffer;
        this.byteOffset = byteOffset;
        this.byteLength = byteLength;
        this.byteStride = byteStride;
        this.target = target;
    }
}

/**
    A typed view into a buffer view that contains raw binary data.
*/
class Accessor {
    /**
        The index of the bufferView.
        REQUIRED here since sparse accessor are not supported.
    */
    int bufferView = -1;
    /// The name of the Accessor.
    string name;
    /** 
        The offset relative to the start of the buffer view in bytes.
    */
    size_t byteOffset = 0;
    /**
        Specifies whether integer data values are normalized before usage.
        OPTIONAL.
    */
    bool normalized = false;
    /**
        The datatype of the accessor’s components.
        REQUIRED. One of TINYGLTF_COMPONENT_TYPE_***
    */
    int componentType = -1;
    /**
        REQUIRED. The number of elements referenced by this accessor.
    */
    int count = 0;
    /**
        Specifies if the accessor’s elements are scalars, vectors, or matrices.
        REQUIRED. One of TINYGLTF_TYPE_***
    */
    int type = -1;
    /**
        Minimum value of each component in this accessor.
        OPTIONAL. Integer value is promoted to double.
    */
    double[] minValues;
    /**
        Maximum value of each component in this accessor.
        OPTIONAL. Integer value is promoted to double.
    */
    double[] maxValues;

    /**
        Utility function to compute byteStride for a given bufferView object.
        Returns -1 upon invalid glTF value or parameter configuration.
    */
    int byteStride(const BufferView bufferViewObject) const {
        if (bufferViewObject.byteStride == 0) {
            // Assume data is tightly packed.
            int componentSizeInBytes = getComponentSizeInBytes(componentType);

            if (componentSizeInBytes <= 0) {
                return -1;
            }
            
            int numComponents = getNumComponentsInType(type);
            
            if (numComponents <= 0) {
                return -1;
            }

            return componentSizeInBytes * numComponents;

        } else {
            // Check if byteStride is a multiple of the size of the accessor's component
            // type.
            int componentSizeInBytes = getComponentSizeInBytes(componentType);

            if (componentSizeInBytes <= 0) {
                return -1;
            }

            if ((bufferViewObject.byteStride % componentSizeInBytes) != 0) {
                return -1;
            }
            return cast(int)bufferViewObject.byteStride;
        }

        // unreachable return 0;
        // return 0;
    }

    this(int bufferView = -1, int byteOffset = 0, bool normalized = false, int componentType = -1, int count = 0, int type = -1) {
        this.bufferView = bufferView;
        this.byteOffset = byteOffset;
        this.normalized = normalized;
        this.componentType = componentType;
        this.count = count;
        this.type = type;
    }
}

/**
    Geometry to be rendered with the given material.
*/
class Primitive {
    /**
        REQUIRED. A plain JSON object, where each key corresponds to a mesh attribute semantic and each
        value is the index of the accessor containing attribute’s data.
    */
    int[string] attributes;

    /// The index of the material to apply to this primitive when rendering.
    int material = -1;
    /// The index of the accessor that contains the vertex indices.
    int indices = -1;
    /**
        The topology type of primitives to render.
        One of TINYGLTF_MODE_***
    */
    int mode = -1;

    /**
        An array of morph targets. Each target is an associative array with attributes in
        ["POSITION, "NORMAL", "TANGENT"] pointing to their corresponding accessors.
    */
    int[string][] targets;
                            

    this(int material = -1, int indices = -1, int mode = -1) {
        this.material = material;
        this.indices = indices;
        this.mode = mode;
    }
}

/**
    A set of primitives to be rendered.
    Its global transform is defined by a node that references it.
*/
class Mesh {
    /// The name of the mesh.
    string name;
    /// An array of primitives, each defining geometry to be rendered.
    Primitive[] primitives;
    /**
        Array of weights to be applied to the morph targets.
        The number of array elements MUST match the number of morph targets.
    */
    double[] weights;

    this() {}
}
/**
    A node in the node hierarchy.
    When the node contains skin, all mesh.primitives MUST contain JOINTS_0 and WEIGHTS_0 attributes.
    A node MAY have either a matrix or any combination of translation/rotation/scale (TRS) properties.
    TRS properties are converted to matrices and postmultiplied in the T * R * S order to compose the transformation matrix.
    First the scale is applied to the vertices, then the rotation, and then the translation.
    If none are provided, the transform is the identity.
    When a node is targeted for animation (referenced by an animation.channel.target), matrix MUST NOT be present.
*/
class Node {

public:
    /// The index of the camera referenced by this node.
    int camera = -1;
    /// The name of this node.
    string name;
    /// The index of the skin referenced by this node.
    int skin = -1;
    /// The index of the mesh in this node.
    int mesh = -1;
    /// The indices of this node’s children.
    int[] children;
    /**
        The node’s unit quaternion rotation in the order (x, y, z, w), where w is the scalar.
        Length must be 0 or 4.
    */
    double[] rotation;
    /**
        The node’s non-uniform scale, given as the scaling factors along the x, y, and z axes.
        Length must be 0 or 3.
    */
    double[] scale;
    /**
        The node’s translation along the x, y, and z axes.
        Length must be 0 or 3.
    */
    double[] translation;
    /**
        A floating-point 4x4 transformation matrix stored in column-major order.
        Length must be 0 or 16.
    */
    double[] matrix;
    /**
        The weights of the instantiated morph target.
        The number of array elements MUST match the number of morph targets of the referenced mesh.
        When defined, mesh MUST also be defined.
    */
    double[] weights;

    this(int camera = -1, int skin = -1, int mesh = -1) {
        this.camera = camera;
        this.skin = skin;
        this.mesh = mesh;
    }
}

/**
    A buffer points to binary geometry, animation, or skins.
*/
class Buffer {
    /// The name of the buffer
    string name;
    /**
       The raw data in ubytes.
       This is decoded from the URI.
    */
    ubyte[] data;
    /// The length of the buffer in bytes.
    int byteLength = -1;

    this() {}
}

/**
    Metadata about the glTF asset.
*/
class Asset {
    /// REQUIRED. The glTF version in the form of <major>.<minor> that this asset targets.
    string version_ = "2.0";
    /// Tool that generated this glTF model. Useful for debugging.
    string generator;
    /**
        The minimum glTF version in the form of <major>.<minor> that this asset targets.
        This property MUST NOT be greater than the asset version.
    */
    string minVersion;
    /// A copyright message suitable for display to credit the content creator.
    string copyright;

    this() {}
}

/**
    Model is the container used to store all the decoded JSON data.
    It loads all the data automatically through it's methods.
*/
class Model {
    /// Accessors in the model.
    Accessor[] accessors;
    /// Animations in the model.
    Animation[] animations;
    /// Buffers in the model.
    Buffer[] buffers;
    /// BufferViews in the model.
    BufferView[] bufferViews;
    /// Meshes in the model.
    Mesh[] meshes;
    /// Nodes in the model.
    Node[] nodes;
    /// Skins in the model.
    Skin[] skins;
    /// Samplers in the model.
    Sampler[] samplers;

    /// The asset info of the model.
    Asset asset;

    // Takes in a raw string so you can do whatever they want with your file location.
    this(string fileLocation, bool debugInfo = true) {
        //* Model can work with it's internal fields so we don't have to chain them
        this.debugInfo = debugInfo;
        this.fileLocation = fileLocation;
        this.asset = new Asset();
        if (debugInfo) {
            writeln("\nMODEL " ~ fileLocation ~ " INITIALIZED\n");
        }
    }
    
    /**
        Automatically loads, decodes, and stores all the implemented JSON data into the model's arrays.
        Returns loading success.
    */
    bool loadFile(){
        if (!this.fileExists()) {
            writeDebug(
                "I'm very sorry, but the file:\n" ~
                this.fileLocation ~ "\n" ~
                "does not exist on the drive. Perhaps you are polling the wrong directory?\n"
            );
            return false;
        }
        
        // Turn the raw disk data into a usable JSON object with the std.json library.
        // Can throw an exception, which we catch and return as false.
        // Going to be extra nice and throw in a link to the khronos verifier straight in the terminal.
        if (!this.loadJson()) {
            writeDebug(
                "I'm very sorry, but the file:\n"~
                this.fileLocation ~ "\n" ~
                "appears to be corrupted, please double-check this model with the Khronos GLTF validator.\n" ~
                "Link: https://github.khronos.org/glTF-Validator/\n"
            );
            return false;
        }

        // Now it has to iterate the JSON object and store the data.
        this.collectJSONInfo();

        return true;
    }

private:

    string fileLocation;
    bool debugInfo = false;
    JSONValue jsonData;

    void collectJSONInfo() {
        // This might look a bit complicated, but we're just iterating the tree of data
        // We start off with a set of keys and values, accessor, bufferViews, etc
        // Then we need to go down them because they're packed pretty tight
        foreach (key,value; this.jsonData.objectNoRef) {

            //! Don't remove this until everything is accounted for
            writeln(key);

            //TODO: surround this with try catch, return false on failure along with debug info on which one failed

            // Key's could be corrupted, so we need a default catch all
            //* key is a string, value is a JSONValue object
            switch (key) {
                case "accessors": {
                    this.grabAccessorsData(value);
                    break;
                }
                case "bufferViews": {
                    this.grabBufferViewsData(value);
                    break;
                }
                case "buffers": {
                    this.grabBuffersData(value);
                    break;
                }
                case "meshes": {
                    this.grabMeshesData(value);
                    break;
                }
                case "nodes": {
                    this.grabNodesData(value);
                    break;
                }
                case "asset": {
                    this.grabAssetData(value);
                    break;
                }
                case "skins": {
                    this.grabSkinsData(value);
                    break;
                }
                default: // Unknown
            }
        }
    }

    void grabSkinsData(JSONValue jsonObject) {
        
        writeln(jsonObject);

    }

    

    void grabNodesData(JSONValue jsonObject) {

        //* This is explicit to help code-d and to be more readable for control flow
        //* Key is integer(size_t), value is JSON value
        foreach (size_t key, JSONValue value; jsonObject.array) {

            // We are assembling this node
            Node nodeObject = new Node();

            // Now parse the string

            //* Key is string, value is JSON value
            foreach (string arrayKey, JSONValue arrayValue; value.object) {
                switch (arrayKey) {
                    // Integer
                    case "camera": {
                        assert(arrayValue.type == JSONType.integer);
                        nodeObject.camera = cast(int)arrayValue.integer;
                        break;
                    }
                    // Integer[]
                    case "children": {
                        assert(arrayValue.type == JSONType.array);
                        foreach(size_t k, JSONValue v; arrayValue.array){
                            assert(v.type == JSONType.integer);
                            nodeObject.children ~= cast(int)v.integer;
                        }
                        break;
                    }
                    // Integer
                    case "skin": {
                        assert(arrayValue.type == JSONType.integer);
                        nodeObject.skin = cast(int)arrayValue.integer;
                        break;
                    }
                    // Double[16] (matrix4)
                    case "matrix": {
                        assert(arrayValue.type == JSONType.array);
                        foreach(size_t k, JSONValue v; arrayValue.array){
                            nodeObject.matrix ~= grabDouble(v);
                        }
                        break;
                    }
                    // Integer
                    case "mesh": {
                        assert(arrayValue.type == JSONType.integer);
                        nodeObject.mesh = cast(int)arrayValue.integer;
                        break;
                    }
                    // Double[4] (quaternion)
                    case "rotation": {
                        assert(arrayValue.type == JSONType.array);
                        foreach(size_t k, JSONValue v; arrayValue.array){
                            nodeObject.rotation ~= this.grabDouble(v);
                        }
                        break;
                    }
                    // Double[3] (vector3)
                    case "scale": {
                        assert(arrayValue.type == JSONType.array);
                        foreach(size_t k, JSONValue v; arrayValue.array){
                            nodeObject.scale ~= this.grabDouble(v);
                        }
                        break;
                    }
                    // Double[3] (vector3)
                    case "translation": {
                        assert(arrayValue.type == JSONType.array);
                        foreach(size_t k, JSONValue v; arrayValue.array){
                            nodeObject.translation ~= this.grabDouble(v);
                        }
                        break;
                    }
                    // Double[]
                    case "weights": {
                        assert(arrayValue.type == JSONType.array);
                        foreach(size_t k, JSONValue v; arrayValue.array){
                            nodeObject.weights ~= this.grabDouble(v);
                        }
                        break;
                    }
                    // String
                    case "name": {
                        assert(arrayValue.type == JSONType.string);
                        nodeObject.name = arrayValue.str;
                        break;
                    }
                    default: // Unknown

                }
            }

            this.nodes ~= nodeObject;
        }
    }

    void grabMeshesData(JSONValue jsonObject) {

        //* This is explicit to help code-d and to be more readable for control flow
        //* Key is integer(size_t), value is JSON value
        foreach (size_t key, JSONValue value; jsonObject.array) {

            //* Implementation note: Meshes are a special type.
            //* They contain a vector of Primitive objects.
 
            // We are assembling this mesh
            Mesh meshObject = new Mesh();

            // Now parse the string

            //* Key is string, value is JSON value
            foreach (string arrayKey, JSONValue arrayValue; value.object) {
                switch (arrayKey) {
                    // Json Object
                    case "primitives": {
                        assert(arrayValue.type == JSONType.array);
                        // Goes to a primitive assembler because it's complex.
                        // This returns an array of primitives, automatically assigns it.
                        meshObject.primitives = this.grabPrimitiveData(arrayValue);
                        break;
                    }
                    // Double[]
                    case "weights": {
                        assert(arrayValue.type == JSONType.array);
                        foreach(size_t k, JSONValue v; arrayValue.array){
                            meshObject.weights ~= this.grabDouble(v);
                        }
                        break;
                    }
                    // String
                    case "name": {
                        assert(arrayValue.type == JSONType.string);
                        meshObject.name = arrayValue.str;
                        break;
                    }
                    default:
                }
            }
            this.meshes ~= meshObject;
        }
    }
    
    Primitive[] grabPrimitiveData(JSONValue jsonObject) {

        // This is assembling an array of primitives
        Primitive[] returningPrimitives;

        //* This is explicit to help code-d and to be more readable for control flow
        //* Key is integer(size_t), value is JSON value
        foreach (size_t key, JSONValue value; jsonObject.array) {

            // We are assembling this primitive
            Primitive primitiveObject = new Primitive();

            // Now parse the string

            //* Key is string, value is JSON value
            foreach (string arrayKey, JSONValue arrayValue; value.object) {
                switch (arrayKey) {
                    // Integer[String] Associative Array
                    case "attributes": {
                        assert(arrayValue.type == JSONType.object);
                        foreach (string attributeKey, JSONValue attributeValue; arrayValue) {
                            assert(attributeValue.type == JSONType.integer);
                            primitiveObject.attributes[attributeKey] = cast(int)attributeValue.integer;
                        }
                        break;
                    }
                    // Integer
                    case "indices": {
                        assert(arrayValue.type == JSONType.integer);
                        primitiveObject.indices = cast(int)arrayValue.integer;
                        break;
                    }
                    // Integer
                    case "material": {
                        assert(arrayValue.type == JSONType.integer);
                        primitiveObject.material = cast(int)arrayValue.integer;
                        break;
                    }
                    // Integer
                    case "mode": {
                        assert(arrayValue.type == JSONType.integer);
                        primitiveObject.mode = cast(int)arrayValue.integer;
                        break;
                    }
                    // Integer[]
                    case "targets": {
                        // TODO
                        break;
                    }
                    default: // Unknown
                }
            }
            returningPrimitives ~= primitiveObject;
        }
        return returningPrimitives;
    }

    void grabBuffersData(JSONValue jsonObject) {

        //* This is explicit to help code-d and to be more readable for control flow
        //* Key is integer(size_t), value is JSON value
        foreach (size_t key, JSONValue value; jsonObject.array) {
            
            // We are assembling this buffer
            Buffer bufferObject = new Buffer();

            // Now parse the string

            //* Key is string, value is JSON value
            foreach (string arrayKey, JSONValue arrayValue; value.object) {
                switch (arrayKey) {
                    // String - REQUIRED to be a string of data
                    case "uri": {
                        assert(arrayValue.type == JSONType.string);
                        // Needs to strip out this header info
                        string data = arrayValue.str.replace("data:application/octet-stream;base64,", "");
                        // If it's a bin, fail state
                        assert(data.length != arrayValue.str.length);
                        // Now decode it
                        bufferObject.data = Base64.decode(data);
                        break;
                    }
                    // Integer
                    case "byteLength": {
                        assert(arrayValue.type == JSONType.integer);
                        bufferObject.byteLength = cast(int)arrayValue.integer;
                        break;
                    }
                    // String
                    case "name": {
                        assert(arrayValue.type == JSONType.string);
                        bufferObject.name = arrayValue.str;
                        break;
                    }
                    default: // Unknown
                }
            }
            this.buffers ~= bufferObject;
        }
    }

    void grabBufferViewsData(JSONValue jsonObject) {

        //* This is explicit to help code-d and to be more readable for control flow
        //* Key is integer(size_t), value is JSON value
        foreach (size_t key, JSONValue value; jsonObject.array) {

            // We are assembling this bufferView
            BufferView bufferViewObject = new BufferView();

            // Now parse the string

            //* Key is string, value is JSON value
            foreach (string arrayKey, JSONValue arrayValue; value.object) {
                switch (arrayKey) {
                    // Integer
                    case "byteOffset": {
                        assert(arrayValue.type == JSONType.integer);
                        bufferViewObject.byteOffset = cast(int)arrayValue.integer;
                        break;
                    }
                    // Integer, alias to TINYGLTF_TARGET_
                    case "target": {
                        assert(arrayValue.type == JSONType.integer);
                        bufferViewObject.target = cast(int)arrayValue.integer;
                        break;
                    }
                    // Integer
                    case "buffer": {
                        assert(arrayValue.type == JSONType.integer);
                        bufferViewObject.buffer = cast(int)arrayValue.integer;
                        break;
                    }
                    // Integer
                    case "byteLength": {
                        assert(arrayValue.type == JSONType.integer);
                        bufferViewObject.byteLength = cast(int)arrayValue.integer;
                        break;
                    }
                    // String
                    case "name": {
                        assert(arrayValue.type == JSONType.string);
                        bufferViewObject.name = arrayValue.str;
                        break;
                    }
                    default: // Unknown
                }
            }
            this.bufferViews ~= bufferViewObject;
        }
    }
    
    void grabAccessorsData(JSONValue jsonObject) {
        
        //* This is explicit to help code-d and to be more readable for control flow
        //* Key is integer(size_t), value is JSON value
        foreach (size_t key, JSONValue value; jsonObject.array) {

            // We are assembling this accessor
            Accessor accessorObject = new Accessor();
            
            // Now parse the string

            //* Key is string, value is JSON value
            foreach (string arrayKey, JSONValue arrayValue; value.object) {
                
                switch (arrayKey) {
                    // Integer
                    case "bufferView": {
                        assert(arrayValue.type() == JSONType.integer);
                        accessorObject.bufferView = cast(int)arrayValue.integer;
                        break;
                    }
                    // Integer
                    case "byteOffset": {
                        assert(arrayValue.type() == JSONType.integer);
                        accessorObject.byteOffset = cast(int)arrayValue.integer;
                        break;

                    }
                    // Integer, alias to TINYGLTF_COMPONENT_TYPE_
                    case "componentType": {
                        assert(arrayValue.type() == JSONType.integer);
                        accessorObject.componentType = cast(int)arrayValue.integer;
                        break;
                    }
                    // Integer
                    case "count": {
                        assert(arrayValue.type() == JSONType.integer);
                        accessorObject.count = cast(int)arrayValue.integer;
                        break;
                    }
                    // Double[]
                    case "min": {
                        assert(arrayValue.type() == JSONType.array);
                        foreach (k,JSONValue v; arrayValue.array) {
                            accessorObject.minValues ~= this.grabDouble(v);
                        }
                        break;
                    }
                    // Double[]
                    case "max": {
                        assert(arrayValue.type() == JSONType.array);
                        foreach (k,JSONValue v; arrayValue.array) {
                            accessorObject.maxValues ~= this.grabDouble(v);
                        }
                        break;
                    }
                    // String
                    case "type": {
                        assert(arrayValue.type == JSONType.string);
                        // Assign the integral value of the enum
                        switch (arrayValue.str) {
                            case "VEC2": {
                                accessorObject.type = TINYGLTF_TYPE_VEC2;
                                break;
                            }
                            case "VEC3": {
                                accessorObject.type = TINYGLTF_TYPE_VEC3;
                                break;
                            }
                            case "VEC4": {
                                accessorObject.type = TINYGLTF_TYPE_VEC4;
                                break;
                            }
                            case "MAT2": {
                                accessorObject.type = TINYGLTF_TYPE_MAT2;
                                break;
                            }
                            case "MAT3": {
                                accessorObject.type = TINYGLTF_TYPE_MAT3;
                                break;
                            }
                            case "MAT4": {
                                accessorObject.type = TINYGLTF_TYPE_MAT4;
                                break;
                            }
                            case "SCALAR": {
                                accessorObject.type = TINYGLTF_TYPE_SCALAR;
                                break;
                            }
                            case "VECTOR": {
                                accessorObject.type = TINYGLTF_TYPE_VECTOR;
                                break;
                            }
                            case "MATRIX": {
                                accessorObject.type = TINYGLTF_TYPE_MATRIX;
                                break;
                            }
                            default: // Unknown
                        }
                        break;
                    }
                    case "name": {
                        assert(arrayValue.type == JSONType.string);
                        accessorObject.name = arrayValue.str;
                        break;
                    }
                    default: // UNKNOWN
                }
            }

            // Finally dump the accessor in
            this.accessors ~= accessorObject;
        }
    }

    void grabAssetData(JSONValue jsonObject) {

        //* This is explicit to help code-d and to be more readable for control flow

        //* Implementation note: There is only one asset so this looks a bit different    

        // We are assembling this asset
        Asset assetObject = new Asset();

        // Now parse the string

        //* Key is string, value is JSON value
        foreach (string arrayKey, JSONValue arrayValue; jsonObject.object) {
            switch (arrayKey) {
                case "copyright": {
                    assert(arrayValue.type == JSONType.string);
                    assetObject.copyright = arrayValue.str;
                    break;
                }
                case "generator": {
                    assert(arrayValue.type == JSONType.string);
                    assetObject.generator = arrayValue.str;
                    break;
                }
                case "version": {
                    assert(arrayValue.type == JSONType.string);
                    assetObject.version_ = arrayValue.str;
                    break;
                }
                case "minVersion": {
                    assert(arrayValue.type == JSONType.string);
                    assetObject.minVersion = arrayValue.str;
                    break;
                }
                default: // Unknown
            }
        }
        this.asset = assetObject;    
    }

    //* This is just a passthrough to keep it looking neat :)
    bool fileExists() {
        return exists(this.fileLocation);
    }

    // Returns parsing the JSON success;
    bool loadJson() {
        void[] rawData;
        string jsonString;
        
        try {
            rawData = read(this.fileLocation);
        } catch (Exception e) {
            return false;
        }

        try {
            jsonString = cast(string)rawData;
        } catch (Exception e) {
            return false;
        }

        try {
            this.jsonData = parseJSON(jsonString);
        } catch (Exception e) {
            return false;
        }

        return true;
    }

    // std.json thinks that 1.0 and 0.0 is integer so we have to work with it
    static double grabDouble(JSONValue input) {
        if (input.type == JSONType.float_) {
            return input.floating;
        } else if (input.type == JSONType.integer) {
            return cast(double)input.integer;
        }
        // Something went HORRIBLY wrong with the model.
        throw new Exception("THIS MODEL HAS A DIFFERENT TYPE THAT'S NOT INTEGRAL AS A DOUBLE!");
    }


    //*===================== DEBUGGING TOOLS ============================
    void writeDebugHeader() {
        writeln(
        "=========================\n" ~
        "DEBUG INFO\n" ~
        "=========================\n"
        );
    }
    void writeDebug(string input) {
        if (!this.debugInfo) {
            return;
        }
        writeDebugHeader();
        writeln(input);
        writeDebugFooter();
    }
    void writeDebugFooter() {
        writeln("=========================\n");
    }
}


unittest {
    // Test fail state and disabling debug info
    Model failedModel = new Model("This is a failure test.", false);
    assert(failedModel !is null);
    assert(failedModel.loadFile() == false);

    writeln("\nFAILURE PASS!\n");

    // Now test loading state again with a known model
    Model successModel = new Model("models/cube_embedded/cube.gltf");
    assert(successModel !is null);
    assert(successModel.loadFile() == true);
    
    writeln("\nSUCCESS PASS\n");

    // Now test a corrupted model.
    Model corruptedModel = new Model("models/missing_brace/json_missing_brace.gltf");
    assert(corruptedModel.loadFile() == false);

    writeln("\nCORRUPTED PASS\n");

    // Now bring Minetest Sam onboard.
    Model sam = new Model("models/sam/sam.gltf");
    assert(sam.loadFile() == true);

    writeln("\nSAM PASSED :)\n");
    
}
