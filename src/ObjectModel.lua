--
-- Lua object model implementation
--

--- Create an instance of the given class
--
-- @param class the class being constructed
-- @param ...   constructor arguments
-- @return table the object
local function new(class, ...)
    local object = {}

    setmetatable(object, class)

    -- invoke constructor of the class
    if class.constructor then
        class.constructor(object, ...)
    elseif class._parent and class._parent.constructor then
        class._parent.constructor(object, ...)
    end

    return object
end

--- Invoke a parent method
--
-- @param object     the current object
-- @param methodName the parent method name
-- @param ...        arguments for the parent method
-- @return the return value(s) of the parent method
local function super(object, methodName, ...)
    return object._parent[methodName](object, ...)
end

--- See if an object is an instance of the given class
--
-- @param object         the object to verify
-- @param classToCompare the class to compare against
-- @return boolean
local function instanceof(object, classToCompare)
    local class = getmetatable(object)

    while class do
        if class == classToCompare then
            return true
        end

        class = class._parent
    end

    return false
end

--- Object destructor handler
--
-- This is the __gc implementation and should not be called manually.
--
-- @param object instance that is being destructed
local function objectGarbageCollect(object)
    if object.destructor then
        object:destructor()
    end
end

--- Class table factory
--
-- @param parent class definition to inherit from
-- @return class table
local function class(parent)
    local class = {}

    -- process the parent
    if parent then
        -- create a shallow copy of the parent class
        for i, v in pairs(parent) do
            class[i] = v
        end

        class._parent = parent
    end

    -- the class will be the metatable for all its instances
    -- and they will look up their methods in it
    class.__index = class

    if not parent then
        class.__gc = objectGarbageCollect
    end

    if parent then
        class.super = super
    end

    -- create a meta table for the class
    -- too hook the <class>(<args>) mechanism
    local meta = {
        __call = new
    }
    setmetatable(class, meta)

    return class
end

-- return the module table
return {
    class = class,
    instanceof = instanceof,
    new = new,
    super = super,
}
